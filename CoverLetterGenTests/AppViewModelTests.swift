import XCTest
import SwiftData
@testable import CoverLetterGen

@MainActor
final class AppViewModelTests: XCTestCase {

    var viewModel: AppViewModel!
    var userDefaultsSuiteName: String!
    var userDefaults: UserDefaults!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    private var openAIService: MockOpenAIService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userDefaultsSuiteName = "AppViewModelTests-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)!
        userDefaults.set("test-key", forKey: "OpenAI_API_Key")
        openAIService = MockOpenAIService()
        viewModel = AppViewModel(userDefaults: userDefaults, openAIServiceFactory: { [openAIService] _ in
            openAIService!
        })
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: CoverLetter.self, configurations: configuration)
        modelContext = modelContainer.mainContext
    }

    override func tearDown() {
        if let userDefaultsSuiteName {
            userDefaults?.removePersistentDomain(forName: userDefaultsSuiteName)
        }
        modelContext = nil
        modelContainer = nil
        openAIService = nil
        viewModel = nil
        userDefaults = nil
        userDefaultsSuiteName = nil
        super.tearDown()
    }

    /// Tests that the character count is formatted with locale-aware separators (e.g., "1,234").
    func testCharacterCountFormatted_FormatsCorrectly() {
        // Given
        viewModel.generatedContent = String(repeating: "a", count: 1234)

        // When
        let formatted = viewModel.characterCountFormatted

        // Then
        // Should be "1,234" in US locale, might vary elsewhere.
        // formatted() uses current locale. We can check if it contains a separator if > 999.
        // Or simply check for "1" and "234".

        // A robust check assuming US locale for development or regex for "1\D234"
        // Let's assume standard behavior for now or verify it's not raw int string
        XCTAssertNotEqual(formatted, "1234")
        XCTAssertTrue(formatted.contains("1") && formatted.contains("234"))
    }

    /// Tests that an empty string results in a formatted count of "0".
    func testCharacterCountFormatted_Zero() {
        viewModel.generatedContent = ""
        XCTAssertEqual(viewModel.characterCountFormatted, "0")
    }

    func testAPIKeyPersistsThroughViewModel() {
        viewModel.apiKey = "updated-key"

        XCTAssertEqual(userDefaults.string(forKey: "OpenAI_API_Key"), "updated-key")
    }

    func testGenerateLetter_WithMissingAPIKeyShowsError() async {
        userDefaults.removeObject(forKey: "OpenAI_API_Key")
        viewModel.resumeInput = "Resume"
        viewModel.jobInput = "Job"

        await viewModel.generateLetter(context: modelContext)

        XCTAssertEqual(viewModel.errorMessage, "Please configure your OpenAI API Key in Settings.")
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testGenerateLetter_WithEmptyInputShowsError() async {
        viewModel.resumeInput = ""
        viewModel.jobInput = "Job"

        await viewModel.generateLetter(context: modelContext)

        XCTAssertEqual(viewModel.errorMessage, "Please enter both resume and job description.")
        XCTAssertFalse(viewModel.isGenerating)
    }

    func testGenerateLetter_CreatesNewLetterFromSnapshot() async throws {
        await openAIService.setResult(title: "iOS Engineer at Acme", content: "Dear team,\n[Your Name]")
        viewModel.userFullName = "Jane Appleseed"
        viewModel.resumeInput = "Snapshot Resume"
        viewModel.jobInput = "Snapshot Job"
        viewModel.length = .short
        viewModel.tone = .confident

        await viewModel.generateLetter(context: modelContext)

        let letters = try modelContext.fetch(FetchDescriptor<CoverLetter>())
        XCTAssertEqual(letters.count, 1)
        XCTAssertEqual(letters[0].title, "iOS Engineer at Acme")
        XCTAssertEqual(letters[0].resumeText, "Snapshot Resume")
        XCTAssertEqual(letters[0].jobDescription, "Snapshot Job")
        XCTAssertEqual(letters[0].lengthOption, TextLengthOption.short.rawValue)
        XCTAssertEqual(letters[0].toneOption, TextToneOption.confident.rawValue)
        XCTAssertTrue(letters[0].generatedContent.contains("Jane Appleseed"))
        XCTAssertEqual(viewModel.selectedLetter, letters[0])
        XCTAssertEqual(viewModel.generatedContent, letters[0].generatedContent)
    }

    func testGenerateLetter_UpdatesLetterSelectedWhenRequestStarted() async throws {
        let firstLetter = CoverLetter(resumeText: "Old Resume", jobDescription: "Old Job", generatedContent: "Old")
        let secondLetter = CoverLetter(resumeText: "Other Resume", jobDescription: "Other Job", generatedContent: "Other")
        modelContext.insert(firstLetter)
        modelContext.insert(secondLetter)
        try modelContext.save()

        viewModel.selectLetter(firstLetter)
        viewModel.resumeInput = "Updated First Resume"
        viewModel.jobInput = "Updated First Job"
        await openAIService.setDelayNanoseconds(100_000_000)

        let generationTask = Task {
            await viewModel.generateLetter(context: modelContext)
        }
        try await waitForMockServiceRequest()
        viewModel.selectLetter(secondLetter)
        viewModel.resumeInput = "Edited Other Resume"
        await generationTask.value

        let expectedGeneratedContent = await openAIService.resultContent()
        XCTAssertEqual(firstLetter.resumeText, "Updated First Resume")
        XCTAssertEqual(firstLetter.jobDescription, "Updated First Job")
        XCTAssertEqual(firstLetter.generatedContent, expectedGeneratedContent)
        XCTAssertEqual(secondLetter.resumeText, "Other Resume")
        XCTAssertEqual(viewModel.selectedLetter, secondLetter)
        XCTAssertEqual(viewModel.generatedContent, secondLetter.generatedContent)
    }

    func testDeleteLetter_RemovesLetterAndClearsSelection() throws {
        let letter = CoverLetter(resumeText: "Resume", jobDescription: "Job", generatedContent: "Generated")
        modelContext.insert(letter)
        try modelContext.save()
        viewModel.selectLetter(letter)

        viewModel.deleteLetter(letter, context: modelContext)

        let letters = try modelContext.fetch(FetchDescriptor<CoverLetter>())
        XCTAssertTrue(letters.isEmpty)
        XCTAssertNil(viewModel.selectedLetter)
        XCTAssertEqual(viewModel.resumeInput, "")
        XCTAssertEqual(viewModel.jobInput, "")
        XCTAssertEqual(viewModel.generatedContent, "")
        XCTAssertNil(viewModel.errorMessage)
    }

    private func waitForMockServiceRequest() async throws {
        for _ in 0..<100 {
            if await openAIService.hasCapturedRequest() {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        XCTFail("Timed out waiting for mock service request")
    }
}

private actor MockOpenAIService: OpenAIGenerating {
    var result: (title: String, content: String) = (title: "Generated Title", content: "Generated Content")
    var delayNanoseconds: UInt64 = 0
    private(set) var capturedResume: String?
    private(set) var capturedJobDescription: String?

    func setResult(title: String, content: String) {
        result = (title, content)
    }

    func setDelayNanoseconds(_ nanoseconds: UInt64) {
        delayNanoseconds = nanoseconds
    }

    func resultContent() -> String {
        result.content
    }

    func hasCapturedRequest() -> Bool {
        capturedResume != nil
    }

    func generateCoverLetter(resume: String, jobDescription: String, lengthInstruction: String, toneInstruction: String, maxTokens: Int?) async throws -> (title: String, content: String) {
        capturedResume = resume
        capturedJobDescription = jobDescription
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return result
    }
}
