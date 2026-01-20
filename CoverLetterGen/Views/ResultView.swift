import SwiftUI
import SwiftData

/// The detail column displaying the generated cover letter.
/// It observes SwiftData queries to show either the selected letter or the most recent one.
struct ResultView: View {
    @Environment(AppViewModel.self) var viewModel
    @Query(sort: \CoverLetter.createdAt, order: .reverse) private var letters: [CoverLetter]
    @State private var showingSettings = false
    @State private var showingProfile = false
    @State private var isCopied = false

    /// Determines which letter to display: specific selection or the latest one.
    private var activeLetter: CoverLetter? {
        viewModel.selectedLetter
    }

    var body: some View {
        VStack(spacing: 0) {
            if let letter = activeLetter {
                // MARK: - Main Content
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // Error Banner
                            if let error = viewModel.errorMessage {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.title)
                                        .foregroundStyle(.red)
                                    Text("Error")
                                        .font(.headline)
                                    Text(error)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            
                            // Generated Letter Card
                            VStack(spacing: 24) {
                                HStack {
                                    Text("Generated Letter")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    let lengthName = TextLengthOption(rawValue: letter.lengthOption)?.displayName ?? "Medium"
                                    let toneName = TextToneOption(rawValue: letter.toneOption)?.displayName ?? "Professional"
                                    Text("\(lengthName) • \(toneName)")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(letter.generatedContent)
                                        .font(.body)
                                        .textSelection(.enabled)
                                        .padding(24)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        )
                                }
                            }
                            .padding(24)
                        }
                    } // End ScrollView
                    
                    Divider()
                    
                    // MARK: - Action Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            UIPasteboard.general.string = letter.generatedContent
                            withAnimation {
                                isCopied = true
                            }
                            // Reset after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isCopied = false
                                }
                            }
                        }) {
                            Label(isCopied ? "Copied!" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(isCopied ? .green : .primary)
                                .cornerRadius(12)
                        }
                        
                        ShareLink(item: letter.generatedContent) {
                            Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .tertiarySystemFill))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                }
            } else {
                EmptyStateView()
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                Button(action: { showingProfile = true }) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environment(viewModel)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(viewModel: viewModel)
        }
    }
}

/// Placeholder view shown when no letters exist in history.
struct EmptyStateView: View {
    @Environment(AppViewModel.self) var viewModel
    @State private var isSpinning = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Rotating Blue Border
                Circle()
                    .strokeBorder(
                        AngularGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0.1)]), center: .center),
                        lineWidth: 3
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isSpinning)
                    .opacity(viewModel.isGenerating ? 1 : 0)
                    .animation(.default, value: viewModel.isGenerating) // Smooth fade in/out
                
                // Static Background
                Circle()
                    .fill(Color(uiColor: .secondarySystemFill))
                    .frame(width: 80, height: 80)
                
                // Icon
                Image(systemName: "wand.and.stars")
                    .font(.largeTitle)
                    .foregroundStyle(viewModel.isGenerating ? .blue : .secondary)
            }
            .padding(10) // Give space for the border
            
            ZStack {
                // Hidden text to reserve layout space prevents jumping
                Text("Your AI-crafted cover letter will appear here after you click generate.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
                    .hidden()
                
                Text(viewModel.isGenerating ? "Crafting your cover letter..." : "Your AI-crafted cover letter will appear here after you click generate.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear { isSpinning = true }
    }
}
