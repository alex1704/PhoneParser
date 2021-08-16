import XCTest
@testable import PhoneParser


final class PhoneParserTests: XCTestCase {
    func testRegionGuessing() throws {
        let parser = PhoneParser()
        let countryCodeMap = try loadCountryCodesMap()
        for (countryCode, regionCodes) in countryCodeMap.data {
            let regionCode = regionCodes[0]
            guard let region = try parser.region(from: PhoneNumber(value: "\(countryCode)")) else {
                throw TestsError.generic(debug: "No region for \(countryCode)")
            }

            XCTAssertEqual(regionCode, region.code)
        }

        XCTAssert(true)
    }

    func testRegionPhones() throws {
        let parser = PhoneParser()
        let extendedCodeMap = try loadRegionsMap()

        for (regionCode, phone) in extendedCodeMap.data {

            guard let region = try parser.region(from: PhoneNumber(value: "\(phone)")) else {
                throw TestsError.generic(debug: "No region for \(phone)")
            }

            XCTAssertEqual(regionCode, region.code)
        }
    }
    
    func testCanadaCodes() throws {
        let parser = PhoneParser()
        for code in canadaCountryCodes {
            guard let region = try parser.region(from: PhoneNumber(value: "\(code)")) else {
                throw TestsError.generic(debug: "No region for \(code)")
            }

            XCTAssertEqual("CA", region.code)
        }
    }
    
    func testPhoneNumberGeneration() throws {
        let parser = PhoneParser()
        let countryCodeMap = try loadCountryCodesMap()
        let regionPhoneMap = try loadRegionsMap()
        let check: (String, [String]) throws -> Void = { countryCode, regionCodes in
            guard let regionCode = regionCodes.first else {
                throw TestsError.unknown
            }

            guard Region(code: regionCode).isValid else {
                return
            }

            let phone = try parser.exampleNumber(for: Region(code: regionCode), startsWith: PhoneNumber(value: countryCode))
            let phoneValue = phone.value(for: .pureNumber)
            XCTAssert(phoneValue.starts(with: countryCode), "\(phone) do not start with \(countryCode)")
            XCTAssert(phoneValue.count > countryCode.count)
        }

        try countryCodeMap.data.forEach { try check($0, $1) }
        try regionPhoneMap.data.forEach { try check($1.cleanedUpPhoneNumberString, [$0]) }
    }
    
    func testPhoneNumberGenerateExceptionOnInvalidRegion() throws {
        let parser = PhoneParser()
        var thrownError: Swift.Error?

        XCTAssertThrowsError( try parser.exampleNumber(for: Region(code: "")) ) {
            thrownError = $0
        }

        XCTAssertEqual(PhoneParserError.invalidRegion.localizedDescription, thrownError?.localizedDescription)
    }
    
}

extension PhoneParserTests {
    var canadaCountryCodes: [String] {
        // https://www.rebtel.com/en/international-calling-guide/phone-codes/canada/
        ["587", "250", "604", "778", "289", "905", "204", "514", "506", "709", "226", "519", "613", "705", "807", "819", "306"].map { "+1\($0)" }
    }
}
