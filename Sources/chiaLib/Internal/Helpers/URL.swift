//
//  URL.swift
//  
//
//  Created by Julian Kahnert on 16.01.20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URL {
    init?(localOrRemotePath path: String) {
        if path.lowercased().starts(with: "http") {
            self.init(string: path)
        } else {
            self.init(fileURLWithPath: path)
        }
    }
}
