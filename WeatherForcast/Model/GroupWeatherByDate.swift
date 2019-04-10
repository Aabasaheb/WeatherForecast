//
//  GroupWeatherByDate.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 07/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import Foundation

class GroupWeatherByDate {
    
    static let sharedInstance = GroupWeatherByDate()
    
    var weatherModels: [WeatherModel]?

    // This function is to group the Model class data by their date
    func groupedWeatherModels() -> [[WeatherModel]] {

        if (weatherModels == nil || weatherModels!.count < 1) {
            return [[]]
        }
        
        // Helper variable to map the samples by their date
        var dict: [String:[WeatherModel]] = [:]
        
        for ws in weatherModels! {
            let dateKey = ws.dateString(format: "YYYYMMdd")
            if (dict[dateKey] == nil || dict[dateKey]!.count < 1) {
                dict[dateKey] = []
            }
            dict[dateKey]?.append(ws)
        }
        
        var retval: [[WeatherModel]] = []
        
        let sortedKeys = Array(dict.keys).sorted()
        for key in sortedKeys {
            retval.append(dict[key]!)
        }
        
        return retval
    }
    
}
