//
//  Collection.swift
//  
//
//  Created by Julian Kahnert on 17.01.20.
//

extension Collection where Element: Hashable {
    func getMostFrequent() -> Element? {
        let mappedItems = self.map { ($0, 1) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        if let (value, _) = counts.max(by: { $0.1 < $1.1 }) {
            return value
        }
        return nil
    }
}
