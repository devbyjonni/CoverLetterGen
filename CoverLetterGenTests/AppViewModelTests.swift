import XCTest
@testable import CoverLetterGen

@MainActor
final class AppViewModelTests: XCTestCase {
    
    var viewModel: AppViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AppViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
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
}
