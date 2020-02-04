//
//  CheckResult.swift
//  
//
//  Created by Julian Kahnert on 17.01.20.
//

import Logging

struct CheckResult {
    let severity: Severity
    let message: String
    let metadata: Logger.Metadata?

    enum Severity: String, Codable {
        case error = "Error"
        case warning = "Warning"
    }

    static func warning(msg: String, metadata: Logger.Metadata? = nil) -> CheckResult {
        CheckResult(severity: .warning, message: msg, metadata: metadata)
    }

    static func error(msg: String, metadata: Logger.Metadata? = nil) -> CheckResult {
        CheckResult(severity: .error, message: msg, metadata: metadata)
    }
}
