//
//  File.swift
//  File
//
//  Created by Alex Kostenko on 16.08.2021.
//

import Foundation

/// Encapsulate region codes keyed by  country codes
struct CountryCodeMap: Decodable {
    let data: [String: [String]]
    
    enum CodingKeys: String, CodingKey {
        case data = "countryCodeToRegionCodeMap"
    }
}
