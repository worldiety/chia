//
//  Chia.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Yams

/// Main part of `Chia`.
public enum Chia {

    /// Array of all available `CheckProvider`s.
    ///
    /// Please add your new provider to this list. :)
    static let providers: [CheckProvider.Type] = [
        LicenseCheck.self,
        ReadmeCheck.self,
        SwiftLintCheck.self
    ]

    /// Parse the `.chia.yml` configuration file.
    ///
    /// ```
    /// skippedProviders:
    ///     - ReadmeCheck
    ///
    /// projectRootAppendix: null
    ///
    /// swiftLintConfig:
    ///     lintingRulesPath: https://raw.githubusercontent.com/USERNAME/REPONAME/master/.swiftlint.yml
    ///
    /// ```
    ///
    /// This function might throw an`Error`.
    ///
    /// - Parameter path: Path of the `.chia.yml` configuration file.
    public static func getConfig(from path: URL) throws -> ChiaConfig {
        let encodedYAML = try ChiaError.perform(String(contentsOf: path)) { error in
            return .yamlReadingError(error)
        }
        return try ChiaError.perform(YAMLDecoder().decode(ChiaConfig.self, from: encodedYAML)) { error in
            return .yamlDecodingError(error)
        }
    }

    /// Main API of `Chia`.
    ///
    /// This function detects the project language and runs all checks.
    public static func runChecks(with config: ChiaConfig) throws {

        // append project root from config, if needed
        let projectRoot: Folder
        if let appendix = config.projectRootAppendix {
            projectRoot = try ChiaError.perform(Folder.current.subfolder(at: appendix)) { error in
                return .projectRootNotFound(error)
            }
        } else {
            projectRoot = Folder.current
        }

        // get project language
        guard let detectedLanguags = Language.detect(at: projectRoot) else { throw LanguageError.languageDetectionFailed }

        // get all check providers for the detected language or generic ones
        let filteredProviders = providers.filter { ($0.type == detectedLanguags || $0.type == .generic) && !$0.isPart(of: config.skippedProviders ?? []) }

        for provider in filteredProviders {
            try provider.run(with: config, at: projectRoot)
        }
    }
}
