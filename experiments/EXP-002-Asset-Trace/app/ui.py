import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import uuid
import shutil
from typing import Optional

try:
    from PIL import Image, ImageTk
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False

from app.catalog import CatalogManager
from app.scanner import Scanner
from app.models import Source

class Application(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("EXP-002: Asset Trace Utility")
        self.geometry("1024x768")
        self.manager: Optional[CatalogManager] = None
        self.current_asset = None

        self._build_ui()

    def _build_ui(self):
        # Top Toolbar
        toolbar_frame = ttk.Frame(self, padding=5)
        toolbar_frame.pack(side=tk.TOP, fill=tk.X)

        ttk.Button(toolbar_frame, text="Open Project", command=self._open_project).pack(side=tk.LEFT, padx=2)
        self.scan_btn = ttk.Button(toolbar_frame, text="Scan", command=self._scan, state=tk.DISABLED)
        self.scan_btn.pack(side=tk.LEFT, padx=2)
        self.save_btn = ttk.Button(toolbar_frame, text="Save", command=self._save, state=tk.DISABLED)
        self.save_btn.pack(side=tk.LEFT, padx=2)

        self.sources_btn = ttk.Button(toolbar_frame, text="Manage Sources", command=self._open_sources_dialog, state=tk.DISABLED)
        self.sources_btn.pack(side=tk.LEFT, padx=2)

        ttk.Separator(self, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=2)

        # Filters
        filter_frame = ttk.Frame(self, padding=5)
        filter_frame.pack(side=tk.TOP, fill=tk.X)

        ttk.Label(filter_frame, text="Search:").pack(side=tk.LEFT, padx=2)
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *args: self._apply_filters())
        ttk.Entry(filter_frame, textvariable=self.search_var, width=30).pack(side=tk.LEFT, padx=2)

        ttk.Label(filter_frame, text="Status:").pack(side=tk.LEFT, padx=(10, 2))
        self.status_var = tk.StringVar(value="ALL")

        statuses = ["ALL", "NEW", "OK", "MODIFIED", "MISSING"]
        for status in statuses:
            ttk.Radiobutton(
                filter_frame, text=status, value=status,
                variable=self.status_var, command=self._apply_filters
            ).pack(side=tk.LEFT, padx=2)

        ttk.Separator(self, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=2)

        # Main content area
        main_paned = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        # Left: Asset List
        list_frame = ttk.Frame(main_paned)
        main_paned.add(list_frame, weight=2)

        columns = ("display_name", "relative_path", "scan_status")
        self.tree = ttk.Treeview(list_frame, columns=columns, show="headings")
        self.tree.heading("display_name", text="Name")
        self.tree.heading("relative_path", text="Path")
        self.tree.heading("scan_status", text="Status")

        self.tree.column("display_name", width=150)
        self.tree.column("relative_path", width=250)
        self.tree.column("scan_status", width=80)

        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.tree.bind('<<TreeviewSelect>>', self._on_select_asset)

        # Right: Inspector
        inspector_frame = ttk.Frame(main_paned, padding=5)
        main_paned.add(inspector_frame, weight=1)

        # Fields mapping
        # Label text, attr_name, read_only
        self.fields = [
            ("Asset UUID", "asset_uuid", True),
            ("Name", "display_name", False),
            ("Relative Path", "relative_path", True),
            ("SHA-256", "sha256", True),
            ("File Size", "file_size", True),
            ("Type", "asset_type", False),
            ("Source UUID", "source_uuid", False), # Handled as combobox below
            ("Scan Status", "scan_status", True),
            ("Audit State", "audit_state", False),
            ("Tags", "tags", False), # Will handle conversion to list
        ]

        self.inspector_vars = {}
        row = 0
        for label_text, attr, read_only in self.fields:
            ttk.Label(inspector_frame, text=label_text).grid(row=row, column=0, sticky=tk.W, pady=2)
            var = tk.StringVar()

            if attr == "source_uuid":
                self.source_combo = ttk.Combobox(inspector_frame, textvariable=var, width=38, state="readonly")
                self.source_combo.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
                self.source_combo.bind("<<ComboboxSelected>>", lambda e: self._on_field_edit("source_uuid", var))
                var.trace_add("write", lambda *args, a=attr, v=var: self._on_field_edit(a, v))
            elif read_only:
                entry = ttk.Entry(inspector_frame, textvariable=var, state="readonly", width=40)
                entry.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
            else:
                entry = ttk.Entry(inspector_frame, textvariable=var, width=40)
                var.trace_add("write", lambda *args, a=attr, v=var: self._on_field_edit(a, v))
                entry.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)

            self.inspector_vars[attr] = var
            row += 1

        ttk.Label(inspector_frame, text="Notes").grid(row=row, column=0, sticky=tk.NW, pady=2)
        self.notes_text = tk.Text(inspector_frame, height=5, width=40)
        self.notes_text.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
        self.notes_text.bind("<<Modified>>", self._on_notes_edit)
        row += 1

        ttk.Separator(inspector_frame, orient=tk.HORIZONTAL).grid(row=row, column=0, columnspan=2, sticky=tk.EW, pady=10)
        row += 1

        ttk.Label(inspector_frame, text="Preview").grid(row=row, column=0, sticky=tk.NW, pady=2)
        self.preview_frame = ttk.Frame(inspector_frame, width=256, height=256, relief=tk.SUNKEN)
        self.preview_frame.grid(row=row, column=1, sticky=tk.NW, pady=2, padx=5)
        self.preview_frame.grid_propagate(False)
        self.preview_label = ttk.Label(self.preview_frame, text="No Preview")
        self.preview_label.place(relx=0.5, rely=0.5, anchor=tk.CENTER)
        self.preview_image_ref = None

        inspector_frame.columnconfigure(1, weight=1)

    def _open_project(self):
        project_dir = filedialog.askdirectory(title="Select Project Root")
        if not project_dir:
            return

        self.manager = CatalogManager(project_dir)
        loaded = self.manager.load()
        if loaded:
            messagebox.showinfo("Project Opened", "Loaded existing asset_catalog.json")
        else:
            messagebox.showinfo("Project Opened", "Started new catalog for project.")

        self.scan_btn.config(state=tk.NORMAL)
        self.save_btn.config(state=tk.NORMAL)
        self.sources_btn.config(state=tk.NORMAL)
        self._update_source_combobox()
        self._refresh_list()

    def _scan(self):
        if not self.manager:
            return

        scanner = Scanner(self.manager)
        try:
            scanner.scan()
            self._refresh_list()
            messagebox.showinfo("Scan Complete", "Finished scanning project.")
        except Exception as e:
            messagebox.showerror("Scan Error", str(e))

    def _save(self):
        if not self.manager:
            return
        try:
            self.manager.save()
            messagebox.showinfo("Save Complete", "Catalog saved successfully.")
        except Exception as e:
            messagebox.showerror("Save Error", str(e))

    def _refresh_list(self):
        if not self.manager:
            return

        # clear tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        self._apply_filters()

    def _apply_filters(self):
        if not self.manager:
            return

        search_term = self.search_var.get().lower()
        status_filter = self.status_var.get()

        # Clear tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        # Clear selection visually and logically when applying filters
        self.current_asset = None
        for var in self.inspector_vars.values():
            var.set("")
        self.notes_text.delete("1.0", tk.END)
        self.notes_text.edit_modified(False)

        for asset in self.manager.get_assets():
            # Apply status filter
            if status_filter != "ALL" and asset.scan_status != status_filter:
                continue

            # Apply text search (name or path)
            if search_term:
                if search_term not in asset.display_name.lower() and search_term not in asset.relative_path.lower():
                    continue

            self.tree.insert("", tk.END, iid=asset.relative_path, values=(
                asset.display_name,
                asset.relative_path,
                asset.scan_status
            ))

    def _on_select_asset(self, event):
        selected = self.tree.selection()
        if not selected:
            self.current_asset = None
            return

        rel_path = selected[0]
        self.current_asset = self.manager.get_asset_by_path(rel_path)

        self._populate_inspector()

    def _update_source_combobox(self):
        if not self.manager:
            return

        sources = self.manager.get_sources()
        values = [""] + [s.source_uuid for s in sources]
        self.source_combo['values'] = values

    def _populate_inspector(self):
        if not self.current_asset:
            return

        for attr, var in self.inspector_vars.items():
            val = getattr(self.current_asset, attr)
            if attr == "tags":
                val = ", ".join(val)

            # Temporarily disable tracing by blocking writes or just let it fire (might cause minor overhead but safe)
            var.set(str(val))

        self.notes_text.delete("1.0", tk.END)
        self.notes_text.insert(tk.END, self.current_asset.notes)
        self.notes_text.edit_modified(False) # reset modified flag

        self._update_preview()

    def _update_preview(self):
        self.preview_label.config(text="Preview unavailable", image="")
        self.preview_image_ref = None

        if not self.current_asset or not HAS_PILLOW:
            if not HAS_PILLOW:
                self.preview_label.config(text="Pillow not installed")
            return

        ext = os.path.splitext(self.current_asset.display_name)[1].lower()
        if ext not in ('.png', '.jpg', '.jpeg', '.webp', '.gif'):
            self.preview_label.config(text="No Preview")
            return

        abs_path = os.path.join(self.manager.project_root, self.current_asset.relative_path)
        if not os.path.exists(abs_path):
            return

        try:
            image = Image.open(abs_path)
            # Handle animated GIFs by taking first frame
            if getattr(image, "is_animated", False):
                image.seek(0)

            # Convert to RGB to avoid issues with some formats
            if image.mode not in ('RGB', 'RGBA'):
                image = image.convert('RGBA')

            image.thumbnail((256, 256))
            photo = ImageTk.PhotoImage(image)
            self.preview_label.config(image=photo, text="")
            self.preview_image_ref = photo # Keep reference
        except Exception:
            self.preview_label.config(text="Preview unavailable")

    def _on_field_edit(self, attr_name, var):
        if not self.current_asset:
            return

        val = var.get()
        if attr_name == "tags":
            # Handle comma separated tags
            tags_list = [t.strip() for t in val.split(",") if t.strip()]
            setattr(self.current_asset, attr_name, tags_list)
        else:
            setattr(self.current_asset, attr_name, val)

        # Special case: if name changed, we might want to update the tree display,
        # but changing tree actively during typing might be annoying.
        # We'll leave the tree update for a manual refresh or just next selection.

    def _on_notes_edit(self, event):
        if not self.current_asset:
            return

        if self.notes_text.edit_modified():
            self.current_asset.notes = self.notes_text.get("1.0", "end-1c")
            self.notes_text.edit_modified(False)

    def _open_sources_dialog(self):
        if not self.manager:
            return

        dialog = tk.Toplevel(self)
        dialog.title("Manage Sources")
        dialog.geometry("600x400")

        # Split into list (left) and editor (right)
        paned = ttk.PanedWindow(dialog, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        list_frame = ttk.Frame(paned)
        paned.add(list_frame, weight=1)

        sources_list = tk.Listbox(list_frame)
        sources_list.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        btn_frame = ttk.Frame(list_frame)
        btn_frame.pack(side=tk.BOTTOM, fill=tk.X)

        def refresh_sources_list():
            sources_list.delete(0, tk.END)
            for s in self.manager.get_sources():
                display = s.product_name if s.product_name else s.source_uuid
                sources_list.insert(tk.END, display)

        refresh_sources_list()

        editor_frame = ttk.Frame(paned, padding=5)
        paned.add(editor_frame, weight=2)

        editor_vars = {}
        source_fields = [
            ("Store Name", "store_name"),
            ("Product Name", "product_name"),
            ("Creator Name", "creator_name"),
            ("Acquisition Date", "acquisition_date"),
            ("License Type", "license_type"),
            ("License URL", "license_url"),
            ("Source URL", "source_url"),
            ("Receipt Path", "receipt_path"),
            ("Notes", "notes")
        ]

        row_idx = 0
        ttk.Label(editor_frame, text="UUID:").grid(row=row_idx, column=0, sticky=tk.W, pady=2)
        uuid_var = tk.StringVar()
        ttk.Entry(editor_frame, textvariable=uuid_var, state="readonly", width=40).grid(row=row_idx, column=1, sticky=tk.EW, pady=2)
        row_idx += 1

        for label, attr in source_fields:
            ttk.Label(editor_frame, text=label + ":").grid(row=row_idx, column=0, sticky=tk.W, pady=2)
            var = tk.StringVar()
            state = "readonly" if attr == "receipt_path" else "normal"
            ttk.Entry(editor_frame, textvariable=var, state=state, width=40).grid(row=row_idx, column=1, sticky=tk.EW, pady=2)
            editor_vars[attr] = var
            row_idx += 1

        # Add requires_attribution checkbox
        req_attr_var = tk.BooleanVar()
        ttk.Checkbutton(editor_frame, text="Requires Attribution", variable=req_attr_var).grid(row=row_idx, column=1, sticky=tk.W, pady=2)
        row_idx += 1

        # Add attribution_text multiline text
        ttk.Label(editor_frame, text="Attribution Text:").grid(row=row_idx, column=0, sticky=tk.NW, pady=2)
        attr_text_widget = tk.Text(editor_frame, height=4, width=40)
        attr_text_widget.grid(row=row_idx, column=1, sticky=tk.EW, pady=2)
        row_idx += 1

        current_source_id = [None]

        def populate_editor(event):
            selection = sources_list.curselection()
            if not selection:
                return
            idx = selection[0]
            source = self.manager.get_sources()[idx]
            current_source_id[0] = source.source_uuid

            uuid_var.set(source.source_uuid)
            for attr, var in editor_vars.items():
                var.set(getattr(source, attr))

            req_attr_var.set(source.requires_attribution)
            attr_text_widget.delete("1.0", tk.END)
            attr_text_widget.insert(tk.END, source.attribution_text)

        sources_list.bind('<<ListboxSelect>>', populate_editor)

        def save_current_source():
            if not current_source_id[0]:
                return

            # Find the source
            sources = self.manager.get_sources()
            source = next((s for s in sources if s.source_uuid == current_source_id[0]), None)

            if source:
                for attr, var in editor_vars.items():
                    setattr(source, attr, var.get())
                source.requires_attribution = req_attr_var.get()
                source.attribution_text = attr_text_widget.get("1.0", "end-1c")
                self.manager.add_or_update_source(source)
                refresh_sources_list()
                self._update_source_combobox()

        def create_source():
            new_source = Source(source_uuid=str(uuid.uuid4()), product_name="New Source")
            self.manager.add_or_update_source(new_source)
            refresh_sources_list()
            sources_list.selection_clear(0, tk.END)
            sources_list.selection_set(tk.END)
            populate_editor(None)
            self._update_source_combobox()

        def delete_source():
            if not current_source_id[0]:
                return
            if messagebox.askyesno("Confirm Delete", "Are you sure you want to delete this source?"):
                success = self.manager.remove_source(current_source_id[0])
                if success:
                    current_source_id[0] = None
                    uuid_var.set("")
                    for var in editor_vars.values():
                        var.set("")
                    refresh_sources_list()
                    self._update_source_combobox()
                else:
                    messagebox.showerror("Error", "Cannot delete source. It is referenced by one or more assets.")

        def attach_receipt():
            if not current_source_id[0]:
                messagebox.showwarning("Warning", "Please select a source first.")
                return

            filepath = filedialog.askopenfilename(
                title="Select Receipt",
                filetypes=[("Evidences", "*.pdf *.png *.jpg *.jpeg *.webp *.gif"), ("All Files", "*.*")]
            )
            if not filepath:
                return

            # Create receipts dir
            receipts_dir = os.path.join(self.manager.metallabs_dir, "receipts")
            os.makedirs(receipts_dir, exist_ok=True)

            filename = os.path.basename(filepath)
            dest_path = os.path.join(receipts_dir, filename)

            # Handle collision
            if os.path.exists(dest_path):
                name, ext = os.path.splitext(filename)
                dest_path = os.path.join(receipts_dir, f"{name}_{str(uuid.uuid4())[:8]}{ext}")
                filename = os.path.basename(dest_path)

            try:
                shutil.copy2(filepath, dest_path)
                rel_path = os.path.relpath(dest_path, self.manager.project_root)
                rel_path = rel_path.replace(os.sep, '/')
                editor_vars['receipt_path'].set(rel_path)
                save_current_source()
            except Exception as e:
                messagebox.showerror("Error", f"Failed to attach receipt: {e}")

        def open_receipt():
            if not current_source_id[0]:
                return

            rel_path = editor_vars['receipt_path'].get()
            if not rel_path:
                return

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

        ttk.Button(btn_frame, text="New", command=create_source).pack(side=tk.LEFT, padx=2)
        ttk.Button(btn_frame, text="Delete", command=delete_source).pack(side=tk.LEFT, padx=2)

        actions_frame = ttk.Frame(editor_frame)
        actions_frame.grid(row=row_idx, column=0, columnspan=2, sticky=tk.E, pady=10)

        ttk.Button(actions_frame, text="Attach Receipt", command=attach_receipt).pack(side=tk.LEFT, padx=2)
        ttk.Button(actions_frame, text="Open Receipt", command=open_receipt).pack(side=tk.LEFT, padx=2)
        ttk.Button(actions_frame, text="Save Source", command=save_current_source).pack(side=tk.LEFT, padx=2)

if __name__ == "__main__":
    app = Application()
    app.mainloop()
