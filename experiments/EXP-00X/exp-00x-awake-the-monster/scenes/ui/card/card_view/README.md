# Card Composition Pass I

**Status:** Integrated

## Progressive narrative

`CardView` reveals narrative text through `RichTextLabel.visible_characters`.
Characters use a configurable base rate, with additional pauses after commas,
sentences, semicolons, colons and line breaks.

While the reveal is active, `ui_accept` completes the text and is marked as
handled before GUI buttons can receive it. Options remain disabled and
transparent until a deferred short fade begins.

A left click inside the narrative area also completes the reveal. The internal
vertical scrollbar remains active for wheel input and automatic following, but
its visual alpha is forced to zero whenever Godot attempts to show it.

## Options

Options contain narrative text only. Their previous icon indicators were
removed.

Hover and keyboard focus use local tweens to fade a restrained background and
move the text horizontally. Existing hover tweens are cancelled before a new
one starts.

## Test indicators

`CardThreatBar` is now a child of `ImageRegion`, placed at the lower-left of the
clipped illustration. Damage remains on the same indicator row and is hidden
when its value is zero. Cards without a threat hide the entire bar.

## Illustration movement

The existing `ImageRegion` geometry and the high-resolution source texture are
unchanged. Each presented card restarts a centered Slow Zoom Out. The initial
scale approximates the original 1370 × 1343 presentation inside the fixed crop:

```text
202% → 100%
```

The default duration is 8 seconds. The pivot is calculated from the visible
centre of `ImageRegion`, so the current crop remains centred during scaling.

## Configurable parameters

- `text_characters_per_second`
- `comma_pause`
- `sentence_pause`
- `options_fade_duration`
- `hover_duration`
- `hover_text_offset`
- `illustration_start_scale`
- `illustration_end_scale`
- `illustration_zoom_duration`

## Known limitations

- All cards use the same reveal, hover and zoom behaviour.
- There is no typing audio or per-card presentation profile.
- The illustration crop remains the manually authored crop in
  `card_view_responsive.tscn`.
- Indicator placement requires visual validation against every illustration.
