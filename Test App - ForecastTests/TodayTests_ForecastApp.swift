//
//  TodayTests.swift
//  TodayTests
//
//  Created by Jakub on 11.01.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import RxSwift
import RxCocoa
import RxBlocking
import RxTest
import XCTest
import CoreLocation

@testable import Test_App___Forecast

class TodayTests_ForecastApp: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Checking jpWeatherService.sourceImageNameToAppImageName function
    func testImageResolving(){
        XCTAssertEqual("TodayWeatherIconImageViewSunny", jpWeatherService.instance.sourceImageNameToAppImageName("01d"))
        
        XCTAssertEqual("TodayWeatherIconImageViewStormy", jpWeatherService.instance.sourceImageNameToAppImageName("11n"))
        
        XCTAssertEqual("TodayWeatherIconImageViewWindy", jpWeatherService.instance.sourceImageNameToAppImageName("50n"))
        
        XCTAssertEqual("TodayWeatherIconImageViewCloudy", jpWeatherService.instance.sourceImageNameToAppImageName("example"))
        
        XCTAssertEqual("TodayWeatherIconImageViewCloudy", jpWeatherService.instance.sourceImageNameToAppImageName("13d"))
    }
    
    /// Checking jpWeatherService.windDegreeToDirection function
    func testDegreeToDirectionString() {
        XCTAssertThrowsError(try jpWeatherService.instance.windDegreeToDirection(361))
        
        XCTAssertThrowsError(try jpWeatherService.instance.windDegreeToDirection(1361))
        
        XCTAssertThrowsError(try jpWeatherService.instance.windDegreeToDirection(-1))
        
        XCTAssertThrowsError(try jpWeatherService.instance.windDegreeToDirection(-50))
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(10) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_N", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(35) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_NE", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(90) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_E", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(123) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_SE", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(185) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_S", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(210) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_SW", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(230) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_SW", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(271) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_W", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(310) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_NW", comment: "Test"))
        }
        
        if let value = try? jpWeatherService.instance.windDegreeToDirection(351) {
            XCTAssertEqual(value, NSLocalizedString("WIND_DIRECTION_N", comment: "Test"))
        }
    }
    
    /// Checking jpWeatherService.sourceJsonToServiceStruct function
    func testJsonSplit(){
        let jsonString:String = "{\"coord\":{\"lon\":-122.03,\"lat\":37.32},\"weather\":[{\"id\":804,\"main\":\"Clouds\",\"description\":\"overcast clouds\",\"icon\":\"04n\"}],\"base\":\"stations\",\"main\":{\"temp\":16.37,\"pressure\":1017,\"humidity\":72,\"temp_min\":15,\"temp_max\":18},\"visibility\":16093,\"wind\":{\"speed\":5.1,\"deg\":210},\"clouds\":{\"all\":90},\"dt\":1486632900,\"sys\":{\"type\":1,\"id\":471,\"message\":0.0925,\"country\":\"US\",\"sunrise\":1486652574,\"sunset\":1486690936},\"id\":5341145,\"name\":\"Cupertino\",\"cod\":200}"
        
        let city = jpLocationServiceCityAndLocation(name: "Cupertino, United States", latitude: 37.3213765, longitude: -122.03186554)
        
        do{
            let data: Data? = jsonString.data(using: String.Encoding.utf8)
            let anyObjJson: [String:Any] = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            let struct1:jpWeatherServiceToday = try jpWeatherService.instance.sourceJsonToServiceStruct(json: anyObjJson, city: city)
            let struct2 = jpWeatherServiceToday(weatherImg: "TodayWeatherIconImageViewCloudy", cityName: "Cupertino, United States", tempWeather: "16.4°C | Clouds", cloudness: "90%", humidity: "72%", pressure: "1017 hPA", windSpeed: "5.1 m/s", windDirection: "SW", mapUrl: URL(string: "http://openweathermap.org/weathermap?basemap=map&cities=true&layer=temperature&lat=37.3213765&lon=-122.03186554&zoom=8")!)
            
            XCTAssert(struct1 == struct2)
        }
        catch let error{
            XCTFail("\(error)")
        }
    }
    
    /// Checking jpWeatherService.getShareDataUrl function
    func testGettingShareUrl(){
        let cityData = jpLocationServiceCityAndLocation(name: "Sunnyvale, United States", latitude: 37.337627159999997, longitude: -122.03976311)
        
        XCTAssert(URL(string: "http://openweathermap.org/weathermap?basemap=map&cities=true&layer=temperature&lat=\(cityData.latitude)&lon=\(cityData.longitude)&zoom=8") == jpWeatherService.instance.getShareDataUrl(latitude: cityData.latitude, longitude: cityData.longitude))
    }
    
    /**
     Checking jpWeatherService.getTodayForecastObservable function and values from observable
     
     Needs internet connection
     */
    func testGettingDataAboutWeather(){
        var weather: jpWeatherServiceToday?
        let cityData = jpLocationServiceCityAndLocation(name: "Sunnyvale, United States", latitude: 37.337627159999997, longitude: -122.03976311)
        
        autoreleasepool {
            do{
                weather = try jpWeatherService.instance.getTodayForecastObservable(cityData: cityData).toBlocking().first()
            }
            catch let error{
                XCTFail("\(error)")
            }
        }
        
        XCTAssertEqual(cityData.name, weather?.cityName)
        XCTAssertEqual(jpWeatherService.instance.getShareDataUrl(latitude: cityData.latitude, longitude: cityData.longitude), weather?.mapUrl)
    }
}
