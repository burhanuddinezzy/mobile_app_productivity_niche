# Dollo

Dollo is a gamified productivity app that turns focused work sessions into visible, long-term progress. Instead of just checking off tasks, you grow a small virtual farm where each plant represents your effort over time.

The goal is to make consistency feel tangible — you don’t just *do* work, you *build* something.

---

## What This App Does

* You run focus sessions (similar to Pomodoro).
* Completing sessions grows your plants.
* Plants progress through visual stages.
* Each stage generates in-game gold.
* Everything is saved locally and restored on app launch.

Right now, this is an MVP focused on the core loop: **focus → growth → reward → persistence**.

---

## Current Features

### Focus Sessions

* Timed focus sessions
* Session completion hooks into plant growth
* Designed to be simple and distraction-free

### Plant System

* Each plant has:

  * A name
  * Growth stages
  * Required sessions to fully grow
  * Gold yield per stage
* Growth is incremental, not instant
* Progress persists between app launches

### Farm View

* Displays plants in a farm-style layout
* Uses snapped positioning (not a rigid visible grid)
* Designed to feel like an open field rather than a board
* MVP uses colored boxes for now (art assets will be added later)

### Persistence

* All app state is saved locally
* Plants, growth progress, gold, and settings persist
* JSON-based storage

---

## Project Structure

```
lib/
  models/
    app_state.dart      # Global app state
    plant.dart          # Plant model and growth logic

  screens/
    home_screen.dart    # Farm view
    focus_screen.dart   # Focus session UI

  services/
    data_service.dart   # Local persistence

  main.dart
```

---

## Status

This project is actively being built. The focus right now is on getting the core loop correct before adding visuals, animations, shops, or social features.

Upcoming work:

* Proper farm background tiles
* Camera-style panning
* Plant sprites and animations
* Gold collection interactions
* Inventory / shop system
* Multiple farms or zones

---

## Philosophy

Most productivity apps optimize for short-term motivation. Dollo is designed around **long-term continuity**. You don’t reset every day — your farm grows with you.

The UI is intentionally calm, simple, and non-punitive. Miss a day? Your plants don’t die. They just wait.

---

## Tech Notes

* Built with Flutter
* Local-first (no backend yet)
* JSON persistence
* Designed to scale into a more complex game loop

---

If you’re working on this project and reading this later: keep the core loop simple. Everything else is optional.
