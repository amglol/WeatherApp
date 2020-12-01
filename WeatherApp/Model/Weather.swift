//
//  Weather.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/29/20.
//

import Foundation

struct WeatherRoot: Codable {
    let current: CurrentData
}

struct CurrentData: Codable {
    let dt: Int //epoch time
    let temp: Double //default = kelvin
    let weather: [WeatherData]
}

struct WeatherData: Codable {
    let main: String //clouds, sun etc
    let description: String //scattered clouds etc
}

struct HourlyRoot: Codable {
    let hourly: [HourlyData]
}

struct HourlyData: Codable {
    let dt: Int //epoch time
    let temp: Double //default = kelvin
    let weather: [WeatherData]
}
