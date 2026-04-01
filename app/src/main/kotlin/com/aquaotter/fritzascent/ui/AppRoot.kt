package com.aquaotter.fritzascent.ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import com.aquaotter.fritzascent.engine.FightEngine
import com.aquaotter.fritzascent.model.FighterStats

@Composable
fun AppRoot() {
    val screenState = remember { mutableStateOf<AppScreen>(AppScreen.Menu) }
    val fightEngine = remember { FightEngine() }

    when (val screen = screenState.value) {
        is AppScreen.Menu -> {
            MenuScreen(
                onStartFight = {
                    fightEngine.initializeFight()
                    screenState.value = AppScreen.Fight
                }
            )
        }
        is AppScreen.Fight -> {
            FightScreen(
                fightEngine = fightEngine,
                onFightEnd = { result ->
                    screenState.value = AppScreen.FightResult(result)
                }
            )
        }
        is AppScreen.FightResult -> {
            // TODO: Result screen
            MenuScreen(
                onStartFight = {
                    fightEngine.initializeFight()
                    screenState.value = AppScreen.Fight
                }
            )
        }
    }
}

sealed class AppScreen {
    object Menu : AppScreen()
    object Fight : AppScreen()
    data class FightResult(val result: String) : AppScreen()
}