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
import ShellOut

protocol CheckProvider {
    static var type: Language { get }
    static func run(with config: ChiaConfig, at projectRoot: Folder) throws
}

extension CheckProvider {
    static func canFindDependency(binary: String) throws {
        do {
            try shellOut(to: "which", arguments: [binary, ">", "/dev/null"])
        } catch {
            throw CheckError.dependencyNotFound(binary)
        }
    }

    static func isPart(of providers: [String]) -> Bool {
        let selfDescription = String(describing: Self.self).lowercased()
        return providers.contains { selfDescription.contains($0.lowercased()) }
    }
}
