# CoverLetterGen
![App Screenshot](screenshots/Screenshot.png)

An AI-powered iPad application that generates tailored cover letters using SwiftUI and SwiftData.

## Features
- **Privacy-First**: Your personal profile data (Name, Contact, Address) is stored **locally** and never sent to OpenAI. It is added to the letter on-device.
- **Smart Generation**: Uses OpenAI's **GPT-4o** to write professional, artifact-free cover letters.
- **Comprehensive Profile**: Support for Portfolio URLs, Country, and detailed contact info.
- **Easy Sharing**: precise text sharing to let you continue editing on any device.
- **Local History**: Auto-saves all generated letters to SwiftData.
- **iPad Optimized**: 3-column layout for maximum productivity.

## Tech Stack
- **Language**: Swift 6 (Strict Concurrency)
- **UI Framework**: SwiftUI (NavigationSplitView, MVVM)
- **Persistence**: SwiftData
- **Networking**: URLSession async/await
- **AI**: OpenAI API

## Setup
1. Clone the repository.
2. Open `CoverLetterGen.xcodeproj` (or the folder in Swift Playgrounds).
3. Run on iPad Simulator or Device.
4. Tap the **Settings** (gear icon) in the sidebar to enter your OpenAI API Key.

## Requirements
- iOS/iPadOS 17.0+
- Xcode 15+
