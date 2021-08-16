//
//  File.swift
//  File
//
//  Created by Alex Kostenko on 16.08.2021.
//

import Foundation

enum TestsError: Error {
    case resouceAbsent
    case generic(debug: String)
    case unknown
}
