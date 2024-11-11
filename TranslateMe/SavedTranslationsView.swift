//
//  SavedTranslationsView.swift
//  TranslateMe
//
//  Created by Ben Gmach on 11/11/24.
//

import SwiftUI

struct SavedTranslationsView: View {
    @Binding var translations: [Translation]
    
    var body: some View {
        List(translations) { translation in
            VStack(alignment: .leading, spacing: 8) {
                Text(translation.originalText)
                    .font(.headline)
                Text(translation.translatedText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(translation.date, style: .date)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Saved Translations")
    }
}
