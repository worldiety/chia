//
//  ChiaError.swift
//  
//
//  Created by Julian Kahnert on 15.01.20.
//

import Foundation

/// Errors that might be thrown by `Chia`.
public enum ChiaError: Error {
    case projectRootNotFound(Error)
    case yamlReadingError(Error)
    case yamlDecodingError(Error)
}
