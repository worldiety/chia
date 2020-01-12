//
//  CheckProvider.swift
//  
//
//  Created by Julian Kahnert on 12.01.20.
//

import Foundation
import ShellOut

public protocol CheckProvider {
    static var type: Language { get }
    static var configUrl: URL? { get }

    static func run() throws
}

public extension CheckProvider {
    static var configUrl: URL? { nil }

    static func canFindDependency(binary: String) throws {
        do {
            try shellOut(to: "which", arguments: [binary, ">", "/dev/null"])
        } catch {
            throw CheckError.dependencyNotFound(binary)
        }
    }
}
