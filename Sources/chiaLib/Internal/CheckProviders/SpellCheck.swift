//
//  SpellCheck.swift
//  
//
//  Created by Julian Kahnert on 03.02.20.
//

import Files
import SwiftSyntax
#if canImport(Cocoa)
import Cocoa
#endif

@available(macOS 10.12, *)
struct SpellCheck: CheckProvider {

    static let languages: [Language] = [.generic]
    static let dependencies: [String] = []

    static func run(with config: ChiaConfig, at projectRoot: Folder) throws -> [CheckResult] {

        let supportedExtensions = Set(languages.flatMap { $0.getExtensions() })
        let ignoredFiles = Set(config.spellCheckConfig?.ignoredFiles ?? [])
        let ignoredWords = config.spellCheckConfig?.ignoredWords ?? []

        // TODO: use SpellChecker protocol
        let spellChecker = NSSpellChecker.shared
        spellChecker.setIgnoredWords(ignoredWords, inSpellDocumentWithTag: 0)
        spellChecker.setLanguage("en_US")

        return projectRoot.files.recursive.includingHidden
            .filter { supportedExtensions.contains($0.extension?.lowercased() ?? "") }
            .filter { !ignoredFiles.contains($0.name) }
            .flatMap { analyse(file: $0, with: spellChecker) }
    }

    static func analyse(file: File, with spellChecker: NSSpellChecker) -> [CheckResult] {
        let fileExtension = file.extension?.lowercased()
        switch fileExtension ?? "" {
        case "swift":

            let syntaxTree: SourceFileSyntax
            do {
                syntaxTree = try SyntaxParser.parse(file.url)
            } catch {
                return [CheckResult(severity: .warning, message: "Could not parse SwiftSyntax.", metadata: ["error": .string(error.localizedDescription)])]
            }

            return syntaxTree.tokens.flatMap { $0.leadingTrivia.compactMap({ $0.comment }) }
                .compactMap { spellChecker.findMisspelled(in: $0) }
                .map { .warning(msg: "Misspelled Word: \($0)") }

        case "md":
            guard let fileContent = try? String(contentsOf: file.url) else { return [] }
            return fileContent.split(separator: "\n")
                .compactMap { spellChecker.findMisspelled(in: String($0)) }
                .map { .warning(msg: "Misspelled Word: \($0)") }

        default:
            if let fileExtension = fileExtension,
                !fileExtension.isEmpty {
                return [.warning(msg: "No parser found for filetype '\(fileExtension)'")]
            } else {
                return []
            }
        }
    }
}

fileprivate extension NSSpellChecker {
    func findMisspelled(in text: String) -> String? {
        let misspelledRange = self.checkSpelling(of: text, startingAt: 0)
        if misspelledRange.location < text.count {
            return (text as NSString).substring(with: misspelledRange)
        }
        return nil
    }
}

extension TriviaPiece {
    public var comment: String? {
        switch self {
        case .spaces,
             .tabs,
             .verticalTabs,
             .formfeeds,
             .newlines,
             .carriageReturns,
             .carriageReturnLineFeeds,
             .backticks,
             .garbageText:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }

    public var isNewline: Bool {
        switch self {
        case .newlines:
            return true
        default:
            return false
        }
    }
}
