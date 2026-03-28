# 🏋️ LiftLens

> **AI-powered gym form analyzer** built for the Google Gemini Hackathon.  
> Upload a workout video → get real-time form corrections powered by Gemini + Veo AI.

---

## Features

- 📹 **Video Upload** — Pick any workout clip from your device
- 🤖 **Gemini Analysis** — AI identifies form issues, scores your lift, and explains corrections
- 🎬 **Veo Video Generation** — Generates a personalized instructional correction video
- 📊 **Progress Tracking** — Track your form score over time across exercises
- 🔒 **Secure by Design** — API key never stored in source; passed at runtime only

---

## Running in Android Studio

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.11.0 |
| Dart SDK | ≥ 3.0.0 |
| Android Studio | Hedgehog (2023.1) or newer |
| Android Emulator / Physical Device | API 24+ |

### 1. Clone the repo

```bash
git clone https://github.com/Kennetha13/LiftLens.git
cd LiftLens
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Get a Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Create a new API key
3. Copy it — you'll need it in the next step

> ⚠️ **Never paste your API key into source code or commit it to git.**

### 4. Configure Android Studio Run Configuration

The API key is injected securely at run-time via `--dart-define`.

**Option A — Android Studio GUI (recommended):**

1. Open the project in Android Studio
2. Click **Edit Configurations...** (top-right run config dropdown → `Edit Configurations...`)
3. Select the `main.dart` configuration (or create one: `+` → `Flutter`)
4. In the **"Additional run args"** field, paste:
   ```
   --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
   ```
   *(Replace `YOUR_KEY_HERE` with your actual key)*
5. Click **OK**
6. Hit ▶️ **Run**

**Option B — Terminal:**

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
```

### 5. Select a Device

- In Android Studio, use the **Device Manager** to start an emulator (API 24+)
- Or plug in a physical Android device with USB debugging enabled
- Select the device from the device dropdown before running

---

## Project Structure

```
lib/
├── config.dart                  # API key & model constants (no hardcoded secrets)
├── main.dart                    # App entry point & key validation
├── theme.dart                   # Design system (colors, typography, decorations)
├── models/
│   └── analysis_result.dart     # Data model for Gemini analysis output
├── screens/
│   ├── home_screen.dart         # Dashboard with recent analyses
│   ├── upload_screen.dart       # Video picker & Gemini analysis flow
│   ├── analysis_screen.dart     # Detailed form correction results
│   ├── veo_generating_screen.dart # Veo video generation loading screen
│   ├── video_screen.dart        # Playback of Veo-generated video
│   ├── progress_screen.dart     # Form score history & trends
│   ├── profile_screen.dart      # User profile & badges
│   └── settings_screen.dart     # App preferences
├── services/
│   ├── gemini_files_service.dart # Gemini Files API (upload + analyze)
│   └── veo_service.dart         # Veo 3 video generation service
└── widgets/
    └── status_bar.dart          # Shared status bar widget
```

---

## Security Notes

- API key is read via `String.fromEnvironment('GEMINI_API_KEY')` — **never hardcoded**
- `local.properties`, `.env`, `*.keystore`, and `.idea/runConfigurations/` are all gitignored
- If you fork this repo, your key is never at risk of accidental commit

---

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Gemini 2.5 Flash** — Video analysis & form correction
- **Veo 3** — AI instructional video generation
- **Google AI Studio** — API key management

---

## License

MIT — built with ❤️ for the Google Gemini Hackathon.
