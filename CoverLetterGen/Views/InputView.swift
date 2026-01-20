import SwiftUI
import SwiftData

/// The middle column view collecting user inputs (Resume, Job Description) and triggering generation.
struct InputView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    HStack {
                        Text("Input Details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, 8)

                    // MARK: - Resume Input
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
                            .foregroundStyle(.blue)
                        }

                        TextEditor(text: $viewModel.resumeInput)
                            .font(.body)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // MARK: - Job Description Input
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
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(24)
            }

            // MARK: - Action Area
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(viewModel.isGenerating)
                .padding(24)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
