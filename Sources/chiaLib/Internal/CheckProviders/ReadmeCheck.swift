//
//  LicenseCheck.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

struct ReadmeCheck: CheckProvider {

    static let type: Language = .generic
    private static let missingFileResult = [CheckResult(severity: .error, message: "README.md file could not be found.", metadata: nil)]

    static func run(with config: ChiaConfig, at projectRoot: Folder) throws -> [CheckResult] {
        let fileMissing = !projectRoot.containsFile(at: "README.md")
        return fileMissing ? missingFileResult : []
    }
}
