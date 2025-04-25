//
//  ContentView.swift
//  WordGarden
//
//  Created by Gary Erickson on 4/9/25.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    private static let maximumGuesses = 8
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var wordsToGuess = ["LOOK", "DOG", "CAT","GRAYSON","THEA", "KENSLEY","JEANETTE", "JOAN", "MIKE", "GARY", "TEST", "WHY", "CANDY", "MORE", "LESS"]
    @State private var currentWordIndex = 0
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var guessedLetter = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = maximumGuesses
    @State private var playItAgainButtonText = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer?
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @FocusState private var textFieldIsFocused: Bool
    var body: some View {
        VStack{
            HStack {
                VStack(alignment: .leading ) {
                    
                    Text(" Words Guessed: \(wordsGuessed)")
                    Text(" Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(" Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text(" Words in Game: \(wordsToGuess.count)")
                }
                .padding(.horizontal)
            }
            Spacer()
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            //Spacer()
            Text(revealedWord)
                .font(.title)
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray,lineWidth: 2)
                            
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else { return }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .focused($textFieldIsFocused)
                        .onSubmit {
                            guard !guessedLetter.isEmpty else { return }
                            guessALetter()
                        }
                    Button("Guess a Letter:") {
                        guessALetter()
                     }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playItAgainButtonText) {
                    if currentWordIndex == wordsToGuess.count - 1 {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playItAgainButtonText = "Another Word?"
                    }
                    
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = Self.maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                }
                .buttonStyle(.bordered)
                .tint(.mint)
                
            }
            //}
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75),
                           value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
        }
        
        
        
    }
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = wordToGuess.map { letter in lettersGuessed.contains(letter) ? "\(letter)" : "_"}.joined(separator: " ")
        updateGamePlay()
       
        
    }
    func updateGamePlay() {
        
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }
           
        } else {
            playSound(soundName: "correct")
        }
        if !revealedWord.contains("_") {
            
            gameStatusMessage = "You Guessed It! It Took You \(lettersGuessed.count) guesses to Guess the Word."
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
         
        } else if guessesRemaining == 0 {
            gameStatusMessage = "So Sorry, You're All Out of Guesses"
            //currentWordIndex += 1
            currentWordIndex = Int.random(in: 0...wordsToGuess.count-1)
            wordsMissed += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es"). Past guesses : \(lettersGuessed)."
        }
        
        if currentWordIndex == wordsToGuess.count {
            playItAgainButtonText = "Restart Game"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All of the Words.  Restart from the Beginning?"
        }
        guessedLetter = ""
        
    }
    func playSound(soundName: String) {
        if audioPlayer != nil && ((audioPlayer?.isPlaying) != nil) {
            audioPlayer?.stop()
        }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer?.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) creating audioPlayer")
        }
    }
    
}
//}

#Preview {
    ContentView()
}
