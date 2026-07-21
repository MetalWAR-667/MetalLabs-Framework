import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
from typing import Optional

from app.catalog import CatalogManager
from app.scanner import Scanner

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
            ("Source UUID", "source_uuid", False),
            ("Scan Status", "scan_status", True),
            ("Audit State", "audit_state", False),
            ("Tags", "tags", False), # Will handle conversion to list
        ]

        self.inspector_vars = {}
        row = 0
        for label_text, attr, read_only in self.fields:
            ttk.Label(inspector_frame, text=label_text).grid(row=row, column=0, sticky=tk.W, pady=2)
            var = tk.StringVar()
            if read_only:
                entry = ttk.Entry(inspector_frame, textvariable=var, state="readonly", width=40)
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

if __name__ == "__main__":
    app = Application()
    app.mainloop()
