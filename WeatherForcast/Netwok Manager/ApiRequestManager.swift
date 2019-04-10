//
//  ApiRequestManager.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 07/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import Foundation

class ApiRequestManager {
    
    /**
      Download weather forecast data for selected city and country.
     - Parameters:
     - city: Indicates selected city name
     - countryCode: Indicates selected country code
     - completionHandler: Send response on getting data or error from API
     */
    
    class func getForecast(latitude:Double, longitude:Double, completionHandler: @escaping ([WeatherModel], Error?) -> Void) {
        
        let url = "\(Config.BaseURL)?lat=\(latitude)&lon=\(longitude)&APPID=\(Config.APIKey)"
        NetworkManager.sendGetRequest(url: url) { (json, error) -> Void in
            if (error == nil && json != nil) {
                let weatherModels = ApiRequestManager.parseWeatherData(json: json!)
                GroupWeatherByDate.sharedInstance.weatherModels = weatherModels
                completionHandler(weatherModels, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    class func parseWeatherData(json: Any) -> [WeatherModel] {
        var weatherDataPoints: [WeatherModel] = []

        if let dict = json as? NSDictionary {
            if let list = dict["list"] as? [[String:AnyObject]] {
                for a in list {
                    let weather = WeatherModel()
                    weather.timestamp = a["dt"] as? Int
                    let main = a["main"] as? [String:AnyObject]
                    weather.temperature = main?["temp"] as? Double
                    weather.minTemperature = main?["temp_min"] as? Double
                    weather.maxTemperature = main?["temp_max"] as? Double
                    weather.pressure = main?["pressure"] as? Double
                    weather.sea_level = main?["sea_level"] as? Double
                    weather.grnd_level = main?["grnd_level"] as? Double
                    weather.humidity = main?["humidity"] as? Double
                    weather.temp_kf = main?["temp_kf"] as? Double
                    
                    let weatherInfo = a["weather"] as? [[String:AnyObject]]
                    if (weatherInfo != nil && weatherInfo!.count > 0) {
                        weather.weatherDescription = weatherInfo?[0]["description"] as? String
                        weather.weatherMain = weatherInfo?[0]["main"] as? String
                    }
                    weatherDataPoints.append(weather)
                }
            }
        }
        return weatherDataPoints
    }
}
