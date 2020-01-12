//
//  Language.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

public enum Language: String, Equatable, Codable {
    case generic
    case swift
//    case go
//    case java

    static func detect() -> Language? {
        let folder = Folder.current

        if folder.containsFile(at: "Package.swift") || folder.files.contains(where: { $0.name.hasSuffix("xcodeproj") || $0.name.hasSuffix("xcworkspace") }) {
            return .swift
        } else {
            return nil
        }
    }
}
