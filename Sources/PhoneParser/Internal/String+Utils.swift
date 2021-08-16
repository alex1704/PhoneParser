//
//  String+Utils.swift
//  String+Utils
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation

extension String {
    var cleanedUpPhoneNumberString: String {
        remove(characters: ["+", "-", " ", "(", ")"])
    }
    
    func remove(characters: Set<Character>) -> String {
        filter { !characters.contains($0) }
    }
}
