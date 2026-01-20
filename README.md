# CoverLetterGen

An intelligent, privacy-first iPad application used to generate tailored cover letters. Built with **Swift 6** and **SwiftUI**, it demonstrates modern iOS architecture patterns including **SwiftData** persistence and the **Observation** framework.

![Status](https://img.shields.io/badge/Status-Active-success)
![Platform](https://img.shields.io/badge/Platform-iPadOS-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)

## 🚀 Overview

CoverLetterGen leverages OpenAI's advanced **GPT-5.2 Responses API** to craft professional cover letters based on your resume and a target job description. It is designed with a **privacy-first architecture**, ensuring personal details (PII) are stored locally and never transmitted to external AI services.

The app features a productivity-focused 3-column layout optimized for iPad, allowing users to manage history, input data, and view results simultaneously.

## ✨ Key Features

- **Privacy-First Design**: Personal identifiers (Name, Address, Contact Info) are injected locally *after* AI generation, ensuring PII never leaves the device.
- **Advanced AI Integration**: Utilizes the **GPT-5.2 Responses API** with strict schema validation for precise control over output length and tone.
- **Robust Persistence**: Every generated letter is auto-saved to **SwiftData**, preserving not just the content but the exact context (Tone, Length settings) used to create it.
- **Smart Context Switching**: Selecting a historical letter instantly restores the application state (inputs + settings) to that point in time.
- **Modern UI/UX**:
    - **SwiftUI NavigationSplitView**: Adaptive 3-column layout.
    - **Real-time Feedback**: Dynamic UI updates using the `@Observable` macro.
    - **Interactive History**: Swipe-to-delete and instant search/filtering.

## 🛠 Technical Highlights

This project serves as a showcase for modern Swift development practices:

- **Swift 6 Concurrency**: Full adoption of strict concurrency checking, `async/await`, and Actor isolation (`@MainActor`, `actor OpenAIService`) to ensure thread safety.
- **Observation Framework**: Replaces `Combine` and `ObservableObject` with the new `@Observable` macro for more efficient and readable state management.
- **SwiftData**: Implements a clean persistence layer with `@Model` and `@Query`, demonstrating effective CRUD operations and data migration strategies.
- **Clean Architecture**:
    - **MVVM Pattern**: Distinct separation of concerns between Views, ViewModels, and Services.
    - **Dependency Injection**: Services and ViewModels are injected via the Environment for testability.
    - **Repository Pattern**: `OpenAIService` acts as a repository for remote data, abstracting API complexity.
- **Unit Testing**: robust test suite covering ViewModels and Services, including `MockURLProtocol` for deterministic networking tests.

## 📦 Tech Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Networking**: URLSession (Native async/await)
- **External API**: OpenAI (GPT-5.2 / Responses Endpoint)
- **Tools**: Xcode 15+, XCTest

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/devbyjonni/CoverLetterGen.git
   ```
2. **Open in Xcode**:
   Open `CoverLetterGen.xcodeproj`.
3. **Configure API Key**:
   - Run the app on a Simulator or Device.
   - Tap simple **Settings** (gear icon) in the toolbar.
   - Enter your OpenAI API Key (stored securely in `UserDefaults`).
4. **Build & Run**:
   Press `Cmd + R` to start.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
