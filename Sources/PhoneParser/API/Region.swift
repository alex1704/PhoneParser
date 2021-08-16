//
//  Region.swift
//  Region
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation

public struct Region {
    public let code: String
}

public extension Region {
    var flag: String {
        code.unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    var isValid: Bool {
        // ISO country code length == 2
        code.count == 2
    }
}
