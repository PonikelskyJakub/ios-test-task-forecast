//
//  ForecastToday.swift
//  Test App - Forecast
//
//  Created by Jakub on 23.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit

struct ForecastToday {
    /// Image of this weather condition
    var weatherImg: String
    var cityName: String
    /// Tempreature and weather description
    var tempWeather: String
    var cloudness: String
    var humidity: String
    var pressure: String
    var windSpeed: String
    var windDirection: String
    /// URL to map with given latitude and longitude
    var mapUrl: URL
}

extension ForecastToday: Equatable {
    /// Comparation of two ForecastToday struct
    public static func == (lhs: ForecastToday, rhs: ForecastToday) -> Bool {
        let areEqual = lhs.weatherImg == rhs.weatherImg &&
            lhs.cityName == rhs.cityName &&
            lhs.tempWeather == rhs.tempWeather &&
            lhs.cloudness == rhs.cloudness &&
            lhs.humidity == rhs.humidity &&
            lhs.pressure == rhs.pressure &&
            lhs.windSpeed == rhs.windSpeed &&
            lhs.windDirection == rhs.windDirection &&
            lhs.mapUrl == rhs.mapUrl
        return areEqual
    }
}
