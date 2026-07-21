import os
import tkinter as tk
from tkinter import ttk

HAS_PILLOW = False
try:
    from PIL import Image, ImageTk
    HAS_PILLOW = True
except ImportError:
    pass

HAS_PYGAME = False
try:
    import pygame
    pygame.mixer.init()
    HAS_PYGAME = True
except Exception:
    pass

class AssetPreviewPanel(ttk.Frame):
    def __init__(self, master, project_root):
        super().__init__(master)
        self.project_root = project_root

        self.preview_frame = ttk.Frame(self, width=256, height=256, relief=tk.SUNKEN)
        self.preview_frame.pack(fill=tk.BOTH, expand=True)
        self.preview_frame.grid_propagate(False)
        self.preview_frame.pack_propagate(False)

        self.preview_label = ttk.Label(self.preview_frame, text="No Preview")
        self.preview_label.place(relx=0.5, rely=0.5, anchor=tk.CENTER)
        self.preview_image_ref = None

        self.audio_controls = ttk.Frame(self.preview_frame)
        self.btn_play = ttk.Button(self.audio_controls, text="Play", command=self.play_audio)
        self.btn_stop = ttk.Button(self.audio_controls, text="Stop", command=self.stop_audio)
        self.btn_play.pack(side=tk.LEFT, padx=5)
        self.btn_stop.pack(side=tk.LEFT, padx=5)
        self.audio_info_label = ttk.Label(self.preview_frame, text="")

        self.current_audio_file = None

    def clear(self):
        self.preview_label.config(text="No Preview", image="")
        self.preview_image_ref = None
        self.preview_label.place(relx=0.5, rely=0.5, anchor=tk.CENTER)

        self.audio_controls.place_forget()
        self.audio_info_label.place_forget()
        self.stop_audio()
        self.current_audio_file = None

    def show_preview(self, asset):
        self.clear()

        if not asset:
            return

        ext = os.path.splitext(asset.display_name)[1].lower()
        abs_path = os.path.join(self.project_root, asset.relative_path)

        if not os.path.exists(abs_path):
            self.preview_label.config(text="Preview unavailable (File missing)")
            return

        # IMAGE
        if ext in ('.png', '.jpg', '.jpeg', '.webp', '.gif'):
            self._show_image(abs_path)

        # AUDIO
        elif ext in ('.ogg', '.wav', '.mp3'):
            self._show_audio(abs_path, asset.display_name)

        else:
            self.preview_label.config(text="Preview not supported for this type")

    def _show_image(self, abs_path):
        if not HAS_PILLOW:
            self.preview_label.config(text="Preview unavailable (Pillow missing)")
            return

        try:
            image = Image.open(abs_path)
            if getattr(image, "is_animated", False):
                image.seek(0)

            if image.mode not in ('RGB', 'RGBA'):
                image = image.convert('RGBA')

            image.thumbnail((256, 256))
            photo = ImageTk.PhotoImage(image)
            self.preview_label.config(image=photo, text="")
            self.preview_image_ref = photo # Keep reference
        except Exception:
            self.preview_label.config(text="Preview unavailable (Corrupt or unsupported)")

    def _show_audio(self, abs_path, filename):
        if not HAS_PYGAME:
            self.preview_label.config(text="Preview unavailable (pygame missing)")
            return

        self.preview_label.config(text="")
        self.current_audio_file = abs_path
        self.audio_info_label.config(text=filename)

        self.audio_info_label.place(relx=0.5, rely=0.3, anchor=tk.CENTER)
        self.audio_controls.place(relx=0.5, rely=0.6, anchor=tk.CENTER)

    def play_audio(self):
        if not self.current_audio_file or not HAS_PYGAME:
            return

        try:
            pygame.mixer.music.load(self.current_audio_file)
            pygame.mixer.music.play()
        except Exception:
            self.audio_info_label.config(text="Playback error")

    def stop_audio(self):
        if HAS_PYGAME:
            try:
                if pygame.mixer.music.get_busy():
                    pygame.mixer.music.stop()
            except Exception:
                pass

    def cleanup(self):
        self.stop_audio()
