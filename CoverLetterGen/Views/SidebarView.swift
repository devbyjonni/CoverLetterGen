import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: AppViewModel
    @Query(sort: \CoverLetter.createdAt, order: .reverse) private var letters: [CoverLetter]
    @State private var showingDeleteAlert = false
    @State private var letterToDelete: CoverLetter?

    var body: some View {
        List(selection: $viewModel.selectedLetter) {
            Section {
                Button(action: {
                    viewModel.createNewLetter()
                }) {
                    Label("New Letter", systemImage: "plus")
                        .font(.headline)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            
            Section(header: Text("History").font(.caption).fontWeight(.semibold)) {
                if letters.isEmpty {
                    Text("No previous letters yet.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .italic()
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(letters) { letter in
                        NavigationLink(value: letter) {
                            VStack(alignment: .leading) {
                                Text(letter.title)
                                    .font(.body)
                                    .lineLimit(1)
                                Text(letter.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                letterToDelete = letter
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("CoverLetterGen")
        .alert("Delete Letter?", isPresented: $showingDeleteAlert, presenting: letterToDelete) { letter in
            Button("Delete", role: .destructive) {
                modelContext.delete(letter)
                if viewModel.selectedLetter == letter {
                    viewModel.createNewLetter()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
