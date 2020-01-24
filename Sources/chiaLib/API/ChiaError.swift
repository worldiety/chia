//
//  ChiaError.swift
//  
//
//  Created by Julian Kahnert on 15.01.20.
//

import Foundation

/// Errors that might be thrown by `Chia`.
public enum ChiaError: String, Error {
    case projectRootNotFound
    case yamlReadingError
    case yamlDecodingError
    case configNotFound
    case someChecksFailed
}
