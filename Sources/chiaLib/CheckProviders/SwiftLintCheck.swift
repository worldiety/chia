//
//  SwiftLintCheck.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import ShellOut

struct SwiftLintCheck: CheckProvider {
    static let type: Language = .swift

    // TODO: change this
    static let configUrl = URL(string: "https://github.com/PDF-Archiver/PDF-Archive-Viewer/raw/develop/.swiftlint.yml")

    private static let configPath = ".swiftlint.yml"
    static func run() throws {

        // validate if swiftlint exists
        try canFindDependency(binary: "swiftlint")

        // get config, if not already exists
        let currentFolder = Folder.current
        if !currentFolder.containsFile(at: configPath) {

            // get remote remote config
            guard let url = configUrl,
                let data = try? Data(contentsOf: url) else { throw CheckError.configNotFound }

            let swiftlintConfigUrl = currentFolder.url.appendingPathComponent(configPath)
            try data.write(to: swiftlintConfigUrl)
        }

        // run swiftlint
        do {
            try shellOut(to: "swiftlint")
        } catch {
            throw CheckError.checkFailed(.init(folder: currentFolder, error: error))
        }
    }
}
