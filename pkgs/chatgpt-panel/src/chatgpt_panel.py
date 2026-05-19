#!/usr/bin/env python3
import argparse
import os
import socket
import sys
import threading
from pathlib import Path

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
gi.require_version("WebKit", "6.0")

from gi.repository import GLib, Gtk, Gtk4LayerShell, WebKit  # noqa: E402


APP_ID = "dev.kane.ChatGPTPanel"
DEFAULT_URL = "https://chatgpt.com/"
BOTTOM_MARGIN = 10
CORNER_RADIUS = 6
RIGHT_MARGIN = 10
TOP_MARGIN = 10


def xdg_runtime_dir() -> Path:
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime:
        return Path(runtime)
    return Path(f"/run/user/{os.getuid()}")


def xdg_data_dir() -> Path:
    data = os.environ.get("XDG_DATA_HOME")
    if data:
        return Path(data)
    return Path.home() / ".local" / "share"


class Panel(Gtk.Application):
    def __init__(self, width: int, url: str):
        super().__init__(application_id=APP_ID)
        self.width = width
        self.url = url
        self.window = None
        self.webview = None
        self.socket_path = xdg_runtime_dir() / "chatgpt-panel.sock"
        self._server_socket = None
        self._server_thread = None

    def do_startup(self):
        Gtk.Application.do_startup(self)
        self._start_ipc()

    def do_activate(self):
        if self.window is None:
            self.window = self._create_window()
        self.show_panel()

    def _create_window(self):
        window = Gtk.ApplicationWindow(application=self)
        window.set_title("ChatGPT Panel")
        window.set_default_size(self.width, 800)
        window.connect("close-request", self._hide_on_close)

        Gtk4LayerShell.init_for_window(window)
        Gtk4LayerShell.set_namespace(window, "chatgpt-panel")
        Gtk4LayerShell.set_layer(window, Gtk4LayerShell.Layer.TOP)
        Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.RIGHT, True)
        Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.TOP, True)
        Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.BOTTOM, True)
        Gtk4LayerShell.set_anchor(window, Gtk4LayerShell.Edge.LEFT, True)
        Gtk4LayerShell.set_margin(window, Gtk4LayerShell.Edge.TOP, TOP_MARGIN)
        Gtk4LayerShell.set_margin(window, Gtk4LayerShell.Edge.RIGHT, RIGHT_MARGIN)
        Gtk4LayerShell.set_margin(window, Gtk4LayerShell.Edge.BOTTOM, BOTTOM_MARGIN)
        Gtk4LayerShell.set_keyboard_mode(window, Gtk4LayerShell.KeyboardMode.ON_DEMAND)

        root = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        root.add_css_class("root")

        dismiss_area = Gtk.Box()
        dismiss_area.set_hexpand(True)
        dismiss_area.set_vexpand(True)
        dismiss_area.add_css_class("dismiss-area")

        outside_click = Gtk.GestureClick.new()
        outside_click.connect("pressed", self._hide_on_outside_click)
        dismiss_area.add_controller(outside_click)

        panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        panel.set_size_request(self.width, -1)
        panel.set_overflow(Gtk.Overflow.HIDDEN)
        panel.set_vexpand(True)
        panel.set_hexpand(False)
        panel.add_css_class("panel")
        panel.append(self._create_webview())

        root.append(dismiss_area)
        root.append(panel)
        window.set_child(root)
        self._install_css(window)

        return window

    def _create_webview(self):
        data_root = xdg_data_dir() / "chatgpt-panel"
        data_root.mkdir(parents=True, exist_ok=True)

        session = WebKit.NetworkSession.new(
            str(data_root / "data"),
            str(data_root / "cache"),
        )
        session.set_persistent_credential_storage_enabled(True)

        cookie_manager = session.get_cookie_manager()
        cookie_manager.set_accept_policy(WebKit.CookieAcceptPolicy.ALWAYS)
        cookie_manager.set_persistent_storage(
            str(data_root / "cookies.sqlite3"),
            WebKit.CookiePersistentStorage.SQLITE,
        )

        settings = WebKit.Settings()
        settings.set_enable_developer_extras(True)
        settings.set_javascript_can_access_clipboard(True)
        settings.set_enable_write_console_messages_to_stdout(False)

        self.webview = WebKit.WebView(network_session=session)
        self.webview.set_settings(settings)
        self.webview.set_vexpand(True)
        self.webview.set_hexpand(True)
        self.webview.load_uri(self.url)
        return self.webview

    def _install_css(self, window):
        provider = Gtk.CssProvider()
        css = """
            window,
            .root,
            .dismiss-area {
              background: transparent;
            }

            .panel {
              background: #303446;
              border-left: 1px solid #51576d;
              border-radius: %dpx;
            }
            """ % CORNER_RADIUS
        provider.load_from_data(css.encode("utf-8"))

        Gtk.StyleContext.add_provider_for_display(
            window.get_display(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    def _hide_on_close(self, _window):
        self.hide_panel()
        return True

    def _hide_on_outside_click(self, _gesture, _n_press, _x, _y):
        self.hide_panel()

    def show_panel(self):
        if self.window is None:
            self.window = self._create_window()
        self.window.present()

    def hide_panel(self):
        if self.window is not None:
            self.window.set_visible(False)

    def toggle_panel(self):
        if self.window is None or not self.window.get_visible():
            self.show_panel()
        else:
            self.hide_panel()

    def _start_ipc(self):
        try:
            if self.socket_path.exists():
                self.socket_path.unlink()

            self._server_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self._server_socket.bind(str(self.socket_path))
            self._server_socket.listen(8)
        except OSError as exc:
            print(f"chatgpt-panel: failed to start IPC: {exc}", file=sys.stderr)
            return

        self._server_thread = threading.Thread(target=self._ipc_loop, daemon=True)
        self._server_thread.start()

    def _ipc_loop(self):
        while True:
            try:
                conn, _ = self._server_socket.accept()
            except OSError:
                return

            with conn:
                command = conn.recv(1024).decode("utf-8", "replace").strip()
                if command == "show":
                    GLib.idle_add(self.show_panel)
                elif command == "hide":
                    GLib.idle_add(self.hide_panel)
                elif command == "toggle":
                    GLib.idle_add(self.toggle_panel)
                elif command == "reload":
                    GLib.idle_add(self.webview.reload)
                elif command == "quit":
                    GLib.idle_add(self.quit)
                conn.sendall(b"ok\n")

    def do_shutdown(self):
        if self._server_socket is not None:
            self._server_socket.close()
        try:
            self.socket_path.unlink()
        except FileNotFoundError:
            pass
        Gtk.Application.do_shutdown(self)


def parse_args():
    parser = argparse.ArgumentParser(description="ChatGPT right-side layer-shell panel")
    parser.add_argument("--width", type=int, default=620, help="panel width in pixels")
    parser.add_argument("--url", default=DEFAULT_URL, help="URL to load")
    return parser.parse_args()


def main():
    args = parse_args()
    app = Panel(width=args.width, url=args.url)
    raise SystemExit(app.run([sys.argv[0]]))


if __name__ == "__main__":
    main()
