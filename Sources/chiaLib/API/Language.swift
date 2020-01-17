//
//  Language.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

/// All languages that `Chia` can handle.
///
/// The `generic` type should be used for language independent check, e.g. the LicenseCheck.
public enum Language: String, Equatable, Codable {
    case generic
    case swift
    case go
//    case java
//    case javaSpringBoot

    static func detect(at projectRoot: Folder) -> Language? {
        if projectRoot.containsFile(at: "Package.swift") || projectRoot.subfolders.contains(where: { $0.name.hasSuffix("xcodeproj") || $0.name.hasSuffix("xcworkspace") }) {
            return .swift
        } else if let mostFrequentFileExt = projectRoot.files.compactMap({ $0.extension }).getMostFrequent(),
            mostFrequentFileExt.lowercased() == "go" {
            return .go
        } else {
            return nil
        }
    }
}
