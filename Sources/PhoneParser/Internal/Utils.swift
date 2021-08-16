//
//  Utils.swift
//  Utils
//
//  Created by Alex Kostenko on 15.08.2021.
//

import Foundation

func perform<T>(_ expression: @autoclosure () throws -> T,
                errorTransform: (Error) -> Error) throws -> T {
    do {
        return try expression()
    } catch {
        throw errorTransform(error)
    }
}
