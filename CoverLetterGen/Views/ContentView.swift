import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .environment(viewModel)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } content: {
            InputView()
                .environment(viewModel)
                .navigationSplitViewColumnWidth(min: 400, ideal: 500)
        } detail: {
            ResultView()
                .environment(viewModel)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
