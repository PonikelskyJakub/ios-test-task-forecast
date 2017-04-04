//
//  jpWeatherService.swift
//  Test App - Forecast
//
//  Created by Jakub on 07.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

enum jpWeatherServiceError: Error {
    case noNetworkConnection
    case urlRequestProblem
    case unknownCity
    case badDataFormat(detail: String)
    case localizationProblem
}

enum jpWeatherServiceForecastType: Int {
    case today
    case fiveDays
}

protocol jpWeatherServiceWeekDataStore {
    func deleteAllData() throws -> Void
    func saveLocationData(appName: String, name: String, country: String, id: Int, latitude: Double, longitude: Double) throws -> Void
    func saveWeatherDataForTime(datetime: Int, temperature: Double, wearherDesc: String, wearherIcon: String, wearherText: String) throws -> Void
}

class jpWeatherService: NSObject {
    
    /// Singleton instance of jpWeatherService
    static let instance = jpWeatherService()
    
    /// Private constructor
    private override init(){
        super.init();
    }
    
    /**
     Transform degree value to localizated string of direction
     - Parameter degree: Int value with degrees
     - Returns: Localizated string of direction (N, NE, SW etc.)
     - Throws: jpWeatherServiceError.badDataFormat if value is incorrect
     */
    class func windDegreeToDirection(_ degree: Int) throws -> String{
        switch degree {
        case 0...22:
            return NSLocalizedString("WIND_DIRECTION_N", comment: "North");
        case 23...67:
            return NSLocalizedString("WIND_DIRECTION_NE", comment: "Northeast");
        case 68...112:
            return NSLocalizedString("WIND_DIRECTION_E", comment: "East");
        case 113...157:
            return NSLocalizedString("WIND_DIRECTION_SE", comment: "Southeast");
        case 158...202:
            return NSLocalizedString("WIND_DIRECTION_S", comment: "South");
        case 203...247:
            return NSLocalizedString("WIND_DIRECTION_SW", comment: "Southwest");
        case 248...292:
            return NSLocalizedString("WIND_DIRECTION_W", comment: "West");
        case 293...337:
            return NSLocalizedString("WIND_DIRECTION_NW", comment: "Northwest");
        case 338...360:
            return NSLocalizedString("WIND_DIRECTION_N", comment: "North");
        default:
            throw jpWeatherServiceError.badDataFormat(detail: "Degree to direction problem")
        }
    }
    
    /**
     Transform image name at OpenWeatherMap to image in app
     - Parameter sourceImageName: name of image at OWM
     - Returns: Image name in app
     */
    class func sourceImageNameToAppImageName(_ sourceImageName: String) -> String{
        switch sourceImageName {
        case "01d", "01n":
            return "TodayWeatherIconImageViewSunny"
        case "11d", "11n":
            return "TodayWeatherIconImageViewStormy"
        case "50d", "50n":
            return "TodayWeatherIconImageViewWindy"
        default:
            return "TodayWeatherIconImageViewCloudy"
        }
    }
    
    /**
     Gets data from OWM JSON and jpLocationServiceCityAndLocation object and create ForecastToday object with correct values
     - Parameter json: OWM JSON
     - Parameter city: City name, longitude, latitude
     - Returns: Info abyout weather (ForecastToday)
     - Throws: jpWeatherServiceError.badDataFormat if some value is incorrect or missing (check detail text)
     */
    class func sourceJsonToServiceStruct(json: [String:Any], city: jpLocationServiceCityAndLocation) throws -> ForecastToday {
        guard let clouds = json["clouds"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'clouds' property")
        }
        
        guard let cloudness = clouds["all"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'clouds:all' property")
        }
        
        guard let main = json["main"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main' property")
        }
        
        guard let humidity = main["humidity"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:humidity' property")
        }
        
        guard let pressure = main["pressure"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:pressure' property")
        }
        
        guard let temp = main["temp"] as? Double else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:temp' property")
        }
        
        guard let wind = json["wind"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind' property")
        }
        
