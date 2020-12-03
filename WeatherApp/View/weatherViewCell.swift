//
//  weatherViewCell.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/29/20.
//

import UIKit

class weatherViewCell: UICollectionViewCell {
    @IBOutlet weak var timePeriod: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    var isNight = false
    let TODAY = 1
    let WEEKLY = 2
    var weatherId = 0
    
    func UpdateDailyView(hour: HourlyData, current: WeatherRoot) {
        let condition = hour.weather[0].main
        let currentTime = "\(current.current.dt)".formattedTime
        let sunsetTime = "\(current.current.sunset)".formattedTime
        
        isNight = currentTime >= sunsetTime ? true : false
        weatherId = TODAY
        
        DisplayCorrectWeatherIcon(condition: condition, isNight: isNight, id: weatherId)
        
        timePeriod.text = "\(hour.dt)".formattedTime
        temperature.text = "\(Int(hour.temp))"
    }
    
    func UpdateWeeklyView(daily: DailyData) {
        let condition = daily.weather[0].main
        weatherId = WEEKLY
        DisplayCorrectWeatherIcon(condition: condition, isNight: isNight, id: weatherId)
        
        temperature.text = "\(Int(daily.temp.max))"
        timePeriod.text = "\(daily.dt)".formattedDay
    }
    
    func DisplayCorrectWeatherIcon(condition: String, isNight: Bool, id: Int) {
        if condition == WeatherConstants.CLOUDY {
            if isNight && id == TODAY {
                weatherImg.image = UIImage(named: "nightIcon.png")
            }
            else {
                weatherImg.image = UIImage(named: "Cloudy.png")
            }
        }
        else if condition == WeatherConstants.DRIZZLE || condition == WeatherConstants.RAINY {
            weatherImg.image = UIImage(named: "Rainy.png")
        }
        else if condition == WeatherConstants.THUNDERSTORM {
            weatherImg.image = UIImage(named: "Lightning.png")
        }
        else if condition == WeatherConstants.CLEAR_SKY {
            if isNight && id == TODAY {
                weatherImg.image = UIImage(named: "clearSkyNight.png")
            }
            else {
                weatherImg.image = UIImage(named: "Sunny.png")
            }
            
        }
        else if condition == WeatherConstants.SNOW {
            weatherImg.image = UIImage(named: "Snow.png")
        }
    }
}
