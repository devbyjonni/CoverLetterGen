# CoverLetterGen

![Status](https://img.shields.io/badge/Status-Active-success)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![Platform](https://img.shields.io/badge/Platform-iPadOS-blue)

## 📋 Executive Summary

**CoverLetterGen** solves the friction of complying with tailored job application requirements while maintaining privacy.

In an era where generic applications are ignored, this iPad-first tool leverages **generative AI** to craft highly specific, tone-matched cover letters in seconds. Uniquely, it enforces a **Privacy-First Architecture**: sensitive personal data (PII) is injected locally on the device *after* generation, ensuring that user identity details are never transmitted to external AI providers.

## 🏗 Modern Tech Stack

This project is built to demonstrate **modern iOS engineering practices** as of 2025/2026.

- **Language**: Swift 6 (Strict Concurrency Checking enabled).
- **UI Framework**: SwiftUI (using `NavigationSplitView` and value-based navigation).
- **State Management**: Observation Framework (`@Observable`, `@Bindable`).
- **Persistence**: SwiftData (modern wrapper for Core Data).
- **Networking**: `async/await` with `URLSession` and strongly-typed `Codable` models.

## 💡 Architectural Intent: The "Why"

### Privacy-First Design by Default
Unlike standard wrappers, this app treats user data as sovereign. The `OpenAIService` only receives the resume content and job description. The application layer (`AppViewModel`) orchestrates the final assembly, prepending personal contact details locally. This separation of concerns ensures PII compliance.

### Strict Concurrency & Thread Safety
The application adopts **Swift 6 strict concurrency**.
- **Services**: `OpenAIService` is defined as an `actor`, isolating network state and ensuring thread-safe execution.
- **ViewModels**: `AppViewModel` is annotated with `@MainActor` to guarantee all UI updates occur on the main thread, eliminating data races.

### Type-Safety as a Feature
Strings are avoided where possible. Configuration options like **Length** and **Tone** are modeled as strictly typed `enum` cases (`TextLengthOption`, `TextToneOption`). This prevents invalid API states and ensures the UI and Data layer are always synchronized.

## 🛠 Technical Highlights

- **Concurrency**: Leverages structured concurrency (`Task`, `async/await`) to handle multiple asynchronous streams (AI generation, Persistence) without blocking the UI.
- **Persistence**: Uses **SwiftData** with `@Model` macro for a declarative schema. Auto-saves generation context (Length/Tone ratings) alongside the content, allowing "time travel" state restoration.
- **Design Pattern**: MVVM (Model-View-ViewModel) with dependency injection via the SwiftUI `Environment`. This decouples the View layer from business logic, making the codebase testable and modular.
- **Networking**: Implements a robust networking layer handling the complex **GPT-5.2 Responses API** schema (nested content arrays, developer roles, reasoning parameters) with custom `Decodable` parsing.
- **Testing**: Includes a comprehensive test suite using `MockURLProtocol` to verify API handling and error states without making live network calls.

## 📸 Visuals

![App Screenshot](screenshots/Screenshot.png)

## 🏆 Golden Snippets

Key areas of the codebase that demonstrate complex logic and clean architecture:

### 1. Advanced API Handling
**File:** [`OpenAIService.swift`](CoverLetterGen/Services/OpenAIService.swift)
Demonstrates handling the complex nested structure of the GPT-5.2 Responses API, including "Developer" roles for strict strict instruction compliance.

```swift
// Strict schema decoding for nested response structures
let decodedResponse = try JSONDecoder().decode(ResponsesResponse.self, from: data)
if let firstOutput = decodedResponse.output.first,
   let textContent = firstOutput.content.first(where: { $0.type == "output_text" })?.text {
    return textContent
}
```

### 2. Robust State & Persistence
**File:** [`AppViewModel.swift`](CoverLetterGen/ViewModels/AppViewModel.swift)
Shows how `SwiftData` is used not just for storage, but for state restoration. Selecting a historical letter instantly reconfigures the app's global settings strings to match that letter's original context.

```swift
var selectedLetter: CoverLetter? {
    didSet {
        if let letter = selectedLetter {
            // Restore Inputs
            resumeInput = letter.resumeText
            jobInput = letter.jobDescription
            
            // Restore Configuration State from Enum raw values
            if let l = TextLengthOption(rawValue: letter.lengthOption) { length = l }
            if let t = TextToneOption(rawValue: letter.toneOption) { tone = t }
        }
    }
}
```

## 🚀 Setup

1. Clone the repository.
2. Open `CoverLetterGen.xcodeproj` in Xcode 15+.
3. Run on iPad Simulator.
4. Add your OpenAI API Key in Settings (stored securely in UserDefaults).

## License
MIT
