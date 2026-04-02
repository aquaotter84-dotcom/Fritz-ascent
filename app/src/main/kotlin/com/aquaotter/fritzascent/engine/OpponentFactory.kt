package com.aquaotter.fritzascent.engine

/**
 * All playable opponents in circuit order.
 */
enum class Opponent { DUSTY, WES, KAINE }

/**
 * OpponentFactory
 *
 * Single entry-point for creating opponent AI instances.
 * Wire this into FightEngine at fight-start:
 *
 *   val engine = FightEngine(OpponentFactory.create(Opponent.WES))
 */
object OpponentFactory {
    fun create(opponent: Opponent): OpponentPattern = when (opponent) {
        Opponent.DUSTY -> DustyPattern()
        Opponent.WES   -> WesPattern()
        Opponent.KAINE -> KainePattern()
    }
}
