<div align="center">

# Mend

### Your gentle healing companion

*Track your days, understand your feelings, and find support that feels human.*

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)](#)
[![Privacy](https://img.shields.io/badge/Privacy-Local%20First-purple.svg)](#)

</div>

---

## Demo

https://github.com/user-attachments/assets/1500c51a-a39c-4cc3-95b3-abf284f9bbef

---

## Screenshots

<p align="center">
  <!-- Replace with your actual simulator screenshots (Cmd+S in Xcode Simulator) -->
  <img src=".github/assets/welcome.png" width="22%" alt="Welcome">
  <img src=".github/assets/home.png" width="22%" alt="Home">
  <img src=".github/assets/chat.png" width="22%" alt="Chat">
  <img src=".github/assets/calm.png" width="22%" alt="Calm Space">
</p>

---

## What is Mend?

Mend is a private, local-first iOS wellness app for people who want a softer place to process their feelings. It combines daily mood check-ins, AI-powered reflections, a guided journal, and a calm space for moments of anxiety — all stored privately on your device.

---

## Features

**Daily check-ins**
Log how you feel each day with a mood picker and optional notes. Mend tracks patterns over time and shows you a gentle weekly snapshot.

**AI companion — Talk to Mend**
Have a real conversation with an AI that listens without judgment. Powered by OpenAI via a secure backend proxy — your messages are never stored by Mend.

**Journal**
Write freely, record voice entries, or log gratitudes. Your journal stays entirely on your device using SwiftData.

**Calm Space**
A dedicated screen for moments of overwhelm. Includes guided breathing, the 5-4-3-2-1 grounding technique, a private vent pad, a drawing canvas, and a direct link to the **988 Suicide & Crisis Lifeline**.

**Personal setup**
Choose your name, healing focus, and daily reminder time during a gentle onboarding flow. Everything adapts to feel like *your* Mend.

---

## Privacy

- All mood entries, journal entries, and profile data are stored **locally on your device** using SwiftData
- AI features send only aggregated mood counts and your nickname to OpenAI — never raw journal text
- No account required, no tracking, no third-party analytics
- [Privacy Policy](https://shehanish.github.io/Mend/privacy-policy.html)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | MVVM |
| Local storage | SwiftData |
| AI | OpenAI API via Cloudflare Workers proxy |
| Notifications | UserNotifications (local only) |
| Voice | AVFoundation + Speech framework (on-device) |

---

## Running Locally

1. **Clone the repo**
   ```bash
   git clone https://github.com/shehanish/Mend.git
   cd Mend
   ```

2. **Open in Xcode**
   Open `Mend.xcodeproj`

3. **Configure the API key** *(optional — only needed for AI features)*

   The app uses a Cloudflare Workers proxy by default. To run AI features locally:
   - Duplicate `Mend/Config/Secrets.example.xcconfig` → rename to `Secrets.xcconfig`
   - Add your OpenAI key: `MYAPI_KEY = sk-your-key-here`
   - In `AppConfig.swift`, set `proxyURL = nil` to call OpenAI directly

4. **Build and run**
   Select a simulator or device → `Cmd + R`

---

## Project Structure

```
Mend/
├── AI/                  OpenAI service + insight models
├── Config/              AppConfig, xcconfig files
├── Data/Repositories/   SwiftData repositories (mood, journal)
├── Models/              MoodEntry, JournalEntry, ChatMessage
├── ViewModel/           HomeViewModel, ChatViewModel, JournalViewModel...
└── Views/
    ├── Components/      Reusable views (HomeView, MoodPicker, BlobAvatar...)
    ├── AuthView         Onboarding flow
    ├── ChatView         AI chat
    ├── JournalView      Journal + history
    ├── PanicRoomView    Calm Space
    └── SettingsView     Notifications + preferences
```

---

## Crisis Resources

Mend includes a direct link to the **988 Suicide & Crisis Lifeline** (call or text 988) in the Calm Space tab. If you or someone you know is in crisis, please reach out.

---

<div align="center">
  <sub>Built with care · Your thoughts are yours</sub>
</div>
