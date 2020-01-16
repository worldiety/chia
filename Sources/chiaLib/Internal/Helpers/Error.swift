//
//  Error.swift
//  
//
//  Created by Julian Kahnert on 15.01.20.
//

extension Error {
    static func perform<T>(_ expression: @autoclosure () throws -> T, errorTransform: (Error) -> Self) throws -> T {
        do {
            return try expression()
        } catch {
            throw errorTransform(error)
        }
    }
}
