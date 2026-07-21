import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import datetime
import os
import uuid
import shutil
from typing import Optional

from app.catalog import CatalogManager
from app.scanner import Scanner
from app.models import Source
from app.constants import AUDIT_STATES
from app.preview import AssetPreviewPanel
from app.source_panel import SourcePanel

class Application(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Asset Trace")
        self.geometry("1024x768")
        self.manager: Optional[CatalogManager] = None
        self.current_asset = None

        self._build_ui()

    def _build_ui(self):
        # Top Toolbar
        toolbar_frame = ttk.Frame(self, padding=5)
        toolbar_frame.pack(side=tk.TOP, fill=tk.X)

        # Application Menu
        menubar = tk.Menu(self)
        self.config(menu=menubar)

        project_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Project", menu=project_menu)
        project_menu.add_command(label="Sources...", command=self._open_sources_dialog, state=tk.DISABLED)
        self.project_menu = project_menu

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

        # QW-001: Status Bar — packed BOTTOM before main_paned so it anchors correctly
        status_bar = ttk.Frame(self, relief=tk.SUNKEN, padding=(4, 2))
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)

        self.status_left = ttk.Label(status_bar, text="No project loaded", anchor=tk.W)
        self.status_right = ttk.Label(status_bar, text="", anchor=tk.E)

        status_bar.columnconfigure(0, weight=1)
        status_bar.columnconfigure(1, weight=0)

        self.status_left.grid(row=0, column=0, sticky=tk.W, padx=(6, 12), pady=2)
        self.status_right.grid(row=0, column=1, sticky=tk.E, padx=(12, 6), pady=2)

        # Main content area
        main_paned = ttk.PanedWindow(self, orient=tk.HORIZONTAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        # Left: Asset List
        list_frame = ttk.Frame(main_paned)
        main_paned.add(list_frame, weight=2)

        columns = ("display_name", "relative_path", "scan_status", "audit_state", "source")
        self.tree = ttk.Treeview(list_frame, columns=columns, show="headings")
        self.tree.heading("display_name", text="Name")
        self.tree.heading("relative_path", text="Path")
        self.tree.heading("scan_status", text="Status")
        self.tree.heading("audit_state", text="Audit State")  # V2-001
        self.tree.heading("source", text="Source")            # V2-001

        self.tree.column("display_name", width=140)
        self.tree.column("relative_path", width=200)
        self.tree.column("scan_status", width=75)
        self.tree.column("audit_state", width=100)  # V2-001
        self.tree.column("source", width=150)       # V2-001

        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.tree.yview)
        self.tree.configure(yscroll=scrollbar.set)

        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.tree.bind('<<TreeviewSelect>>', self._on_select_asset)

        # Right: Inspector
        inspector_frame = ttk.Frame(main_paned, padding=5)
        main_paned.add(inspector_frame, weight=1)

        # Asset Fields mapping
        # Label text, attr_name, read_only
        self.fields = [
            # QW-004: asset_uuid removed from Inspector (remains in model and JSON)
            ("Name", "display_name", False),
            ("Relative Path", "relative_path", True),
            ("SHA-256", "sha256", True),       # QW-004: displayed truncated, Copy button
            ("File Size", "file_size", True),  # QW-004: displayed as human-readable
            ("Type", "asset_type", True),      # QW-004: converted to read-only
            ("Scan Status", "scan_status", True),
            ("Audit State", "audit_state", False),
            ("Tags", "tags", False),
        ]

        self.inspector_vars = {}
        row = 0
        for label_text, attr, read_only in self.fields:
            ttk.Label(inspector_frame, text=label_text).grid(row=row, column=0, sticky=tk.W, pady=2)
            var = tk.StringVar()

            if attr == "audit_state":
                self.audit_state_combo = ttk.Combobox(inspector_frame, textvariable=var, width=38, state="readonly", values=AUDIT_STATES)
                self.audit_state_combo.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
                self.audit_state_combo.bind("<<ComboboxSelected>>", lambda e: self._on_field_edit("audit_state", var))
                var.trace_add("write", lambda *args, a=attr, v=var: self._on_field_edit(a, v))
            elif attr == "sha256":  # QW-004: truncated display + Copy button
                sha_frame = ttk.Frame(inspector_frame)
                sha_frame.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
                sha_frame.columnconfigure(0, weight=1)
                sha_entry = ttk.Entry(sha_frame, textvariable=var, state="readonly", width=20)
                sha_entry.grid(row=0, column=0, sticky=tk.EW)
                self.copy_sha_btn = ttk.Button(sha_frame, text="Copy", width=6, command=self._copy_sha)
                self.copy_sha_btn.grid(row=0, column=1, padx=(4, 0))
            elif read_only:
                entry = ttk.Entry(inspector_frame, textvariable=var, state="readonly", width=40)
                entry.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
            else:
                entry = ttk.Entry(inspector_frame, textvariable=var, width=40)
                var.trace_add("write", lambda *args, a=attr, v=var: self._on_field_edit(a, v))
                entry.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)

            self.inspector_vars[attr] = var
            row += 1

        ttk.Separator(inspector_frame, orient=tk.HORIZONTAL).grid(row=row, column=0, columnspan=2, sticky=tk.EW, pady=10)
        row += 1

        # Preview — V2-003: moved above Source to reflect natural identification flow
        ttk.Label(inspector_frame, text="Preview").grid(row=row, column=0, sticky=tk.NW, pady=2)

        # Will be initialized after project load
        self.preview_panel = None
        self.preview_container = ttk.Frame(inspector_frame, width=256, height=256)
        self.preview_container.grid(row=row, column=1, sticky=tk.NW, pady=2, padx=5)
        row += 1

        ttk.Separator(inspector_frame, orient=tk.HORIZONTAL).grid(row=row, column=0, columnspan=2, sticky=tk.EW, pady=10)
        row += 1

        # Embedded Source Panel
        self.source_panel = SourcePanel(inspector_frame, None, on_source_changed=self._on_source_assigned_to_asset, on_manage_sources=self._open_sources_dialog)  # V2-002
        self.source_panel.grid(row=row, column=0, columnspan=2, sticky=tk.EW, pady=2, padx=5)
        row += 1

        ttk.Separator(inspector_frame, orient=tk.HORIZONTAL).grid(row=row, column=0, columnspan=2, sticky=tk.EW, pady=10)
        row += 1

        ttk.Label(inspector_frame, text="Notes").grid(row=row, column=0, sticky=tk.NW, pady=2)
        self.notes_text = tk.Text(inspector_frame, height=5, width=40)
        self.notes_text.grid(row=row, column=1, sticky=tk.EW, pady=2, padx=5)
        self.notes_text.bind("<<Modified>>", self._on_notes_edit)

        inspector_frame.columnconfigure(1, weight=1)

        # QW-005: Welcome screen — shown when no project is open
        self.welcome_frame = ttk.Frame(main_paned)
        self.welcome_label = ttk.Label(
            self.welcome_frame,
            text='No project open.\nUse "Open Project" to begin.',
            justify=tk.CENTER,
            anchor=tk.CENTER,
        )
        self.welcome_label.place(relx=0.5, rely=0.5, anchor=tk.CENTER)
        main_paned.add(self.welcome_frame, weight=3)

        # Handle window close
        self.protocol("WM_DELETE_WINDOW", self._on_closing)

        # QW-005: show welcome on startup
        self._show_welcome()

    # --- QW-005 ---

    def _show_welcome(self):
        """Show the welcome screen and hide list + inspector panes."""
        main_paned = self.welcome_frame.master
        for pane in main_paned.panes():
            widget = self.nametowidget(pane)
            if widget is not self.welcome_frame:
                main_paned.forget(widget)
        if str(self.welcome_frame) not in [str(p) for p in main_paned.panes()]:
            main_paned.add(self.welcome_frame, weight=3)

    def _hide_welcome(self):
        """Hide the welcome screen and restore list + inspector panes."""
        main_paned = self.welcome_frame.master
        pane_names = [str(p) for p in main_paned.panes()]

        if str(self.welcome_frame) in pane_names:
            main_paned.forget(self.welcome_frame)

        list_frame = self.tree.master
        inspector_frame = self.source_panel.master

        if str(list_frame) not in [str(p) for p in main_paned.panes()]:
            main_paned.add(list_frame, weight=2)
        if str(inspector_frame) not in [str(p) for p in main_paned.panes()]:
            main_paned.add(inspector_frame, weight=1)

    # --- end QW-005 ---

    # --- QW-001 ---

    def _update_status_bar(self):
        """Central method — recalculates and updates all status bar counters."""
        if not self.manager:
            self.status_left.config(text="No project loaded")
            self.status_right.config(text="")
            return

        assets = self.manager.get_assets()
        total    = len(assets)
        new      = sum(1 for a in assets if a.scan_status == "NEW")
        modified = sum(1 for a in assets if a.scan_status == "MODIFIED")
        missing  = sum(1 for a in assets if a.scan_status == "MISSING")
        no_src   = sum(1 for a in assets if not a.source_uuid)

        project_name = self.manager.catalog.project.name or "Unnamed Project"

        self.status_left.config(
            text=(
                f"{project_name}  |  "
                f"Total: {total}  |  "
                f"NEW: {new}  |  "
                f"MODIFIED: {modified}  |  "
                f"MISSING: {missing}  |  "
                f"Without Source: {no_src}"
            )
        )

    # --- end QW-001 ---

    # --- QW-004 ---

    def _format_file_size(self, size: int) -> str:
        """Returns a human-readable file size string."""
        if size < 1024:
            return f"{size} B"
        elif size < 1024 * 1024:
            return f"{size / 1024:.1f} KB"
        else:
            return f"{size / (1024 * 1024):.1f} MB"

    def _get_full_sha(self) -> str:
        """Returns the most current SHA-256 hash for the selected asset."""
        if not self.current_asset:
            return ""
        current = getattr(self.current_asset, '_current_sha256', "")
        return current if current else self.current_asset.sha256

    def _copy_sha(self):
        """Copies the full SHA-256 hash to the clipboard."""
        full_sha = self._get_full_sha()
        if full_sha:
            self.clipboard_clear()
            self.clipboard_append(full_sha)

    # --- end QW-004 ---

    # --- V2-001 ---

    def _get_source_label(self, source_uuid: str) -> str:
        """Returns a human-readable label for a source_uuid, or — if none."""
        if not source_uuid or not self.manager:
            return "—"
        sources = self.manager.get_sources()
        source = next((s for s in sources if s.source_uuid == source_uuid), None)
        if not source:
            return "—"
        parts = [p for p in (source.product_name, source.store_name) if p]
        return " — ".join(parts) if parts else f"Unnamed ({source_uuid[:8]})"

    # --- end V2-001 ---

    def _on_closing(self):
        if hasattr(self, 'preview_panel') and self.preview_panel:
            self.preview_panel.cleanup()
        self.destroy()

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
        self.project_menu.entryconfig("Sources...", state=tk.NORMAL)

        self._hide_welcome()  # QW-005
        self.status_right.config(text="")  # QW-002: clear event message from previous project
        self.source_panel.manager = self.manager

        # Init preview panel
        for widget in self.preview_container.winfo_children():
            widget.destroy()
        self.preview_panel = AssetPreviewPanel(self.preview_container, project_dir)
        self.preview_panel.pack(fill=tk.BOTH, expand=True)

        self._refresh_list()
        self._update_status_bar()  # QW-001

    def _scan(self):
        if not self.manager:
            return

        scanner = Scanner(self.manager)
        try:
            scanner.scan()
            self._refresh_list()
            self._update_status_bar()  # QW-001
            assets = self.manager.get_assets()
            new      = sum(1 for a in assets if a.scan_status == "NEW")
            modified = sum(1 for a in assets if a.scan_status == "MODIFIED")
            missing  = sum(1 for a in assets if a.scan_status == "MISSING")
            self.status_right.config(  # QW-002
                text=f"Scan completed \u2014 {new} NEW, {modified} MODIFIED, {missing} MISSING"
            )
            self.update_idletasks()
        except Exception as e:
            messagebox.showerror("Scan Error", str(e))

    def _save(self):
        if not self.manager:
            return
        try:
            # Normalize invalid legacy audit_states before save
            for asset in self.manager.get_assets():
                if asset.audit_state not in AUDIT_STATES:
                    asset.audit_state = "PLACEHOLDER"

            self.manager.save()

            # Store current selection to restore it
            selected_iid = None
            if self.tree.selection():
                selected_iid = self.tree.selection()[0]

            # Refresh UI after save to show updated values (promoted hashes/sizes)
            self._refresh_list()

            if selected_iid and self.tree.exists(selected_iid):
                self.tree.selection_set(selected_iid)
                self.tree.see(selected_iid)

            self._populate_inspector()
            self._update_status_bar()  # QW-001
            ts = datetime.datetime.now().strftime("%H:%M")
            self.status_right.config(text=f"Catalog saved — {ts}")  # QW-002 — written last
            self.update_idletasks()

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
                asset.scan_status,
                asset.audit_state,                              # V2-001
                self._get_source_label(asset.source_uuid),     # V2-001
            ))

    def _on_select_asset(self, event):
        selected = self.tree.selection()
        if not selected:
            self.current_asset = None
            return

        rel_path = selected[0]
        self.current_asset = self.manager.get_asset_by_path(rel_path)

        self._populate_inspector()

    def _on_source_assigned_to_asset(self, source_uuid):
        if self.current_asset:
            self.current_asset.source_uuid = source_uuid
            self._update_status_bar()  # QW-001
            # V2-001: update the list row immediately without full refresh
            iid = self.current_asset.relative_path
            if self.tree.exists(iid):
                self.tree.set(iid, "source", self._get_source_label(source_uuid))

    def _populate_inspector(self):
        if not self.current_asset:
            return

        for attr, var in self.inspector_vars.items():
            val = getattr(self.current_asset, attr)

            if attr == "sha256":  # QW-004: show truncated, manage Copy button state
                full_sha = self._get_full_sha()
                if full_sha:
                    var.set(full_sha[:12] + "...")
                    self.copy_sha_btn.config(state=tk.NORMAL)
                else:
                    var.set("—")
                    self.copy_sha_btn.config(state=tk.DISABLED)
                continue
            elif attr == "file_size":  # QW-004: human-readable size
                current_size = getattr(self.current_asset, '_current_file_size', 0)
                raw_size = current_size if current_size > 0 else val
                var.set(self._format_file_size(raw_size))
                continue
            elif attr == "tags":
                val = ", ".join(val)

            var.set(str(val))

        self.source_panel.set_source(self.current_asset.source_uuid)

        self.notes_text.delete("1.0", tk.END)
        self.notes_text.insert(tk.END, self.current_asset.notes)
        self.notes_text.edit_modified(False) # reset modified flag

        if hasattr(self, 'preview_panel') and self.preview_panel:
            self.preview_panel.show_preview(self.current_asset)

    def _on_field_edit(self, attr_name, var):
        if not self.current_asset:
            return

        val = var.get()
        if attr_name == "tags":
            # Handle comma separated tags
            tags_list = [t.strip() for t in val.split(",") if t.strip()]
            setattr(self.current_asset, attr_name, tags_list)
        elif attr_name == "audit_state":
            # Normalize to PLACEHOLDER if invalid
            if val not in AUDIT_STATES:
                val = "PLACEHOLDER"
            setattr(self.current_asset, attr_name, val)
            self._update_status_bar()  # QW-001
            # V2-001: update the list row immediately without full refresh
            iid = self.current_asset.relative_path
            if self.tree.exists(iid):
                self.tree.set(iid, "audit_state", val)
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

        panel = SourcePanel(dialog, self.manager)
        panel.pack(fill=tk.BOTH, expand=True)
        panel.set_source("") # Initialize the list
        # We need to refresh in case source changes happen here and we close

        def on_close():
            self._populate_inspector()
            dialog.destroy()

        dialog.protocol("WM_DELETE_WINDOW", on_close)

if __name__ == "__main__":
    app = Application()
    app.mainloop()