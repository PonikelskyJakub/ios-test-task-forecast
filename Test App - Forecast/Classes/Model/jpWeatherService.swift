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

struct jpWeatherServiceToday {
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

enum jpWeatherServiceError: Error {
    case noNetworkConnection
    case urlRequestProblem
    case unknownCity
    case badDataFormat(detail: String)
    case localizationProblem
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
    private func windDegreeToDirection(_ degree: Int) throws -> String{
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
    private func sourceImageNameToAppImageName(_ sourceImageName: String) -> String{
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
     Gets data from OWM JSON and jpLocationServiceCityAndLocation object and create jpWeatherServiceToday object with correct values
     - Parameter json: OWM JSON
     - Parameter city: City name, longitude, latitude
     - Returns: Info abyout weather (jpWeatherServiceToday)
     - Throws: jpWeatherServiceError.badDataFormat if some value is incorrect or missing (check detail text)
     */
    private func sourceJsonToServiceStruct(json: [String:Any], city: jpLocationServiceCityAndLocation) throws -> jpWeatherServiceToday {
        guard let clouds = json["clouds"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'clouds' folder")
        }
        
        guard let cloudness = clouds["all"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'clouds:all' folder")
        }
        
        guard let main = json["main"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main' folder")
        }
        
        guard let humidity = main["humidity"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:humidity' folder")
        }
        
        guard let pressure = main["pressure"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:pressure' folder")
        }
        
        guard let temp = main["temp"] as? Double else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'main:temp' folder")
        }
        
        guard let wind = json["wind"] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind' folder")
        }
        
        guard let windSpeed = wind["speed"] as? Double else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind:speed' folder")
        }
        
        guard let windDeg = wind["deg"] as? Int else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'wind:deg' folder")
        }
        
        guard let weather = json["weather"] as? [Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather' folder")
        }
        
        guard let weatherObj = weather[0] as? [String: Any] else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0' folder")
        }
        
        guard let weatherDesc = weatherObj["main"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0:main' folder")
        }
        
        guard let weatherCode = weatherObj["icon"] as? String else {
            throw jpWeatherServiceError.badDataFormat(detail: "Missing 'weather:0:icon' folder")
        }
        
        let weatherText: String = String(format: "%.1f%@ | %@", temp, NSLocalizedString("TEMP_UNIT_DC", comment: "Degrees Celsius"), weatherDesc)
        let cloudnessText: String = String(format: "%d%@", cloudness, "%")
        let humidityText: String = String(format: "%d%@", humidity, "%")
        let pressureText: String = String(format: "%d %@", pressure, NSLocalizedString("PRESSURE_UNIT_HPA", comment: "hPascal"))
        let cityName: String = city.name
        let windSpeedText: String = String(format: "%.1f %@", windSpeed, NSLocalizedString("WIND_SPEED_UNIT_MPS", comment: "Meters per second"))
        let windDirectionText = try self.windDegreeToDirection(windDeg)
        let weatherImg = self.sourceImageNameToAppImageName(weatherCode)
        let mapUrl = self.getShareDataUrl(latitude: city.latitude, longitude: city.longitude)
        
        return jpWeatherServiceToday(weatherImg: weatherImg, cityName: cityName, tempWeather: weatherText, cloudness: cloudnessText, humidity: humidityText, pressure: pressureText, windSpeed: windSpeedText, windDirection: windDirectionText, mapUrl: mapUrl)
    }
    
    /**
     Gets URL to OWM API for JSON
     - Parameter latitude: position latitude
     - Parameter longitude: position longitude
     - Returns: Correct URL
     */
    private func getSourceDataUrl(latitude: Double, longitude: Double) -> URL{
        return URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=18f1e34ef94fff88795abb0a8363619b&units=metric")!
    }
    
    /**
     Gets URL to OWM Weather map
     - Parameter latitude: position latitude
     - Parameter longitude: position longitude
     - Returns: Correct URL
     */
    private func getShareDataUrl(latitude: Double, longitude: Double) -> URL{
        return URL(string: "http://openweathermap.org/weathermap?basemap=map&cities=true&layer=temperature&lat=\(latitude)&lon=\(longitude)&zoom=8")!
    }
    
    /**
     Get Observer to jpWeatherServiceToday.
     
     Simply checking city name of position (via jpLocationService.getCityAndLocationObservable) and if value is changed check current weather on OWM for this location.
     
     Returns:
     - onNext: jpWeatherServiceToday object
     - onError: jpWeatherServiceError object
     */
    public func getTodayForecastObservable() -> Observable<jpWeatherServiceToday> {
        return Observable.create{ observer in
            let location = jpLocationService.instance.getCityAndLocationObservable();
            var task: URLSessionDataTask?;
            
            let disposableWeather = location.subscribe(onNext: { n in
                guard Reachability.connectedToNetwork() else {
                    observer.on(.error(jpWeatherServiceError.noNetworkConnection))
                    return
                }
                
                struct CityHolder {
                    static var cityName:String? = nil
                }
                
                if(n.name != CityHolder.cityName){
                    CityHolder.cityName = n.name
                    
                    let url = self.getSourceDataUrl(latitude: n.latitude, longitude: n.longitude)
                    
                    task = URLSession.shared.dataTask(with: url) { data, response, error in
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
                            observer.on(.next(try self.sourceJsonToServiceStruct(json: json, city: n)))
                            //observer.on(.completed)
                        } catch let errorBDF as jpWeatherServiceError {
                            observer.on(.error(errorBDF))
                            return
                        } catch {
                            observer.on(.error(jpWeatherServiceError.badDataFormat(detail: "Other problem")))
                            return
                        }
                    }
                    task?.resume()
                }
            }, onError:{n in
                if let err = n as? jpLocationServiceError {
                    if(err == jpLocationServiceError.noNetworkConnection){
                        observer.on(.error(jpWeatherServiceError.noNetworkConnection))
                        return
                    }
                }
                observer.on(.error(jpWeatherServiceError.localizationProblem))
            })
            
            return Disposables.create {
                task?.cancel()
                disposableWeather.dispose()
            }
        }
    }
}
