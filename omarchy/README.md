# Omarchy theme support

This fork makes Telegram Desktop follow the current [Omarchy](https://omarchy.org) theme.

On start, and whenever `omarchy theme set` runs, Telegram applies
`~/.local/state/omarchy/current/theme/telegram.tdesktop-theme`. Omarchy renders
that file from the template in this folder, so install the template once:

```bash
cp omarchy/telegram.tdesktop-theme.tpl ~/.config/omarchy/themed/
omarchy theme set "$(omarchy theme current)"
```

Remove the template to turn it off. `omarchy/check.sh` renders the template for
every installed Omarchy theme and checks syntax and text contrast.

## Build on Arch / Omarchy

The change is two files, so the Arch package recipe plus a patch is enough:

```bash
git diff dev omarchy-theme -- Telegram/SourceFiles > /tmp/omarchy.patch
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/telegram-desktop.git
cd telegram-desktop && mv /tmp/omarchy.patch .
cat >> PKGBUILD <<'PKG'
prepare() {
  patch -Np1 -d "tdesktop-$pkgver-full" < "$startdir/omarchy.patch"
}
PKG
makepkg -si
```

A full build needs roughly 16 GB of free RAM and an hour or more.
