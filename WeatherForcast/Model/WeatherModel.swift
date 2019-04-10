//
//  WeatherModel.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 07/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import Foundation

class WeatherModel {
    
    var timestamp: Int?
    var temperature: Double?
    var minTemperature: Double?
    var maxTemperature: Double?
    var pressure: Double?
    var sea_level: Double?
    var grnd_level: Double?
    var humidity:Double?
    var temp_kf:Double?
    
    var weatherMain: String?
    var weatherDescription: String?
    
    func temperatureInCelsius(temp: Double) -> Double? {
        return round(temp - 273.15)
    }
    
    func date() -> Date? {
        if (timestamp == nil) {
            return nil
        }
        let ti = TimeInterval(timestamp!)
        return Date(timeIntervalSince1970: ti)
    }

    func dateString(format: String) -> String {
        if let date = date() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: date)
        }
        return ""
    }

}
