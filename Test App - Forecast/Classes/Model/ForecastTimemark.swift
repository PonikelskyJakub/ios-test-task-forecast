//
//  ForecastTimemark.swift
//  Test App - Forecast
//
//  Created by Jakub on 21.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

struct ForecastTimemark {
    var datetime: Int32
    var temperature: Double
    var weather_desc: String
    var weather_icon: String
    var weather_text: String
}


extension ForecastTimemark : Equatable {
    /// Comparation of two ForecastTimemark struct
    public static func == (lhs: ForecastTimemark, rhs: ForecastTimemark) -> Bool {
        return lhs.datetime == rhs.datetime
    }
}

extension ForecastTimemark : IdentifiableType {
    typealias Identity = String
    
    /// Unicate value
    var identity: Identity { return "\(datetime)" }
}

extension ForecastTimemark : Persistable {
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "ForecastTimemark"
    }
    
    static var primaryAttributeName: String {
        return "datetime"
    }
    
    init(entity: T) {
        datetime = entity.value(forKey: "datetime") as! Int32
        temperature = entity.value(forKey: "temperature") as! Double
        weather_desc = entity.value(forKey: "weather_desc") as! String
        weather_icon = entity.value(forKey: "weather_icon") as! String
        weather_text = entity.value(forKey: "weather_text") as! String
    }
    
    func update(_ entity: T) {
        entity.setValue(datetime, forKey: "datetime")
        entity.setValue(temperature, forKey: "temperature")
        entity.setValue(weather_desc, forKey: "weather_desc")
        entity.setValue(weather_icon, forKey: "weather_icon")
        entity.setValue(weather_text, forKey: "weather_text")
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
        }
    }
    
    /**
     Transform current date (int value) to formatted string
     - Returns: Date as formatted string
     */
    func getDateInFormat() -> String{
        let date = NSDate(timeIntervalSince1970: Double(self.datetime))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = NSLocalizedString("DATEFORMAT_TABLE_WEATHER", comment: "Date format of weather")
        return dayTimePeriodFormatter.string(from: date as Date)
    }
    
    /**
     Transform current temperature (double value) to formatted string
     - Returns: Temperature as formatted string
     */
    func getTemperatureString() -> String{
        return String(format: "%.1f%@", self.temperature, NSLocalizedString("TEMP_UNIT_DC", comment: "Degrees Celsius"))
    }
}
