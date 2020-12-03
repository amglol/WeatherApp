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
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var dayTemp: UILabel!
    @IBOutlet weak var nightTemp: UILabel!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var sunsetTime: UILabel!
    @IBOutlet weak var detailsInfoView: UIView!
    @IBOutlet weak var dateTitleLbl: UILabel!
    
    var getTodaysWeather = true
    var hourly: HourlyRoot?
    var daily: DailyRoot?
    var weatherRoot: WeatherRoot?
    let locationManager = CLLocationManager()
    var locationCoordinates = CLLocationCoordinate2D()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupBackgroundImage()
        
        //collection view setup
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        
        //update UIView properties
        weatherInfoView.layer.cornerRadius = 15
        weatherInfoView.layer.masksToBounds = true
        detailsInfoView.layer.cornerRadius = 15
        detailsInfoView.layer.masksToBounds = true
        //label property
        dateTitleLbl.layer.cornerRadius = 15
        dateTitleLbl.layer.masksToBounds = true
        
        //init location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(PullToRefresh(_:)), for: .valueChanged)
        weatherCollectionView.refreshControl = refreshControl
        
        //initially hide UIViews
        weatherInfoView.isHidden = true
        detailsInfoView.isHidden = true
        
    }
    
    @objc func PullToRefresh(_ sender: AnyObject) {
        print("rr- called refresh poull")
        GetWeather(getTodaysWeather: getTodaysWeather)
        weatherCollectionView.reloadData()
        
        refreshControl.endRefreshing()
    }
    
    //CLLocationManager delegate function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    
        locationCoordinates = locationValue
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locationCoordinates.latitude, longitude: locationCoordinates.longitude)
        
        //get name of city based on coordinates
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            
            if let city = placeMark.subAdministrativeArea {
                self.cityNameLbl.text = city
            }
        })
        
        //convert to negative for longitude number
        locationCoordinates.longitude *= -1
        //get initial weather data
        GetWeather(getTodaysWeather: getTodaysWeather)
    }
    
    //Assign and display a background image on the view
    func SetupBackgroundImage() {
        //set background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "mountains.png")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }

    //refresh weather when button is tapped
    @IBAction func RefreshWeatherBtnTapped(_ sender: Any) {
        GetWeather(getTodaysWeather: getTodaysWeather)
    }
    
    //toggle weather display based on which segment is selected
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
        //update weather view
        GetWeather(getTodaysWeather: getTodaysWeather)
    }
    
    //Get and display the weather
    func GetWeather(getTodaysWeather: Bool) {
        WeatherService.sharedService.GetWeather(locationValue: locationCoordinates) { (weatherData, hourlyData, dailyData) in
            
            //show the ui views
            self.weatherInfoView.isHidden = false
            self.detailsInfoView.isHidden = false
            
            //show todays weather
            if getTodaysWeather {
                //get daily weather
                self.SetWeatherInfoViewData(weatherData: weatherData)
                self.ParseHourlyData(hourlyRoot: hourlyData)
                self.weatherRoot = weatherData
                self.daily = dailyData
                self.UpdateDetailsInfoView()
            }
            else {
                //get weekly data
                self.ParseWeeklyWeatherData(dailyData: dailyData)
            }
        } onError: { (errorMessage) in
            debugPrint("Parsing error: \(errorMessage)")
        }
    }
    
    //update the details UIView when there is data
    func UpdateDetailsInfoView() {
        //verify weatherRoot is not empty
        if let data = weatherRoot {
            feelsLikeTemp.text = "\(Int(data.current.feels_like))°"
            sunriseTime.text = "\(data.current.sunrise)".formattedTime
            sunsetTime.text = "\(data.current.sunset)".formattedTime
            dateTitleLbl.text = "\(data.current.dt)".formattedDate
        }
        //verify daily is not empty
        if let dailyData = daily {
            dayTemp.text = "\(Int(dailyData.daily[0].temp.day))°"
            nightTemp.text = "\(Int(dailyData.daily[0].temp.night))°"
        }
    }
    
    //update the weather info UIView when there is data
    func SetWeatherInfoViewData(weatherData: WeatherRoot) {
        let weatherMain = weatherData.current.weather[0].main
        var backgroundImageName = ""
        var currentWeatherName = ""
        let description = weatherData.current.weather[0].description
        let currentTemp = weatherData.current.temp
        
        //check what weather condition and apply image based on name
        if weatherMain.hasPrefix(WeatherConstants.CLOUDY) {
            if weatherData.current.dt >= weatherData.current.sunset {
                //show night icon
                currentWeatherName = "nightIcon.png"
            }
            else {
                currentWeatherName = "PartiallyCloudy.png"
            }
            backgroundImageName = "cloudyDay.jpg"
        }
        else if weatherMain.hasPrefix(WeatherConstants.CLEAR_SKY) {
            if weatherData.current.dt >= weatherData.current.sunset {
                currentWeatherName = "clearSkyNight.png"
                backgroundImageName = "nightSky.jpg"
            }
            else {
                currentWeatherName = "Sunny.png"
                backgroundImageName = "sky.jpg"
            }
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
    
        //update the images and labels
        weatherInfoBackgroundImg.image = UIImage(named: backgroundImageName)
        currentWeatherImg.image = UIImage(named: currentWeatherName)
        weatherDescription.text = description.capitalized
        currentTempLbl.text = "\(Int(currentTemp))°"
    }
    
    //reload collection view when data changes
    func ParseWeeklyWeatherData(dailyData: DailyRoot) {
        daily = dailyData
        weatherCollectionView.reloadData()
    }
    
    //reload collection view when data changes
    func ParseHourlyData(hourlyRoot: HourlyRoot) {
        hourly = hourlyRoot
        weatherCollectionView.reloadData()
    }
    
    //animate UILabel
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
    
    //COLLECTION VIEW DELEGATE FUNCTIONS
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? weatherViewCell {
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
            return UICollectionViewCell()
        }
    }
}
