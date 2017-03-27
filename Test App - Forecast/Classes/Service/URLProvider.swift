//
//  URLProvider.swift
//  capp
//
//  Created by Jakub Ponikelsky on 27.02.17.
//  Copyright © 2017 Home Credit Consumer Finance ltd. All rights reserved.
//

class URLProvider {
    private init() {}
    static let shared = URLProvider()
    
    private let productionUrl = "http://api.openweathermap.org/data/2.5"
    private let devUrl        = ""
    
    func url(for endpoint: Endpoint, dev: Bool = false) -> String {
        let baseUrl: String
        
        if dev {
            baseUrl = devUrl
        } else {
            baseUrl = productionUrl
        }
        
        let endpointUrl = endpoint.rawValue
        return "\(baseUrl)\(endpointUrl)&appId=\(Config.openWeatherMap.appId)"
    }
}

// TODO: Delete
enum Endpoint: String {
    case fiveDays  = "/forecast?units=metric"
    case today  = "/weather?units=metric"
}
