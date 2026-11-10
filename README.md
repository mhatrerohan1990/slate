# Slate

A tiny, plain-text editor for macOS. No rich text, no formatting toolbar, no auto-corrections. Just type.

## Features

- Plain text only, saved as UTF-8
- New, Open, Save, Save As (⇧⌘S), Print (⌘P)
- Native tabs, autosave and restore of unsaved documents
- Find (⌘F)
- Appearance: System, Light or Dark (View menu)
- Word wrap toggle, font size with ⌘+, ⌘- and ⌘0
- Smart quotes, auto-dashes and auto-correct are off

Settings (appearance, font size, word wrap) are remembered between launches.

## Requirements

- macOS 14 or later
- Swift 6 toolchain. The Xcode Command Line Tools are enough (`xcode-select --install`); full Xcode is not needed.

## Build

```bash
./build.sh
```

This compiles a release build with Swift Package Manager and assembles `build/Slate.app` (ad-hoc signed).

Run it without installing:

```bash
open build/Slate.app
```

## Install

```bash
./build.sh
rm -rf /Applications/Slate.app
cp -R build/Slate.app /Applications/
```

Then open it from Spotlight (⌘Space, "Slate") or Launchpad. To keep it in the Dock, right-click its icon and choose Options → Keep in Dock.

To update after changing the code, run the same three commands again. If Slate is running, quit it first (`pkill -x Slate`).

### Make it the default for `.txt` files

In Finder, right-click a `.txt` file, choose **Get Info**, set **Open with** to Slate, then click **Change All…**. Repeat for other extensions you want.

### Gatekeeper

An app you build yourself is not quarantined, so it opens normally. If you copy the app to another Mac, macOS will warn about an unidentified developer. Right-click the app and choose Open, or run:

```bash
xattr -dr com.apple.quarantine /Applications/Slate.app
```

Distributing it without that warning requires signing with an Apple Developer ID and notarizing.

## Project layout

```
Package.swift             Swift package definition
Sources/Slate/
  SlateApp.swift          App entry point, menus and settings
  TextDoc.swift           Plain-text document model (read/write)
  PlainTextView.swift     NSTextView wrapper (editing, find, wrap, font)
Resources/
  Info.plist              Bundle metadata and file-type declarations
  AppIcon.icns            App icon
tools/make-icon.swift     Draws the app icon
build.sh                  Builds build/Slate.app
```

## Regenerating the icon

The icon is drawn in code. After editing `tools/make-icon.swift`:

```bash
swift tools/make-icon.swift
iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
./build.sh
```

If Finder or the Dock still shows the old icon, run `killall Dock Finder`.
