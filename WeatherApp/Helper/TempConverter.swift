//
//  TempConverter.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 12/1/20.
//

import Foundation

extension Double {
    var kelvinToFahrenheit: Double {
        let kelvinMax = 459.67
        return (self * (9/5) - kelvinMax)
    }
}

extension String {
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(Int(self)!))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
}

extension String {
    var formattedDay: String {
        let date = Date(timeIntervalSince1970: TimeInterval(Int(self)!))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "EE dd"
        return formatter.string(from: date)
    }
}
