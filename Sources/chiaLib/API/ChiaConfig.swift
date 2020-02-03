//
//  ChiaConfig.swift
//  
//
//  Created by Julian Kahnert on 15.01.20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Base config for `Chia`.
///
/// All `CheckProvider` configs should be added as properties here.
public struct ChiaConfig: Codable {

    /// Providers that should be skipped.
    public let skippedProviders: [String]?

    /// Use this appendix, if your project has a diffrent root folder.
    ///
    /// In the following example the `projectRootAppendix` would be `MyCoolPrject`.
    /// ```
    /// .
    /// ├── .git
    /// ├── i18n
    /// │   ├── de
    /// │   └── en
    /// └── MyCoolPrject
    ///     ├── Sources
    ///     ├── Tests
    ///     ├── Package.swift
    ///     └── .git
    /// ```
    public let projectRootAppendix: String?

    /// Config: `SwiftLintCheck`
    public let swiftLintConfig: SwiftLint?

    /// Config: `SpellCheck`
    public let spellCheckConfig: SpellCheck?

    public init(skippedProviders: [String]? = nil, projectRootAppendix: String? = nil, swiftLintConfig: SwiftLint? = nil, spellCheckConfig: SpellCheck? = nil) {
        self.skippedProviders = skippedProviders
        self.projectRootAppendix = projectRootAppendix
        self.swiftLintConfig = swiftLintConfig
        self.spellCheckConfig = spellCheckConfig
    }
}

// MARK: - Individual CheckProvider configs

public extension ChiaConfig {

    // MARK: - SwiftLint
    struct SwiftLint: Codable {
        let lintingRulesPath: String?

        public init(lintingRulesPath: String? = nil) {
            self.lintingRulesPath = lintingRulesPath
        }
    }

    // MARK: - SpellCheck
    struct SpellCheck: Codable {
        let ignoredFiles: [String]
        let ignoredWords: [String]

        public init(ignoredFiles: [String] = [String](), ignoredWords: [String] = [String]()) {
            self.ignoredFiles = ignoredFiles
            self.ignoredWords = ignoredWords
        }
    }

    // MARK: - $YourProviderHere
}
