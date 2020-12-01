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
    
    func UpdateView(test: TestModel) {
        timePeriod.text = test.periodLbl
        weatherImg.image = UIImage(named: test.weatherImg)
        temperature.text = test.currentTemp
        
        print("timePeried = \(test.periodLbl), weatherImg = \(UIImage(named: test.weatherImg)), temperature = \(test.currentTemp)")
    }
}
