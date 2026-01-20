# CoverLetterGen

![Status](https://img.shields.io/badge/Status-Active-success)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![Platform](https://img.shields.io/badge/Platform-iPadOS-blue)

## Project Overview

**CoverLetterGen** is a native iPad application that generates cover letters using the OpenAI API. It automates the formatting and drafting process while ensuring that personally identifiable information (PII) remains local to the device.

## Technical Specifications

- **Language**: Swift 6
- **Architecture**: MVVM
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData
- **Concurrency**: Swift Structured Concurrency (Async/Await, Actors)
- **External API**: OpenAI (Responses Endpoint)

## Architecture & Implementation

### Privacy Mechanism
To prevent PII leakage, the application separates generation from data assembly:
1.  **Generation**: The `OpenAIService` sends only the anonymized resume text and job description to the LLM.
2.  **Assembly**: The `AppViewModel` receives the raw text and prepends the user's contact details (name, address, phone) locally.
3.  **Storage**: User profile data is persisted in `UserDefaults`, while generated content is stored in `SwiftData`.

### Concurrency (Swift 6)
The project adopts strict concurrency checking to ensure thread safety:
- **Actor Isolation**: `OpenAIService` is defined as an `actor` to serialize network requests and manage session state.
- **Main Actor**: `AppViewModel` is isolated to `@MainActor`, ensuring all state mutations and UI updates occur on the main thread without manual dispatching.

### Persistence Strategy
Data persistence is handled by **SwiftData**:
- **Schema**: The `CoverLetter` model stores the generated text along with the configuration state used at the time of generation (`TextLengthOption`, `TextToneOption`).
- **State Restoration**: Selecting a historical item re-initializes the application state (Input fields, Tone, Length) to match that record, enabling context switching.

### Networking
Networking is implemented using `URLSession` and custom `Codable` structs.
- **Schema Validation**: The client maps the nested response structure of the GPT-5.2 API (`output` -> `content` -> `text`) to strongly typed models.
- **Testing**: Deterministic tests are implemented using a `MockURLProtocol`, allowing the service to be tested without live API calls.

## Visuals

![App Screenshot](screenshots/Screenshot.png)

## Code Examples

### API Response Handling
**File:** [`OpenAIService.swift`](CoverLetterGen/Services/OpenAIService.swift)
Parsing the nested response structure from the Responses API.

```swift
let decodedResponse = try JSONDecoder().decode(ResponsesResponse.self, from: data)

// Parse nested structure: output[0] -> content[0] -> text
if let firstOutput = decodedResponse.output.first,
   let textContent = firstOutput.content.first(where: { $0.type == "output_text" })?.text {
    return textContent
}
```

### State Restoration
**File:** [`AppViewModel.swift`](CoverLetterGen/ViewModels/AppViewModel.swift)
Restoring configuration state from a persisted model. The usage of Enums prevents invalid state.

```swift
var selectedLetter: CoverLetter? {
    didSet {
        if let letter = selectedLetter {
            resumeInput = letter.resumeText
            jobInput = letter.jobDescription
            
            // Restore Settings from persisted raw values
            if let l = TextLengthOption(rawValue: letter.lengthOption) { length = l }
            if let t = TextToneOption(rawValue: letter.toneOption) { tone = t }
        }
    }
}
```

## Setup

1. Clone the repository.
2. Open `CoverLetterGen.xcodeproj` (Xcode 26.2+).
3. Run on a simulator or device.
4. Configure the OpenAI API Key in the application settings.

## License
MIT
