//
//  File.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files

public enum CheckError: Error {
    case checkFailed(Info)
    case dependencyNotFound(String)
    case configNotFound
}

public extension CheckError {
    struct Info: CustomStringConvertible {
        let folder: Folder
        let error: Error?
        public var description: String {
            let files = folder.files.map { $0.name }
            return """
            Current Working Directory: \(folder)
            Files: \(files.joined(separator: ", "))

            Error: \(error?.localizedDescription ?? "")
            """
        }
    }
}
