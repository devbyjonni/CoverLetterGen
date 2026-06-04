import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
class AppViewModel {
    typealias OpenAIServiceFactory = @Sendable (String) -> any OpenAIGenerating

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

    var userFullName: String { didSet { userDefaults.set(userFullName, forKey: "userFullName") } }
    var userJobTitle: String { didSet { userDefaults.set(userJobTitle, forKey: "userJobTitle") } }
    var userEmail: String { didSet { userDefaults.set(userEmail, forKey: "userEmail") } }
    var userPhone: String { didSet { userDefaults.set(userPhone, forKey: "userPhone") } }
    var userAddress: String { didSet { userDefaults.set(userAddress, forKey: "userAddress") } }
    var userCity: String { didSet { userDefaults.set(userCity, forKey: "userCity") } }
    var userState: String { didSet { userDefaults.set(userState, forKey: "userState") } }
    var userZip: String { didSet { userDefaults.set(userZip, forKey: "userZip") } }
    var userCountry: String { didSet { userDefaults.set(userCountry, forKey: "userCountry") } }
    var userPortfolio: String { didSet { userDefaults.set(userPortfolio, forKey: "userPortfolio") } }

    // MARK: - AI Preferences

    var length: TextLengthOption {
        didSet { userDefaults.set(length.rawValue, forKey: "TextLength") }
    }

    var tone: TextToneOption {
        didSet { userDefaults.set(tone.rawValue, forKey: "TextTone") }
    }

    var apiKey: String {
        didSet { userDefaults.set(apiKey, forKey: "OpenAI_API_Key") }
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

    @ObservationIgnored
    private let userDefaults: UserDefaults

    @ObservationIgnored
    private let openAIServiceFactory: OpenAIServiceFactory

    private var openAIService: (any OpenAIGenerating)? {
        let key = userDefaults.string(forKey: "OpenAI_API_Key") ?? ""
        guard !key.isEmpty else { return nil }
        return openAIServiceFactory(key)
    }

    init(userDefaults: UserDefaults = .standard, openAIServiceFactory: @escaping OpenAIServiceFactory = { OpenAIService(apiKey: $0) }) {
        self.userDefaults = userDefaults
        self.openAIServiceFactory = openAIServiceFactory
        self.userFullName = userDefaults.string(forKey: "userFullName") ?? ""
        self.userJobTitle = userDefaults.string(forKey: "userJobTitle") ?? ""
        self.userEmail = userDefaults.string(forKey: "userEmail") ?? ""
        self.userPhone = userDefaults.string(forKey: "userPhone") ?? ""
        self.userAddress = userDefaults.string(forKey: "userAddress") ?? ""
        self.userCity = userDefaults.string(forKey: "userCity") ?? ""
        self.userState = userDefaults.string(forKey: "userState") ?? ""
        self.userZip = userDefaults.string(forKey: "userZip") ?? ""
        self.userCountry = userDefaults.string(forKey: "userCountry") ?? ""
        self.userPortfolio = userDefaults.string(forKey: "userPortfolio") ?? ""
        self.length = TextLengthOption(rawValue: userDefaults.string(forKey: "TextLength") ?? "") ?? .medium
        self.tone = TextToneOption(rawValue: userDefaults.string(forKey: "TextTone") ?? "") ?? .professional
        self.apiKey = userDefaults.string(forKey: "OpenAI_API_Key") ?? ""
    }

    // MARK: - Actions

    /// Clears the current selection to allow creating a new letter.
    func createNewLetter() {
        selectedLetter = nil
        resumeInput = ""
        jobInput = ""
        generatedContent = ""
        errorMessage = nil
    }

    /// Selects a letter from history and loads its data.
    func selectLetter(_ letter: CoverLetter) {
        selectedLetter = letter
    }

    func deleteLetter(_ letter: CoverLetter, context: ModelContext) {
        do {
            context.delete(letter)
            try context.save()
            if selectedLetter == letter {
                createNewLetter()
            }
        } catch {
            errorMessage = "Could not delete letter: \(error.localizedDescription)"
        }
    }

    /// Fills the input fields with test data for demonstration.
    func fillTestData() {
        resumeInput = """
        Experience:
        - Senior Backend Engineer at NovaPay (2021-Present): Architected high-volume payment processing service handling $50M/day. Migrated legacy monolith to Go microservices, reducing latency by 40%.
        - Software Engineer at DataFlow Inc (2018-2021): Built real-time analytics dashboard using React and Node.js.
        Skills: Go, Python, TypeScript, AWS (Lambda, DynamoDB), Kubernetes, PostgreSQL, System Design.
        Education: MS in Computer Science, Georgia Tech.
        """

        jobInput = """
        Role: Principal Software Engineer (Platform)
        Company: KubeScale

        We are looking for an experienced leader to drive the evolution of our internal developer platform.
        Requirements:
        - 5+ years of production experience with Go or Rust.
        - Deep expertise in distributed systems and Kubernetes operators.
        - Track record of designing high-availability APIs and mentoring senior engineers.
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

        let generation = LetterGenerationRequest(
            resume: resumeInput,
            jobDescription: jobInput,
            length: length,
            tone: tone,
            senderDetails: senderDetails,
            userFullName: userFullName,
            targetLetter: selectedLetter
        )

        guard !generation.resume.isEmpty, !generation.jobDescription.isEmpty else {
            errorMessage = "Please enter both resume and job description."
            return
        }

        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let (aiTitle, rawContent) = try await service.generateCoverLetter(resume: generation.resume, jobDescription: generation.jobDescription, lengthInstruction: generation.length.promptInstruction, toneInstruction: generation.tone.promptInstruction, maxTokens: generation.length.maxTokenLimit)
            var cleanedContent = cleanArtifacts(from: rawContent)

            // Replace placeholders with real name
            if !generation.userFullName.isEmpty {
                cleanedContent = cleanedContent.replacingOccurrences(of: "[Your Name]", with: generation.userFullName)
            }

            // Prepend User Profile Data locally (Privacy)
            let finalContent: String
            if !generation.senderDetails.isEmpty {
                finalContent = generation.senderDetails + "\n\n" + cleanedContent
            } else {
                finalContent = cleanedContent
            }

            // Save to History using SwiftData
            if let existing = generation.targetLetter {
                existing.resumeText = generation.resume
                existing.jobDescription = generation.jobDescription
                existing.generatedContent = finalContent
                existing.lengthOption = generation.length.rawValue
                existing.toneOption = generation.tone.rawValue
                existing.createdAt = Date() // Updates timestamp to show as recent
                // Optionally update title if re-generating, but maybe user customized it?
                // Let's update it to the smart title since it's a "re-generation" action.
                existing.title = aiTitle
                if selectedLetter == existing {
                    generatedContent = finalContent
                }
            } else {
                let newLetter = CoverLetter(
                    resumeText: generation.resume,
                    jobDescription: generation.jobDescription,
                    generatedContent: finalContent,
                    title: aiTitle,
                    lengthOption: generation.length.rawValue,
                    toneOption: generation.tone.rawValue
                )
                context.insert(newLetter)

                // Select and save
                selectedLetter = newLetter
                generatedContent = finalContent
            }
            // Explicit save is often auto-handled by SwiftData Autosave, but explicit is safe
            try context.save()

        } catch {
            errorMessage = error.localizedDescription
        }
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

private struct LetterGenerationRequest {
    let resume: String
    let jobDescription: String
    let length: TextLengthOption
    let tone: TextToneOption
    let senderDetails: String
    let userFullName: String
    let targetLetter: CoverLetter?
}
