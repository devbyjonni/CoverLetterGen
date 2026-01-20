import Foundation

enum TextToneOption: String, CaseIterable, Identifiable {
    case professional
    case conversational
    case simple
    case confident
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .professional: return "Professional"
        case .conversational: return "Conversational"
        case .simple: return "Simple & Direct"
        case .confident: return "Confident"
        }
    }
    
    var promptInstruction: String {
        switch self {
        case .professional:
            return "Use a professional, polished, and formal tone. Suitable for corporate environemnts."
        case .conversational:
            return "Use a warm, human, and conversational tone. Avoid overly stiff or bureaucratic language. Keep it professional but approachable."
        case .simple:
            return "Use simple, clear, and direct language. Avoid jargon, complex sentence structures, and flowery words. Get straight to the point."
        case .confident:
            return "Use a strong, persuasive, and confident tone. Highlight achievements boldly and show conviction in suitability for the role."
        }
    }
}
