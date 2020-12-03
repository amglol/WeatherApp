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
    
    //update todays weather view
    func UpdateDailyView(hour: HourlyData, current: WeatherRoot) {
        let condition = hour.weather[0].main
        
        //check if it is night
        isNight = current.current.dt >= current.current.sunset ? true : false
        weatherId = TODAY
        
        //display correct icon based on day / night
        DisplayCorrectWeatherIcon(condition: condition, isNight: isNight, id: weatherId)
        
        //update labels
        timePeriod.text = "\(hour.dt)".formattedTime
        temperature.text = "\(Int(hour.temp))"
    }
    
    //update weekly weather view
    func UpdateWeeklyView(daily: DailyData) {
        let condition = daily.weather[0].main
        weatherId = WEEKLY
        //update icons
        DisplayCorrectWeatherIcon(condition: condition, isNight: isNight, id: weatherId)
        //update labels
        temperature.text = "\(Int(daily.temp.max))"
        timePeriod.text = "\(daily.dt)".formattedDay
    }
    
    //display weather icon based on isNight flag
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
