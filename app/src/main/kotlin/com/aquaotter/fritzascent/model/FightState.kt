package com.aquaotter.fritzascent.model

data class FightState(
    // ─── Health ───────────────────────────────────────────────────────
    val fritzHealth: Int = 100,
    val fritzMaxHealth: Int = 100,
    val opponentHealth: Int = 100,
    val opponentMaxHealth: Int = 100,

    // ─── Stars (Star Punch fuel) ──────────────────────────────────────
    val stars: Int = 0,
    val maxStars: Int = 3,

    // ─── Round ────────────────────────────────────────────────────────
    val currentRound: Int = 1,
    val roundTimeMs: Long = 120_000L,   // 2-minute round clock

    // ─── Combat phase ─────────────────────────────────────────────────
    val combatPhase: CombatPhase = CombatPhase.OBSERVE,

    // ─── Knockdown ────────────────────────────────────────────────────
    val knockdownState: KnockdownState = KnockdownState(),

    // ─── Fight result ─────────────────────────────────────────────────
    val fightOver: Boolean = false,
    val playerWon: Boolean = false
)

enum class CombatPhase {
    OBSERVE,    // Watching for the opponent's tell
    EVADE,      // Active dodge window
    PUNISH,     // Counter-attack window after clean dodge
    STUNNED,    // Fritz is staggered (light hit)
    IDLE        // Gap between exchanges
}
