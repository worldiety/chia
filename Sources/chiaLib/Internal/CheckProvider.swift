//
//  CheckProvider.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Files
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging
import ShellOut

protocol CheckProvider {
    static var type: Language { get }
    static func run(with config: ChiaConfig, at projectRoot: Folder) throws -> [CheckResult]
}

extension CheckProvider {

    static var logger: Logger {
        Logger(label: "CheckProvider")
    }

    static func canFindDependency(binary: String) throws {
        do {
            try shellOut(to: "which", arguments: [binary])
        } catch {
            logger.error("Could not find the dependency '\(binary)'.\n\(error.localizedDescription)")
            throw CheckError.dependencyNotFound(dependency: binary)
        }
    }

    static func isPart(of providers: [String]) -> Bool {
        let selfDescription = String(describing: Self.self).lowercased()
        return providers.contains { selfDescription.contains($0.lowercased()) }
    }
}
