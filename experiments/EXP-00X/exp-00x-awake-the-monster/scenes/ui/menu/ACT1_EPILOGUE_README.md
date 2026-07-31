# Act 1 Epilogue

**Status:** Integrated

## Resources

- Godot playback video: res://Assets/videos/act1-epilogue.ogv
- Music: res://Assets/music/act1-epilogue.mp3

Playback uses Godot's native Ogg Theora support and requires no external video
decoder. A local AudioStreamPlayer reproduces the epilogue track after the
global MusicPlayer stops.

VideoPlayer remains muted, so only the authored MP3 is heard even if the OGV
contains an audio track.

## Flow

Card 06 completed -> save removed -> Act 1 Epilogue -> Final Vertical Slice -> Main Menu

Entry holds a black frame for 0.25 seconds. Music starts first and video starts
0.12 seconds later, followed by a 0.4 second fade from black.

Natural completion and hold-to-skip use the same exit function. It fades to
black, fades the local music, stops both players and loads end_screen.tscn.

## Hold-to-skip

Holding ui_accept for 1.5 seconds completes the skip. The indicator remains
hidden until the hold begins. Releasing early hides it and resets progress.

## Save policy

The game is considered completed when Card 06 closes. The prototype save is
removed before entering this scene, so the epilogue cannot become a resumable
game state and Continue cannot restore a completed Card 06.

## Limitations

- Audio and video use a fixed 0.12 second start offset; there is no beat or
  timeline synchronization.
- Losing application focus pauses both local players together.
- The epilogue does not introduce a pause menu or playback controls.

## Future replacement

Final Vertical Slice may become the Credits scene.
