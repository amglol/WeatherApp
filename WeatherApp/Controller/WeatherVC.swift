//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/28/20.
//

import UIKit

class WeatherVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var todayTxtLbl: UILabel!
    @IBOutlet weak var weeklyTxtLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var timeFrameController: UISegmentedControl!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    
    let dummyData: [TestModel] = [TestModel(periodLbl: "8:53", weatherImg: "Cloudy.png", currentTemp: "18"), TestModel(periodLbl: "9:53", weatherImg: "Sunny.png", currentTemp: "25"),TestModel(periodLbl: "10:53", weatherImg: "Cloudy.png", currentTemp: "18"), TestModel(periodLbl: "11:53", weatherImg: "Sunny.png", currentTemp: "25"),TestModel(periodLbl: "12:53", weatherImg: "Sunny.png", currentTemp: "25")]
    
    var getTodaysWeather = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupBackgroundImage()
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        
//        WeatherService.sharedService.GetWeather { (weatherData) in
//            debugPrint("ww- weatherData = \(weatherData)")
////            self.weatherData = weatherData.forecast
//            self.Testing()
//        } onError: { (errorMessage) in
//            debugPrint("ww- in viewDidLoad: error: \(errorMessage)")
//        }

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
        
        GetWeather(todayOrWeekly: getTodaysWeather)
    }
    
    func GetWeather(todayOrWeekly weatherFlag: Bool) {
        WeatherService.sharedService.GetWeather { (weatherData, hourlyData) in
            debugPrint("ww- weatherData = \(weatherData)")
            debugPrint("ww- weatherData = \(hourlyData)")
            self.ParseHourlyData(hourlyRoot: hourlyData)
        } onError: { (errorMessage) in
            debugPrint("ww- in viewDidLoad: error: \(errorMessage)")
        }
    }
    
    func ParseHourlyData(hourlyRoot: HourlyRoot) {
        
        for index in 0...hourlyRoot.hourly.count {
            if index <= 4 {
                print("hh- hour:\(index) = \(hourlyRoot.hourly[index])")
            }
            else {
                break
            }
            
        }
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
        print("returning 1 section")
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items = \(dummyData.count)")
        return dummyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("hello")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? weatherViewCell {
            print("calling cell.updateView")
            cell.UpdateView(test: dummyData[indexPath.row])
            return cell
        }
        else {
            print("custom view not getting called")
            return UICollectionViewCell()
        }
    }
}
