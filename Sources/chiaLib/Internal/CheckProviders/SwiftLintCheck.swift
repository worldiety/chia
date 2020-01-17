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
    static let languages: [Language] = [.swift]
    static let dependencies: [String] = ["swiftlint"]
    private static let configFilename = ".swiftlint.yml"

    static func run(with config: ChiaConfig, at projectRoot: Folder) throws -> [CheckResult] {

        // get config, if not already exists
        var customSwiftLintConfigUrl: URL?
        if let path = config.swiftLintConfig?.lintingRulesPath {

            // get local or remote config
            guard let url = URL(localOrRemotePath: path),
                let data = try? Data(contentsOf: url) else { throw CheckError.configPathNotFound(path: path) }

            let swiftlintConfigUrl = projectRoot.url.appendingPathComponent(configFilename)
            try data.write(to: swiftlintConfigUrl)
            customSwiftLintConfigUrl = swiftlintConfigUrl
        }

        do {
            // cleanup config, if it was downloaded
            defer {
                if let customSwiftLintConfigUrl = customSwiftLintConfigUrl {
                    try? FileManager.default.removeItem(at: customSwiftLintConfigUrl)
                }
            }

            // run swiftlint
            let jsonOutput = try shellOut(to: "swiftlint", arguments: ["lint", "--quiet", "--reporter json"], at: projectRoot.path)
            guard let outputData = jsonOutput.data(using: .utf8) else {
                return [CheckResult(severity: .error, message: "Could not create data from SwiftLint output.", metadata: nil)]
            }
            return parseAndLog(output: outputData)

        } catch let error {
            if let shellOutError = error as? ShellOutError,

                let outputData = shellOutError.output.data(using: .utf8) {
                return parseAndLog(output: outputData)

            } else {
                throw CheckError.checkFailed(with: .init(folder: projectRoot, error: error))
            }
        }
    }

    private static func parseAndLog(output data: Data) -> [CheckResult] {

        guard let violatons = try? JSONDecoder().decode([Violation].self, from: data) else {
            return [CheckResult(severity: .error, message: "Failed to parse violations!", metadata: nil)]
        }

        return violatons.map { violation in
            CheckResult(severity: violation.severity,
                        message: "\(violation.type) - \(violation.reason)",
                        metadata: ["file": .string(violation.file), "line": .stringConvertible(violation.line)])
        }
    }
}

// MARK: - SwiftLint Codable Output

extension SwiftLintCheck {
    struct Violation: Codable {
        let character: Int?
        let file: String
        let line: Int
        let reason: String
        let ruleID: String
        let severity: CheckResult.Severity
        let type: String

        enum CodingKeys: String, CodingKey {
            case character, file, line, reason
            case ruleID = "rule_id"
            case severity, type
        }
    }
}
