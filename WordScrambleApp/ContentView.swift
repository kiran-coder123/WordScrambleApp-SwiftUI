//
//  ContentView.swift
//  WordScrambleApp
//
//  Created by Kiran Sonne on 22/11/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var rootWord = " "
    @State private var newWord = " "

    //Alert
    @State private var  errorTitle = ""
    @State private var  errorMessage = ""
    @State private var showingAlert = false
    
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word",text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    ForEach(usedWord,id: \.self) {
                        word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                        Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .toolbar {
                Button("Start Game") {
                    startGame()
                }
            }
        }
       
        .alert(errorTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
             Text(errorMessage)
        }
       
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remeining string is empty
        guard answer.count > 0 else { return }
        
        // extra validation to come
        withAnimation {
            usedWord.insert(answer, at: 0)
             newWord = " "
        }
        guard isOriginal(word: answer) else {
            wordError(title: "word used already", message: "Be more original ")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "word not possible", message: "You can't spell that word from \(rootWord)' !")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "word not recognized", message: "You can't just make them up, you know!")
            return
        }
      
    }
    
    func startGame(){
        // find Url start.txt in app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //load txt into string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                // pick one random word
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError(" could not start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        
        !usedWord.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
