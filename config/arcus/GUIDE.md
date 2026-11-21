# Setting up a machine with arcus

How to install a machine from this repository, what to do right after, how to bring an existing Arch install under arcus, and the commands used day to day. Keep it current: when something changes how a machine gets set up, change it here too.

## Install from the Arch ISO

1. **Make the USB stick:** write the [Arch ISO](https://archlinux.org/download/) to it.
2. **Boot the ISO** (UEFI or BIOS both work) and get online: wired works by itself; for Wi-Fi run `iwctl`, then `station wlan0 connect <network>`.
3. **Download the installer** from the latest release and start it; `arcus` must sit next to it:
   ```sh
   curl -LO https://github.com/grunclepug/arcus/releases/latest/download/arcus-install
   curl -LO https://github.com/grunclepug/arcus/releases/latest/download/arcus
   chmod +x arcus-install arcus && ./arcus-install
   ```
   To try a build that isn't released, copy both files from `bin/` (after `make build`) onto a second stick, mount it (`mkdir -p /mnt/usb && mount /dev/sdX1 /mnt/usb`) and run `/mnt/usb/arcus-install`.
4. **Answer the screens.** For this repository:
   - Dotfiles: `https://github.com/grunclepug/dot`, clone to `~/builds/dot` (arcus config stays `config/arcus`).
   - Profile: `laptop` or `pc`, or `t3box` for the headless box (its own section below); add a theme (`h2o`, `aurora` or `nebula`), `dwm` for an X11 fallback session, and anything else the profile leaves out. `machine` is always on.
   - 32-bit packages: yes (steam needs them).
   - Swap: zram, unless the machine should hibernate. With dotfiles, zram needs the machine module, which the installer writes, so nothing else to pick.
5. **Review**, then `r` to run; type the disk name to confirm. `s` only saves the plan (`/root/plan.toml`); `arcus-install run /root/plan.toml` runs it later.
6. When it says `Installed.`: `poweroff`, remove the sticks, boot.

If the install stops, its log is in `/tmp/arcus-install.log` on the ISO; after a finished install it is in `/var/log/arcus-install.log`.

## Right after the install

1. Log in on the TTY and start a session: `startw` for stream, or `startx` for dwm where it's on.
2. **Monitors**, in the session: `wmon` saves each one at its native resolution and highest refresh rate, where it is now; kanshi applies that from then on. If they're in the wrong order, arrange them first (`wlr-randr --output DP-3 --left-of DP-2`), then `wmon` again.
3. **Git identity**, kept on the machine (this repository is public):
   ```sh
   touch ~/.gitconfig     # first, so --global writes here and not into dot
   git config --global user.name "<name>"
   git config --global user.email "<email>"
   ```
4. **GitHub sign-in**, once per machine: `gh auth login` (GitHub.com, HTTPS, web browser). Pushing then needs no token.
5. **Syncthing**, set up by hand: open `http://127.0.0.1:8384`, add the other devices, and share `~/Sync` (PC, laptop, phone, t3box) and `~/code` (PC, laptop, t3box). Leave *auto accept* off for every device, so a folder another device offers can't land in a stray directory. On the t3box and the PC, give both folders *trash can* versioning, kept 30 days: Syncthing keeps a copy only of what *another* device changed, so the PC (catching up when it wakes) keeps what the t3box's agents delete, and the t3box, always on, keeps what you delete.
6. **AUR packages:** approvals come with dot (`aurlock/home/.config/aurlock/approved`), so `arcus apply` installs every approved AUR package without asking; aurlock prompts only for packages nobody has approved yet.
7. **Shared drive** (share module): save the TrueNAS login root-only, then `/mnt/share` mounts when opened:
   ```sh
   sudo install -d -m 700 /etc/samba/credentials
   printf 'username=grunclepug\npassword=%s\n' "$(read -rsp 'Password: ' p; echo "$p")" | sudo install -m 600 /dev/stdin /etc/samba/credentials/andromeda
   ```
8. **Rust** (dev module): `rustup default stable && rustup component add rust-analyzer`; rustup installs no toolchain by itself, and Neovim uses its rust-analyzer.
9. **Coding agents:** install Claude Code, Codex and agy with their own installers. Each puts itself in `~/.local/bin` (already on PATH through `.bashrc`) and updates itself (`claude update`, `codex update`, `agy update`). Installers like to append a PATH line to `~/.bashrc` or `~/.bash_profile`, which are dot's files: afterwards, `git -C ~/builds/dot status`, and revert any such line before it gets committed.
10. **Neovim:** the first start installs the plugins and the other language servers; let it finish.
11. **Check:** `arcus doctor` says no problems, `arcus plan` says nothing to do.
12. Sign in to the apps (Steam, Discord, Obsidian with its vault in `~/Sync`).

## The t3box

The always-on headless machine: agents run there through T3 Code, in a stream session with no monitor where they can run and screenshot the GUIs they build, and it keeps Syncthing's versions, so the PC can sleep. Nobody logs in at it, so it has no keyring; the T3 server and the CLIs keep their secrets in files.

1. **Install** with profile `t3box` and a theme (VNC and screenshots show it); no dwm, no 32-bit packages. Disk encryption asks for its passphrase at boot, so an unattended reboot stops there.
2. **SSH:** `ssh-copy-id <host>` from the PC and the laptop; everything after this works over SSH.
3. **The usual steps:** 3 to 9 and 11 of "Right after the install". Syncthing's GUI is on the box's loopback: `ssh -L 8385:localhost:8384 <host>`, then `http://localhost:8385`. The installer skips AUR packages nobody has approved yet, so run `arcus apply` once and review `wlrctl` at aurlock's prompt. `gh auth login` and the agents' sign-ins (`claude auth login`, `codex login --device-auth`) give a URL and a code for another device.
4. **Linger**, so the session and T3 run with nobody logged in: `sudo loginctl enable-linger "$USER"`, then `systemctl --user status stream-headless wayvnc`.
5. **T3 Code:** `t3 up --connect` installs the server as a user service and signs it in to T3 Connect with a URL and a code; turn on approval for new devices, then approve each one with `t3 auth connect-device approve <code>`. Then `t3 browser setup` and `t3 service protect` (they ask for sudo where they need it). So agents find the session, add these lines to `~/.t3/service.env` and `t3 service restart`:
   ```sh
   WAYLAND_DISPLAY=wayland-stream
   XDG_SESSION_TYPE=wayland
   ```
6. **Watch or take over the session** from another machine: `ssh -L 5900:localhost:5900 <host>`, then a VNC client on `localhost:5900`.
7. **Check after a reboot**, without logging in: `t3 status`, the units from step 4, and `grim /tmp/shot.png` from an agent's shell.

T3's version is t3code-bin's, from aurlock: `update` moves the service to a new one (it asks, since that stops running agent turns). Never `t3 update`, which installs a release aurlock hasn't seen. For a test GPU, `arcus machine` and `arcus apply` with the card in, and again once it's out.

## Bring an existing Arch install under arcus

The result is the same machine as a fresh install of the profile.

```sh
git clone https://github.com/grunclepug/dot ~/builds/dot
mkdir -p ~/.config && ln -s ~/builds/dot/config/arcus ~/.config/arcus
curl -LO https://github.com/grunclepug/arcus/releases/latest/download/arcus
sudo install -m 755 arcus /usr/local/bin/arcus && rm arcus   # or build it from a clone, see "Update arcus"
arcus machine        # writes /etc/arcus/modules/machine from this system
arcus on pc          # the profile; takes over what is already installed, installs the rest
arcus on h2o         # a theme, if the profile has none
arcus clean          # removes what no module lists (read its plan first)
```

Then do the steps of "Right after the install" that the machine doesn't have yet. AUR packages another helper installed stay outside aurlock until you adopt them: `aurlock list` shows them, and `aurlock install <pkg>...` reviews and rebuilds them.

## Cheat sheet

### arcus

| Command | Does |
|---------|------|
| `arcus ls` | Profiles and modules, by category: on or off, stack rank, why it's on |
| `arcus plan` | What `apply` would do; changes nothing |
| `arcus apply` | Makes the machine match the host file (asks first; `-y` doesn't) |
| `arcus on <module or profile>` | Turns it on and records it in the host file; a conflicting module (another theme) is swapped out |
| `arcus off <module or profile>` | Turns it off: removes what it installed or took over, unless another module lists it or it's protected (`-f` also turns off what requires it) |
| `arcus clean` | Removes packages no module lists, marks the rest's install reasons (shows its plan first) |
| `arcus doctor` | Checks state, files and the host file; lists packages no module lists; reports a stale machine module and units, groups and AUR approvals no module lists; `-fix` repairs what is safe |
| `arcus machine` | Writes this machine's module again (kernel, bootloader, filesystems, swap) |
| `arcus update` | Replaces arcus with the latest release, checksum-verified; `doctor` says when one is out |
| `arcus rebuild <package>` | Builds an own build again although its recipe didn't change |
| `arcus new` / `rm` / `mv` | Creates, deletes or renames a module |
| `arcus history` | The latest entries of the state history: each command that changed the machine, with dot's commit (`*`: dot had uncommitted changes) |
| `arcus rollback <entry>` | Puts the host file's profiles and modules back as of an entry and applies them (shows the plan and asks, like `apply`); it doesn't change dot |

`-n` shows the plan without asking or doing anything.

### Day to day

- **Edit a file a module deploys in `$HOME`:** edit it in `~/builds/dot`; it's a link, so the change is live. Commit and push.
- **Add or remove a module's file, change `module.toml`, or edit a system file (`system/`):** then `arcus apply`.
- **Turn a module on or off:** `arcus on <module>` / `arcus off <module>`. It only changes this machine; dot changes only when a module or profile does.
- **Monitors changed** (another monitor, another desk, a new arrangement): arrange them with `wlr-randr` if needed, then `wmon`. It keeps the profiles for other sets of monitors.
- **Switch theme:** `arcus on h2o` (or `aurora`, `nebula`), then log out and back in.
- **Own builds** (`pkg/<name>/PKGBUILD`): change the recipe and `arcus apply` rebuilds it; bump `_commit` and `pkgver` together to update.
- **System updates:** `update`: it pulls dot (for the other machine's aurlock approvals), runs `sudo pacman -Syu`, `rustup update stable`, `aurlock upgrade` and the agent CLIs' own updates, commits and pushes new approvals, and ends with what `arcus plan` says; it never runs `arcus apply`. It stops if dot has other uncommitted work. `aurlock outdated` lists AUR updates that are waiting. When an update ends with rebuild-detector listing packages, they are linked against a library that's gone: `arcus rebuild <package>` for own builds; `checkrebuild` lists them again.
- **AUR packages:** a module's new AUR package gets reviewed at aurlock's prompt during `arcus apply` (`-y` skips it until it's approved). Approving writes into dot: commit `approved` and push, and `git pull` brings it to the other machine. aurlock's README has a cheatsheet.
- **Firmware updates** (base module): `fwupdmgr refresh`, then `fwupdmgr get-updates` and `fwupdmgr update`; BIOS updates install on the next reboot.
- **Update arcus:** `arcus update` installs the latest release. On a machine with a clone (`~/code/go/arcus` where you write code, `~/builds/arcus` elsewhere; building needs `go` from the `dev` module): `git pull && make build && sudo make install` in it (build as yourself, install with sudo).
- **Undo a change:** `arcus history` lists the entries; `arcus rollback <entry>` goes back to the state after that entry, so to undo the latest command, roll back to the one before it. It restores which modules are on, not what they contained: if it says dot has moved on since, check out dot's commit from then (`git -C ~/builds/dot log`) to see the modules as they were.
- **Release arcus:** bump `VERSION` in `config.mk`, commit, `git tag v<version> && git push origin master v<version>`; CI tests, builds and publishes the release.

### Where things are

| Path | What |
|------|------|
| `~/builds/dot/config/arcus` (`~/.config/arcus` links here) | Modules, profiles |
| `~/.local/state/arcus/host.toml` | This machine: its profile and its own modules (not in dot) |
| `~/.config/aurlock/approved` (links to `modules/aurlock/home/.config/aurlock/approved`) | AUR approvals, tracked in dot |
| `/etc/arcus/modules/machine` | The machine module (root-owned, not in dot) |
| `/etc/samba/credentials/andromeda` | The shared drive's login (root-only, not in dot) |
| `~/.local/share/arcus/modules` | This machine's own modules, such as `trial` for packages being tried out (not in dot) |
| `~/.config/kanshi/config` | This machine's monitor profiles, written by `wmon` (not in dot) |
| `~/.config/theme` | The active theme's shared colours (`colors.sh`, `colors.css`, `Xresources`); each app's own sit next to its config, such as `~/.config/foot/theme.ini` |
| `~/Pictures/wallpaper.png` | The active theme's wallpaper, if it has one (the file it replaced is kept as `wallpaper.png.orig`) |
| `~/.local/state/arcus`, `/var/lib/arcus` | What arcus has done (state, ledgers) |
| `~/.local/state/arcus/history` | The state history, a git repository only you can read (not in dot; `rm -rf` it to drop the history) |
| `~/.cache/arcus` | Own builds: their packages and sources |
| `/var/log/arcus-install.log` | The install log |
