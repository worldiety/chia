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
import ShellOut
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

    /// Filename that will be searched if no config url will be provided.
    private let localConfigFilename = ".chia.yml"

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
            logger?.info("Using config from: \(url.path)")

        } else {
            if let localConfigString = try? String(contentsOf: Folder.current.url.appendingPathComponent(localConfigFilename)),
                let localConfig = try? YAMLDecoder().decode(ChiaConfig.self, from: localConfigString) {
                logger?.info("Using local config from: \(localConfigFilename)")
                config = localConfig
            } else {
                logger?.info("Using default chia config.")
                config = ChiaConfig()
            }
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
            let projectRootFolder = self.projectRootFolder else { throw ChiaError.configNotFound }

        // get project language
        guard let detectedLanguage = Language.detect(at: projectRootFolder) else { throw LanguageError.languageDetectionFailed }
        logger?.info("Detected the language: \(detectedLanguage)")

        // get all check providers for the detected language or generic ones
        let filteredProviders = Chia.providers.filter { ($0.languages.contains(detectedLanguage) || $0.languages.contains(.generic)) && !$0.isPart(of: config.skippedProviders ?? []) }
        logger?.info("These checks will be used:\n\(filteredProviders.map { String(describing: $0) })")

        // run all checks
        var results = [CheckResult]()
        for provider in filteredProviders {
            do {

                // validate if all dependencies (e.g. "swiftlint") exist
                for dependency in provider.dependencies {
                    try canFindDependency(binary: dependency)
                }

                // run the check
                let checkResults = try provider.run(with: config, at: projectRootFolder)
                results.append(contentsOf: checkResults)

            } catch CheckError.checkFailed(let info) {
                results.append(CheckResult(severity: .error, message: "CheckError: Failed with info: \(info.description)", metadata: ["checkProvider": .string(String(describing: provider))]))
            } catch CheckError.dependencyNotFound(let dependency) {
                results.append(CheckResult(severity: .error, message: "CheckError: Dependency '\(dependency)' not found.", metadata: ["checkProvider": .string(String(describing: provider))]))
            } catch CheckError.configPathNotFound(let path) {
                results.append(CheckResult(severity: .error, message: "CheckError: Config path invalid: '\(path)'", metadata: ["checkProvider": .string(String(describing: provider))]))
            } catch {
                results.append(CheckResult(severity: .error, message: "\(error.localizedDescription)", metadata: ["checkProvider": .string(String(describing: provider))]))
            }
        }

        // log the output of all checks
        log(results)

        // throw an error if a check failed - this will result in an exit(1) in the 
        if !results.isEmpty {
            throw ChiaError.someChecksFailed
        }
    }

    // MARK: - Helper Function

    private func perform<T>(_ expression: @autoclosure () throws -> T, msg: String, errorTransform: (Error) -> ChiaError) throws -> T {
        return try ChiaError.perform(expression()) { error in
            logger?.error(Logger.Message(extendedGraphemeClusterLiteral: msg), metadata: ["error": .string(error.localizedDescription)])
            return errorTransform(error)
        }
    }

    private func canFindDependency(binary: String) throws {
        do {
            try shellOut(to: "which", arguments: [binary])
        } catch {
            throw CheckError.dependencyNotFound(dependency: binary)
        }
    }

    private func log(_ results: [CheckResult]) {

        logger?.info("\n\nCheck Results:\n")
        let warnings = results.filter { $0.severity == .warning }
        for warning in warnings {
            logger?.warning("WARNING: \(warning.message)", metadata: warning.metadata)
        }

        let errors = results.filter { $0.severity == .error }
        for error in errors {
            logger?.error("ERROR: \(error.message)", metadata: error.metadata)
        }

        if warnings.isEmpty && errors.isEmpty {
            logger?.notice("\nAll checks successful.\n")
        } else if errors.isEmpty {
            logger?.warning("\nFound \(warnings.count) warnings.\n")
        } else {
            logger?.error("\nFound \(errors.count) errors and \(warnings.count) warnings.\n")
        }
    }
}
