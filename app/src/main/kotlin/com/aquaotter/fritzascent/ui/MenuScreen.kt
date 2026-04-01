package com.aquaotter.fritzascent.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun MenuScreen(onStartFight: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "FRITZ'S ASCENT",
            style = TextStyle(
                color = Color.White,
                fontSize = 40.sp
            )
        )
        
        Text(
            text = "A Punch-Out Clone",
            style = TextStyle(
                color = Color.Gray,
                fontSize = 16.sp
            ),
            modifier = Modifier.padding(bottom = 32.dp)
        )

        Button(onClick = onStartFight) {
            Text("START FIGHT")
        }
    }
}