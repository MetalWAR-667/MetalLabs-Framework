import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import uuid
import shutil

HAS_PYMUPDF = False
try:
    import fitz # PyMuPDF
    HAS_PYMUPDF = True
except ImportError:
    pass

HAS_PILLOW = False
try:
    from PIL import Image, ImageTk
    HAS_PILLOW = True
except ImportError:
    pass

from app.models import Source

class SourcePanel(ttk.Frame):
    def __init__(self, master, manager, on_source_changed=None):
        super().__init__(master)
        self.manager = manager
        self.on_source_changed = on_source_changed
        self.current_source = None

        self._build_ui()

    def _build_ui(self):
        # Header/Selector
        header_frame = ttk.Frame(self)
        header_frame.pack(side=tk.TOP, fill=tk.X, pady=5)

        ttk.Label(header_frame, text="Source:").pack(side=tk.LEFT, padx=(0, 5))

        self.source_combo_var = tk.StringVar()
        self.source_combo = ttk.Combobox(header_frame, textvariable=self.source_combo_var, state="readonly", width=40)
        self.source_combo.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        self.source_combo.bind("<<ComboboxSelected>>", self._on_combo_selected)

        ttk.Button(header_frame, text="New Source", command=self._create_source).pack(side=tk.LEFT, padx=5)

        self.usage_label = ttk.Label(header_frame, text="")
        self.usage_label.pack(side=tk.LEFT, padx=5)

        ttk.Button(header_frame, text="Delete Source", command=self._delete_source).pack(side=tk.RIGHT, padx=5)

        # Content area (hidden if no source selected)
        self.content_frame = ttk.Frame(self)
        self.content_frame.pack(side=tk.TOP, fill=tk.BOTH, expand=True, pady=5)

        # Left side: Editor
        editor_frame = ttk.Frame(self.content_frame)
        editor_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Group: Identity
        id_frame = ttk.LabelFrame(editor_frame, text="Identity", padding=5)
        id_frame.pack(fill=tk.X, pady=2)

        self.vars = {}
        def add_field(parent, label, attr):
            f = ttk.Frame(parent)
            f.pack(fill=tk.X, pady=1)
            ttk.Label(f, text=label, width=15).pack(side=tk.LEFT)
            var = tk.StringVar()
            entry = ttk.Entry(f, textvariable=var)
            entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
            var.trace_add("write", lambda *args, a=attr, v=var: self._on_edit(a, v))
            self.vars[attr] = var

        add_field(id_frame, "Product Name", "product_name")
        add_field(id_frame, "Creator Name", "creator_name")
        add_field(id_frame, "Store Name", "store_name")
        add_field(id_frame, "Acquisition Date", "acquisition_date")

        # Group: Origin and license
        lic_frame = ttk.LabelFrame(editor_frame, text="Origin and license", padding=5)
        lic_frame.pack(fill=tk.X, pady=2)

        add_field(lic_frame, "Source URL", "source_url")
        add_field(lic_frame, "License Type", "license_type")
        add_field(lic_frame, "License URL", "license_url")

        # Attribution
        attr_f = ttk.Frame(lic_frame)
        attr_f.pack(fill=tk.X, pady=2)
        self.req_attr_var = tk.BooleanVar()
        ttk.Checkbutton(attr_f, text="Requires Attribution", variable=self.req_attr_var, command=lambda: self._on_edit("requires_attribution", self.req_attr_var)).pack(side=tk.LEFT)

        ttk.Label(lic_frame, text="Attribution Text:").pack(anchor=tk.W)
        self.attr_text = tk.Text(lic_frame, height=3, width=40)
        self.attr_text.pack(fill=tk.X)
        self.attr_text.bind("<<Modified>>", self._on_text_edit)

        # Group: Evidence
        ev_frame = ttk.LabelFrame(editor_frame, text="Evidence", padding=5)
        ev_frame.pack(fill=tk.X, pady=2)

        add_field(ev_frame, "Receipt Path", "receipt_path")
        self.vars["receipt_path"].trace_add("write", lambda *a: self._update_receipt_preview())

        btn_f = ttk.Frame(ev_frame)
        btn_f.pack(fill=tk.X, pady=2)
        ttk.Button(btn_f, text="Attach Receipt", command=self._attach_receipt).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_f, text="Open Receipt", command=self._open_receipt).pack(side=tk.LEFT, padx=2)

        # Notes
        notes_frame = ttk.LabelFrame(editor_frame, text="Notes", padding=5)
        notes_frame.pack(fill=tk.X, pady=2)
        self.notes_text = tk.Text(notes_frame, height=3, width=40)
        self.notes_text.pack(fill=tk.X)
        self.notes_text.bind("<<Modified>>", self._on_notes_edit)

        # Right side: Receipt Preview
        self.preview_frame = ttk.LabelFrame(self.content_frame, text="Receipt Preview", width=200, height=300)
        self.preview_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=5)
        self.preview_frame.pack_propagate(False)

        self.preview_label = ttk.Label(self.preview_frame, text="No Receipt")
        self.preview_label.place(relx=0.5, rely=0.5, anchor=tk.CENTER)
        self.preview_image_ref = None

        self._disable_content()

    def refresh_sources(self):
        sources = self.manager.get_sources()
        # Create map of uuid -> label
        self.source_map = {}
        values = [""]
        for s in sources:
            label = f"{s.product_name} — {s.store_name}" if s.product_name or s.store_name else f"Unnamed ({s.source_uuid})"
            self.source_map[label] = s.source_uuid
            values.append(label)

        self.source_combo['values'] = values

    def set_source(self, source_uuid):
        self.refresh_sources()
        if not source_uuid:
            self.source_combo_var.set("")
            self.current_source = None
            self._disable_content()
            self._update_usage()
            return

        sources = self.manager.get_sources()
        self.current_source = next((s for s in sources if s.source_uuid == source_uuid), None)

        if self.current_source:
            # Find label
            for label, uuid in self.source_map.items():
                if uuid == source_uuid:
                    self.source_combo_var.set(label)
                    break
            self._populate()
            self._enable_content()
            self._update_usage()
        else:
            self.source_combo_var.set("")
            self._disable_content()
            self._update_usage()

    def _update_usage(self):
        if not self.current_source:
            self.usage_label.config(text="")
            return

        count = sum(1 for a in self.manager.catalog.assets if a.source_uuid == self.current_source.source_uuid)
        self.usage_label.config(text=f"Used by {count} Assets")

    def _on_combo_selected(self, event):
        label = self.source_combo_var.get()
        if not label:
            source_uuid = ""
        else:
            source_uuid = self.source_map.get(label, "")

        self.set_source(source_uuid)
        if self.on_source_changed:
            self.on_source_changed(source_uuid)

    def _create_source(self):
        new_source = Source(source_uuid=str(uuid.uuid4()), product_name="New Source")
        self.manager.add_or_update_source(new_source)
        self.set_source(new_source.source_uuid)
        if self.on_source_changed:
            self.on_source_changed(new_source.source_uuid)

    def _delete_source(self):
        if not self.current_source:
            return

        if messagebox.askyesno("Confirm Delete", "Are you sure you want to delete this source?"):
            success = self.manager.remove_source(self.current_source.source_uuid)
            if success:
                if self.on_source_changed:
                    self.on_source_changed("")
                self.set_source("")
            else:
                messagebox.showerror("Error", "Cannot delete source. It is referenced by one or more assets.")

    def _populate(self):
        if not self.current_source:
            return

        for attr, var in self.vars.items():
            var.set(getattr(self.current_source, attr))

        self.req_attr_var.set(self.current_source.requires_attribution)

        self.attr_text.delete("1.0", tk.END)
        self.attr_text.insert(tk.END, self.current_source.attribution_text)
        self.attr_text.edit_modified(False)

        self.notes_text.delete("1.0", tk.END)
        self.notes_text.insert(tk.END, self.current_source.notes)
        self.notes_text.edit_modified(False)

    def _on_edit(self, attr_name, var):
        if not self.current_source:
            return
        val = var.get()
        setattr(self.current_source, attr_name, val)
        self.manager.add_or_update_source(self.current_source)

        if attr_name in ("product_name", "store_name"):
            # Update label in combobox safely without triggering select event immediately
            pass

    def _on_text_edit(self, event):
        if not self.current_source: return
        if self.attr_text.edit_modified():
            self.current_source.attribution_text = self.attr_text.get("1.0", "end-1c")
            self.manager.add_or_update_source(self.current_source)
            self.attr_text.edit_modified(False)

    def _on_notes_edit(self, event):
        if not self.current_source: return
        if self.notes_text.edit_modified():
            self.current_source.notes = self.notes_text.get("1.0", "end-1c")
            self.manager.add_or_update_source(self.current_source)
            self.notes_text.edit_modified(False)

    def _disable_content(self):
        for child in self.content_frame.winfo_children():
            child.pack_forget()

    def _enable_content(self):
        # We assume child 0 is editor and child 1 is preview, just pack them
        children = self.content_frame.winfo_children()
        if len(children) >= 2:
            children[0].pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
            children[1].pack(side=tk.RIGHT, fill=tk.Y, padx=5)
            self._update_receipt_preview()

    def _attach_receipt(self):
        if not self.current_source: return

        filepath = filedialog.askopenfilename(
            title="Select Receipt",
            filetypes=[("Evidences", "*.pdf *.png *.jpg *.jpeg *.webp *.gif"), ("All Files", "*.*")]
        )
        if not filepath: return

        receipts_dir = os.path.join(self.manager.metallabs_dir, "receipts")
        os.makedirs(receipts_dir, exist_ok=True)

        filename = os.path.basename(filepath)
        dest_path = os.path.join(receipts_dir, filename)

        if os.path.exists(dest_path):
            name, ext = os.path.splitext(filename)
            dest_path = os.path.join(receipts_dir, f"{name}_{str(uuid.uuid4())[:8]}{ext}")

        try:
            shutil.copy2(filepath, dest_path)
            rel_path = os.path.relpath(dest_path, self.manager.project_root)
            rel_path = rel_path.replace(os.sep, '/')
            self.vars['receipt_path'].set(rel_path)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to attach receipt: {e}")

    def _open_receipt(self):
        if not self.current_source: return
        rel_path = self.vars['receipt_path'].get()
        if not rel_path: return

        abs_path = os.path.join(self.manager.project_root, rel_path)
        if os.path.exists(abs_path):
            try:
                if os.name == 'nt':
                    os.startfile(abs_path)
                else:
                    import subprocess
                    import sys
                    opener = "open" if sys.platform == "darwin" else "xdg-open"
                    subprocess.call([opener, abs_path])
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open receipt: {e}")
        else:
            messagebox.showerror("Error", "Receipt file not found on disk.")

    def _update_receipt_preview(self):
        self.preview_label.config(text="No Receipt", image="")
        self.preview_image_ref = None

        if not self.current_source: return

        rel_path = self.vars['receipt_path'].get()
        if not rel_path: return

        abs_path = os.path.join(self.manager.project_root, rel_path)
        if not os.path.exists(abs_path):
            self.preview_label.config(text="Receipt file missing")
            return

        ext = os.path.splitext(rel_path)[1].lower()

        try:
            if ext == '.pdf':
                if HAS_PYMUPDF:
                    doc = fitz.open(abs_path)
                    page = doc.load_page(0)
                    pix = page.get_pixmap(matrix=fitz.Matrix(0.2, 0.2)) # Scale down
                    img_data = pix.tobytes("ppm")
                    photo = tk.PhotoImage(data=img_data)
                    self.preview_label.config(image=photo, text="")
                    self.preview_image_ref = photo
                    doc.close()
                else:
                    sz = os.path.getsize(abs_path) // 1024
                    self.preview_label.config(text=f"PDF Receipt\n{os.path.basename(rel_path)}\n{sz} KB\n\nPyMuPDF not installed")
            elif ext in ('.png', '.jpg', '.jpeg', '.webp', '.gif') and HAS_PILLOW:
                image = Image.open(abs_path)
                if image.mode not in ('RGB', 'RGBA'):
                    image = image.convert('RGBA')
                image.thumbnail((180, 250))
                photo = ImageTk.PhotoImage(image)
                self.preview_label.config(image=photo, text="")
                self.preview_image_ref = photo
            else:
                sz = os.path.getsize(abs_path) // 1024
                self.preview_label.config(text=f"Receipt\n{os.path.basename(rel_path)}\n{sz} KB\n\nPreview not supported")
        except Exception:
            self.preview_label.config(text="Preview unavailable")
