//
//  LocationModel.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 08/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import Foundation
class LocationModel: NSObject {
    
    var countryName : String = ""
    var cityName : String = ""
    var latitude : Double = 0
    var longitude : Double = 0
    
    init(countryName: String, cityName: String, latitude : Double, longitude : Double) {
        self.countryName = countryName
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encode(countryName)
        encoder.encode(cityName)
        encoder.encode(latitude)
        encoder.encode(longitude)
    }
    
    func initWithCoder(decoder: NSCoder) -> LocationModel {
        self.countryName = decoder.decodeObject(forKey: "countryName") as! String
        self.cityName = decoder.decodeObject(forKey: "cityName") as! String
        self.latitude = decoder.decodeObject(forKey: "latitude") as! Double
        self.longitude = decoder.decodeObject(forKey: "longitude") as! Double
        return self
    }
    
    init(coder aDecoder: NSCoder!) {
        self.countryName = aDecoder.decodeObject(forKey: "countryName") as! String
        self.cityName = aDecoder.decodeObject(forKey: "cityName") as! String
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as! Double
    }

    override init() {

    }
}
