//
//  APIError.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/29/20.
//

import Foundation

struct APIError: Codable {
    let code: Int
    let message: String
}

struct Error: Codable {
    let error: Array<APIError>
}
