import SwiftUI

struct ContentView: View {
    @State private var originalText = ""
    @State private var translatedText = ""
    @State private var isLoading = false
    @State private var translations: [Translation] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Translate Me")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                TextField("Enter text", text: $originalText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: translateText) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(height: 50)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Translate Me")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal)
                .disabled(originalText.isEmpty || isLoading)
                
                TextEditor(text: .constant(translatedText))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .disabled(true)
                
                NavigationLink(destination: SavedTranslationsView(translations: $translations)) {
                    Text("View Saved Translations")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
    }
    
    func translateText() {
        isLoading = true
        var urlComponents = URLComponents(string: "https://api.mymemory.translated.net/get")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: originalText),
            URLQueryItem(name: "langpair", value: "en|fr")
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
