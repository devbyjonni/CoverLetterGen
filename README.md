# CoverLetterGen

An AI-powered iPad application that generates tailored cover letters using SwiftUI and SwiftData.

## Features
- **Smart Generation**: Uses OpenAI's GPT-4o to write professional cover letters based on your resume and job description.
- **Local History**: Saves all generated letters on-device using SwiftData.
- **iPad Optimized**: Designed with a 3-column layout for maximum productivity on iPadOS.
- **Secure**: Direct API integration without intermediate servers.

## Tech Stack
- **Language**: Swift 6 (Strict Concurrency)
- **UI Framework**: SwiftUI (NavigationSplitView, MVVM)
- **Persistence**: SwiftData
- **Networking**: URLSession async/await
- **AI**: OpenAI API

## Setup
1. Clone the repository.
2. Open `CoverLetterGen.xcodeproj` (or the folder in Swift Playgrounds).
3. Insert your OpenAI API Key in `ViewModels/AppViewModel.swift`.
4. Run on iPad Simulator or Device.

## Requirements
- iOS/iPadOS 17.0+
- Xcode 15+
