import Foundation
import SwiftData

@Model
final class CoverLetter {
    var id: UUID
    var createdAt: Date
    var resumeText: String
    var jobDescription: String
    var generatedContent: String
    var title: String
    var lengthOption: String
    var toneOption: String
    
    init(id: UUID = UUID(), createdAt: Date = Date(), resumeText: String, jobDescription: String, generatedContent: String = "", title: String = "Untitled Letter", lengthOption: String = TextLengthOption.medium.rawValue, toneOption: String = TextToneOption.professional.rawValue) {
        self.id = id
        self.createdAt = createdAt
        self.resumeText = resumeText
        self.jobDescription = jobDescription
        self.generatedContent = generatedContent
        self.title = title
        self.lengthOption = lengthOption
        self.toneOption = toneOption
    }
}
