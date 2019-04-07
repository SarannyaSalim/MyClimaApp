//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sarannya on 13/03/19.
//  Copyright © 2019 Sarannya. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    //5e2f01506c5e9974e57fd0346f3ec76a //mykey
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url : String, parameters : [String : String]){
        //Alamofire calls need url and parameters to make the http request to fetch the weather data from the openweathermap.org
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                let weatherJson : JSON = JSON(response.result.value)
                self.updateWeatherData(json: weatherJson)
            }else{
                
            }
        }
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON){
//        print(json)
        
//        let currentTemp = json["main"]["temp"].double //this simple way to access is provided by SwiftyJSON, not the way by SWIFT itslef, which is very wordy and long like any language but better

        //        weatherDataModel.temperature = Int(currentTemp! - 273.15) //force unwrapping may lead to crash
        
        if let currentTemp = json["main"]["temp"].double{
        weatherDataModel.temperature = Int(currentTemp - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        print(weatherDataModel.weatherIconName)
        updateUIWithWeatherData()
            
        }
        else{
            cityLabel.text = "weather unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    func updateUIWithWeatherData(){
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil //to stop updateing once location fetched
//            print("Longitude: \(location.coordinate.longitude), Latitude:\(location.coordinate.latitude)")
            
            let parameters : [String : String] = ["lat" : String(location.coordinate.latitude), "lon" : String(location.coordinate.longitude), "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: parameters)
            
            //search on latlong.net on browser and put in the coordinates to check if the location exits on globe
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCity(cityName: String) {
        print(cityName)
        
        let parameters : [String : String] = ["q" : cityName, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: parameters)
     }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.changeCityDelegate = self
        }
    }
    
    
    
}


