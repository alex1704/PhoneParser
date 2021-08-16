//
//  File.swift
//  File
//
//  Created by Alex Kostenko on 16.08.2021.
//

import XCTest
@testable import PhoneParser


final class RegionTests: XCTestCase {
    func testFlagsGeneration() throws {
        let countryCodeMap = try loadCountryCodesMap()
        let regionCodes = Array(countryCodeMap.data.values.flatMap { $0 })
        
        for regionCode in regionCodes {
            let region = Region(code: regionCode)
            
            guard region.isValid else {
                continue
            }
            
            XCTAssert(!region.flag.isEmpty)
        }
    }
}
