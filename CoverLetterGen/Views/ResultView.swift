import SwiftUI

struct ResultView: View {
    @Environment(AppViewModel.self) var viewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.generatedContent.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("Generated Letter")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        
                        Text(viewModel.generatedContent) // In a real app, use a Markdown renderer like MarkdownUI
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
                    .padding(24)
                }
                
                // Action Buttons
                VStack {
                    Divider()
                    HStack(spacing: 16) {
                        Button(action: {
                            UIPasteboard.general.string = viewModel.generatedContent
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Placeholder for PDF export
                        }) {
                            Label("Download PDF", systemImage: "arrow.down.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
            }
        }
        .background(Color(uiColor: .systemGroupedBackground)) // Right panel usually white in the design
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemFill))
                    .frame(width: 80, height: 80)
                Image(systemName: "wand.and.stars")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            
            Text("Your AI-crafted cover letter will appear here after you click generate.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
