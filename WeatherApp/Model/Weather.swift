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

struct DailyRoot: Codable {
    let daily: [DailyData]
}

struct DailyData: Codable {
    let dt: Int
    let temp: DailyTempData
    let weather: [WeatherData]
}

struct DailyTempData: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
}

struct CurrentData: Codable {
    let dt: Int //epoch time
    let temp: Double //default = kelvin
    let sunset: Int //epoch time
    let sunrise: Int
    let feels_like: Double
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

struct WeatherConstants {
    static let CLOUDY = "Clouds"
    static let CLEAR_SKY = "Clear"
    static let RAINY = "Rain"
    static let DRIZZLE = "Drizzle"
    static let THUNDERSTORM = "Thunderstorm"
    static let SNOW = "Snow"
}
