import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class AppViewModel {
    var selectedLetter: CoverLetter? {
        didSet {
            if let letter = selectedLetter {
                resumeInput = letter.resumeText
                jobInput = letter.jobDescription
                generatedContent = letter.generatedContent
            } else {
                resumeInput = ""
                jobInput = ""
                generatedContent = ""
            }
        }
    }
    
    // User Profile Data
    var userFullName: String = UserDefaults.standard.string(forKey: "userFullName") ?? "" { didSet { UserDefaults.standard.set(userFullName, forKey: "userFullName") } }
    var userJobTitle: String = UserDefaults.standard.string(forKey: "userJobTitle") ?? "" { didSet { UserDefaults.standard.set(userJobTitle, forKey: "userJobTitle") } }
    var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? "" { didSet { UserDefaults.standard.set(userEmail, forKey: "userEmail") } }
    var userPhone: String = UserDefaults.standard.string(forKey: "userPhone") ?? "" { didSet { UserDefaults.standard.set(userPhone, forKey: "userPhone") } }
    var userAddress: String = UserDefaults.standard.string(forKey: "userAddress") ?? "" { didSet { UserDefaults.standard.set(userAddress, forKey: "userAddress") } }
    var userCity: String = UserDefaults.standard.string(forKey: "userCity") ?? "" { didSet { UserDefaults.standard.set(userCity, forKey: "userCity") } }
    var userState: String = UserDefaults.standard.string(forKey: "userState") ?? "" { didSet { UserDefaults.standard.set(userState, forKey: "userState") } }
    var userZip: String = UserDefaults.standard.string(forKey: "userZip") ?? "" { didSet { UserDefaults.standard.set(userZip, forKey: "userZip") } }
    var userPortfolio: String = UserDefaults.standard.string(forKey: "userPortfolio") ?? "" { didSet { UserDefaults.standard.set(userPortfolio, forKey: "userPortfolio") } }

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
    }
    
    func selectLetter(_ letter: CoverLetter) {
        selectedLetter = letter
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
            let rawContent = try await service.generateCoverLetter(resume: resumeInput, jobDescription: jobInput)
            let cleanedContent = cleanArtifacts(from: rawContent)
            
            // Prepend User Profile Data locally (Privacy)
            let header = senderDetails
            if !header.isEmpty {
                generatedContent = header + "\n\n" + cleanedContent
            } else {
                generatedContent = cleanedContent
            }
            
            // Save to History
            if let existing = selectedLetter {
                existing.resumeText = resumeInput
                existing.jobDescription = jobInput
                existing.generatedContent = generatedContent
                existing.createdAt = Date() // touch
            } else {
                let newLetter = CoverLetter(
                    resumeText: resumeInput,
                    jobDescription: jobInput,
                    generatedContent: generatedContent,
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
    
     func cleanArtifacts(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let processedLines = lines.compactMap { line -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Remove code fences (beginning or end)
            if trimmed.hasPrefix("```") { return nil }
            
            // Remove horizontal rules
            if trimmed.hasPrefix("---") { return nil }
            
            // Remove headers but keep text (remove leading # and space)
            if trimmed.hasPrefix("#") {
                return trimmed.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
            }
            
            return line // Keep original line if no artifacts
        }
        
        return processedLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var senderDetails: String {
        var details = [String]()
        if !userFullName.isEmpty { details.append(userFullName) }
        if !userJobTitle.isEmpty { details.append(userJobTitle) }
        
        var contact = [String]()
        if !userEmail.isEmpty { contact.append(userEmail) }
        if !userPhone.isEmpty { contact.append(userPhone) }
        if !userPortfolio.isEmpty { contact.append(userPortfolio) }
        if !contact.isEmpty { details.append(contact.joined(separator: " | ")) }
        
        var address = [String]()
        if !userAddress.isEmpty { address.append(userAddress) }
        var cityStateZip = [String]()
        if !userCity.isEmpty { cityStateZip.append(userCity) }
        if !userState.isEmpty { cityStateZip.append(userState) }
        if !userZip.isEmpty { cityStateZip.append(userZip) }
        if !cityStateZip.isEmpty { address.append(cityStateZip.joined(separator: ", ")) }
        if !address.isEmpty { details.append(address.joined(separator: "\n")) }
        
        return details.joined(separator: "\n")
    }
}
