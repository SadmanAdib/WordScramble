//
//  ContentView.swift
//  WordScramble
//
//  Created by Sadman Adib on 3/2/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var newWord = ""
    @State private var usedWords = [String] ()
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
            NavigationView{
            List{
                    Section{
                        TextField("Enter your word", text:$newWord).autocapitalization(.none)
                    }
                Section{
                    ForEach(usedWords, id:\.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        
                    }
                }
            }.navigationTitle(rootWord)
                    .toolbar {
                        Button("Restart", action: startGame)
                    }
            }
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel){}
            }message: {
                Text(errorMessage)
            }
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.title)
            }
    }
    
    func isLongerThanThree(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isDifferent(word: String) -> Bool {
        return !(word == rootWord) 
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                score = 0
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Try another one!")
            return
        }
        if answer.count >= 3{
            guard isReal(word: answer) else {
                wordError(title: "Word not recognized", message: "You cannot just make them up")
                return
            }
        }
        guard isLongerThanThree(word: answer) else {
            wordError(title: "Length too short", message: "Try words having more 2 letters")
            return
        }
        guard isDifferent(word: answer) else {
            wordError(title: "Same Words!", message: "Try something new other than the original one")
            return
        }
        withAnimation{
            usedWords.insert(answer, at:0)
        }
        
        score += usedWords[0].count
       
        newWord=""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
