import Foundation

struct Translation: Codable, Identifiable {
    let id: UUID
    let originalText: String
    let translatedText: String
    let date: Date
    
    init(originalText: String, translatedText: String) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.date = Date()
    }
} 