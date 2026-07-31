# BackgroundFX

BackgroundFX is the single composition entry point for the visual background of
Awake the Monster. It coordinates visibility and transitions, but contains no
narrative or gameplay logic.

## Current state

### Atmospheric Layer

**Status:** Integrated

Contains an independent adaptation of EXP-VFX-004 Geometric Flow Fields and the
existing Dream Residue particles. The experiment itself remains unchanged.

The fog uses three existing grayscale sources and one geometric vortex field.
`BackgroundFX.set_card()` selects a composition and interpolates its shader
parameters over 2.2 seconds:

- Card 01 uses a fixed calm composition.
- Card 02 uses a fixed, reproducible vortex.
- Other cards use controlled random values inside conservative ranges.

The geometric field remains centred at `(0.5, 0.5)` in every composition. Its
core stays behind the main card while the surrounding deformation remains
visible around the UI.

### Resolution feedback

`BackgroundFX` exposes two visual-only reactions:

- `play_success_feedback()` produces a 0.4 second cold lightning flash.
- `play_failure_feedback()` produces a 1.2 second oppressive red pulse.

Both animate independent shader uniforms over the active composition. They do
not alter card parameters, cancel composition transitions or inspect gameplay
state. Starting a new reaction replaces the previous feedback and resets all
temporary uniforms before continuing.

The random composition is visual-only and is deliberately excluded from the
save file. Loading a game requests a new valid composition for the restored
card; Card 02 always restores the same vortex.

### Memory Layer

**Status:** Experimental Integration

Memory Layer now contains an original `DreamGraph` implementation. It uses one
custom-drawn Control with 18 deterministic nodes and 21 predefined connections;
it does not copy or translate an external shader. The topology is created once
and remains recognisably identical throughout the chapter.

The graph grows by revealing nodes and extending curved connections over 1.3
seconds. A soft central suppression keeps the card dominant, while a two-pixel
maximum drift prevents the network from appearing completely static.

Card progression and initial palette:

- Card 01: 0.15, subdued blue-grey, intensity 0.18.
- Card 02: 0.30, cold indigo, intensity 0.24.
- Card 03: 0.45, muted ivory, intensity 0.30.
- Card 04: 0.65, old gold, intensity 0.36.
- Card 05: 0.82, dark crimson, intensity 0.42.
- Card 06: 1.00, cold violet-white, intensity 0.50.

`BackgroundFX.set_card()` drives fog and DreamGraph through the same card
identifier. During normal play, progress, colour and intensity interpolate.
When Continue restores a saved card, HUD requests the corresponding graph state
immediately; exact animation progress is deliberately not persisted.

DreamGraph remains independent from fog and resolution feedback. It has no
gameplay knowledge, creates no particles and implements no success/failure
pulses. Its minimal API supports enabling the layer and applying visual state;
travelling pulses remain possible future work, but are not prepared or
connected in this iteration.

Acceptance requires visible structural growth without competing with the card
or reading as a technological interface. If manual composition testing rejects
that premise, the graph should be removed from the final composition rather
than expanded with additional systems.

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

The DreamGraph still requires manual composition validation with the card,
vortex and actor panels. Possible travelling pulses are intentionally deferred.
