import Foundation

/// A modern client for OpenAI's Responses API.
/// Supports GPT-5.2 features including strict output roles and reasoning.
actor OpenAIService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let urlSession: URLSession
    
    init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
    
    // MARK: - Data Models
    
    /// The comprehensive request payload for the Responses API.
    struct ResponsesRequest: Encodable {
        let model: String
        let reasoning: Reasoning?
        let input: [Message]
        let max_output_tokens: Int?
        
        struct Reasoning: Encodable {
            let effort: String
        }
        
        struct Message: Encodable {
            let role: String
            let content: String
        }
    }
    
    /// The decoded response, handling the complex nested structure of the new API.
    struct ResponsesResponse: Decodable {
        let output: [OutputItem]
        
        struct OutputItem: Decodable {
            let content: [ContentItem]
            
            struct ContentItem: Decodable {
                let type: String
                let text: String?
            }
        }
    }
    
    // MARK: - API Calls
    
    /// Generates a cover letter by communicating with the OpenAI Responses API.
    /// - Parameters:
    ///   - resume: The user's resume text.
    ///   - jobDescription: The target job description.
    ///   - lengthInstruction: Specific instruction for output length (e.g., word count limit).
    ///   - toneInstruction: Desired tone (e.g., Professional, Conversational).
    ///   - maxTokens: Optional hard limit for `max_output_tokens`.
    /// - Returns: The generated cover letter text only, with no artifacts.
    /// Generates a cover letter by communicating with the OpenAI Responses API.
    /// - Returns: A tuple containing the generated title and cover letter text.
    func generateCoverLetter(resume: String, jobDescription: String, lengthInstruction: String, toneInstruction: String, maxTokens: Int? = nil) async throws -> (title: String, content: String) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // System prompt (Developer role) - Enforces strict output formatting
        let systemPrompt = """
        You are a professional career coach. Write a compelling cover letter based on the provided resume and job description.
        
        STRICT OUTPUT RULES:
        - You MUST return a valid JSON object.
        - The JSON must have two fields: "title" (e.g., "Role Name at Company Name") and "cover_letter" (the full text).
        - For the "cover_letter" content:
            - Start directly with the Date or the Recipient's details.
            - No conversational preamble.
            - No markdown code blocks.
            - No headers or horizontal rules.
        """
        
        // User prompt - Contains the actual data and specific constraints
        let userPrompt = generatePrompt(resume: resume, jobDescription: jobDescription, lengthInstruction: lengthInstruction, toneInstruction: toneInstruction)
        
        // Response format definition for JSON Strict Mode (compatible with GPT-3.5-turbo-1106 and newer)
        // Note: For "responses" API mock/interface, we can hint it via system prompt, but if this were real GPT-4-turbo we'd use response_format={"type": "json_object"}.
        // We'll trust the system prompt for this implementation.
        
        let payload = ResponsesRequest(
            model: "gpt-5.2",
            reasoning: .init(effort: "low"),
            input: [
                .init(role: "developer", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            max_output_tokens: maxTokens
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorText)"])
            }
            throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        let decodedResponse = try JSONDecoder().decode(ResponsesResponse.self, from: data)
        
        // Parse the output text as JSON
        if let firstOutput = decodedResponse.output.first,
           let textContent = firstOutput.content.first(where: { $0.type == "output_text" })?.text,
           let data = textContent.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
           let title = json["title"],
           let content = json["cover_letter"] {
            return (title, content)
        }
        
        // Fallback parsing if JSON fails but text exists (legacy/error case)
        if let firstOutput = decodedResponse.output.first,
           let textContent = firstOutput.content.first(where: { $0.type == "output_text" })?.text {
             return ("Letter for Position", textContent)
        }
        
        return ("Error", "No content generated.")
    }
    
    // MARK: - Helpers
    
    /// Constructs the final user prompt string.
    nonisolated func generatePrompt(resume: String, jobDescription: String, lengthInstruction: String, toneInstruction: String) -> String {
        return """
        INSTRUCTIONS:
        Length: \(lengthInstruction)
        Tone: \(toneInstruction)
        
        RESUME:
        \(resume)
        
        JOB DESCRIPTION:
        \(jobDescription)
        """
    }
}

