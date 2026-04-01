package com.aquaotter.fritzascent.model

enum class AttackType {
    LEFT_JAB,
    RIGHT_JAB,
    HAYMAKER,
    BODY_BLOW
}

class DustyPattern {
    private var exchangeCount = 0
    private var currentAttackType = AttackType.LEFT_JAB
    private var knockdowns = 0

    fun reset() {
        exchangeCount = 0
        currentAttackType = AttackType.LEFT_JAB
        knockdowns = 0
    }

    fun currentAttack(): AttackType = currentAttackType

    fun resolvePlayerDefense(direction: String): String {
        return when (currentAttackType) {
            AttackType.LEFT_JAB -> {
                if (direction == "right") "safe_dodge" else "hit"
            }
            AttackType.RIGHT_JAB -> {
                if (direction == "left") "safe_dodge" else "hit"
            }
            AttackType.HAYMAKER -> {
                if (direction in listOf("left", "right", "duck")) "perfect_haymaker_dodge" else "hit"
            }
            AttackType.BODY_BLOW -> {
                if (direction == "block_low") "safe_dodge" else "hit"
            }
        }
    }

    fun prepareNextAttack() {
        exchangeCount++
        currentAttackType = when {
            knockdowns > 0 -> AttackType.HAYMAKER
            exchangeCount % 3 == 0 -> AttackType.HAYMAKER
            exchangeCount % 2 == 0 -> AttackType.RIGHT_JAB
            else -> AttackType.LEFT_JAB
        }
    }
}