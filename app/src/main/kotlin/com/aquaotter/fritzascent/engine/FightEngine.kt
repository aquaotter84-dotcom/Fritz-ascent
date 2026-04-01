package com.aquaotter.fritzascent.engine

import androidx.compose.runtime.mutableStateOf
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import com.aquaotter.fritzascent.model.FightState
import com.aquaotter.fritzascent.model.DustyPattern

class FightEngine {
    private val _fightState = MutableStateFlow(FightState())
    val fightState: StateFlow<FightState> = _fightState

    private val dustyAI = DustyPattern()

    fun initializeFight() {
        val newState = FightState(opponentName = "Dusty")
        dustyAI.reset()
        _fightState.value = newState
    }

    fun playerDodge(direction: String) {
        val current = _fightState.value
        if (current.isOpponentKO || current.playerHealth <= 0) return

        val currentAttack = dustyAI.currentAttack()
        val result = dustyAI.resolvePlayerDefense(direction)

        val newState = current.copy(
            playerVulnerable = false,
            opponentVulnerable = result == "safe_dodge" || result == "perfect_haymaker_dodge"
        )

        if (result == "perfect_haymaker_dodge") {
            newState.copy(stars = newState.stars + 1)
        } else if (result == "hit") {
            newState.copy(playerHealth = (newState.playerHealth - 8).coerceAtLeast(0))
        }

        _fightState.value = newState
        dustyAI.prepareNextAttack()
    }

    fun playerCounter(direction: String) {
        val current = _fightState.value
        if (!current.opponentVulnerable || current.isOpponentKO || current.playerHealth <= 0) return

        val newState = current.copy(
            opponentHealth = (current.opponentHealth - 12).coerceAtLeast(0),
            opponentVulnerable = false
        )

        if (newState.opponentHealth <= 0) {
            newState.copy(isOpponentKO = true)
        }

        _fightState.value = newState
        dustyAI.prepareNextAttack()
    }

    fun playerStarPunch() {
        val current = _fightState.value
        if (current.stars <= 0 || !current.opponentVulnerable || current.isOpponentKO) return

        val newState = current.copy(
            stars = current.stars - 1,
            opponentHealth = (current.opponentHealth - 25).coerceAtLeast(0),
            opponentVulnerable = false
        )

        if (newState.opponentHealth <= 0) {
            newState.copy(isOpponentKO = true)
        }

        _fightState.value = newState
        dustyAI.prepareNextAttack()
    }
}