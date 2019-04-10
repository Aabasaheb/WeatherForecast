//
//  HomeViewController.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 07/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var weatherBackgroundImg: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var selectedCityLabel: UILabel!
    
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var humidityValueLbl: UILabel!
    @IBOutlet weak var humidityTitleLbl: UILabel!
    
    @IBOutlet weak var windValueLbl: UILabel!
    @IBOutlet weak var windTitleLbl: UILabel!
    
    @IBOutlet weak var pressureValueLbl: UILabel!
    @IBOutlet weak var pressureTitleLabel: UILabel!
    
    @IBOutlet weak var tempMinValueLbl: UILabel!
    @IBOutlet weak var tempMinTitleLbl: UILabel!
    
    @IBOutlet weak var tempMaxValueLbl: UILabel!
    @IBOutlet weak var tempMaxTitleLbl: UILabel!
    
    @IBOutlet weak var seaLevelValueLbl: UILabel!
    @IBOutlet weak var seaLevelTitleLbl: UILabel!
    
    @IBOutlet weak var selectDateTxtField: UITextField!
    @IBOutlet weak var datewiseCollectionView: UICollectionView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var datePickerBackgroundView: UIView!
    
    //MARK:- Variables
    var selectedLocationModel: LocationModel?
    var locationManager = CLLocationManager()
    var dailyGroupedWeather: [WeatherModel] = []
    
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true;
        
        datePicker.addTarget(self, action: #selector(donedatePicker), for: .valueChanged)
        
        if selectedLocationModel == nil {
            // Get location details from current location
            if CLLocationManager.locationServicesEnabled() == true {
                if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                }
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
            } else {
                print("Please turn on location services or GPS")
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK:- Private Methods
    @objc func donedatePicker() {
        
        datePickerBackgroundView.isHidden = true
        let weatherGoruped:[[WeatherModel]] = GroupWeatherByDate.sharedInstance.groupedWeatherModels()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        var selectedIndex = -1
        for (index, weathersObject) in weatherGoruped.enumerated() {
            if weathersObject.first?.dateString(format: "dd-MMM-yyyy") == selectedDate {
                dailyGroupedWeather = weathersObject
                selectedIndex = index
                break;
            }
        }
        
        if selectedIndex != -1 {
            selectDateTxtField.text = dailyGroupedWeather.first?.dateString(format: "dd-MMM-yyyy")
            datewiseCollectionView.reloadData()
        }
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }

    // Get weather details for selected location object
    func getWeatherDetailsForSelectedLocation() {
    
        guard let latitude = selectedLocationModel?.latitude else {
            return
        }
        guard let longitude = selectedLocationModel?.longitude else {
            return
        }
        
        self.selectedCityLabel.text = "\(selectedLocationModel?.cityName ?? "No City"), \(selectedLocationModel?.countryName ?? "No Country")"
        
        indicator.isHidden = false
        self.view.bringSubviewToFront(indicator)
        indicator.startAnimating()
        
        // Download the data from OpenWeatherMap
        ApiRequestManager.getForecast(latitude: latitude, longitude: longitude) {[unowned self] (weatherDetails, error) in

            if ( error == nil ) {
                if weatherDetails.count != 0 {
                    // Update details
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                    
                    // UpdateUI for weather details
                    self.updateUIForWeatherDetails(weatherObjects:weatherDetails)
                }
            } else {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                // If there's an error, let's display the message here
                let alert = UIAlertController()
                alert.title = "Error"
                alert.message = error?.localizedDescription
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) -> Void in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    func updateLocationObject(location: CLLocation) {
        fetchCityAndCountry(from: location) { [unowned self]city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            
            let locationModel: LocationModel = LocationModel()
            locationModel.latitude = location.coordinate.latitude
            locationModel.longitude = location.coordinate.longitude
            locationModel.countryName = country
            locationModel.cityName = city
            self.updateWeatherForSelectedLocation(selectedLocationObject: locationModel)
        }
    }
    func updateWeatherForSelectedLocation(selectedLocationObject: LocationModel) {
        selectedLocationModel = selectedLocationObject
        getWeatherDetailsForSelectedLocation()
        self.saveLocationObject(locationModel: selectedLocationObject)
    }
    
    func saveLocationObject(locationModel:LocationModel)
    {
        if Config.locationArray.count == 0 {
            Config.locationArray.append(locationModel)
        }
        else {
            let filterLocation = Config.locationArray.filter { $0.cityName == locationModel.cityName
            }
            if(filterLocation.count == 0)
            {
                Config.locationArray.append(locationModel)
            }
        }
    }
    
    func updateUIForWeatherDetails(weatherObjects:[WeatherModel])
    {
        
        if weatherObjects.count > 0 {
            let weatherModel:WeatherModel = weatherObjects[0]
            
            let tempVal:Double = weatherModel.temperatureInCelsius(temp: weatherModel.temperature ?? 0) ?? 0
            
            switch tempVal {
            case let x where x < 5:
                weatherBackgroundImg.image = UIImage(named: "snowfall")
            case let x where x < 20:
                weatherBackgroundImg.image = UIImage(named: "cloudyImg")
            case let x where x < 30:
                weatherBackgroundImg.image = UIImage(named: "cloudy2")
            default:
                weatherBackgroundImg.image = UIImage(named: "sunny")
            }
  
            currentTemp.text = "\(tempVal)"
            weatherDescription.text = weatherModel.weatherDescription ?? ""
            humidityValueLbl.text = "\(weatherModel.humidity ?? 0) %"
            humidityTitleLbl.text = "Humidity"
            windValueLbl.text = "\(weatherModel.pressure ?? 0) mb"
            windTitleLbl.text = "Pressure"
            tempMinValueLbl.text = "\(weatherModel.temperatureInCelsius(temp: weatherModel.minTemperature ?? 0) ?? 0) °C"
            tempMinTitleLbl.text = "Min Temp"
            tempMaxValueLbl.text = "\(weatherModel.temperatureInCelsius(temp: weatherModel.maxTemperature ?? 0) ?? 0) °C"
            tempMaxTitleLbl.text = "Max Temp"
            seaLevelValueLbl.text = "\(weatherModel.sea_level ?? 0) mb"
            seaLevelTitleLbl.text = "Sea Level"
            pressureValueLbl.text = "\(weatherModel.grnd_level ?? 0) mb"
            pressureTitleLabel.text = "Ground Level"
            
            let weatherGoruped:[[WeatherModel]] = GroupWeatherByDate.sharedInstance.groupedWeatherModels()
            
            guard let groupeWeather = weatherGoruped.first  else { return }
            guard let groupeWeatherLastObject = weatherGoruped.last  else { return }
            dailyGroupedWeather = groupeWeather;
            
            guard let weatherFirstObject = dailyGroupedWeather.first  else { return }
            guard let weatherLastObject = groupeWeatherLastObject.first  else { return }
            
            datePicker.minimumDate = displayDateFromWeatherModel(weatherModel: weatherFirstObject)
            datePicker.maximumDate = displayDateFromWeatherModel(weatherModel: weatherLastObject)
            datePicker.date = displayDateFromWeatherModel(weatherModel: weatherFirstObject)
            selectDateTxtField.text = weatherFirstObject.dateString(format: "dd-MMM-yyyy")
            datewiseCollectionView.reloadData()
            // Add object to user defaults
        }
    }
    
    func displayDateFromWeatherModel(weatherModel:WeatherModel) -> Date {
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let dateString = weatherModel.dateString(format: "dd-MMM-yyyy")
        let convertedDate = dateFormatter.date(from: dateString)
        return convertedDate ?? currentDate;
    }
    
    //MARK:- IBAction Method
    @IBAction func addLocationButtonAction(_ sender: Any) {
        let viewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
        viewController?.delegate = self
        guard let vc = viewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UpdateWeatherCustomDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    //MARK:- UITextFieldDelegate Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if datePickerBackgroundView.isHidden {
            datePickerBackgroundView.isHidden = false
            self.view.bringSubviewToFront(datePickerBackgroundView)
        }
        else {
            datePickerBackgroundView.isHidden = true
        }
    }
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        updateLocationObject(location: locations[0])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyViewCell", for: indexPath) as! DailyViewCell
        
        let weatherModel = dailyGroupedWeather[indexPath.row] //weatherModels[indexPath.row]
        cell.setWeatherModel(weatherModel: weatherModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyGroupedWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 102
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(kWhateverHeightYouWant))
    }
}
