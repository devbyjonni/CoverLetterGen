import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .environmentObject(viewModel)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } content: {
            InputView()
                .environmentObject(viewModel)
                .navigationSplitViewColumnWidth(min: 400, ideal: 500)
        } detail: {
            ResultView()
                .environmentObject(viewModel)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
