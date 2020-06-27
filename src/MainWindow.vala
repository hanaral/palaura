public class Palaura.MainWindow : Hdy.Window {
    private Hdy.HeaderBar headerbar;
    private Hdy.HeaderBar fauxheaderbar;
    private Hdy.Leaflet leaflet;
    private Gtk.Stack stack;
    private Gtk.SearchEntry search_entry;
    private Gtk.Stack button_stack;
    private Gtk.Button return_button;
    private Gtk.Switch mode_switch;
    private Palaura.SearchView search_view;
    private Palaura.NormalView normal_view;
    private Palaura.DefinitionView definition_view;
    private Gtk.ListBox view;
    private Gtk.ListBox bkview;
    private Gee.LinkedList<View> return_history;

    string[] recents = {};
    string[] bookmarks = {};

    public MainWindow(Gtk.Application app) {
        Object (application: app,
                title: "Palaura");

        search_entry.activate.connect (() => {
            trigger_search ();

            recents += search_entry.text;
            Palaura.Application.gsettings.set_strv("recents", recents);

            var viewbox = new Palaura.RecentsRow (search_entry.text);
            view.add (viewbox);
        });
        search_entry.key_press_event.connect ((event) => {
            if (event.keyval == Gdk.Key.Escape) {
                search_entry.text = "";
                return true;
            }
            return false;
        });

        search_entry.grab_focus_without_selecting();

        search_view.show_definition.connect (show_definition);
        normal_view.show_definition.connect (show_definition);

        return_button.clicked.connect (on_return_clicked);

        key_press_event.connect ((e) => {
            uint keycode = e.hardware_keycode;
            if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                if (match_keycode (Gdk.Key.q, keycode)) {
                    this.destroy ();
                }
            }
            return false;
        });

        if (Palaura.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
            Palaura.Application.gsettings.set_boolean("dark-mode", true);
            mode_switch.visible = false;
        } else if (Palaura.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
            Palaura.Application.gsettings.set_boolean("dark-mode", false);
            mode_switch.visible = true;
        }

        Palaura.Application.grsettings.notify["prefers-color-scheme"].connect (() => {
            if (Palaura.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                Palaura.Application.gsettings.set_boolean("dark-mode", true);
                mode_switch.visible = false;
            } else if (Palaura.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                Palaura.Application.gsettings.set_boolean("dark-mode", false);
                mode_switch.visible = true;
            }
        });

        if (Palaura.Application.gsettings.get_boolean("dark-mode")) {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            this.get_style_context ().add_class ("palaura-window-dark");
            this.get_style_context ().remove_class ("palaura-window");
            search_view.get_style_context ().add_class ("palaura-view-dark");
            search_view.get_style_context ().remove_class ("palaura-view");
            normal_view.get_style_context ().add_class ("palaura-view-dark");
            normal_view.get_style_context ().remove_class ("palaura-view");
            definition_view.get_style_context ().add_class ("palaura-view-dark");
            definition_view.get_style_context ().remove_class ("palaura-view");
            stack.get_style_context ().add_class ("palaura-view-dark");
            stack.get_style_context ().remove_class ("palaura-view");
            headerbar.get_style_context ().add_class ("palaura-toolbar-dark");
            headerbar.get_style_context ().remove_class ("palaura-toolbar");
        } else {
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            this.get_style_context ().remove_class ("palaura-window-dark");
            this.get_style_context ().add_class ("palaura-window");
            search_view.get_style_context ().add_class ("palaura-view");
            search_view.get_style_context ().remove_class ("palaura-view-dark");
            normal_view.get_style_context ().add_class ("palaura-view");
            normal_view.get_style_context ().remove_class ("palaura-view-dark");
            definition_view.get_style_context ().add_class ("palaura-view");
            definition_view.get_style_context ().remove_class ("palaura-view-dark");
            stack.get_style_context ().add_class ("palaura-view");
            stack.get_style_context ().remove_class ("palaura-view-dark");
            headerbar.get_style_context ().add_class ("palaura-toolbar");
            headerbar.get_style_context ().remove_class ("palaura-toolbar-dark");
        }

        Palaura.Application.gsettings.changed.connect (() => {
            if (Palaura.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                this.get_style_context ().add_class ("palaura-window-dark");
                this.get_style_context ().remove_class ("palaura-window");
                search_view.get_style_context ().add_class ("palaura-view-dark");
                search_view.get_style_context ().remove_class ("palaura-view");
                normal_view.get_style_context ().add_class ("palaura-view-dark");
                normal_view.get_style_context ().remove_class ("palaura-view");
                definition_view.get_style_context ().add_class ("palaura-view-dark");
                definition_view.get_style_context ().remove_class ("palaura-view");
                stack.get_style_context ().add_class ("palaura-view-dark");
                stack.get_style_context ().remove_class ("palaura-view");
                headerbar.get_style_context ().add_class ("palaura-toolbar-dark");
                headerbar.get_style_context ().remove_class ("palaura-toolbar");
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                this.get_style_context ().remove_class ("palaura-window-dark");
                this.get_style_context ().add_class ("palaura-window");
                search_view.get_style_context ().add_class ("palaura-view");
                search_view.get_style_context ().remove_class ("palaura-view-dark");
                normal_view.get_style_context ().add_class ("palaura-view");
                normal_view.get_style_context ().remove_class ("palaura-view-dark");
                definition_view.get_style_context ().add_class ("palaura-view");
                definition_view.get_style_context ().remove_class ("palaura-view-dark");
                stack.get_style_context ().add_class ("palaura-view");
                stack.get_style_context ().remove_class ("palaura-view-dark");
                headerbar.get_style_context ().add_class ("palaura-toolbar");
                headerbar.get_style_context ().remove_class ("palaura-toolbar-dark");
            }
        });
    }

