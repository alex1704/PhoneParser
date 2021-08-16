//
//  File.swift
//  File
//
//  Created by Alex Kostenko on 16.08.2021.
//

import Foundation

func load<Entity: Decodable>(name: String, subfolder: String = "Resources") throws -> Entity {
    guard let url = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: subfolder) else {
        throw TestsError.resouceAbsent
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(Entity.self, from: data)
}

func loadCountryCodesMap() throws -> CountryCodeMap {
    try load(name: "countryCodes.json")
}

func loadRegionsMap() throws -> RegionsMap {
    try load(name: "regionPhones.json")
}
