//
//  DailyViewCell.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 09/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import UIKit

class DailyViewCell: UICollectionViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var minTempLbl: UILabel!
    @IBOutlet weak var maxTempLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!
    @IBOutlet weak var descriptoinLbl: UILabel!
    
    //MARK:- Private Methods
    func setWeatherModel(weatherModel: WeatherModel) {
        
        timeLbl.text = weatherModel.dateString(format: "HH:mm a")
        tempLbl.text = "\(weatherModel.temperatureInCelsius(temp: weatherModel.temperature ?? 0) ?? 15) °C"
        descriptoinLbl.text = weatherModel.weatherDescription ?? ""
        humidityLbl.text = "\(weatherModel.humidity ?? 30) %"
        windLbl.text = "\(weatherModel.pressure ?? 10) mb"
        minTempLbl.text = "\(weatherModel.temperatureInCelsius(temp: weatherModel.minTemperature ?? 0) ?? 10) °C"
        maxTempLbl.text = "\(weatherModel.temperatureInCelsius(temp: weatherModel.maxTemperature ?? 0) ?? 10) °C"
        pressureLbl.text = "\(weatherModel.sea_level ?? 0) mb"
    }
}

