//
//  LocationViewController.swift
//  WeatherForcast
//
//  Created by Aabasaheb Dilip Deshpande (Digital) on 08/04/19.
//  Copyright © 2019 Aabasaheb Dilip Deshpande (Digital). All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol UpdateWeatherCustomDelegate {
    func updateWeatherForSelectedLocation(selectedLocationObject: LocationModel)
}

class LocationViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var searchBarView: UIView!
    //MARK:- Variables
    var locationManager = CLLocationManager()
    var latitude:Double?
    var longitude:Double?
    var delegate: UpdateWeatherCustomDelegate?
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    //MARK:- init()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setGooglePlaceWithSearchBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }

    //MARK:- Private Methods
    func setGooglePlaceWithSearchBar() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Enter your location"
        searchBarView.addSubview((searchController?.searchBar)!)
        view.addSubview(searchBarView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    func updateLocationObject(location: CLLocation) {
        
        fetchCityAndCountry(from: location) { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            
            let locationModel: LocationModel = LocationModel()
            locationModel.latitude = location.coordinate.latitude
            locationModel.longitude = location.coordinate.longitude
            locationModel.countryName = country
            locationModel.cityName = city
            self.delegate?.updateWeatherForSelectedLocation(selectedLocationObject: locationModel)
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }

    //MARK:- IBAction Methods
    @IBAction func getCurrentLocation(_ sender: Any) {

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

extension LocationViewController: CLLocationManagerDelegate, GMSAutocompleteResultsViewControllerDelegate, UITableViewDelegate,UITableViewDataSource {

    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        updateLocationObject(location: locations[0])
        self.navigationController?.popToRootViewController(animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    //MARK:- GMSAutocompleteResultsViewControllerDelegate
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        updateLocationObject(location: location)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {

        self.dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        return true
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let locationModel: LocationModel = Config.locationArray[indexPath.row]
        cell.textLabel?.text = "\(locationModel.cityName), \(locationModel.countryName)"
        return cell
    }
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationModel: LocationModel = Config.locationArray[indexPath.row]
        self.delegate?.updateWeatherForSelectedLocation(selectedLocationObject: locationModel)
        self.navigationController?.popToRootViewController(animated: true)
    }
}

