//
//  Config.swift
//  Test App - Forecast
//
//  Created by Jakub on 23.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import Foundation

struct Config {
    struct locationManager {
        static let distanceFilter = 1000.0
    }
    
    struct openWeatherMap {
        static let apiUrl = "http://api.openweathermap.org/data/2.5"
        static let appId = "XXX"

        static let mapUrl = "http://openweathermap.org/weathermap"
    }
    
    struct share {
        static let defaultMapMsg = NSLocalizedString("SHARE_DEFAULT_MESSAGE", comment: "Default share msg")
    }
}
