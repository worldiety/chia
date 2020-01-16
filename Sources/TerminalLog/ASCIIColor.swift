//
//  ASCIIColor.swift
//  
//
//  Created by Julian Kahnert on 16.01.20.
//
// Source: https://stackoverflow.com/a/56510700/10026834

enum ASCIIColor: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T, color: ASCIIColor) {
        appendInterpolation("\(color.rawValue)\(value)\(ASCIIColor.default.rawValue)")
    }
}
