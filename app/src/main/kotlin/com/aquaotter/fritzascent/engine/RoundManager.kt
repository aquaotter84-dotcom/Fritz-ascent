package com.aquaotter.fritzascent.engine

import com.aquaotter.fritzascent.model.FightState
import com.aquaotter.fritzascent.model.KnockdownPhase
import com.aquaotter.fritzascent.model.KnockdownState

object RoundManager {

    const val MAX_ROUNDS = 3
    const val KNOCKDOWNS_PER_ROUND_TKO = 3      // 3 knockdowns in one round = TKO
    const val STANDING_8_COUNT_TICK_MS = 1000L  // 1 tick per second
    const val STAGGER_DURATION_MS = 600L        // how long the stagger state lasts
    const val BETWEEN_ROUND_RECOVERY_PCT = 0.25f // Fritz regains 25% health at round end
    const val ROUND_DURATION_MS = 120_000L       // 2-minute rounds

    // ─── Incoming damage ───────────────────────────────────────────────

    /**
     * Apply heavy damage to Fritz. If health hits 0, drop him to the canvas.
     * Otherwise stagger him briefly.
     */
    fun onHeavyHit(state: FightState, damageTaken: Int): FightState {
        val newHealth = (state.fritzHealth - damageTaken).coerceAtLeast(0)
        return if (newHealth <= 0) {
            state.copy(
                fritzHealth = 0,
                knockdownState = KnockdownState(
                    phase = KnockdownPhase.KNOCKDOWN,
                    countTickMs = System.currentTimeMillis(),
                    knockdownsThisRound = state.knockdownState.knockdownsThisRound + 1,
                    totalKnockdowns = state.knockdownState.totalKnockdowns + 1
                )
            )
        } else {
            state.copy(
                fritzHealth = newHealth,
                knockdownState = state.knockdownState.copy(
                    phase = KnockdownPhase.STAGGER,
                    countTickMs = System.currentTimeMillis()
                )
            )
        }
    }

    // ─── Per-frame FSM tick ────────────────────────────────────────────

    /**
     * Advance the knockdown state machine. Call once per game-loop tick.
     */
    fun tickKnockdown(state: FightState, nowMs: Long): FightState {
        val kd = state.knockdownState
        return when (kd.phase) {

            KnockdownPhase.STAGGER -> {
                if (nowMs - kd.countTickMs >= STAGGER_DURATION_MS) {
                    // Stagger window expired - back to standing
                    state.copy(knockdownState = kd.copy(phase = KnockdownPhase.STANDING, countTickMs = 0L))
                } else state
            }

            KnockdownPhase.KNOCKDOWN -> {
                // Immediately begin the standing 8-count
                state.copy(
                    knockdownState = kd.copy(
                        phase = KnockdownPhase.STANDING_8,
                        countValue = 1,
                        countTickMs = nowMs
                    )
                )
            }

            KnockdownPhase.STANDING_8 -> {
                val elapsed = nowMs - kd.countTickMs
                if (elapsed >= STANDING_8_COUNT_TICK_MS) {
                    val nextCount = kd.countValue + 1
                    if (nextCount > 8) {
                        // Beat the count - start rising
                        state.copy(knockdownState = kd.copy(phase = KnockdownPhase.RISING, countValue = 0, countTickMs = nowMs))
                    } else {
                        // Advance the count
                        state.copy(knockdownState = kd.copy(countValue = nextCount, countTickMs = nowMs))
                    }
                } else state
            }

            KnockdownPhase.RISING -> {
                // Check TKO rule: too many knockdowns this round
                if (kd.knockdownsThisRound >= KNOCKDOWNS_PER_ROUND_TKO) {
                    state.copy(knockdownState = kd.copy(phase = KnockdownPhase.KO))
                } else {
                    // Fritz is back up
                    state.copy(knockdownState = kd.copy(phase = KnockdownPhase.STANDING))
                }
            }

            else -> state // STANDING or KO - no tick action
        }
    }

    // ─── Round transitions ─────────────────────────────────────────────

    /**
     * End the current round and start the next, or resolve on judge's decision.
     */
    fun advanceRound(state: FightState): FightState {
        val nextRound = state.currentRound + 1
        return if (nextRound > MAX_ROUNDS) {
            // All rounds done - judge decision by health totals
            state.copy(
                fightOver = true,
                playerWon = state.fritzHealth > state.opponentHealth
            )
        } else {
            val recovered = (state.fritzHealth + (state.fritzMaxHealth * BETWEEN_ROUND_RECOVERY_PCT).toInt())
                .coerceAtMost(state.fritzMaxHealth)
            state.copy(
                currentRound = nextRound,
                fritzHealth = recovered,
                roundTimeMs = ROUND_DURATION_MS,
                knockdownState = KnockdownState() // knockdown count resets per round
            )
        }
    }
}
