import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class AppViewModel {
    var selectedLetter: CoverLetter?
    var resumeInput: String = ""
    var jobInput: String = ""
    var isGenerating: Bool = false
    var generatedContent: String = ""
    var errorMessage: String?
    
    private var openAIService: OpenAIService? {
        let key = UserDefaults.standard.string(forKey: "OpenAI_API_Key") ?? ""
        guard !key.isEmpty else { return nil }
        return OpenAIService(apiKey: key)
    }
    
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
        guard let service = openAIService else {
            errorMessage = "Please configure your OpenAI API Key in Settings."
            return
        }
        
        guard !resumeInput.isEmpty, !jobInput.isEmpty else {
            errorMessage = "Please enter both resume and job description."
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            let content = try await service.generateCoverLetter(resume: resumeInput, jobDescription: jobInput)
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
                
                // Select and save
                selectedLetter = newLetter
            }
            // Explicit save is often auto-handled by SwiftData Autosave, but explicit is safe
            try context.save()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
}
