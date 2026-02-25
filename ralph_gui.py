import argparse
import os
import subprocess
import shutil
import sys
from pathlib import Path

def _get_version() -> str:
    base = Path(getattr(sys, '_MEIPASS', Path(__file__).parent))
    version_file = base / "VERSION"
    if version_file.exists():
        return version_file.read_text().strip()
    return "dev"

VERSION = _get_version()

import keyring
from textual.app import App, ComposeResult
from textual.containers import Horizontal
from textual.widgets import (
    Header,
    Footer,
    Button,
    Input,
    Label,
    TabbedContent,
    TabPane,
)

SERVICE_NAME = "ralph_docker_app"
IMAGE_NAME = "ralph"


# ---------------------------------------------------------------------------
# Keyring helpers
# ---------------------------------------------------------------------------

def load_keys() -> dict[str, str]:
    return {
        "anthropic_key": keyring.get_password(SERVICE_NAME, "anthropic_key") or "",
        "claude_token": keyring.get_password(SERVICE_NAME, "claude_token") or "",
    }


def save_keys(anthropic_key: str, claude_token: str) -> None:
    for name, value in [("anthropic_key", anthropic_key), ("claude_token", claude_token)]:
        if value:
            keyring.set_password(SERVICE_NAME, name, value)
        else:
            try:
                keyring.delete_password(SERVICE_NAME, name)
            except keyring.errors.PasswordDeleteError:
                pass


# ---------------------------------------------------------------------------
# Docker helpers
# ---------------------------------------------------------------------------

