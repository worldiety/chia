//
//  SpellCheck.swift
//  
//
//  Created by Julian Kahnert on 03.02.20.
//

#if canImport(Cocoa)
import Cocoa
#endif
import Foundation

extension SpellCheck {
    static func createSpellChecker(with ignoredWords: [String]) -> SpellChecker {
        let spellChecker: SpellChecker
        #if canImport(Cocoa)
        let tmp = NSSpellChecker.shared
        tmp.setIgnoredWords(ignoredWords, inSpellDocumentWithTag: 0)
        tmp.setLanguage("en_US")
        spellChecker = tmp
        #else
        print("SpellChecker on this OS currently not supported!")
        spellChecker = Anspell()
        #endif
        return spellChecker
    }
}

protocol SpellChecker {
    func findMisspelled(in text: String) -> String?
}

#if canImport(Cocoa)
extension NSSpellChecker: SpellChecker {
    func findMisspelled(in text: String) -> String? {
        let misspelledRange = self.checkSpelling(of: text, startingAt: 0)
        if misspelledRange.location < text.count {
            return (text as NSString).substring(with: misspelledRange)
        }
        return nil
    }
}
#endif

struct Anspell: SpellChecker {
    func findMisspelled(in text: String) -> String? {
        return nil
    }
}
