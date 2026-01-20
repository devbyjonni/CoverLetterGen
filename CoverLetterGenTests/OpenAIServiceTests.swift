import XCTest
@testable import CoverLetterGen

final class OpenAIServiceTests: XCTestCase {
    
    var service: OpenAIService!
    
    override func setUp() {
        super.setUp()
        service = OpenAIService(apiKey: "test-key")
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    /// Tests that the generated prompt string contains the user's specific instructions for Length and Tone, as well as the input data.
    func testGeneratePrompt_ContainsInstructions() {
        // Given
        let resume = "My Resume"
        let job = "My Job"
        let length = "Keep it short. Do not exceed 300 words."
        let tone = "Be professional"
        
        // When
        let prompt = service.generatePrompt(resume: resume, jobDescription: job, lengthInstruction: length, toneInstruction: tone)
        
        // Then
        XCTAssertTrue(prompt.contains("Length: Keep it short. Do not exceed 300 words."), "Prompt should contain length instruction")
        XCTAssertTrue(prompt.contains("Tone: Be professional"), "Prompt should contain tone instruction")
        XCTAssertTrue(prompt.contains("RESUME:\nMy Resume"), "Prompt should contain the resume")
        XCTAssertTrue(prompt.contains("JOB DESCRIPTION:\nMy Job"), "Prompt should contain the job description")
    }
    
    /// Tests that changing the input parameters results in the prompt reflecting those changes correctly.
    func testGeneratePrompt_DifferentInputs() {
        // Given
        let resume = "Experience: Swift"
        let job = "iOS Dev"
        let length = "Long (Full Page). Do not exceed 750 words."
        let tone = "Conversational"
        
        // When
        let prompt = service.generatePrompt(resume: resume, jobDescription: job, lengthInstruction: length, toneInstruction: tone)
        
        // Then
        XCTAssertTrue(prompt.contains("Length: Long (Full Page). Do not exceed 750 words."))
        XCTAssertTrue(prompt.contains("Tone: Conversational"))
    }
    
    // MARK: - Network Tests
    
    /// Tests that the service correctly parses a successful JSON response from the API and extracts the content.
    func testGenerateCoverLetter_Success() async throws {
        // Given
        let expectedTitle = "Senior Dev at Apple"
        let expectedContent = "This is a generated cover letter."
        
        // The service now expects a JSON object serialized as a string inside the OpenAI response 'text' field
        let innerJson = """
        {
            "title": "\(expectedTitle)",
            "cover_letter": "\(expectedContent)"
        }
        """
        // Escape newlines and quotes for the outer JSON string
        let escapedInnerJson = innerJson.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\"", with: "\\\"")
        
        let jsonString = """
        {
            "output": [
                {
                    "content": [
                        {
                            "type": "output_text",
                            "text": "\(escapedInnerJson)"
                        }
                    ]
                }
            ]
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        // Inject Mock Session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)
        service = OpenAIService(apiKey: "test-key", urlSession: mockSession)
        
        // When
        let (title, content) = try await service.generateCoverLetter(resume: "R", jobDescription: "J", lengthInstruction: "S", toneInstruction: "P")
        
        // Then
        XCTAssertEqual(title, expectedTitle)
        XCTAssertEqual(content, expectedContent)
    }
    
    /// Tests that the service throws an error when the API returns a server error (e.g., 500), ensuring robust error handling.
    func testGenerateCoverLetter_ServerError() async {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        // Inject Mock Session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)
        service = OpenAIService(apiKey: "test-key", urlSession: mockSession)
        
        // When/Then
        do {
            _ = try await service.generateCoverLetter(resume: "R", jobDescription: "J", lengthInstruction: "S", toneInstruction: "P")
            XCTFail("Should have thrown error")
        } catch {
            // Success (caught error)
        }
    }
}

// MARK: - MockURLProtocol
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
