//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/28/20.
//

import UIKit
import CoreLocation

class WeatherVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var todayTxtLbl: UILabel!
    @IBOutlet weak var weeklyTxtLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var timeFrameController: UISegmentedControl!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var weatherInfoView: UIView!
    @IBOutlet weak var weatherInfoBackgroundImg: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    
    var getTodaysWeather = true
    var hourly: HourlyRoot?
    var daily: DailyRoot?
    var weatherRoot: WeatherRoot?
    let locationManager = CLLocationManager()
    var locationCoordinates = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupBackgroundImage()
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        
        weatherInfoView.layer.cornerRadius = 15
        weatherInfoView.layer.masksToBounds = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    
        locationCoordinates = locationValue
        //convert to negative for longitude number
        
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locationCoordinates.latitude, longitude: locationCoordinates.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            
            if let city = placeMark.subAdministrativeArea {
                self.cityNameLbl.text = city
            }
        })
        
        locationCoordinates.longitude *= -1
        //get initial weather data
        GetWeather(getTodaysWeather: getTodaysWeather)
    }
    
    func SetupBackgroundImage() {
        //set background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "night.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }

    @IBAction func RefreshWeatherBtnTapped(_ sender: Any) {
    }
    
    
    @IBAction func SegmentControlSwitched(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
        //animate text
            AnimateTextLabel(label: todayTxtLbl)
            getTodaysWeather = true
        case 1:
        //animate text
            AnimateTextLabel(label: weeklyTxtLbl)
            getTodaysWeather = false
        default:
            print("Nothing selected")
            break
        }
        
        GetWeather(getTodaysWeather: getTodaysWeather)
    }
    
    func GetWeather(getTodaysWeather: Bool) {
        WeatherService.sharedService.GetWeather(locationValue: locationCoordinates) { (weatherData, hourlyData, dailyData) in
            if getTodaysWeather {
                //get daily weather
                self.SetWeatherInfoViewData(weatherData: weatherData)
                self.ParseHourlyData(hourlyRoot: hourlyData)
                self.weatherRoot = weatherData
            }
            else {
                //get weekly data
                self.ParseWeeklyWeatherData(dailyData: dailyData)
            }
        } onError: { (errorMessage) in
            debugPrint("ww- in viewDidLoad: error: \(errorMessage)")
        }
    }
    
    func SetWeatherInfoViewData(weatherData: WeatherRoot) {
        let weatherMain = weatherData.current.weather[0].main
        var backgroundImageName = ""
        var currentWeatherName = ""
        var currentWeatherImageName = ""
        var description = weatherData.current.weather[0].description
        let currentTemp = weatherData.current.temp
        let currentTime = "\(weatherData.current.dt)".formattedTime
        let sunsetTime = "\(weatherData.current.sunset)".formattedTime
        
        if weatherMain.hasPrefix(WeatherConstants.CLOUDY) {
            if currentTime >= sunsetTime {
                //show night icon
                currentWeatherName = "scatteredCloudsNight.png"
            }
            else {
                currentWeatherName = "scatteredClouds.png"
            }
            backgroundImageName = "cloudyDay.jpg"
//            currentWeatherName = "Cloudy.png"
        }
        else if weatherMain.hasPrefix(WeatherConstants.CLEAR_SKY) {
            if currentTime >= sunsetTime {
                currentWeatherName = "clearSkyNight.png"
                backgroundImageName = "nightSky.jpg"
            }
            else {
                currentWeatherName = "clearSkyDay.png"
                backgroundImageName = "sunnyDay.jpg"
            }
//            backgroundImageName = "sunnyDay.jpg"
//            currentWeatherName = "Sunny.png"
        }
        else if weatherMain.hasPrefix(WeatherConstants.THUNDERSTORM) {
            backgroundImageName = "thunderstorm.jpg"
            currentWeatherName = "Lightning.png"
        }
        else if weatherMain.hasPrefix(WeatherConstants.DRIZZLE) || weatherMain.hasPrefix(WeatherConstants.THUNDERSTORM) || weatherMain.hasPrefix(WeatherConstants.RAINY) {
            backgroundImageName = "rainyDay.jpg"
            currentWeatherName = "Rainy.png"
        }
        else if weatherMain.hasPrefix(WeatherConstants.SNOW) {
            backgroundImageName = "snowyDay.jpg"
            currentWeatherName = "Snow.png"
        }
    
        weatherInfoBackgroundImg.image = UIImage(named: backgroundImageName)
        currentWeatherImg.image = UIImage(named: currentWeatherName)
        weatherDescription.text = description.capitalized
        currentTempLbl.text = "\(Int(currentTemp))°"
    }
    
    func ParseWeeklyWeatherData(dailyData: DailyRoot) {
        daily = dailyData
        weatherCollectionView.reloadData()
    }
    
    func ParseHourlyData(hourlyRoot: HourlyRoot) {
        hourly = hourlyRoot
        weatherCollectionView.reloadData()
    }
    
    func AnimateTextLabel(label: UILabel) {
        let scaleTransform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        let backToNormal = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        UILabel.animate(withDuration: 1.5, animations: {
            label.transform = scaleTransform
        })
        UILabel.animate(withDuration: 1.5, animations: {
            label.transform = backToNormal
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var viewCount = 0
        if getTodaysWeather {
            //return hourly count
            if let hours = hourly {
                viewCount = hours.hourly.count
            }
        }
        else {
            //return weekly count
            if let days = daily {
                viewCount = days.daily.count
            }
        }
        return viewCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hello")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? weatherViewCell {
            print("calling cell.updateView")
            if getTodaysWeather {
                //display daily
                if let dailyHours = hourly, let current = weatherRoot {
                    cell.UpdateDailyView(hour: dailyHours.hourly[indexPath.row], current: current)
                    
                }
            }
            else {
                //display weekly
                if let weeklyDays = daily {
                    cell.UpdateWeeklyView(daily: weeklyDays.daily[indexPath.row])
                }
            }
            
            return cell
        }
        else {
            print("custom view not getting called")
            return UICollectionViewCell()
        }
    }
}
