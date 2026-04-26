# Gaming Sidekick

Gaming Sidekick is a personal game library manager for tracking what you own, what you are playing, what is finished, and what you may want to play next.

The app is built as a single-file vanilla HTML/CSS/JavaScript web app. It also includes a bundled standalone Windows EXE launcher for portable desktop use.

## Features

- Track games by platform, status, genre, priority, estimated length, release date, tags, details, and notes
- Browse your full library with filters and sorting
- Organize owned games into a backlog by priority
- Track currently playing games with quick editable notes
- Use the Play Next wizard to get recommendations from your backlog
- Manage upcoming and wishlist games
- Search the embedded game database
- Choose light/dark visual themes
- Pick a profile icon
- Store all user data locally on your device

## Run The Web App

Open `index.html` directly in a browser.

No install, build step, package manager, server, or network request is required.

## Run The Windows App

Open:

```text
Gaming Sidekick Portable/Gaming Sidekick Standalone.exe
```

The standalone EXE includes the app HTML and icon. On launch, it opens the app in an Edge or Chrome app-style window.

## Local Data

The web app stores data in browser `localStorage` under:

```text
gaming-sidekick-v1
```

The standalone Windows app creates a `Profile` folder next to the EXE. That folder contains browser profile data, including the app's saved library.

To move the portable Windows app and keep your data, move both:

```text
Gaming Sidekick Standalone.exe
Profile/
```

To reset the standalone app, close it and delete the `Profile` folder.

## Rebuild The Standalone EXE

On Windows, run:

```powershell
.\build-standalone.ps1
```

The script embeds `index.html` into `Gaming Sidekick Portable/Gaming Sidekick Standalone.exe` and applies the game controller icon.

## Tech Stack

- HTML
- CSS
- JavaScript
- Windows standalone launcher built with the .NET Framework C# compiler

## Credits

Built By Jon Kaplan with vanilla HTML, CSS, and JavaScript.

Game data sources:

- [Video Game Sales Dataset](https://github.com/Bakikhan/Video-Game-Sales-Dataset)
- [Video Game Encyclopedia](https://github.com/trung-hn/video-game-encyclopedia)
