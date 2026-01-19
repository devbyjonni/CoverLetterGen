import SwiftUI
import SwiftData

@MainActor
class AppViewModel: ObservableObject {
    @Published var selectedLetter: CoverLetter?
    @Published var resumeInput: String = ""
    @Published var jobInput: String = ""
    @Published var isGenerating: Bool = false
    @Published var generatedContent: String = ""
    @Published var errorMessage: String?
    
    // TODO: Replace with secure storage or user input in settings
    private let openAIService = OpenAIService(apiKey: "YOUR_API_KEY_HERE")
    
    func createNewLetter() {
        selectedLetter = nil
        resumeInput = ""
        jobInput = ""
        generatedContent = ""
    }
    
    func selectLetter(_ letter: CoverLetter) {
        selectedLetter = letter
        resumeInput = letter.resumeText
        jobInput = letter.jobDescription
        generatedContent = letter.generatedContent
    }
    
    func fillTestData() {
        resumeInput = """
        John Doe
        Software Engineer
        Experience:
        - Senior Developer at Tech Corp (2020-Present): Led a team of 5 developers.
        - Junior Developer at Startup Inc (2018-2020): React and Redux.
        Skills: React, Node.js, TypeScript, SQL, AWS, Docker
        Education: BS in Computer Science
        """
        
        jobInput = """
        We are looking for a Senior Software Engineer to join our cloud infra team.
        Must have experience with AWS and leading teams.
        """
    }
    
    func generateLetter(context: ModelContext) async {
        guard !resumeInput.isEmpty, !jobInput.isEmpty else {
            errorMessage = "Please enter both resume and job description."
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            let content = try await openAIService.generateCoverLetter(resume: resumeInput, jobDescription: jobInput)
            generatedContent = content
            
            // Save to History
            if let existing = selectedLetter {
                existing.resumeText = resumeInput
                existing.jobDescription = jobInput
                existing.generatedContent = content
                existing.createdAt = Date() // touch
            } else {
                let newLetter = CoverLetter(
                    resumeText: resumeInput,
                    jobDescription: jobInput,
                    generatedContent: content,
                    title: "Letter for Position" // Could extract company name later
                )
                context.insert(newLetter)
                selectedLetter = newLetter
            }
            
            try context.save()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
}
