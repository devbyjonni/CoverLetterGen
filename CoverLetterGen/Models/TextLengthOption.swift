import Foundation

enum TextLengthOption: String, CaseIterable, Identifiable {
    case short
    case medium
    case long
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .long: return "Long"
        }
    }
    
    var promptInstruction: String {
        switch self {
        case .short:
            return "Keep the cover letter concise and to the point, approximately 200-300 words. Do not exceed 300 words."
        case .medium:
            return "Write a standard length cover letter, approximately 300-500 words, balancing detail and brevity. Do not exceed 500 words."
        case .long:
            return "Write a comprehensive and detailed cover letter, approximately 500-700 words, fully expanding on experience and skills. Do not exceed 750 words."
        }
    }
    
    var maxTokenLimit: Int {
        switch self {
        case .short: return 450  // ~300 words
        case .medium: return 750 // ~500 words
        case .long: return 1200  // ~800 words
        }
    }
}
