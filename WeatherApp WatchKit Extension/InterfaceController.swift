//
//  InterfaceController.swift
//  WeatherApp WatchKit Extension
//
//  Created by Networks Mac2 on 6/18/16.
//  Copyright © 2016 Networks Mac2. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController , WCSessionDelegate{

    @IBOutlet var cityLabel: WKInterfaceLabel!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var session : WCSession?
    var temp = String()
    var desc = String()
    var city = String()

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        session = WCSession.defaultSession()
        session?.delegate = self
        session?.activateSession()

        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("Hello World. Thing is activated!")
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let values = (message["values"] as? String)!
        let all_description = values.characters.split{$0 == "-"}.map(String.init)
        cityLabel.setText(all_description[0])
        descriptionLabel.setText(all_description[1])
        temperatureLabel.setText("\(all_description[2])65\u{00B0}")
        
        
        switch(all_description[1]){
            case "Clouds":
                weatherImage.setImage(UIImage(named: "clouds"))
            print("Used clouds image")
        default:
            print("Nothing")
        }
    
        //self.setUpdateLabels()
    }
    func setUpdateLabels(){
        cityLabel.setText(city)
        temperatureLabel.setText(temp)
        descriptionLabel.setText(desc)
    }

}
