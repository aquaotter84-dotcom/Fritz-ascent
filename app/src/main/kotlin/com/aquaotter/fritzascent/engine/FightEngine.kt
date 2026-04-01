package com.aquaotter.fritzascent.engine

import com.aquaotter.fritzascent.model.CombatPhase
import com.aquaotter.fritzascent.model.FightState
import com.aquaotter.fritzascent.model.KnockdownPhase

class FightEngine(private val opponentPattern: OpponentPattern) {

    private var state: FightState = FightState()
    private var lastTickMs: Long = System.currentTimeMillis()

    fun currentState(): FightState = state

    // ─── Player input ──────────────────────────────────────────────────

    fun onPlayerAction(action: PlayerAction): FightState {
        // Block input while down or fight is over
        if (state.knockdownState.isDown || state.fightOver) return state

        state = when (action) {
            PlayerAction.DODGE_LEFT,
            PlayerAction.DODGE_RIGHT -> handleDodge()
            PlayerAction.JAB         -> handleAttack(baseDamage = 8)
            PlayerAction.BODY_BLOW   -> handleAttack(baseDamage = 14)
            PlayerAction.STAR_PUNCH  -> handleStarPunch()
        }
        return state
    }

    // ─── Game loop tick ────────────────────────────────────────────────

    fun tick(nowMs: Long): FightState {
        if (state.fightOver) return state

        val delta = nowMs - lastTickMs
        lastTickMs = nowMs

        // 1. Advance knockdown FSM
        state = RoundManager.tickKnockdown(state, nowMs)

        // 2. KO check
        if (state.knockdownState.phase == KnockdownPhase.KO) {
            state = state.copy(fightOver = true, playerWon = false)
            return state
        }

        // 3. Round timer
        val newTime = (state.roundTimeMs - delta).coerceAtLeast(0L)
        state = state.copy(roundTimeMs = newTime)
        if (newTime <= 0L) {
            state = RoundManager.advanceRound(state)
            if (state.fightOver) return state
        }

        // 4. Opponent AI tick
        state = opponentPattern.tick(state, nowMs)

        return state
    }

    // ─── Private helpers ───────────────────────────────────────────────

    private fun handleDodge(): FightState {
        return if (state.combatPhase == CombatPhase.EVADE) {
            // Clean dodge: earn a star, open punish window
            val newStars = (state.stars + 1).coerceAtMost(state.maxStars)
            state.copy(stars = newStars, combatPhase = CombatPhase.PUNISH)
        } else {
            // Mistimed dodge: opponent connects
            RoundManager.onHeavyHit(state, damageTaken = 15)
        }
    }

    private fun handleAttack(baseDamage: Int): FightState {
        return if (state.combatPhase == CombatPhase.PUNISH) {
            val newOppHealth = (state.opponentHealth - baseDamage).coerceAtLeast(0)
            val next = state.copy(opponentHealth = newOppHealth, combatPhase = CombatPhase.OBSERVE)
            if (newOppHealth <= 0) next.copy(fightOver = true, playerWon = true) else next
        } else {
            // Whiff - no effect
            state
        }
    }

    private fun handleStarPunch(): FightState {
        if (state.stars < state.maxStars) return state // Not enough stars

        val newOppHealth = (state.opponentHealth - 35).coerceAtLeast(0)
        val next = state.copy(
            opponentHealth = newOppHealth,
            stars = 0,
            combatPhase = CombatPhase.OBSERVE
        )
        return if (newOppHealth <= 0) next.copy(fightOver = true, playerWon = true) else next
    }
}

// ─── Player actions ────────────────────────────────────────────────────────

enum class PlayerAction {
    DODGE_LEFT,
    DODGE_RIGHT,
    JAB,
    BODY_BLOW,
    STAR_PUNCH
}

// ─── Opponent AI contract ──────────────────────────────────────────────────

interface OpponentPattern {
    fun tick(state: FightState, nowMs: Long): FightState
}
