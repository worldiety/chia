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
import Logging
import Yams

/// Main part of `Chia`.
public struct Chia {

    /// Array of all available `CheckProvider`s.
    ///
    /// Please add your new provider to this list. :)
    static let providers: [CheckProvider.Type] = [
        LicenseCheck.self,
        ReadmeCheck.self,
        SwiftLintCheck.self
    ]

    /// `Logger` instance that gets injected.
    private let logger: Logger?

    /// `ChiaConfig` that will be save in the `setConfig(from:)` method.
    private var config: ChiaConfig?

    /// Root folder of the project.
    ///
    /// It includes the `Package.swift` file or might include the `.git` folder and is set in the  `setConfig(from:)` method.
    private var projectRootFolder: Folder?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    /// Parse the `.chia.yml` configuration file.
    ///
    /// If no url is provided, this functions sets the default config.
    /// This sets also the project root acording to the config.
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
    public mutating func setConfig(from url: URL?) throws {
        if let url = url {
            let encodedYAML = try perform(String(contentsOf: url),
                                          msg: "Config YAML could not be read.",
                                          errorTransform: { .yamlReadingError($0) })

            config = try perform(YAMLDecoder().decode(ChiaConfig.self, from: encodedYAML),
                                 msg: "YAML is not valid could not be decoded.",
                                 errorTransform: { .yamlDecodingError($0) })
        } else {
            config = ChiaConfig()
        }

        // append project root from config, if needed
        if let appendix = config?.projectRootAppendix {
            projectRootFolder = try perform(Folder.current.subfolder(at: appendix),
                                      msg: "Could not find subfolder '\(appendix)'.",
                                      errorTransform: { .projectRootNotFound($0) })
        } else {
            projectRootFolder = Folder.current
        }
    }

    /// Returns a project language for a given root folder.
    public func detectProjectLanguage() -> Language? {
        guard let projectRootFolder = self.projectRootFolder else {
            logger?.error("Could not find a projectRootFolder!")
            return nil
        }
        return Language.detect(at: projectRootFolder)
    }

    /// Main API of `Chia`.
    ///
    /// This function detects the project language and runs all checks.
    public func runChecks() throws {

        guard let config = self.config,
            let projectRootFolder = self.projectRootFolder else { throw CheckError.configNotFound }

        // get project language
        guard let detectedLanguags = Language.detect(at: projectRootFolder) else { throw LanguageError.languageDetectionFailed }

        // get all check providers for the detected language or generic ones
        let filteredProviders = Chia.providers.filter { ($0.type == detectedLanguags || $0.type == .generic) && !$0.isPart(of: config.skippedProviders ?? []) }

        var noCheckFailed = true
        for provider in filteredProviders {
            do {
                try perform(provider.run(with: config, at: projectRootFolder),
                            msg: "Check Failed [\(provider)]",
                    errorTransform: { .checkFailed($0) })
            } catch {
                logger?.error("\(error)")
                noCheckFailed = false
            }
        }

        if noCheckFailed {
            logger?.info("All checks successful. We used:\n\(filteredProviders)")
        }
    }

    // MARK: - Helper Function

    private func perform<T>(_ expression: @autoclosure () throws -> T, msg: String, errorTransform: (Error) -> ChiaError) throws -> T {
        return try ChiaError.perform(expression()) { error in
            logger?.error(Logger.Message(extendedGraphemeClusterLiteral: msg), metadata: ["error": .string(error.localizedDescription)])
            return errorTransform(error)
        }
    }

}
