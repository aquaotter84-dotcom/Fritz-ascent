package com.aquaotter.fritzascent.engine

import com.aquaotter.fritzascent.model.CombatPhase
import com.aquaotter.fritzascent.model.FightState
import kotlin.random.Random

/**
 * Kaine – The Iron Circuit Closer
 *
 * Most dangerous opponent. Short tell windows, frequent feints,
 * and a 3-hit combo chain. Enters a berserker phase below 30 % health:
 * faster, harder, fewer readable feints.
 *
 * Stats (normal / berserker)
 * ──────────────────────────
 * Tell window      : 540 ms / 420 ms
 * Attack interval  : 2000 ms / 1400 ms
 * Hook damage      : 15
 * Uppercut damage  : 22
 * Combo lead + 2×  : 16 + 12 + 12
 * Feint chance     : 35 % / 20 %
 * Combo chance     : 20 % / 40 %
 */
class KainePattern : OpponentPattern {

    private enum class KaineMove { HOOK, UPPERCUT, COMBO, FEINT }

    private var nextMoveMs: Long      = 0L
    private var tellStartMs: Long     = 0L
    private var pendingMove: KaineMove? = null
    private var inTell: Boolean       = false
    private var comboHitsLeft: Int    = 0   // follow-up hits still queued

    // ── Tuning ────────────────────────────────────────────────────────────
    private fun tellWindowMs(state: FightState): Long =
        if (state.opponentHealth < 30) 420L else 540L

    private fun attackIntervalMs(state: FightState): Long =
        if (state.opponentHealth < 30) 1_400L else 2_000L

    private fun feintChance(state: FightState): Float =
        if (state.opponentHealth < 30) 0.20f else 0.35f

    private fun comboChance(state: FightState): Float =
        if (state.opponentHealth < 30) 0.40f else 0.20f

    // ── Tick ──────────────────────────────────────────────────────────────
    override fun tick(state: FightState, nowMs: Long): FightState {
        if (state.fightOver || state.knockdownState.isDown) {
            resetOnKnockdown(state, nowMs)
            return state
        }

        // ── Combo chain: rapid follow-up hits ───────────────────────────
        if (comboHitsLeft > 0 && nowMs >= nextMoveMs) {
            comboHitsLeft--
            nextMoveMs = nowMs + 600L
            return if (state.combatPhase != CombatPhase.PUNISH) {
                RoundManager.onHeavyHit(state, damageTaken = 12)
                    .copy(combatPhase = CombatPhase.OBSERVE)
            } else {
                state.copy(combatPhase = CombatPhase.OBSERVE)
            }
        }

        // ── Idle → start tell (or feint) ────────────────────────────────
        if (!inTell && comboHitsLeft == 0 && nowMs >= nextMoveMs) {
            pendingMove = pickMove(state)

            if (pendingMove == KaineMove.FEINT) {
                nextMoveMs = nowMs + 500L
                return state   // flash – no real EVADE window
            }

            tellStartMs = nowMs
            inTell      = true
            return state.copy(combatPhase = CombatPhase.EVADE)
        }

        // ── Tell active → resolve ────────────────────────────────────────
        if (inTell && nowMs >= tellStartMs + tellWindowMs(state)) {
            inTell     = false
            nextMoveMs = nowMs + attackIntervalMs(state)

            return if (state.combatPhase == CombatPhase.EVADE) {
                // Player failed to dodge
                when (pendingMove) {
                    KaineMove.COMBO -> {
                        // Lead hit + queue 2 follow-ups
                        comboHitsLeft = 2
                        nextMoveMs    = nowMs + 700L
                        RoundManager.onHeavyHit(state, damageTaken = 16)
                            .copy(combatPhase = CombatPhase.OBSERVE)
                    }
                    KaineMove.UPPERCUT ->
                        RoundManager.onHeavyHit(state, damageTaken = 22)
                            .copy(combatPhase = CombatPhase.OBSERVE)
                    else ->
                        RoundManager.onHeavyHit(state, damageTaken = 15)
                            .copy(combatPhase = CombatPhase.OBSERVE)
                }
            } else {
                // Player dodged successfully – PUNISH window already open
                state
            }
        }

        return state
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private fun pickMove(state: FightState): KaineMove {
        val roll = Random.nextFloat()
        return when {
            roll < feintChance(state)                        -> KaineMove.FEINT
            roll < feintChance(state) + comboChance(state)  -> KaineMove.COMBO
            Random.nextBoolean()                             -> KaineMove.HOOK
            else                                             -> KaineMove.UPPERCUT
        }
    }

    private fun resetOnKnockdown(state: FightState, nowMs: Long) {
        inTell        = false
        pendingMove   = null
        comboHitsLeft = 0
        nextMoveMs    = nowMs + attackIntervalMs(state)
    }
}
