public class Palaura.MainWindow : Hdy.Window {

    private Hdy.HeaderBar headerbar;
    private Gtk.Stack stack;
    private Gtk.SearchEntry search_entry;
    private Gtk.Stack button_stack;
    private Gtk.Button return_button;
    public Granite.ModeSwitch mode_switch;

    private Palaura.SearchView search_view;
    private Palaura.NormalView normal_view;
    private Palaura.DefinitionView definition_view;

    private Gtk.TreeIter root;
    private Gtk.TreeStore store;

    private Gee.LinkedList<View> return_history;

    string[] recents = {};

    public MainWindow(Gtk.Application app) {
        Object (application: app,
                title: "Palaura");

        search_entry.activate.connect (() => {
            trigger_search ();

            recents += search_entry.text;
            for (int i=0; i <= 5; i++)
                Palaura.Application.gsettings.set_strv("recents", recents);

            store.clear ();
            foreach (var r in recents) {
                store.insert (out root, null, -1);
                store.set (root, 0, r, -1);
            }
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
        search_entry.placeholder_text = _("Search words");

        button_stack = new Gtk.Stack ();
        return_button = new Gtk.Button.with_label (_("Home"));
        return_button.get_style_context ().add_class ("back-button");
        button_stack.add (return_button);
        button_stack.no_show_all = true;

        mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
        mode_switch.primary_icon_tooltip_text = _("Light Mode");
        mode_switch.secondary_icon_tooltip_text = _("Dark Mode");
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.has_focus = false;

        if (Palaura.Application.gsettings.get_boolean("dark-mode")) {
            mode_switch.active = true;
        } else {
            mode_switch.active = false;
        }

        mode_switch.notify["active"].connect (() => {
            if (mode_switch.active) {
                debug ("Get dark!");
                Palaura.Application.gsettings.set_boolean("dark-mode", true);
            } else {
                debug ("Get light!");
                Palaura.Application.gsettings.set_boolean("dark-mode", false);
            }
        });

        var label = new Gtk.Label (_("Lookup language:"));
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


        var settings_grid = new Gtk.Grid ();
        settings_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_grid.column_homogeneous = true;
        settings_grid.column_spacing = 6;
        settings_grid.margin = 12;
        settings_grid.attach (label, 0, 2, 1, 1);
        settings_grid.attach (lang, 1, 2, 1, 1);
        settings_grid.show_all ();

        var settings_pop = new Gtk.Popover (null);
        settings_pop.add (settings_grid);

        var menu_button = new Gtk.MenuButton ();
        menu_button.has_tooltip = true;
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        menu_button.tooltip_text = _("Settings");
        menu_button.popover = settings_pop;

        headerbar = new Hdy.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.set_title (_("Palaura"));
        headerbar.has_subtitle = false;
        headerbar.pack_start (button_stack);
        headerbar.set_custom_title (search_entry);
        headerbar.pack_end (menu_button);
        headerbar.pack_end (mode_switch);

        headerbar.get_style_context ().add_class ("palaura-toolbar");

        search_view = new Palaura.SearchView();
        normal_view = new Palaura.NormalView();
        definition_view = new Palaura.DefinitionView();
        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.add (normal_view);
        stack.add (search_view);
        stack.add (definition_view);

        var view = new Gtk.TreeView ();
        view.expand = true;
        view.hexpand = true;
        view.headers_visible = false;
        view.activate_on_single_click = true;

        var crt = new Gtk.CellRendererText ();
        crt.font = "Inter 10";
        crt.ellipsize = Pango.EllipsizeMode.END;

        view.insert_column_with_attributes (-1, "Outline", crt, "text", 0);

        store = new Gtk.TreeStore (1, typeof (string));
        view.set_model (store);

        store.clear ();
        foreach (var r in Palaura.Application.gsettings.get_strv("recents")) {
            store.insert (out root, null, -1);
            store.set (root, 0, r, -1);
        }
        view.expand_all ();

        var selection = view.get_selection ();
        selection.set_mode (Gtk.SelectionMode.SINGLE);

        view.button_press_event.connect ((widget, event) => {
            //capture which mouse button
            uint clicked_button;
            event.get_button(out clicked_button);
			//handle right button click for context menu
            if (event.get_event_type ()  == Gdk.EventType.BUTTON_PRESS  &&  clicked_button == 1){
                Gtk.TreePath path; Gtk.TreeViewColumn column; int cell_x; int cell_y;
		        view.get_path_at_pos ((int)event.x, (int)event.y, out path, out column, out cell_x, out cell_y);
		        view.grab_focus ();
                view.set_cursor (path, column, false);

				selchanged (selection);
			}
			return false;
        });

        var rec_label = new Gtk.Label (null);
        rec_label.use_markup = true;
        rec_label.halign = Gtk.Align.START;
        rec_label.margin = 6;
        rec_label.label = _("<span size=\"xx-large\">Recents</span>");

        var outline_grid = new Gtk.Grid ();
        outline_grid.get_style_context ().add_class ("palaura-recents");
        outline_grid.hexpand = false;
        outline_grid.vexpand = false;
        outline_grid.set_size_request (150, -1);
        outline_grid.attach (rec_label, 0, 0, 1, 1);
        outline_grid.attach (view, 0, 1, 1, 1);
        outline_grid.show_all ();

        var main_grid = new Gtk.Grid ();
        main_grid.attach (headerbar, 0, 0, 2, 1);
        main_grid.attach (outline_grid, 0, 1, 1, 1);
        main_grid.attach (stack, 1, 1, 1, 1);
        main_grid.show_all ();

        add (main_grid);

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

    public void selchanged (Gtk.TreeSelection row) {
        Gtk.TreeModel pathmodel;
        Gtk.TreeIter pathiter;
        if (row.count_selected_rows () == 1){
            row.get_selected (out pathmodel, out pathiter);
            Value val;
            pathmodel.get_value (pathiter, 0, out val);

            search_entry.text = val.get_string ();
        }
    }

    private void trigger_search () {
        unowned string search = search_entry.text;
        if (search.length < 2) {
            if (stack.get_visible_child () == search_view) {
                pop_view ();
            }
        } else {
            if (stack.get_visible_child () != search_view) push_view (search_view);
                search_view.search(search_entry.text);
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
        return false;
    }
}
