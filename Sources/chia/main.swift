// swiftlint:disable line_length

import chiaLib
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Files
import Logging
import TerminalLog
import TSCUtility

// bootstrap logging
LoggingSystem.bootstrap(TerminalLog.init)
var logger = Logger(label: "chia-cli")

// parse command line argument
let parser = ArgumentParser(commandName: "chia",
                            usage: "[--config path] [--language-detection] [--verbose]",
                            overview: "Run several check like linting etc. in your CI process.")
let configPath: OptionArgument<String> = parser.add(option: "--config", shortName: "-c", kind: String.self, usage: "Path to the Config file (local or remote), e.g. 'https://PATH/TO/.chia.yml'", completion: .filename)
let onlyLanguageDetection: OptionArgument<Bool> = parser.add(option: "--language-detection", kind: Bool.self, usage: "Returns a project language for a given root folder. All checks will be skipped.")
let verboseModeActive: OptionArgument<Bool> = parser.add(option: "--verbose", shortName: "-v", kind: Bool.self, usage: "Increse logging.")

do {
    let result = try parser.parse(Array(CommandLine.arguments.dropFirst()))

    // set logging level
    let increasedLogging = result.get(verboseModeActive) ?? false
    logger.logLevel = increasedLogging ? .debug : .warning

    // setup chia
    var chia = Chia(logger: logger)

    // try to get a config path from the CLI - use default config otherwise
    if let configPath = result.get(configPath) {

        guard let url = URL(localOrRemotePath: configPath) else {
                logger.error("Could not find a config at:\n\(configPath)")
                exit(1)
        }
        try chia.setConfig(from: url)
    } else {

        // no url is provided - use the default one
        try chia.setConfig(from: nil)
    }

    if result.get(onlyLanguageDetection) ?? false {
        if let detectedLanguage = chia.detectProjectLanguage() {
            logger.info("Language: \(detectedLanguage)")
        } else {
            logger.warning("No language detected.")
        }
    } else {
        try chia.runChecks()
    }
} catch ArgumentParserError.expectedValue(let value) {
    logger.error("Missing value for argument \(value).")
    exit(1)
} catch ArgumentParserError.expectedArguments(_, let stringArray) {
    logger.error("Missing arguments: \(stringArray.joined()).")
    exit(1)
} catch {
    logger.error("\(error.localizedDescription)")
    exit(1)
}
exit(0)
