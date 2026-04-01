package com.aquaotter.fritzascent.model

data class FightState(
    val playerHealth: Int = 100,
    val playerMaxHealth: Int = 100,
    val playerVulnerable: Boolean = false,
    val opponentName: String = "Opponent",
    val opponentHealth: Int = 100,
    val opponentMaxHealth: Int = 100,
    val opponentVulnerable: Boolean = false,
    val isOpponentKO: Boolean = false,
    val stars: Int = 0,
    val round: Int = 1,
    val secondsElapsed: Int = 0
)