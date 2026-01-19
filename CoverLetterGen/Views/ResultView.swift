import SwiftUI

struct ResultView: View {
    @EnvironmentObject var viewModel: AppViewModel

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
                                .foregroundStyle(Color.primaryBlue)
                            Spacer()
                        }
                        
                        Text(viewModel.generatedContent) // In a real app, use a Markdown renderer like MarkdownUI
                            .font(.body)
                            .textSelection(.enabled)
                            .padding(24)
                            .background(Color("CardBackground"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.slate200.opacity(0.5), lineWidth: 1)
                                    .dash([5])
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
                                .background(Color.slate100)
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Placeholder for PDF export
                        }) {
                            Label("Download PDF", systemImage: "arrow.down.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.slate100)
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                }
                .background(Color("CardBackground"))
            }
        }
        .background(Color.white) // Right panel usually white in the design
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.slate100)
                    .frame(width: 80, height: 80)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.slate400)
            }
            
            Text("Your AI-crafted cover letter will appear here after you click generate.")
                .font(.body)
                .foregroundStyle(Color.slate500)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("MainBackground").opacity(0.5))
    }
}
