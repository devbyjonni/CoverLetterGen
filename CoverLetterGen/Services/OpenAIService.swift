import Foundation

actor OpenAIService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/responses")!
    private let urlSession: URLSession
    
    init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
    
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
    
    func generateCoverLetter(resume: String, jobDescription: String, lengthInstruction: String, toneInstruction: String, maxTokens: Int? = nil) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // System prompt (Developer role)
        let systemPrompt = """
        You are a professional career coach. Write a compelling cover letter based on the provided resume and job description.
        
        STRICT OUTPUT RULES:
        - Return ONLY the cover letter content.
        - Do NOT include the sender's contact information (Name, Address, Phone, Email) at the top.
        - Start directly with the Date or the Recipient's details.
        - No conversational preamble.
        - No markdown code blocks.
        - No headers or horizontal rules.
        """
        
        // User prompt
        let userPrompt = generatePrompt(resume: resume, jobDescription: jobDescription, lengthInstruction: lengthInstruction, toneInstruction: toneInstruction)
        
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
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }
        if let str = String(data: data, encoding: .utf8) {
             print("Raw Response: \(str)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorText)"])
            }
            throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        let decodedResponse = try JSONDecoder().decode(ResponsesResponse.self, from: data)
        // Parse nested structure: output[0] -> content[0] -> text
        if let firstOutput = decodedResponse.output.first,
           let textContent = firstOutput.content.first(where: { $0.type == "output_text" })?.text {
            return textContent
        }
        
        return "No content generated."
    }
    
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

