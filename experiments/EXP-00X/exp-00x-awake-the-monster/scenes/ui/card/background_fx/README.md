# BackgroundFX

BackgroundFX is the single composition entry point for the visual background of
Awake the Monster. It coordinates visibility and transitions, but contains no
narrative or gameplay logic.

## Current state

### Atmospheric Layer

**Status:** Integrated

Contains the existing Dream Background material and Dream Residue particles.
Their material, particle configuration and visible result remain unchanged.
They were only grouped below `AtmosphericLayer` so they can participate in a
crossfade.

### Memory Layer

**Status:** Prototype Placeholder

> **Research Placeholder**  
> **Not final implementation.**  
> **External visual reference.**  
> **May be replaced by an original implementation.**

The current placeholder uses a dark background and a small authored arrangement
of nodes and connections. It does not reuse the external experimental shader.
Its only purpose is to evaluate composition beneath the card and HUD.

### Transition Controller

**Status:** Integrated

`BackgroundFX` exposes:

- `show_atmosphere()`
- `show_memory()`
- `fade_to_atmosphere()`
- `fade_to_memory()`

The immediate methods set layer visibility directly. The fade methods perform a
configurable crossfade using `TransitionController.fade_duration`.

## Future work

The definitive Memory Layer depends on:

- composition validation with the card and HUD;
- an art-direction decision;
- compatible permission for the reference shader or a future original
  implementation.

None of these decisions is made by the current integration.
