import Foundation

actor OpenAIService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    struct ChatCompletionRequest: Encodable {
        let model: String
        let messages: [Message]
        
        struct Message: Encodable {
            let role: String
            let content: String
        }
    }
    
    struct ChatCompletionResponse: Decodable {
        let choices: [Choice]
        
        struct Choice: Decodable {
            let message: Message
            
            struct Message: Decodable {
                let content: String
            }
        }
    }
    
    func generateCoverLetter(resume: String, jobDescription: String) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        You are a professional career coach. Write a compelling cover letter based on the following resume and job description.
        
        RESUME:
        \(resume)
        
        JOB DESCRIPTION:
        \(jobDescription)
        
        STRICT OUTPUT RULES:
        - Return ONLY the cover letter content.
        - Do NOT include the sender's contact information (Name, Address, Phone, Email) at the top. I will add this automatically.
        - Start directly with the Date or the Recipient's details (e.g., [Recipient Name]).
        - Do NOT include any conversational preamble like "Certainly!" or "Here is the letter".
        - Do NOT wrap the output in markdown code blocks (no ```).
        - Do NOT use Markdown headers (lines starting with #). Use **Bold** or CAPS for section titles.
        - Do NOT use horizontal rules (---).
        - Use standard paragraph spacing.
        """
        
        let payload = ChatCompletionRequest(
            model: "gpt-4o",
            messages: [
                .init(role: "system", content: "You are a helpful assistant that writes cover letters. You strictly output only the letter content with no filler."),
                .init(role: "user", content: prompt)
            ]
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorText)"])
            }
            throw NSError(domain: "OpenAIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        }
        
        let decodedResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        return decodedResponse.choices.first?.message.content ?? "No content generated."
    }
}
