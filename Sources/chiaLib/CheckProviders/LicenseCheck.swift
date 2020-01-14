//
//  LicenseCheck.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

struct LicenseCheck: CheckProvider {
    static let type: Language = .generic

    static func run() throws {
        let folder = Folder.current
        guard folder.containsFile(at: "LICENSE") else {
            throw CheckError.checkFailed(.init(folder: folder, error: nil))
        }
    }
}
