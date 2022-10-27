//
//  ViewController.swift
//  Project5
//
//  Created by RqwerKnot on 07/10/2022.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = Array<String>()
    var usedWords = Array<String>() {
        didSet {
            save()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty { //in case we could not load the words
            allWords = ["silkworm"]
        }
        
        // UserDefaults challenge:
        let defaults = UserDefaults.standard
        if let savedWords = defaults.stringArray(forKey: "savedWords") {
            title = savedWords[0]
            usedWords = Array( savedWords[1...] )
        } else {
            startGame()
        }
        
        
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Your answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction =  UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowercasedAnswer = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
//        let errorTitle: String // not an issue as long you don't try to access the value before you set it for the first (and last) time
//        let errorMessage: String
        
        guard isPossible(lowercasedAnswer) else {
            showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }
        
        guard isOriginal(lowercasedAnswer) else {
            showErrorMessage(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isReal(lowercasedAnswer) else {
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title!.lowercased())")
            return
        }
        
        usedWords.insert(answer, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
//        if isPossible(lowercasedAnswer) {
//            if isOriginal(lowercasedAnswer) {
//                if isReal(lowercasedAnswer) {
//                    usedWords.insert(lowercasedAnswer, at: 0)
//
//                    let indexPath = IndexPath(row: 0, section: 0)
//                    tableView.insertRows(at: [indexPath], with: .automatic)
//
//                    return // mandatory, otherwise it would continue to the activity controller declaration without having initialized errorTitle and errorMessage
//                } else {
//                    errorTitle = "Word not recognised"
//                    errorMessage = "You can't just make them up, you know!"
//                }
//            } else {
//                errorTitle = "Word used already"
//                errorMessage = "Be more original!"
//            }
//        } else {
//            errorTitle = "Word not possible"
//            errorMessage = "You can't spell that word from \(title!.lowercased())"
//        }
//
//        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
    }
    
    func isPossible(_ proposedWord: String) -> Bool {
        guard var sourceWord = title?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        if sourceWord == proposedWord { return false }
        
        for letter in proposedWord {
            if let position = sourceWord.firstIndex(of: letter) {
                sourceWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(_ word: String) -> Bool {
        !usedWords.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .contains(word)
    }
    
    func isReal(_ word: String) -> Bool {
        if word.count < 3 { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func save() {
        var savedWords = [title ?? ""]
        savedWords.append(contentsOf: usedWords)
        
        let defaults = UserDefaults.standard
        
        defaults.set(savedWords, forKey: "savedWords")
    }
    
}

