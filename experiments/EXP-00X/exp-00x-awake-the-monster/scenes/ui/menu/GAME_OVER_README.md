# Game Over

**Status: Integrated**

`GameHUD._apply_player_damage()` is the canonical defeat check. At Health ≤ 0
the HUD blocks interaction, removes the prototype save and fades to black
before loading `game_over.tscn`.

The scene stops music, reveals `game_over.png` from 120% scale and zero alpha to
its stable state over 0.45 seconds, holds for 2.5 seconds, fades out and returns
to `main_menu.tscn`. It has no buttons, scoring or independent defeat state.

