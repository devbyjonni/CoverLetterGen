import SwiftUI
import SwiftData

struct InputView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Input Details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, 8)

                    // Resume Input
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your Resume")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(action: { viewModel.fillTestData() }) {
                                Label("Fill Test Data", systemImage: "wand.and.stars")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.primaryBlue)
                        }

                        TextEditor(text: $viewModel.resumeInput)
                            .font(.body)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.slate200, lineWidth: 1)
                            )
                    }

                    // Job Input
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Job Description")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        TextEditor(text: $viewModel.jobInput)
                            .font(.body)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.slate200, lineWidth: 1)
                            )
                    }
                }
                .padding(24)
            }

            // Generate Button Area
            VStack {
                Divider()
                Button(action: {
                    Task {
                        await viewModel.generateLetter(context: modelContext)
                    }
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "bolt.fill")
                        }
                        Text(viewModel.isGenerating ? "Generating..." : "Generate Cover Letter")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(viewModel.isGenerating)
                .padding(24)
            }
            .background(Color("CardBackground"))
        }
        .background(Color("MainBackground"))
    }
}
