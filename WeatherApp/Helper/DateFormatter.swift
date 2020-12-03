//
//  DateFormatter.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 12/3/20.
//

import Foundation

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

extension String {
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(Int(self)!))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