        guard let windSpeed = wind["speed"] as? Double else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind:speed' property")
        }
        
        guard let windDeg = wind["deg"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind:deg' property")
        }
        
        guard let weather = json["weather"] as? [Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather' property")
        }
        
        guard let weatherObj = weather[0] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0' property")
        }
        
        guard let weatherDesc = weatherObj["main"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0:main' property")
        }
        
        guard let weatherCode = weatherObj["icon"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0:icon' property")
        }
        
        let weatherText: String = String(format: "%.1f%@ | %@", temp, NSLocalizedString("TEMP_UNIT_DC", comment: "Degrees Celsius"), weatherDesc)
        let cloudnessText: String = String(format: "%d%@", cloudness, "%")
        let humidityText: String = String(format: "%d%@", humidity, "%")
        let pressureText: String = String(format: "%d %@", pressure, NSLocalizedString("PRESSURE_UNIT_HPA", comment: "hPascal"))
        let cityName: String = city.name
        let windSpeedText: String = String(format: "%.1f %@", windSpeed, NSLocalizedString("WIND_SPEED_UNIT_MPS", comment: "Meters per second"))
        let windDirectionText = try jpWeatherService.windDegreeToDirection(windDeg)
        let weatherImg = jpWeatherService.sourceImageNameToAppImageName(weatherCode)
        let mapUrl = jpWeatherService.getShareDataUrl(latitude: city.latitude, longitude: city.longitude)
        
        return ForecastToday(weatherImg: weatherImg, cityName: cityName, tempWeather: weatherText, cloudness: cloudnessText, humidity: humidityText, pressure: pressureText, windSpeed: windSpeedText, windDirection: windDirectionText, mapUrl: mapUrl)
    }
    
    /**
     Gets data from OWM JSON and jpLocationServiceCityAndLocation object and save it to Core Data
     - Parameter json: OWM JSON
     - Parameter city: City name, longitude, latitude
     - Parameter store: Store for weather data
     - Throws: jpWeatherServiceError.badDataFormat if some value is incorrect or missing (check detail text)
     */
    class func storeWeekForecastData(json: [String:Any], city: jpLocationServiceCityAndLocation, store: jpWeatherServiceWeekDataStore) throws -> Void {
        guard let cityJson = json["city"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'city' property")
        }
        
        guard let cityIdJson = cityJson["id"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'city:id' property")
        }
        
        guard let cityNameJson = cityJson["name"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'city:name' property")
        }
        
        guard let cityCountryJson = cityJson["country"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'city:country' property")
        }
    
        do {
            try store.deleteAllData()
            
            try store.saveLocationData(appName: city.name, name: cityNameJson, country: cityCountryJson, id: cityIdJson, latitude: city.latitude, longitude: city.longitude)
        } catch {
            throw jpWeatherServiceError.badDataFormat(detail: "Storing in Core Data problem")
        }
        
        guard let listJson = json["list"] as? [Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list' property")
        }
        
        for i in 0...listJson.count-1 {
            if let listItemJson = listJson[i] as? [String: Any] {
                guard let dateTime = listItemJson["dt"] as? Int else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):dt' property")
                }
                
                guard let main = listItemJson["main"] as? [String: Any] else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):main' property")
                }
                
                guard let temp = main["temp"] as? Double else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):main:temp' property")
                }
                
                guard let weather = listItemJson["weather"] as? [Any] else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):weather' property")
                }
                
                guard let weatherObj = weather[0] as? [String: Any] else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):weather:0' property")
                }
                
                guard let weatherDesc = weatherObj["main"] as? String else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):weather:0:main' property")
                }
                
                guard let weatherCode = weatherObj["icon"] as? String else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):weather:0:icon' property")
                }
                
                guard let weatherDescDetail = weatherObj["description"] as? String else {
                    throw jpWeatherServiceError.badDataFormat(detail: "Missing 'list:\(i):weather:0:description' property")
                }
                
                do {
                    try store.saveWeatherDataForTime(datetime: dateTime, temperature: temp, wearherDesc: weatherDesc, wearherIcon: jpWeatherService.sourceImageNameToAppImageName(weatherCode), wearherText: weatherDescDetail.capitalized)
                } catch {
                    throw jpWeatherServiceError.badDataFormat(detail: "Storing in Core Data problem")
                }
            }
        }
        
        jpCoreDataService.instance.saveContext()
    }
    
    /**
     Gets URL to OWM API for JSON
     - Parameter latitude: position latitude
     - Parameter longitude: position longitude
     - Parameter forecastType: type of forecast
     - Returns: Correct URL
     */
    class func getSourceDataUrl(latitude: Double, longitude: Double, forecastType: jpWeatherServiceForecastType) -> URL{
        let url: String
        switch forecastType {
        case jpWeatherServiceForecastType.fiveDays:
            url = "\(URLProvider.shared.url(for: .fiveDays))&lat=\(latitude)&lon=\(longitude)"
        case jpWeatherServiceForecastType.today:
            url = "\(URLProvider.shared.url(for: .today))&lat=\(latitude)&lon=\(longitude)"
        }
        return URL(string: url)!
    }
    
    /**
     Gets URL to OWM Weather map
     - Parameter latitude: position latitude
     - Parameter longitude: position longitude
     - Returns: Correct URL
     */
    class func getShareDataUrl(latitude: Double, longitude: Double) -> URL{
        return URL(string: "\(Config.openWeatherMap.mapUrl)?basemap=map&cities=true&layer=temperature&lat=\(latitude)&lon=\(longitude)&zoom=8")!
    }
    
    /// Only last open weather map task makes sence to load
    private var owmDownloadTask: URLSessionDataTask?

    /**
     Returns observable for checking current weather for city from parameter cityData
     
     Returns:
     - onNext: ForecastToday object
     - onError: jpWeatherServiceError object
     
     - Parameter cityData: data about city
     */
    public func getTodayForecastObservable(cityData: jpLocationServiceCityAndLocation) -> Observable<ForecastToday> {
        return Observable.create{ observer in
            if let owmDownloadTask = self.owmDownloadTask {
                owmDownloadTask.cancel()
            }
            
            let url = jpWeatherService.getSourceDataUrl(latitude: cityData.latitude, longitude: cityData.longitude, forecastType: jpWeatherServiceForecastType.today)
            self.owmDownloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    observer.on(.error(jpWeatherServiceError.urlRequestProblem))
                    return
                }
                
                guard let data = data else {
                    observer.on(.error(jpWeatherServiceError.badDataFormat(detail: "Data is nil")))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    observer.on(.next(try jpWeatherService.sourceJsonToServiceStruct(json: json, city: cityData)))
                    observer.on(.completed)
                } catch let errorBDF as jpWeatherServiceError {
                    observer.on(.error(errorBDF))
                    return
                } catch {
                    observer.on(.error(jpWeatherServiceError.badDataFormat(detail: "Other problem")))
                    return
                }
            }
            self.owmDownloadTask?.resume()
            
            return Disposables.create {
                self.owmDownloadTask?.cancel()
            }
        }
    }
    
    /**
     Returns observable for checking forecast for city from parameter cityData and store it in coredata
     
     Returns:
     - onError: jpWeatherServiceError object
     
     - Parameter cityData: data about city
     */
    public func getWeekForecastObservable(cityData: jpLocationServiceCityAndLocation) -> Observable<Bool> {
        return Observable.create{ observer in
            if let owmDownloadTask = self.owmDownloadTask {
                owmDownloadTask.cancel()
            }
            
            let url = jpWeatherService.getSourceDataUrl(latitude: cityData.latitude, longitude: cityData.longitude, forecastType: jpWeatherServiceForecastType.fiveDays)
            self.owmDownloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    observer.on(.error(jpWeatherServiceError.urlRequestProblem))
                    return
                }
                
                guard let data = data else {
                    observer.on(.error(jpWeatherServiceError.badDataFormat(detail: "Data is nil")))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    try jpWeatherService.storeWeekForecastData(json: json, city: cityData, store: jpCoreDataService.instance)
                    observer.on(.completed)
                } catch let errorBDF as jpWeatherServiceError {
                    observer.on(.error(errorBDF))
                    return
                } catch {
                    observer.on(.error(jpWeatherServiceError.badDataFormat(detail: "Other problem")))
                    return
                }
            }
            self.owmDownloadTask?.resume()
            
            return Disposables.create {
                self.owmDownloadTask?.cancel()
            }
        }
    }
}
