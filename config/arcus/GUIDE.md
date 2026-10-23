# Setting up a machine with arcus

How to install a machine from this repository, what to do right after, how to bring an existing Arch install under arcus, and the commands used day to day. Keep it current: when something changes how a machine gets set up, change it here too.

## Install from the Arch ISO

1. **Make the USB stick:** write the [Arch ISO](https://archlinux.org/download/) to it, then copy `arcus-install` and `arcus` onto a second stick (or a partition of the same one). Until arcus has releases on GitHub, build them on a machine that has Go: `cd ~/code/go/arcus && make build`, then copy both files from `bin/`; they must sit in the same directory.
2. **Boot the ISO** (UEFI or BIOS both work) and get online: wired works by itself; for Wi-Fi run `iwctl`, then `station wlan0 connect <network>`.
3. **Mount the stick with the binaries** and start the installer from there. Not under `/mnt`: the installer mounts the new system there.
   ```sh
   mkdir -p /root/usb && mount /dev/sdX1 /root/usb    # lsblk shows which one
   /root/usb/arcus-install
   ```
4. **Answer the screens.** For this repository:
   - Dotfiles: `https://github.com/grunclepug/dot`, clone to `~/builds/dot` (arcus config stays `config/arcus`).
   - Profile: `laptop` or `pc`; add a theme (`aurora` or `neon`) and anything else the profile leaves out. `machine` is always on.
   - 32-bit packages: yes (steam needs them).
   - Swap: zram, unless the machine should hibernate. With dotfiles, zram needs the machine module, which the installer writes, so nothing else to pick.
5. **Review**, then `r` to run; type the disk name to confirm. `s` only saves the plan (`/root/plan.toml`); `arcus-install run /root/plan.toml` runs it later.
6. When it says `Installed.`: `poweroff`, remove the sticks, boot.

If the install stops, its log is in `/tmp/arcus-install.log` on the ISO; after a finished install it is in `/var/log/arcus-install.log`.

## Right after the install

1. Log in on the TTY and start a session: `pg-river` for river, `startx` for dwm.
2. **Git identity**, kept on the machine (this repository is public):
   ```sh
   touch ~/.gitconfig     # first, so --global writes here and not into dot
   git config --global user.name "<name>"
   git config --global user.email "<email>"
   ```
3. **GitHub sign-in**, once per machine: `gh auth login` (GitHub.com, HTTPS, web browser). Pushing then needs no token.
4. **Syncthing**, set up by hand: open `http://127.0.0.1:8384`, add the other devices, and share `~/Sync` and `~/code`.
5. **Neovim:** the first start installs the plugins and the language servers; let it finish.
6. **Check:** `arcus doctor` says no problems, `arcus plan` says nothing to do.
7. Sign in to the apps (Steam, Discord, Obsidian with its vault in `~/Sync`).

## Bring an existing Arch install under arcus

The result is the same machine as a fresh install of the profile.

```sh
git clone https://github.com/grunclepug/dot ~/builds/dot
mkdir -p ~/.config && ln -s ~/builds/dot/config/arcus ~/.config/arcus
git clone https://github.com/grunclepug/arcus ~/code/go/arcus   # once arcus is on GitHub
cd ~/code/go/arcus && make build && sudo make install
arcus machine        # writes /etc/arcus/modules/machine from this system
arcus on pc          # the profile; takes over what is already installed, installs the rest
arcus on aurora      # a theme, if the profile has none
arcus clean          # removes what no module lists (read its plan first)
```

Then do the steps of "Right after the install" that the machine doesn't have yet.

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
| `arcus doctor` | Checks state, files and the host file; lists packages no module lists; `-fix` repairs what is safe |
| `arcus machine` | Writes this machine's module again (kernel, bootloader, filesystems, swap) |
| `arcus rebuild <package>` | Builds an own build again although its recipe didn't change |
| `arcus new` / `rm` / `mv` | Creates, deletes or renames a module |

`-n` shows the plan without asking or doing anything; `-host <name>` uses another machine's host file.

### Day to day

- **Edit a file a module deploys in `$HOME`:** edit it in `~/builds/dot`; it's a link, so the change is live. Commit and push.
- **Add or remove a module's file, change `module.toml`, or edit a system file (`system/`):** then `arcus apply`.
- **Switch theme:** `arcus on neon` (or `aurora`), then log out and back in.
- **Own builds** (`pkg/<name>/PKGBUILD`): change the recipe and `arcus apply` rebuilds it; bump `_commit` and `pkgver` together to update.
- **System updates:** `yay` (or `sudo pacman -Syu`) as always; arcus doesn't update packages.
- **Update arcus:** `cd ~/code/go/arcus && git pull && make build && sudo make install` (build as yourself, install with sudo).

### Where things are

| Path | What |
|------|------|
| `~/builds/dot/config/arcus` (`~/.config/arcus` links here) | Modules, profiles, host files |
| `hosts/<hostname>.toml` | This machine: its profile and its own modules |
| `/etc/arcus/modules/machine` | The machine module (root-owned, not in dot) |
| `~/.config/theme` | The active theme's colour files |
| `~/.local/state/arcus`, `/var/lib/arcus` | What arcus has done (state, ledgers) |
| `~/.cache/arcus` | Own builds: their packages and sources |
| `/var/log/arcus-install.log` | The install log |
