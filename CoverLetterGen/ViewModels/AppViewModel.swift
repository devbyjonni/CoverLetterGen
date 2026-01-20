import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class AppViewModel {
    
    // MARK: - State Properties
    
    /// The currently selected cover letter.
    /// Setting this property automatically populates the input fields and generated content.
    var selectedLetter: CoverLetter? {
        didSet {
            if let letter = selectedLetter {
                resumeInput = letter.resumeText
                jobInput = letter.jobDescription
                generatedContent = letter.generatedContent
                
                // Restore Settings
                if let l = TextLengthOption(rawValue: letter.lengthOption) { length = l }
                if let t = TextToneOption(rawValue: letter.toneOption) { tone = t }
            } else {
                resumeInput = ""
                jobInput = ""
                generatedContent = ""
            }
        }
    }
    
    // MARK: - User Profile Data
    // These properties are persisted to UserDefaults for privacy.
    
    var userFullName: String = UserDefaults.standard.string(forKey: "userFullName") ?? "" { didSet { UserDefaults.standard.set(userFullName, forKey: "userFullName") } }
    var userJobTitle: String = UserDefaults.standard.string(forKey: "userJobTitle") ?? "" { didSet { UserDefaults.standard.set(userJobTitle, forKey: "userJobTitle") } }
    var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? "" { didSet { UserDefaults.standard.set(userEmail, forKey: "userEmail") } }
    var userPhone: String = UserDefaults.standard.string(forKey: "userPhone") ?? "" { didSet { UserDefaults.standard.set(userPhone, forKey: "userPhone") } }
    var userAddress: String = UserDefaults.standard.string(forKey: "userAddress") ?? "" { didSet { UserDefaults.standard.set(userAddress, forKey: "userAddress") } }
    var userCity: String = UserDefaults.standard.string(forKey: "userCity") ?? "" { didSet { UserDefaults.standard.set(userCity, forKey: "userCity") } }
    var userState: String = UserDefaults.standard.string(forKey: "userState") ?? "" { didSet { UserDefaults.standard.set(userState, forKey: "userState") } }
    var userZip: String = UserDefaults.standard.string(forKey: "userZip") ?? "" { didSet { UserDefaults.standard.set(userZip, forKey: "userZip") } }
    var userCountry: String = UserDefaults.standard.string(forKey: "userCountry") ?? "" { didSet { UserDefaults.standard.set(userCountry, forKey: "userCountry") } }
    var userPortfolio: String = UserDefaults.standard.string(forKey: "userPortfolio") ?? "" { didSet { UserDefaults.standard.set(userPortfolio, forKey: "userPortfolio") } }
    
    // MARK: - AI Preferences
    
    var length: TextLengthOption = TextLengthOption(rawValue: UserDefaults.standard.string(forKey: "TextLength") ?? "") ?? .medium {
        didSet { UserDefaults.standard.set(length.rawValue, forKey: "TextLength") }
    }
    
    var tone: TextToneOption = TextToneOption(rawValue: UserDefaults.standard.string(forKey: "TextTone") ?? "") ?? .professional {
        didSet { UserDefaults.standard.set(tone.rawValue, forKey: "TextTone") }
    }

    // MARK: - Input State
    
    var resumeInput: String = ""
    var jobInput: String = ""
    var isGenerating: Bool = false
    var generatedContent: String = ""
    var errorMessage: String?
    
    var characterCountFormatted: String {
        generatedContent.count.formatted()
    }
    
    // MARK: - Dependencies
    
    private var openAIService: OpenAIService? {
        let key = UserDefaults.standard.string(forKey: "OpenAI_API_Key") ?? ""
        guard !key.isEmpty else { return nil }
        return OpenAIService(apiKey: key)
    }
    
    // MARK: - Actions
    
    /// Clears the current selection to allow creating a new letter.
    func createNewLetter() {
        selectedLetter = nil
    }
    
    /// Selects a letter from history and loads its data.
    func selectLetter(_ letter: CoverLetter) {
        selectedLetter = letter
    }
    
    /// Fills the input fields with test data for demonstration.
    func fillTestData() {
        resumeInput = """
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
    
    /// Fills the user profile with test data.
    func fillTestProfile() {
        userFullName = "John Doe"
        userJobTitle = "Senior Software Engineer"
        userEmail = "john.doe@example.com"
        userPhone = "555-0100"
        userAddress = "123 Tech Lane"
        userCity = "San Francisco"
        userState = "CA"
        userZip = "94105"
        userCountry = "USA"
        userPortfolio = "github.com/johndoe"
    }
    
    /// Generates a cover letter using OpenAI's API.
    /// - Parameter context: The SwiftData model context to save the generated letter.
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
            let rawContent = try await service.generateCoverLetter(resume: resumeInput, jobDescription: jobInput, lengthInstruction: length.promptInstruction, toneInstruction: tone.promptInstruction, maxTokens: length.maxTokenLimit)
            var cleanedContent = cleanArtifacts(from: rawContent)
            
            // Replace placeholders with real name
            if !userFullName.isEmpty {
                cleanedContent = cleanedContent.replacingOccurrences(of: "[Your Name]", with: userFullName)
            }
            
            // Prepend User Profile Data locally (Privacy)
            let header = senderDetails
            if !header.isEmpty {
                generatedContent = header + "\n\n" + cleanedContent
            } else {
                generatedContent = cleanedContent
            }
            
            // Save to History using SwiftData
            if let existing = selectedLetter {
                existing.resumeText = resumeInput
                existing.jobDescription = jobInput
                existing.generatedContent = generatedContent
                existing.lengthOption = length.rawValue
                existing.toneOption = tone.rawValue
                existing.createdAt = Date() // Updates timestamp to show as recent
            } else {
                let newLetter = CoverLetter(
                    resumeText: resumeInput,
                    jobDescription: jobInput,
                    generatedContent: generatedContent,
                    title: "Letter for Position", // Feature idea: Extract company name from job desc
                    lengthOption: length.rawValue,
                    toneOption: tone.rawValue
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
    
    // MARK: - Helpers
    
    /// Removes markdown artifacts like code blocks or horizontal rules from the AI response.
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
    
    /// Constructs the header string from user profile details.
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
        if !userCountry.isEmpty { cityStateZip.append(userCountry) }
        if !cityStateZip.isEmpty { address.append(cityStateZip.joined(separator: ", ")) }
        if !address.isEmpty { details.append(address.joined(separator: "\n")) }
        
        return details.joined(separator: "\n")
    }
}
