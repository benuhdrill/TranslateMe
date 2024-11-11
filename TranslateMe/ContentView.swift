import SwiftUI

struct ContentView: View {
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var isLoading = false
    @State private var translations: [Translation] = []
    @State private var selectedLanguage = "French"
    
    let languages = [
        "French": "en|fr",
        "Spanish": "en|es",
        "Italian": "en|it"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Text("Translate Me")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.top, 40)
                
                Menu {
                    ForEach(languages.keys.sorted(), id: \.self) { key in
                        Button(action: {
                            selectedLanguage = key
                        }) {
                            HStack {
                                Text(key)
                                if selectedLanguage == key {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Select Language: \(selectedLanguage)")
                            .font(.system(.body, design: .rounded))
                        Image(systemName: "chevron.down")
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal)
                
                HStack {
                    Text("English")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Spacer()
                }
                
                TextField("Enter text", text: $originalText)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                
                Button(action: translateText) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .frame(height: 50)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Translate Me")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .disabled(originalText.isEmpty || isLoading)
                
                HStack {
                    Text(selectedLanguage)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Spacer()
                }
                
                TextEditor(text: .constant(translatedText))
                    .frame(height: 100)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .disabled(true)
                
                NavigationLink(destination: SavedTranslationsView(translations: $translations)) {
                    Text("View Saved Translations")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.top)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    func translateText() {
        isLoading = true
        var urlComponents = URLComponents(string: "https://api.mymemory.translated.net/get")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: originalText),
            URLQueryItem(name: "langpair", value: languages[selectedLanguage] ?? "en|fr")
        ]
        
        guard let url = urlComponents.url else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isLoading = false }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(TranslationResponse.self, from: data)
                    DispatchQueue.main.async {
                        let cleanedTranslation = result.responseData.translatedText
                            .components(separatedBy: ",")[0]
                            .trimmingCharacters(in: .whitespaces)
                        
                        translatedText = cleanedTranslation
                        let newTranslation = Translation(originalText: originalText, translatedText: cleanedTranslation)
                        translations.append(newTranslation)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

struct TranslationResponse: Codable {
    let responseData: ResponseData
    
    struct ResponseData: Codable {
        let translatedText: String
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SavedTranslationsView: View {
    @Binding var translations: [Translation]
    
    var body: some View {
        List(translations) { translation in
            VStack(alignment: .leading, spacing: 8) {
                Text(translation.originalText)
                    .font(.system(.headline, design: .rounded))
                Text(translation.translatedText)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
                Text(translation.date, style: .date)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Saved Translations")
        .navigationBarTitleDisplayMode(.large)
    }
}
