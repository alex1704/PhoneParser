//
//  NBAsYouTypeFormatter+PhonePrefix.swift
//  NBAsYouTypeFormatter+PhonePrefix
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation
import libPhoneNumber

extension NBAsYouTypeFormatter {
    
    // MARK: - Public
    
    /// Returns phone prefix only if country code and area code are present. They are deemed present if NBAsYouTypeFormatter.inputString() returns string formatted as "1 123-1" or "1 123 1" so country code = 1 and area code = 123.
    ///
    ///     - Warning:
    ///     Area code can be incomple, say input = "+1 58" which results in area code == 58 which is not valid (587 would be valid - "CA").
    /// - Parameter number: Phone number
    /// - Returns: Phone prefix if present
    func phonePrefix(from phone: PhoneNumber) -> PhonePrefix? {
        return phonePrefix(from: phone.value(for: .mobile))
    }

    /// Normalize inputString functionality by removing occurances of '+' character and replacing '.' and '-' with spaces
    /// - Parameter string: Phone number string to normalize
    /// - Returns: Normalized phone number
    public func normalizedInputString(_ string: String) -> String? {
        // formattedString == 1 123-1 or 44 45 31
        // normalize to one format 'num num num': '1 123-1' -> '1 123 1'
        inputString(string)?
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "+", with: "")
    }
    
    // MARK: - Private

    private func phonePrefix(from string: String) -> PhonePrefix? {
        let components = inputStringComponents(string)

        // make sure that area code is present
        guard components.count >= 2 else {
            return nil
        }

        return PhonePrefix(idd: components[0], areaCode: components[1])
    }
    
    private func inputStringComponents(_ string: String) -> [String] {
        guard let formattedString = normalizedInputString(string) else {
            return []
        }
        
        return formattedString.split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
