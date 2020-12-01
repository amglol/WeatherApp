//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Adrian Galecki on 11/29/20.
//

import Foundation

class WeatherService {
    //create singleton
    static let sharedService = WeatherService()
    
    //URL constants
    let URL_BASE = "https://api.openweathermap.org/data/2.5/onecall?"
    
//    https://api.openweathermap.org/data/2.5/onecall?lat=39.9526&lon=75.1652&exclude=minutely, alerts, current&appid=862184c60a136e2be3d1aeb39649c35b
    
    //API KEY
    let KEY_START = "&appid="
    let API_KEY = "862184c60a136e2be3d1aeb39649c35b"
    
    //location format
    let API_DAYS = "days="
    let API_LAT = "lat="
    let API_LON = "&lon="
    let API_EXCLUDE = "exclude"
    
    //create the session
    let session = URLSession(configuration: .default)
    
    func GetWeather(onSuccess: @escaping (WeatherRoot, HourlyRoot) -> Void, onError: @escaping (String) -> Void) {
        print("ww- IN GetWeather()")
        let lat = 39.9526
        let lon = 75.1652
        let createdURL = URL(string: "\(URL_BASE)\(API_LAT)\(lat)\(API_LON)\(lon)\(KEY_START)\(API_KEY)")!
        //verify weather url is populated
//        guard let weatherURL = createdURL else { return }
        print("ww- createdURL = \(createdURL)")
        //create the task
        let task = session.dataTask(with: createdURL) { (data, response, error) in
            print("ww- Started TASK")
            //run on main
            DispatchQueue.main.async {
                //check for any error
                if let error = error {
                    print("ww- received erorr in FIRST PLACE")
                    onError(error.localizedDescription)
                    return
                }
                
                //verify there is data
                guard let incomingData = data, let incomingResponse = response as? HTTPURLResponse else {
                    print("ww- received error verifying data or response")
                    onError("Invalid data or response")
                    return
                }
                
                do {
                    if incomingResponse.statusCode == 200 {
                        print("ww- statusCode == 200")
                        //parse succesfful result
                        let weatherData = try JSONDecoder().decode(WeatherRoot.self, from: incomingData)
                        let hourlyData = try JSONDecoder().decode(HourlyRoot.self, from: incomingData)
                        
                        //handle success
                        onSuccess(weatherData, hourlyData)
                    }
                    else {
                        print("ww- error received in THIRD place")
                        //show error to user
                        let err = try JSONDecoder().decode(APIError.self, from: incomingData)
                        
                        //handle error
                        onError(err.message)
                    }
                }
                catch {
                    print("ww- error received in FORTH place")
                    onError("\(error)")
                }
            }
        }
        task.resume()
    }
}
