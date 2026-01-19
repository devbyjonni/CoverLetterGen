import SwiftUI
import SwiftData

@main
struct CoverLetterGenApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CoverLetter.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let url = modelConfiguration.url
            print("📂 SwiftData Database Path: \(url.path(percentEncoded: false))")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
