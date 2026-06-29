# Mend - Breakup Recovery & No Contact Tracker

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Enabled-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)

**Mend** is a specialized iOS application built with SwiftUI, designed to support users navigating the difficult emotions of a breakup. It provides a safe, interactive environment to track healing milestones, maintain boundaries, process feelings via AI, and manage sudden waves of anxiety or grief.

## ✨ Key Features

* 🚫 **No Contact Counter:** A dedicated breakup tracker to help you stay focused on your healing journey, counting the days since you last contacted your ex to encourage space and recovery.

* 🤖 **AI Emotional Support & Affirmations:** Chat in real-time with an empathetic AI companion powered by OpenAI that:
  * **Listens & Validates:** Engages in meaningful conversations to help you process your feelings and emotions
  * **Offers Affirmations & Self-Love:** Delivers compassionate affirmations tailored to your emotional state and healing journey
  * **Mood Tracking & Reflection:** Helps you explore your emotional patterns and understand what you're feeling
  * **Supportive Guidance:** Suggests healthy perspectives and positive reframing to work through difficult moments
  * **Safe Space to Express:** Provides a judgment-free companion to help you navigate complex emotions

* ❤️‍🩹 **The Panic Room:** An interactive, immediate safe space designed to alleviate sudden anxiety attacks or overwhelming urges to reach out. It includes:
  * 🌬️ **Guided Breathing:** Visual, paced breathing animations (Inhale/Exhale) to calm your nervous system
  * 🧘‍♀️ **Grounding Techniques:** The 5-4-3-2-1 mindfulness exercise to bring you back to the present moment
  * 🎨 **Distraction Pad:** A simple, built-in canvas for doodling your mind away from the stress
  * 📝 **Private Vent Space:** A secure text box to type out unsaid thoughts or texts you shouldn't send (content is intentionally never saved)
  * 🆘 **Emergency Lifelines:** Quick-action buttons to instantly dial or text crisis support (911, Crisis Text Line, 988 Lifeline) and personal contacts

* 🔒 **Local Privacy:** Built with SwiftData to ensure personal mood logs, journal entries, and AI conversations remain strictly private and secure on-device.

## 📸 Screenshots

<!-- Example:
<img src="link_to_screenshot_1" width="200"/> <img src="link_to_screenshot_2" width="200"/> <img src="link_to_screenshot_3" width="200"/>
-->

## 🛠 Tech Stack

* **Language:** Swift 5.9+
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel) + Components
* **Database:** SwiftData (Local persistence)
* **AI & APIs:** OpenAI API (for empathetic AI conversations, affirmations, and emotional support)
* **Frameworks:** AVFoundation (for soothing soundscapes), ContactsUI

## ⚙️ Requirements

* Xcode 15.0 or later
* iOS 17.0 or later
* An active OpenAI API Key (for the AI Emotional Support feature)

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/Mend-iosapp.git
   cd Mend-iosapp
   ```

2. **Open the project in Xcode:**
   Open the `Mend-iosapp.xcodeproj` or `.xcworkspace` file in Xcode.

3. **Configure the OpenAI API Key:**
   This project uses an `.xcconfig` file to keep API keys secure.
   * In the `Config` folder, locate `Secrets.example.xcconfig`.
   * Duplicate this file and rename the copy to `Secrets.xcconfig`.
   * Open `Secrets.xcconfig` and add your OpenAI API key:
     ```xcconfig
     MYAPI_KEY = sk-your_actual_openai_api_key_here
     ```
   *(Note: Build settings are automatically mapped to the Info.plist and read via `AppConfig.swift`).*

4. **Build and Run:**
   * Select your target device or simulator (iPhone 15 recommended).
   * Press `Cmd + R` or click the Play button to build and run the app!

## 📂 Project Structure

This project follows a clean **MVVM architecture**:
* `Models/`: Data structures representing Core entities (MoodEntry, ChatMessage, AffirmationLog, etc.).
* `Views/`: SwiftUI views defining the user interface.
  * `Components/`: Reusable, smaller view components (e.g., `PanicRoomComponents.swift`, `ChatComponents.swift`, `AffirmationView.swift`) to keep code modular.
* `ViewModel/`: Handles the presentation logic, state management, and acts as a bridge between Views and Data.
* `Data/Repositories/`: Protocol-oriented data access layers handling `SwiftData` operations.
* `AI/`: Services interacting with the OpenAI API for generating empathetic responses and affirmations to support emotional processing.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/Mend-iosapp/issues) if you want to contribute.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
