package com.aquaotter.fritzascent.engine

import com.aquaotter.fritzascent.model.CombatPhase
import com.aquaotter.fritzascent.model.FightState
import kotlin.random.Random

/**
 * Wes – The Southpaw Slickster
 *
 * Intermediate opponent. Mixes hooks and uppercuts. Throws feints to bait
 * early dodges. Ramps speed and damage below 40 % health.
 *
 * Stats (normal / enraged)
 * ────────────────────────
 * Tell window     : 750 ms / 550 ms
 * Attack interval : 2400 ms / 1800 ms
 * Hook damage     : 13
 * Uppercut damage : 18
 * Feint chance    : 25 % / 15 %   (less feints when desperate – goes pure aggression)
 */
class WesPattern : OpponentPattern {

    private enum class WesMove { HOOK, UPPERCUT, FEINT }

    private var nextMoveMs: Long  = 0L
    private var tellStartMs: Long = 0L
    private var pendingMove: WesMove? = null
    private var inTell: Boolean   = false

    // ── Tuning ────────────────────────────────────────────────────────────
    private fun tellWindowMs(state: FightState): Long =
        if (state.opponentHealth < 40) 550L else 750L

    private fun attackIntervalMs(state: FightState): Long =
        if (state.opponentHealth < 40) 1_800L else 2_400L

    private fun feintChance(state: FightState): Float =
        if (state.opponentHealth < 40) 0.15f else 0.25f

    // ── Tick ──────────────────────────────────────────────────────────────
    override fun tick(state: FightState, nowMs: Long): FightState {
        if (state.fightOver || state.knockdownState.isDown) {
            resetOnKnockdown(state, nowMs)
            return state
        }

        // Idle → start tell (or feint)
        if (!inTell && nowMs >= nextMoveMs) {
            pendingMove = pickMove(state)

            if (pendingMove == WesMove.FEINT) {
                // Feint: flash EVADE for one frame then snap back
                nextMoveMs = nowMs + 600L
                return state   // no real EVADE window – bait only
            }

            tellStartMs = nowMs
            inTell      = true
            return state.copy(combatPhase = CombatPhase.EVADE)
        }

        // Tell active → resolve
        if (inTell && nowMs >= tellStartMs + tellWindowMs(state)) {
            inTell     = false
            nextMoveMs = nowMs + attackIntervalMs(state)

            return if (state.combatPhase == CombatPhase.EVADE) {
                // Player failed to dodge
                val dmg = if (pendingMove == WesMove.UPPERCUT) 18 else 13
                RoundManager.onHeavyHit(state, dmg)
                    .copy(combatPhase = CombatPhase.OBSERVE)
            } else {
                // Player already in PUNISH window – don't override it
                state
            }
        }

        return state
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private fun pickMove(state: FightState): WesMove = when {
        Random.nextFloat() < feintChance(state) -> WesMove.FEINT
        Random.nextBoolean()                    -> WesMove.HOOK
        else                                    -> WesMove.UPPERCUT
    }

    private fun resetOnKnockdown(state: FightState, nowMs: Long) {
        inTell      = false
        pendingMove = null
        nextMoveMs  = nowMs + attackIntervalMs(state)
    }
}
