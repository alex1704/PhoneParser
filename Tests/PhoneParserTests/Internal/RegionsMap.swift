//
//  File.swift
//  File
//
//  Created by Alex Kostenko on 16.08.2021.
//

import Foundation

/// Phone numbers dial codes keyed by region code
struct RegionsMap: Decodable {
    var data: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case phone = "dial_code"
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var output: [String: String] = [:]
        while !container.isAtEnd {
            let nested = try container.nestedContainer(keyedBy: CodingKeys.self)
            let code = try nested.decode(String.self, forKey: .code)
            let phone = try nested.decode(String.self, forKey: .phone)
            output[code] = phone
        }

        data = output
    }
}
