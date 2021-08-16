//
//  PhoneParser.swift
//  PhoneParser
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation
import libPhoneNumber

public enum PhoneParserError: Error {
    case unknown
    case `internal`(description: String)
    case invalidRegion
}

public class PhoneParser {
    
    // MARK: - Public
    
    public init() {
        helper = NBMetadataHelper()!
        util = NBPhoneNumberUtil(metadataHelper: helper)!
    }
    
    /// Infer Region code (ISO country code') from PhoneNumber
    /// - Parameter phone: Encapsulate phone number string
    /// - Returns: Region with string code (ISO country code) if possible
    public func region(from phone: PhoneNumber) throws -> Region? {
        if let parsedNumber = try? util.parse(withPhoneCarrierRegion: phone.value(for: .mobile)),
           util.isValidNumber(parsedNumber) {
            
            guard let code =  util.getRegionCode(for: parsedNumber) else {
                // No reason for this to be fired - we have valid number
                throw PhoneParserError.unknown
            }
            
            return Region(code: code)
        } else {
            guard let code = inferRegionCodeByShortening(phone: phone) else {
                return nil
            }
            
            let region = Region(code: code)
            
            guard let specificRegion = try specificRegion(from: Region(code: code), phone: phone) else {
                return region
            }
            
            return specificRegion
        }
    }
    
    /// Generates example phone number via NBPhoneNumberUtil from given Region
    /// If ''startsWith'' is provided then begining returned value will be overwritten by it.
    /// If "startsWith" length is equal to generated example phone then returned value would be equal to "startsWith"
    /// - Parameters:
    ///   - region: Region with ISO country code
    ///   - phone: PhoneNumber which overwrite
    /// - Returns: PhoneNumber example for given Region
    public func exampleNumber(
        for region: Region,
        startsWith phone: PhoneNumber? = nil
    ) throws -> PhoneNumber {
        guard region.isValid else {
            throw PhoneParserError.invalidRegion
        }
        
        let exampleNumber = try perform(try util.getExampleNumber(forType: region.code, type: .MOBILE)) { err in
            PhoneParserError.internal(description: "util.getExampleNumber(forType:type:) error = \(err); region == \(region.code)")
        }
        
        let exampleNumberValue =  try perform(try util.format(exampleNumber, numberFormat: .INTERNATIONAL).cleanedUpPhoneNumberString) { err in
            PhoneParserError.internal(description: "util.format(_, numberFormat:) error = \(err); nbNumber == \(exampleNumber)")
        }
        
        let phonePrefix = phone?.value(for: .pureNumber) ?? ""
        let phoneSuffix = String(exampleNumberValue.dropFirst(phonePrefix.count))
        
        return try generateValidatedPhoneNumber(phonePrefix: phonePrefix, phoneSuffix: phoneSuffix)
    }
    
    // MARK: - Private
    // MARK: -
    
    private let helper: NBMetadataHelper
    private let util: NBPhoneNumberUtil
    
    // MARK: -
    
    /// Try to infer specific region from given Region and provided PhoneNumber
    /// To find out phone number's country sometimes country code is not enough, we also need to find out are code
    /// For example "+1 240" (US) and "+1 587" (CA) have the same country code (1) but area code defines country
    /// - Parameters:
    ///   - region: Region to generate starter phone number example
    ///   - phone: Phone number which will override beining of generated phone number example. We generate example number in order to know valid phone number length for given region
    /// - Returns: Specific region (SC) with ISO country code if SC = country code + area code and provided phone has country code + area code in it
    private func specificRegion(
        from region: Region,
        phone: PhoneNumber
    ) throws -> Region? {
        guard let formatter = NBAsYouTypeFormatter(regionCode: region.code) else {
            throw PhoneParserError.internal(description: "Unable instanciate NBAsYouTypeFormatter for region \(region.code)")
        }
        
        // do not try to infer specific region if area code is absent
        guard formatter.phonePrefix(from: phone) != nil else {
            return nil
        }
        
        let examplePhone = try exampleNumber(for: region, startsWith: phone)
        let phoneNumber = try perform(try util.parse(withPhoneCarrierRegion: examplePhone.value(for: .mobile))) { err in
            PhoneParserError.internal(description: "util.parse(withPhoneCarrierRegion:) error = \(err)")
        }
        
        guard let code = util.getRegionCode(for: phoneNumber) else {
            return nil
        }
        
        return Region(code: code)
    }
    
    /// Try to infer ISO country code (ex. 'US') in iterations.
    /// If previous iteration failed to infer country code then we remove phone number last digit on next one till we find ISO country code or fail.
    /// - Parameter phone: phone number to infer ISO country code from
    /// - Returns: ISO country code
    private func inferRegionCodeByShortening(phone: PhoneNumber) -> String? {
        var value = phone.value(for: .pureNumber)
        
        while value.count >= 1 {
            if let countryCode = Int(value),
               let regionCode = firstRegionCode(fromCountryCode: NSNumber(integerLiteral: countryCode)) {
                return regionCode
            }
            
            value = String(value.dropLast())
        }
        
        return nil
    }
    
    /// All ISO country codes (ex 'US') defined as lists keyed by country code.  If  ISO country code = country code + area code then there will be multiple entries in country code list otherwise one entry. Here we always select first entry.
    /// - Parameter countryCode: Country code number, ex 1
    /// - Returns: ISO country code
    private func firstRegionCode(fromCountryCode countryCode: NSNumber) -> String? {
        guard let codes = helper.regionCode(fromCountryCode: countryCode),
              let code = codes.first as? String else {
                  return nil
              }
        return code
    }
    
    /// Combines phonePrefix with phoneSuffix to create PhoneNumber and  attemps to validates it with NBPhoneNumberUtil.isValid() method. Final PhoneNumber can still be invalid according to NBPhoneNumberUtil.isValid(). If phone is invalid we attempt to validate it maximum 10 times by replacing first digit of phoneSuffix with values from 0 to 9
    /// - Parameters:
    ///   - phonePrefix: phone first part
    ///   - phoneSuffix: phone second part
    /// - Returns: PhoneNumber
    private func generateValidatedPhoneNumber(phonePrefix: String, phoneSuffix: String) throws -> PhoneNumber {
        var result = PhoneNumber(value: "\(phonePrefix)\(phoneSuffix)")
        
        guard !phoneSuffix.isEmpty else {
            return result
        }
        
        var count = 0
        let generateCheckPhoneNumber: (String) throws -> NBPhoneNumber = { [weak self] phoneValue in
            guard let self = self else { throw PhoneParserError.unknown }
            return try perform(try self.util.parse(phoneValue, defaultRegion: nil)) { _ in
                PhoneParserError.unknown
            }
        }
        
        var phoneNumberCheck = try generateCheckPhoneNumber(result.value(for: .mobile))
        
        while !util.isValidNumber(phoneNumberCheck) && count <= 9 {
            let updatedSuffix = "\(count)\(phoneSuffix.dropFirst())"
            result = PhoneNumber(value: "\(phonePrefix)\(updatedSuffix)")
            phoneNumberCheck = try generateCheckPhoneNumber(result.value(for: .mobile))
            count += 1
        }
        
        return result
    }
}
