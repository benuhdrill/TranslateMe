//
//  Translation.swift
//  TranslateMe
//
//  Created by Ben Gmach on 11/11/24.
//
import Foundation

struct Translation: Identifiable, Codable {
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
