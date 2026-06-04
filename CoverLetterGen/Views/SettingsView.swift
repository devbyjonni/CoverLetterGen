import SwiftUI

/// The settings screen for configuring API keys and AI generation preferences.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section(header: Text("OpenAI Configuration"), footer: Text("Your API key is stored locally on this device.")) {
                    SecureField("API Key", text: $viewModel.apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("AI Preferences")) {
                    Picker("Length", selection: $viewModel.length) {
                        ForEach(TextLengthOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    Picker("Tone", selection: $viewModel.tone) {
                        ForEach(TextToneOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