def docker_image_exists(image: str = IMAGE_NAME) -> bool:
    """Return True if the Docker image is already built."""
    try:
        result = subprocess.run(
            ["docker", "image", "inspect", image],
            capture_output=True,
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False


def docker_available() -> bool:
    """Return True if the docker CLI is on PATH."""
    return shutil.which("docker") is not None


# ---------------------------------------------------------------------------
# Shared Docker launch logic (used by both CLI and TUI paths)
# ---------------------------------------------------------------------------

def validate_and_run(
    workspace: str,
    iterations: str,
    anthropic_key: str,
    claude_token: str,
) -> str | None:
    """Validate inputs and run Docker. Returns an error string, or None on success."""

    # -- validate workspace ------------------------------------------------
    if not workspace:
        return "Workspace path is required."

    ws_path = Path(workspace).expanduser().resolve()
    if not ws_path.is_dir():
        return f"Not a directory: {ws_path}"

    if not (ws_path / ".ralph" / "prompt.md").exists():
        return "Workspace must contain .ralph/prompt.md"

    # -- validate auth -----------------------------------------------------
    if not anthropic_key and not claude_token:
        return (
            "No auth keys found. Run `ralph` (no arguments) to open the "
            "TUI and configure keys in the Settings tab."
        )

    # -- validate docker ---------------------------------------------------
    if not docker_available():
        return "Docker CLI not found on PATH."

    if not docker_image_exists():
        return (
            f"Docker image '{IMAGE_NAME}' not found. Build it first:\n"
            f"  docker build --target runtime -t {IMAGE_NAME} ."
        )

    # -- build command -----------------------------------------------------
    ws_mount = str(ws_path).replace("\\", "/")  # Windows path safety

    cmd = ["docker", "run", "--rm", "-it"]

    if claude_token:
        cmd.extend(["-e", "CLAUDE_CODE_OAUTH_TOKEN"])
    if anthropic_key:
        cmd.extend(["-e", "ANTHROPIC_API_KEY"])

    cmd.extend([
        "-e", "RALPH_MAX_ITERATIONS",
        "-v", f"{ws_mount}:/workspace",
        IMAGE_NAME,
    ])

    # Pass secrets via inherited env, not CLI args (avoid ps leaks).
    run_env = os.environ.copy()
    if claude_token:
        run_env["CLAUDE_CODE_OAUTH_TOKEN"] = claude_token
    if anthropic_key:
        run_env["ANTHROPIC_API_KEY"] = anthropic_key
    run_env["RALPH_MAX_ITERATIONS"] = iterations

    # -- run ---------------------------------------------------------------
    subprocess.run(cmd, env=run_env)
    return None


# ---------------------------------------------------------------------------
# TUI App
# ---------------------------------------------------------------------------

class RalphApp(App):
    """TUI to configure and launch the Ralph Docker container."""

    TITLE = "Ralph Launcher"

    CSS = """
    Screen {
        align: center middle;
    }
    TabbedContent {
        width: 80%;
        max-width: 100;
        height: auto;
        max-height: 80%;
        background: $surface;
    }
    ContentSwitcher {
        height: auto;
    }
    TabPane {
        height: auto;
        padding: 1 2;
    }
    Horizontal {
        height: auto;
        align-horizontal: right;
        margin-top: 1;
    }
    Input {
        margin-bottom: 1;
    }
    Label {
        margin-bottom: 1;
    }
    #auth_status {
        text-style: italic;
        margin-bottom: 1;
    }
    .status-ok {
        color: green;
    }
    .status-err {
        color: red;
    }
    Button {
        margin-left: 1;
    }
    """

    BINDINGS = [("q", "quit", "Quit")]

    def __init__(
        self,
        initial_workspace: str = "",
        initial_iterations: str = "",
        auto_run: bool = False,
    ):
        super().__init__()
        self._initial_workspace = initial_workspace
        self._initial_iterations = initial_iterations
        self._auto_run = auto_run

    # ---- layout ----------------------------------------------------------

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)

        with TabbedContent(initial="run_tab"):
            # --- Run tab --------------------------------------------------
            with TabPane("Run", id="run_tab"):
                yield Label("Auth Status:", id="auth_status")

                yield Label("Workspace Directory Path:")
                yield Input(
                    value=self._initial_workspace,
                    placeholder="/path/to/workspace",
                    id="workspace_input",
                )

                yield Label("Max Iterations (empty = unlimited):")
                yield Input(
                    value=self._initial_iterations,
                    placeholder="0 (unlimited)",
                    id="iterations_input",
                )

                with Horizontal():
                    yield Button("Quit", variant="error", id="btn_quit")
                    yield Button("Run", variant="success", id="btn_run")

            # --- Settings tab ---------------------------------------------
            with TabPane("Settings", id="settings_tab"):
                yield Label("Anthropic API Key:")
                yield Input(
                    password=True,
                    placeholder="sk-ant-...",
                    id="anthropic_input",
                )

                yield Label("Claude Code OAuth Token:")
                yield Input(
                    password=True,
                    placeholder="token...",
                    id="claude_input",
                )

                with Horizontal():
                    yield Button("Quit", variant="error", id="btn_quit_settings")
                    yield Button("Save Keys", variant="primary", id="btn_save")

        yield Footer()

    # ---- lifecycle -------------------------------------------------------

    def on_mount(self) -> None:
        keys = load_keys()
        self.query_one("#anthropic_input", Input).value = keys["anthropic_key"]
        self.query_one("#claude_input", Input).value = keys["claude_token"]
        self._refresh_auth_status()

        if not keys["anthropic_key"] and not keys["claude_token"]:
            self.query_one(TabbedContent).active = "settings_tab"
            self.query_one("#anthropic_input", Input).focus()
            self.notify(
                "Configure at least one auth key to get started.",
                title="Welcome",
            )
        else:
            self.query_one("#workspace_input", Input).focus()
            if self._auto_run:
                self._run_docker()

    # ---- events ----------------------------------------------------------

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "btn_save":
            self._save_settings()
        elif event.button.id == "btn_run":
            self._run_docker()
        elif event.button.id in ("btn_quit", "btn_quit_settings"):
            self.exit()

    # ---- internal --------------------------------------------------------

    def _refresh_auth_status(self) -> None:
        anthropic = self.query_one("#anthropic_input", Input).value.strip()
        claude = self.query_one("#claude_input", Input).value.strip()

        label = self.query_one("#auth_status", Label)
        parts: list[str] = []
        if anthropic:
            parts.append("Anthropic Key")
        if claude:
            parts.append("Claude Token")

        if parts:
            label.update("Auth Status: " + "  |  ".join(parts))
            label.remove_class("status-err")
            label.add_class("status-ok")
        else:
            label.update("Auth Status: No keys configured -- add them in Settings")
            label.remove_class("status-ok")
            label.add_class("status-err")

    def _save_settings(self) -> None:
        anthropic_key = self.query_one("#anthropic_input", Input).value.strip()
        claude_token = self.query_one("#claude_input", Input).value.strip()
        save_keys(anthropic_key, claude_token)
        self._refresh_auth_status()
        self.notify("Keys saved to OS keychain.", title="Saved")

    def _run_docker(self) -> None:
        workspace = self.query_one("#workspace_input", Input).value.strip()
        iters_raw = self.query_one("#iterations_input", Input).value.strip()
        anthropic_key = self.query_one("#anthropic_input", Input).value.strip()
        claude_token = self.query_one("#claude_input", Input).value.strip()

        # -- validate iterations (TUI-specific, before shared logic) -------
        if iters_raw == "":
            iterations = "0"
        elif iters_raw.isdigit() and int(iters_raw) >= 0:
            iterations = iters_raw
        else:
            self.notify(
                "Max iterations must be empty or a non-negative integer.",
                title="Validation Error",
                severity="error",
            )
            return

        # -- check auth before suspending TUI ------------------------------
        if not anthropic_key and not claude_token:
            self.query_one(TabbedContent).active = "settings_tab"
            self.query_one("#anthropic_input", Input).focus()
            self.notify(
                "No auth keys configured. Add at least one key below.",
                title="Auth Required",
                severity="error",
            )
            return

        # -- hand off TTY --------------------------------------------------
        with self.suspend():
            error = validate_and_run(workspace, iterations, anthropic_key, claude_token)
            if error:
                print(f"\n{error}")
                print("Press Enter to return to Ralph Launcher...")
                input()


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="ralph",
        description="Launch the Ralph Docker container.",
        epilog="Run with no arguments to open the interactive TUI.",
    )
    parser.add_argument(
        "-v", "--version",
        action="version",
        version=f"%(prog)s {VERSION}",
    )
    parser.add_argument(
        "workspace",
        nargs="?",
        default=None,
        help="Path to the workspace directory (must contain .ralph/prompt.md)",
    )
    parser.add_argument(
        "-i", "--iterations",
        type=int,
        default=0,
        metavar="N",
        help="Max loop iterations (default: 0 = unlimited)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.workspace:
        if args.iterations < 0:
            print("--iterations must be a non-negative integer.", file=sys.stderr)
            sys.exit(1)

        RalphApp(
            initial_workspace=args.workspace,
            initial_iterations=str(args.iterations),
            auto_run=True,
        ).run()
    else:
        RalphApp().run()


if __name__ == "__main__":
    main()
