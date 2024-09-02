//
//  ContentView.swift
//  WordScramble
//
//  Created by Mayank Jangid on 8/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter the word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section{
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar{
                ToolbarItem (placement: .bottomBar, content: {
                    HStack {
                        Button("Start Game") {
                            startGame()
                            newWord = ""
                            usedWord = []
                        }
                        Spacer()
                        Text("Score : \(usedWord.count)")
                    }
                })
            }
            .alert(errorTitle, isPresented: $showingError) {
                //Button("OK") {} -> Swift will do this automatically
            } message: {
                Text(errorMessage)
            }
        }
    }
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespaces)
        guard answer.count>2 else {
            wordError(title: "Not accepted", message: "Word should contain atleast 3 letters")
            return
        }
        guard answer != rootWord else {
            newWord = ""
            wordError(title: "Same Word", message: "DO NOT WRITE THE SAME WORD FOR THE LOVE OF GOD!")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be original for once in ur godDamn life!")
            newWord = ""
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)', you teletubbyzurückwinker")
            newWord = ""
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "English is not a language for u, i guess!")
            newWord = ""
            return
        }
        withAnimation{
            usedWord.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        /*What we need to do now is write a new method called startGame() that will:
         
         1. Find start.txt in our bundle.
         2. Load it into a string.
         3. Split that string into array of strings, with each element being one word.
         4. Pick one random word from there to be assigned to rootWord, or use a sensible default if the array is empty.
        */
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordURL) {
                let allWord = startWord.components(separatedBy: "\n")
                rootWord = allWord.randomElement() ?? "silkworm"
                return
            }
        }
       fatalError("could not load start.txt from bundle.")
    }
    
    func isOriginal (word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isPossible (word: String) -> Bool {
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
    
    func isReal (word: String) -> Bool {
        //the checker (UITextchecker()) is responsible for scanning strings of mispelled words
        //the range(NSRange) scans the entire length of our string
        //now we call rangeofmisspelledWord on checker to look for the wrong words.
        // When that finishes we’ll get back another NSRange telling us where the misspelled word was found, but if the word was OK the location for that range will be the special value NSNotFound.
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
        //the mispelledRange returns an NSNotFound if there are no mistaked found on the particaular location of the NSRange.
    }
    
    func wordError (title: String, message: String) {
        errorMessage = message
        errorTitle = title
        showingError = true
    }
}
#Preview {
    ContentView()
}
