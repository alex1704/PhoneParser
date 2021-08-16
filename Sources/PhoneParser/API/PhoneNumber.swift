//
//  PhoneNumber.swift
//  PhoneNumber
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation

public enum PhoneFormat {
    case mobile, pureNumber
}

public struct PhoneNumber {
    public init(value: String) {
        self.value = value.cleanedUpPhoneNumberString
    }
    
    private let value: String
}

public extension PhoneNumber {
    func value(for format: PhoneFormat) -> String {
        switch format {
        case .mobile: return "+\(value)"
        case .pureNumber: return value
        }
    }
}
