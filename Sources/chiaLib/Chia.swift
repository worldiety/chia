//
//  Chia.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

public enum Chia {
    public static var providers: [CheckProvider.Type] = [
        LicenseCheck.self,
        ReadmeCheck.self,
        SwiftLintCheck.self
    ]

    public static func runChecks() throws {

        // get project language
        guard let detectedLanguags = Language.detect() else { throw LanguageError.languageDetectionFailed }

        // get all check providers for the detected language or generic ones
        let filteredProviders = providers.filter { $0.type == detectedLanguags || $0.type == .generic }

        for provider in filteredProviders {
            try provider.run()
        }
    }
}
