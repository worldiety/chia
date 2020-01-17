//
//  LicenseCheck.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

struct LicenseCheck: CheckProvider {

    static let languages: [Language] = [.generic]
    static let dependencies: [String] = []
    private static let missingFileResult = [CheckResult(severity: .error, message: "LICENSE file could not be found.", metadata: nil)]
    private static let missingContentResult = [CheckResult(severity: .error, message: "No content in LICENSE file found.", metadata: nil)]

    static func run(with config: ChiaConfig, at projectRoot: Folder) throws -> [CheckResult] {

        // try to find file
        guard let file = try? projectRoot.file(at: "LICENSE") else { return missingFileResult }

        // try to get the file content
        guard let content = try? String(contentsOf: file.url),
            !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return missingContentResult }

        return []
    }
}
