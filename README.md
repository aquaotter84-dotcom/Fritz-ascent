# Fritz's Ascent

A Punch-Out Clone for Android built in **Kotlin + Jetpack Compose**.

## Project Structure

```
app/src/main/
  kotlin/com/aquaotter/fritzascent/
    ui/
      AppRoot.kt           (Navigation & screen state)
      MenuScreen.kt        (Main menu)
      FightScreen.kt       (Combat arena UI)
      theme/
        Theme.kt           (Dark theme)
    engine/
      FightEngine.kt       (Combat orchestrator)
    model/
      FightState.kt        (Immutable state)
      DustyPattern.kt      (AI opponent)
    MainActivity.kt        (Entry point)
  res/
    AndroidManifest.xml
```

## Core Gameplay Loop

1. **Watch** the opponent's tell
2. **Dodge** the incoming attack
3. **Counter** during the vulnerable window
4. **Build stars** on perfect dodges → spend on star punches
5. **Win** by KO

## How to Build

```bash
git clone https://github.com/aquaotter84-dotcom/Fritz-ascent.git
cd Fritz-ascent
./gradlew build
./gradlew installDebug    # Install on connected device
```

## Current Status

- ✅ Android project scaffold (Kotlin + Compose)
- ✅ Main menu & fight screen UI
- ✅ FightEngine with Dusty AI pattern
- ⏳ **Next:** Combat state refinement & visual polish

## Author

Jeremy / Solace