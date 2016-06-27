//
//  ViewController.swift
//  WeatherApp
//
//  Created by Networks Mac2 on 6/18/16.
//  Copyright © 2016 Networks Mac2. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import WatchConnectivity

class ViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate  {
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "06db44f389d2172e9b1096cdce7b051c&units=metric"
    private let locationManager = CLLocationManager()
    private var city = String()
    private var JSONdictionary = [String:AnyObject]()
    private var weather_description = String()
    private var temperature = String()
    var session : WCSession?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    lazy var data = NSMutableData()
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up location manager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let location = self.locationManager.location
        let latitude: Double = location!.coordinate.latitude
        let longitude: Double = location!.coordinate.longitude
        
        print("current latitude :: \(latitude)")
        print("current longitude :: \(longitude)")
        
        // setting up session with i watch and transfering data
        session = WCSession.defaultSession()
        session?.delegate = self
        session?.activateSession()
        
        
    }
    @IBAction func sendData(sender: AnyObject) {
        saveToPhoneValues(city, TEMPERATURE: temperature, DESCRIPTION: weather_description)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //--- CLGeocode to get address of current location ---//
        CLGeocoder().reverseGeocodeLocation(locationManager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil){
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0{
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            }
            else{
                print("Problem with the data received from geocoder")
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     Function makes http request to Weather service
     RETURNS string which is JSON response
     */
    func getWeatherInfo(city: String) {
        print("Finding weather for \(city)")
        let session = NSURLSession.sharedSession()
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                print("ERROR! Can not make HTTP request. \(error.localizedDescription)")
            }
            else {
                let dataString = String(data: data!, encoding: NSUTF8StringEncoding)
                print("Data retrieved:\n\(dataString!)")
                self.extractInfoFromJSON(self.convertStringToDictionary(dataString!)!)
            }
        }
        dataTask.resume()
    }
    
    
    func displayLocationInfo(placemark:CLPlacemark?)
    {
        if let containsPlacemark = placemark
        {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            // not sure that works
            city = administrativeArea!
            
            getWeatherInfo(city)
            
            city = locality!
            
            print("City is \(locality!)")
            print("Postal code is \(postalCode!)")
            print("Administrative area is \(administrativeArea!)")
            print("Country is \(country!)")
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    /*Hardcoded part specific only for JSON return */
    func extractInfoFromJSON(dict:[String:AnyObject]){
            if let weather = dict["weather"] as? [AnyObject] {
                for dict2 in weather {
                    let main = dict2["main"] as? String
                    weather_description = main!
                }
            }
        print(dict["weather"])
        print(dict["main"])
        let temp = dict["main"] as? [String:AnyObject]
        
        temperature = "\(temp!["temp"]!)"
   
        print("Weather Description is \(weather_description)")
        print("Temperature is \(temperature)")
        saveToPhoneValues(city, TEMPERATURE: temperature, DESCRIPTION: weather_description)
    }
    
    func saveToPhoneValues(CITY:String, TEMPERATURE:String, DESCRIPTION:String){
        session = WCSession.defaultSession()
        
        session!.sendMessage(["values": "\(CITY)-\(DESCRIPTION)-\(TEMPERATURE)"], replyHandler: nil, errorHandler: { (error) -> Void in
            print("Watch failed with error \(error)")
        })


    }
    
    
    
}