#if VALA_0_42
    protected bool match_keycode (uint keyval, uint code) {
#else
    protected bool match_keycode (int keyval, uint code) {
#endif
        Gdk.KeymapKey [] keys;
        Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
        if (keymap.get_entries_for_keyval (keyval, out keys)) {
            foreach (var key in keys) {
                if (code == key.keycode)
                    return true;
                }
            }

        return false;
    }

    public void show_definition (Core.Definition definition) {
        definition_view.set_definition (definition);
        push_view (definition_view);
    }

    construct {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/lainsce/palaura/stylesheet.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        if (Palaura.Application.gsettings.get_boolean("dark-mode")) {
            this.get_style_context ().add_class ("palaura-window-dark");
            this.get_style_context ().remove_class ("palaura-window");
        } else {
            this.get_style_context ().remove_class ("palaura-window-dark");
            this.get_style_context ().add_class ("palaura-window");
        }

        search_entry = new Gtk.SearchEntry ();
        search_entry.placeholder_text = _("Search words…");

        button_stack = new Gtk.Stack ();
        return_button = new Gtk.Button.with_label (_("Home"));
        return_button.get_style_context ().add_class ("back-button");
        button_stack.add (return_button);
        button_stack.no_show_all = true;

        var dlabel = new Gtk.Label (_("Dark Mode:"));
        dlabel.halign = Gtk.Align.END;
        mode_switch = new Gtk.Switch ();
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.halign = Gtk.Align.START;
        Palaura.Application.gsettings.bind ("dark-mode", mode_switch, "active", SettingsBindFlags.DEFAULT);
        mode_switch.has_focus = false;

        var label = new Gtk.Label (_("Lookup language:"));
        label.halign = Gtk.Align.END;
        var lang = new Gtk.ComboBoxText ();
        lang.append_text (_("English"));
        lang.append_text (_("Spanish"));
        lang.append_text (_("Hindi"));
        var dict_lang = Palaura.Application.gsettings.get_string("dict-lang");

        switch (dict_lang) {
            case "en":
                lang.active = 0;
                break;
            case "es":
                lang.active = 1;
                break;
            case "hi":
                lang.active = 2;
                break;
            default:
                lang.active = 0;
                break;
        }
        lang.changed.connect (() => {
            switch (lang.active) {
                case 0:
                    Palaura.Application.gsettings.set_string("dict-lang", "en");
                    break;
                case 1:
                    Palaura.Application.gsettings.set_string("dict-lang", "es");
                    break;
                case 2:
                    Palaura.Application.gsettings.set_string("dict-lang", "hi");
                    break;
            }
        });

        var dark_header = new Granite.HeaderLabel (_("Interface"));
        var dict_header = new Granite.HeaderLabel (_("Dictionary"));

        var settings_grid = new Gtk.Grid ();
        settings_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_grid.column_homogeneous = true;
        settings_grid.column_spacing = 6;
        settings_grid.margin = 12;
        settings_grid.attach (dark_header, 0, 0, 1, 1);
        settings_grid.attach (dlabel, 0, 1, 1, 1);
        settings_grid.attach (mode_switch, 1, 1, 1, 1);
        settings_grid.attach (dict_header, 0, 2, 1, 1);
        settings_grid.attach (label, 0, 4, 1, 1);
        settings_grid.attach (lang, 1, 4, 1, 1);
        settings_grid.show_all ();

        var settings_pop = new Gtk.Popover (null);
        settings_pop.add (settings_grid);

        var menu_button = new Gtk.MenuButton ();
        menu_button.has_tooltip = true;
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
        menu_button.tooltip_text = _("Settings");
        menu_button.popover = settings_pop;

        headerbar = new Hdy.HeaderBar ();
        headerbar.set_size_request (-1,45);
        headerbar.show_close_button = true;
        headerbar.set_decoration_layout (":maximize");
        headerbar.set_title (_("Palaura"));
        headerbar.has_subtitle = false;
        headerbar.pack_start (button_stack);
        headerbar.pack_start (search_entry);
        headerbar.pack_end (menu_button);

        search_view = new Palaura.SearchView();
        normal_view = new Palaura.NormalView();
        definition_view = new Palaura.DefinitionView();
        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.add (normal_view);
        stack.add (search_view);
        stack.add (definition_view);

        view = new Gtk.ListBox ();
        view.hexpand = true;
        view.margin_start = 6;
        view.margin_bottom = 12;

        var no_tasks = new Gtk.Label (_("No Recents…"));
        no_tasks.halign = Gtk.Align.CENTER;
        var no_tasks_style_context = no_tasks.get_style_context ();
        no_tasks_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
        no_tasks_style_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        no_tasks.margin = 12;
        no_tasks.show_all ();
        view.set_placeholder (no_tasks);

        view.row_selected.connect ((row) => {
            search_entry.text = ((Palaura.RecentsRow)row).title;
            trigger_search ();
        });

        var bk_button = new Gtk.Button ();
        bk_button.tooltip_text = _("Bookmark Word");
        bk_button.image = new Gtk.Image.from_icon_name ("star-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        bkview = new Gtk.ListBox ();
        bkview.hexpand = true;
        bkview.margin_start = 6;
        bkview.margin_bottom = 12;

        var bkno_tasks = new Gtk.Label (_("No Bookmarks…"));
        bkno_tasks.halign = Gtk.Align.CENTER;
        var bkno_tasks_style_context = bkno_tasks.get_style_context ();
        bkno_tasks_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
        bkno_tasks_style_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        bkno_tasks.margin = 12;
        bkno_tasks.show_all ();
        bkview.set_placeholder (bkno_tasks);

        foreach (var b in Palaura.Application.gsettings.get_strv("bookmarks")) {
            bookmarks += b;
            var viewbox = new Palaura.BookmarkRow (b);
            bkview.add (viewbox);
        }

        bk_button.clicked.connect (() => {
            bookmarks += search_entry.text;
            Palaura.Application.gsettings.set_strv("bookmarks", bookmarks);

            var viewbox = new Palaura.BookmarkRow (search_entry.text);
            bkview.add (viewbox);
        });

        bkview.row_selected.connect ((row) => {
            search_entry.text = ((Palaura.BookmarkRow)row).title;
            trigger_search ();
        });

        var rec_label = new Gtk.Label (null);
        rec_label.tooltip_text = _("Recents will only show searched words in this session.");
        rec_label.use_markup = true;
        rec_label.halign = Gtk.Align.START;
        rec_label.margin = 6;
        rec_label.margin_start = 15;
        rec_label.label = _("<span weight=\"bold\">RECENTS</span>");

        var bk_label = new Gtk.Label (null);
        bk_label.tooltip_text = _("Bookmarks will show saved words.");
        bk_label.use_markup = true;
        bk_label.halign = Gtk.Align.START;
        bk_label.margin = 6;
        bk_label.margin_start = 15;
        bk_label.label = _("<span weight=\"bold\">BOOKMARKS</span>");

        var bk_remove_all_button = new Gtk.Button ();
        bk_remove_all_button.tooltip_text = _("Clean Bookmarks");
        bk_remove_all_button.image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        bk_remove_all_button.clicked.connect (() => {
            foreach (Gtk.Widget item in bkview.get_children ()) {
                item.destroy ();
            }
            bookmarks = null;
            Palaura.Application.gsettings.set_strv("bookmarks", null);
        });

        var bk_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        bk_box.add(bk_label);
        bk_box.add(bk_button);
        bk_box.add(bk_remove_all_button);

        fauxheaderbar = new Hdy.HeaderBar ();
        fauxheaderbar.show_close_button = true;
        fauxheaderbar.has_subtitle = false;
        fauxheaderbar.title = null;
        fauxheaderbar.set_decoration_layout ("close:");
        fauxheaderbar.get_style_context ().add_class ("palaura-recents");

        var outline_grid = new Gtk.Grid ();
        outline_grid.get_style_context ().add_class ("palaura-recents");
        outline_grid.hexpand = false;
        outline_grid.vexpand = true;
        outline_grid.set_size_request (251, -1);
        outline_grid.attach (rec_label, 0, 0, 1, 1);
        outline_grid.attach (view, 0, 1, 1, 1);
        outline_grid.attach (bk_box, 0, 2, 1, 1);
        outline_grid.attach (bkview, 0, 3, 1, 1);
        outline_grid.show_all ();

        var side_grid = new Gtk.Grid ();
        side_grid.attach (fauxheaderbar, 0, 0, 1, 1);
        side_grid.attach (outline_grid, 0, 1, 1, 1);
        side_grid.show_all ();

        var main_grid = new Gtk.Grid ();
        main_grid.attach (headerbar, 0, 0, 1, 1);
        main_grid.attach (stack, 0, 1, 1, 1);
        main_grid.show_all ();

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        var separator_cx = separator.get_style_context ();
        separator_cx.add_class ("vsep");

        leaflet = new Hdy.Leaflet ();
        leaflet.add (side_grid);
        leaflet.add (separator);
        leaflet.add (main_grid);
        leaflet.transition_type = Hdy.LeafletTransitionType.UNDER;
        leaflet.show_all ();
        leaflet.can_swipe_back = true;
        leaflet.set_visible_child (main_grid);

        leaflet.child_set_property (separator, "allow-visible", false);

        leaflet.notify["folded"].connect (() => {
            update ();
        });

        add (leaflet);

        return_history = new Gee.LinkedList<Palaura.View> ();

        int x = Palaura.Application.gsettings.get_int("window-x");
        int y = Palaura.Application.gsettings.get_int("window-y");
        int w = Palaura.Application.gsettings.get_int("window-w");
        int h = Palaura.Application.gsettings.get_int("window-h");

        if (x != -1 && y != -1) {
            move (x, y);
        }

        if (w != -1 && h != -1) {
            resize (w, h);
        }

        set_size_request (360, 435);
    }

    private void update () {
        if (leaflet != null && leaflet.get_folded ()) {
            // On Mobile size, so.... have to have no buttons anywhere.
            fauxheaderbar.set_decoration_layout (":");
            headerbar.set_decoration_layout (":");
        } else {
            // Else you're on Desktop size, so business as usual.
            fauxheaderbar.set_decoration_layout ("close:");
            headerbar.set_decoration_layout (":maximize");
        }
    }

    private void trigger_search () {
        unowned string search = search_entry.text;
        if (search.length < 2) {
            if (stack.get_visible_child () == search_view) {
                pop_view ();
            }
        } else {
            if (stack.get_visible_child () != search_view)
                push_view (search_view);
                search_view.search(search_entry.text);

                recents += search_entry.text;
                for (int i=0; i <= 5; i++)
                    Palaura.Application.gsettings.set_strv("recents", recents);
        }
    }

    private void push_view (Palaura.View new_view) {

        if(return_history.is_empty) {
            button_stack.no_show_all = false;
            button_stack.show_all ();
        }

        View old_view = stack.get_visible_child () as View;
        return_history.offer_head (old_view);
        stack.set_visible_child (new_view);
        return_button.label = old_view.get_header_name ();
    }

    private void pop_view () {
        if(!return_history.is_empty) {
            View previous_view = return_history.poll_head ();
            stack.set_visible_child (previous_view);

            if(!return_history.is_empty)
                return_button.label = return_history.peek_head ().get_header_name ();
            else {
                button_stack.hide();
            }
        }
        else {
            return_button.label = _("Home");
            button_stack.hide();
        }
    }

    private void on_return_clicked() {
        if(stack.get_visible_child() == search_view) {
            search_entry.text = "";
        }

        pop_view ();
    }

    public override bool delete_event (Gdk.EventAny event) {
        int x, y;
        get_position (out x, out y);
        int w, h;
        get_size (out w, out h);
        Palaura.Application.gsettings.set_int("window-x", x);
        Palaura.Application.gsettings.set_int("window-y", y);
        Palaura.Application.gsettings.set_int("window-w", w);
        Palaura.Application.gsettings.set_int("window-h", h);
        Palaura.Application.gsettings.set_strv("recents", null);
        Palaura.Application.gsettings.set_strv("bookmarks", bookmarks);
        return false;
    }
}
