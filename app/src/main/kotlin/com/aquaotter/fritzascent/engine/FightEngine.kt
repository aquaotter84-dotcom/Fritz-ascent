package com.aquaotter.fritzascent.engine

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import com.aquaotter.fritzascent.model.FightState
import com.aquaotter.fritzascent.model.DustyPattern

class FightEngine {
    private val _fightState = MutableStateFlow(FightState())
    val fightState: StateFlow<FightState> = _fightState

    private val dustyAI = DustyPattern()

    fun initializeFight() {
        _fightState.value = FightState(opponentName = "Dusty")
        dustyAI.reset()
    }

    fun playerDodge(direction: String) {
        val current = _fightState.value
        if (current.isOpponentKO || current.playerHealth <= 0) return

        val result = dustyAI.resolvePlayerDefense(direction)
        
        var nextHealth = current.playerHealth
        var nextStars = current.stars
        var isVulnerable = result == "safe_dodge" || result == "perfect_haymaker_dodge"

        if (result == "perfect_haymaker_dodge") {
            nextStars += 1
        } else if (result == "hit") {
            nextHealth = (current.playerHealth - 15).coerceAtLeast(0)
        }

        _fightState.value = current.copy(
            playerHealth = nextHealth,
            stars = nextStars,
            opponentVulnerable = isVulnerable,
            playerVulnerable = false
        )
        
        if (result == "hit" || !isVulnerable) {
            dustyAI.prepareNextAttack()
        }
    }

    fun playerCounter(direction: String) {
        val current = _fightState.value
        if (!current.opponentVulnerable || current.isOpponentKO || current.playerHealth <= 0) return

        // Hit detection & Combo logic
        val damage = 12
        val nextOpponentHealth = (current.opponentHealth - damage).coerceAtLeast(0)
        
        _fightState.value = current.copy(
            opponentHealth = nextOpponentHealth,
            opponentVulnerable = false,
            isOpponentKO = nextOpponentHealth <= 0
        )

        dustyAI.prepareNextAttack()
    }

    fun playerStarPunch() {
        val current = _fightState.value
        if (current.stars <= 0 || !current.opponentVulnerable || current.isOpponentKO) return

        val damage = 35
        val nextOpponentHealth = (current.opponentHealth - damage).coerceAtLeast(0)
        
        _fightState.value = current.copy(
            stars = current.stars - 1,
            opponentHealth = nextOpponentHealth,
            opponentVulnerable = false,
            isOpponentKO = nextOpponentHealth <= 0
        )

        dustyAI.prepareNextAttack()
    }
}