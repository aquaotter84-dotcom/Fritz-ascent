package com.aquaotter.fritzascent.model

enum class KnockdownPhase {
    STANDING,       // Normal fight state
    STAGGER,        // Just hit hard - brief recovery window before resuming
    KNOCKDOWN,      // On the canvas - transition to count
    STANDING_8,     // Ref is counting (1-8); Fritz must survive the count
    RISING,         // Getting up - brief invincible window
    KO              // Fight over - Fritz did not beat the count
}

data class KnockdownState(
    val phase: KnockdownPhase = KnockdownPhase.STANDING,
    val countValue: Int = 0,            // 1–8 during STANDING_8
    val countTickMs: Long = 0L,         // timestamp of last count increment
    val knockdownsThisRound: Int = 0,   // resets each round
    val totalKnockdowns: Int = 0        // career total
) {
    val isDown: Boolean
        get() = phase == KnockdownPhase.KNOCKDOWN || phase == KnockdownPhase.STANDING_8

    val isFightOver: Boolean
        get() = phase == KnockdownPhase.KO
}
