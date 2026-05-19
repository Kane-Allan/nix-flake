#!/usr/bin/env python3
import argparse
import os
import socket
import sys
from pathlib import Path


def socket_path() -> Path:
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime:
        return Path(runtime) / "chatgpt-panel.sock"
    return Path(f"/run/user/{os.getuid()}") / "chatgpt-panel.sock"


def main():
    parser = argparse.ArgumentParser(description="Control chatgpt-panel")
    parser.add_argument(
        "command",
        nargs="?",
        default="toggle",
        choices=["show", "hide", "toggle", "reload", "quit"],
    )
    args = parser.parse_args()

    path = socket_path()
    if not path.exists():
        print("chatgpt-panel is not running", file=sys.stderr)
        return 1

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.connect(str(path))
        client.sendall(args.command.encode("utf-8"))
        print(client.recv(1024).decode("utf-8", "replace"), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
