//
//  LicenseCheck.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

struct ReadmeCheck: CheckProvider {
    static let type: Language = .generic

    static func run(with config: ChiaConfig, at projectRoot: Folder) throws {
        guard projectRoot.containsFile(at: "README.md") else {
            throw CheckError.checkFailed(.init(folder: projectRoot, error: nil))
        }
    }
}
