package com.aquaotter.fritzascent.engine

import com.aquaotter.fritzascent.model.CombatPhase
import com.aquaotter.fritzascent.model.FightState

/**
 * Dusty – The Tutorial Brawler
 *
 * Slow, fully telegraphed attacks. Long tell window, no feints.
 * Purpose: teach the Observe → Evade → Punish rhythm without punishing mistakes too hard.
 *
 * Stats
 * ─────
 * Tell window : 1000 ms
 * Attack interval : 2800 ms
 * Hit damage : 10
 */
class DustyPattern : OpponentPattern {

    private var nextMoveMs: Long  = 0L
    private var tellStartMs: Long = 0L
    private var inTell: Boolean   = false

    private val TELL_WINDOW_MS    = 1_000L
    private val ATTACK_INTERVAL_MS = 2_800L

    override fun tick(state: FightState, nowMs: Long): FightState {
        // Pause while Fritz is knocked down or fight is over
        if (state.fightOver || state.knockdownState.isDown) {
            nextMoveMs = nowMs + ATTACK_INTERVAL_MS
            inTell     = false
            return state
        }

        // Idle → begin tell
        if (!inTell && nowMs >= nextMoveMs) {
            tellStartMs = nowMs
            inTell      = true
            return state.copy(combatPhase = CombatPhase.EVADE)
        }

        // Tell active → resolve
        if (inTell && nowMs >= tellStartMs + TELL_WINDOW_MS) {
            inTell     = false
            nextMoveMs = nowMs + ATTACK_INTERVAL_MS
            return if (state.combatPhase == CombatPhase.EVADE) {
                // Player didn't dodge – Dusty connects
                RoundManager.onHeavyHit(state, damageTaken = 10)
                    .copy(combatPhase = CombatPhase.OBSERVE)
            } else {
                state   // Player already dodged (PUNISH window is open)
            }
        }

        return state
    }
}
