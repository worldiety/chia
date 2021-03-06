//
//  TerminalLog.swift
//  
//
//  Created by Julian Kahnert on 16.01.20.
//
// Source: https://github.com/chrisaljoudi/swift-log-oslog

import Logging

public struct TerminalLog: LogHandler {

    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }
    public var logLevel: Logger.Level = .info
    private let xcodeOutput: Bool
    private var prettyMetadata: String?

    public init(xcodeOutput: Bool = false) {
        self.xcodeOutput = xcodeOutput
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {

        var combinedPrettyMetadata = self.prettyMetadata
        if let metadataOverride = metadata, !metadataOverride.isEmpty {
            combinedPrettyMetadata = self.prettify(
                self.metadata.merging(metadataOverride) {
                    return $1
                }
            )
        }

        var formedMessage = message.description
        if let combinedPrettyMetadata = combinedPrettyMetadata {
            formedMessage += " -- " + combinedPrettyMetadata
        }

        if xcodeOutput,
            let filename = metadata?["file"]?.description,
            let linenumber = metadata?["line"]?.description {
            
            var typeId = ""
            if let type = metadata?["rule_id"]?.description {
                typeId = " (\(type))"
            }
            print("\(filename):\(linenumber):1: \(level.rawValue): \(message.description)\(typeId)")
        } else {
            print("\(formedMessage, color: getColor(for: level))")
        }
    }

    /// Add, remove, or change the logging metadata.
    /// - parameters:
    ///    - metadataKey: the key for the metadata item.
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map {
            "\($0)=\($1)"
        }.joined(separator: " ")
    }

    private func getColor(for level: Logger.Level) -> ASCIIColor {
        let color: ASCIIColor
        switch level {
        case .critical, .error:
            color = .red
        case .warning:
            color = .yellow
        case .notice:
            color = .green
        default:
            color = .default
        }
        return color
    }
}
