package com.aquaotter.fritzascent.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.aquaotter.fritzascent.engine.FightEngine

@Composable
fun FightScreen(fightEngine: FightEngine, onFightEnd: (String) -> Unit) {
    val fightState = fightEngine.fightState.collectAsState()
    val state = fightState.value

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(16.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        // Health bars
        HealthBars(
            playerHealth = state.playerHealth,
            playerMaxHealth = state.playerMaxHealth,
            opponentHealth = state.opponentHealth,
            opponentMaxHealth = state.opponentMaxHealth
        )

        // Ring (placeholder)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(300.dp)
                .background(Color.DarkGray),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "RING - ${state.opponentName}",
                style = TextStyle(color = Color.White, fontSize = 20.sp)
            )
        }

        // Control buttons
        ControlPanel(
            onDodgeLeft = { fightEngine.playerDodge("left") },
            onDodgeRight = { fightEngine.playerDodge("right") },
            onCounterLeft = { fightEngine.playerCounter("left") },
            onCounterRight = { fightEngine.playerCounter("right") },
            canStarPunch = state.stars > 0,
            onStarPunch = { fightEngine.playerStarPunch() }
        )

        // Check for fight end
        if (state.isOpponentKO) {
            onFightEnd("Victory")
        }
        if (state.playerHealth <= 0) {
            onFightEnd("Defeat")
        }
    }
}

@Composable
fun HealthBars(
    playerHealth: Int,
    playerMaxHealth: Int,
    opponentHealth: Int,
    opponentMaxHealth: Int
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 16.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        HealthBar(health = playerHealth, maxHealth = playerMaxHealth, label = "Fritz")
        HealthBar(health = opponentHealth, maxHealth = opponentMaxHealth, label = "Opponent")
    }
}

@Composable
fun HealthBar(health: Int, maxHealth: Int, label: String) {
    Column(modifier = Modifier.weight(1f)) {
        Text(label, style = TextStyle(color = Color.White, fontSize = 12.sp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(20.dp)
                .background(Color.Red)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(fraction = (health.toFloat() / maxHealth).coerceIn(0f, 1f))
                    .height(20.dp)
                    .background(Color.Green)
            )
        }
    }
}

@Composable
fun ControlPanel(
    onDodgeLeft: () -> Unit,
    onDodgeRight: () -> Unit,
    onCounterLeft: () -> Unit,
    onCounterRight: () -> Unit,
    canStarPunch: Boolean,
    onStarPunch: () -> Unit
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(onClick = onDodgeLeft, modifier = Modifier.weight(1f)) {
                Text("← Dodge")
            }
            Button(onClick = onDodgeRight, modifier = Modifier.weight(1f)) {
                Text("Dodge →")
            }
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(onClick = onCounterLeft, modifier = Modifier.weight(1f)) {
                Text("← Counter")
            }
            Button(onClick = onCounterRight, modifier = Modifier.weight(1f)) {
                Text("Counter →")
            }
        }
        Button(
            onClick = onStarPunch,
            modifier = Modifier.fillMaxWidth(),
            enabled = canStarPunch
        ) {
            Text("⭐ STAR PUNCH")
        }
    }
}