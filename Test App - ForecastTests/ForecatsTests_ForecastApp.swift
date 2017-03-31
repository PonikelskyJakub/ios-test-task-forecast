//
//  ForecatsTests_ForecastApp.swift
//  Test App - Forecast
//
//  Created by Jakub Ponikelsky on 31.03.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import Foundation

import XCTest

@testable import Test_App___Forecast

class ForecastTests_ForecastApp: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Checking jpWeatherService.storeWeekForecastData function
    func testWeekForecastDataStoring(){
        let jsonString: String = "{\"city\":{\"id\":5341145,\"name\":\"Cupertino\",\"coord\":{\"lon\":-122.032181,\"lat\":37.323002},\"country\":\"US\",\"population\":0,\"sys\":{\"population\":0}},\"cod\":\"200\",\"message\":0.0143,\"cnt\":35,\"list\":[{\"dt\":1490972400,\"main\":{\"temp\":10.59,\"temp_min\":8.89,\"temp_max\":10.59,\"pressure\":991.89,\"sea_level\":1031.18,\"grnd_level\":991.89,\"humidity\":45,\"temp_kf\":1.7},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":5.11,\"deg\":347.001},\"rain\":{},\"sys\":{\"pod\":\"d\"},\"dt_txt\":\"2017-03-31 15:00:00\"},{\"dt\":1490983200,\"main\":{\"temp\":14.98,\"temp_min\":13.71,\"temp_max\":14.98,\"pressure\":991.53,\"sea_level\":1030.34,\"grnd_level\":991.53,\"humidity\":40,\"temp_kf\":1.28},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":5.72,\"deg\":350.503},\"rain\":{},\"sys\":{\"pod\":\"d\"},\"dt_txt\":\"2017-03-31 18:00:00\"},{\"dt\":1490994000,\"main\":{\"temp\":18.23,\"temp_min\":17.38,\"temp_max\":18.23,\"pressure\":989.74,\"sea_level\":1028.2,\"grnd_level\":989.74,\"humidity\":35,\"temp_kf\":0.85},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":5.73,\"deg\":349.501},\"rain\":{},\"sys\":{\"pod\":\"d\"},\"dt_txt\":\"2017-03-31 21:00:00\"},{\"dt\":1491004800,\"main\":{\"temp\":18.89,\"temp_min\":18.47,\"temp_max\":18.89,\"pressure\":988.51,\"sea_level\":1026.75,\"grnd_level\":988.51,\"humidity\":32,\"temp_kf\":0.43},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01n\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":5.16,\"deg\":350.003},\"rain\":{},\"sys\":{\"pod\":\"n\"},\"dt_txt\":\"2017-04-01 00:00:00\"},{\"dt\":1491015600,\"main\":{\"temp\":16.01,\"temp_min\":16.01,\"temp_max\":16.01,\"pressure\":989.18,\"sea_level\":1027.46,\"grnd_level\":989.18,\"humidity\":31,\"temp_kf\":0},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01n\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":4.49,\"deg\":350.002},\"rain\":{},\"sys\":{\"pod\":\"n\"},\"dt_txt\":\"2017-04-01 03:00:00\"}]}"
        
        let city = jpLocationServiceCityAndLocation(name: "Cupertino, United States", latitude: 37.3213765, longitude: -122.03186554)
        
        do{
            let data: Data? = jsonString.data(using: String.Encoding.utf8)
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            let store = TestStore()
            try jpWeatherService.storeWeekForecastData(json: json, city: city, store: store)
        }
        catch let error{
            XCTFail("\(error)")
        }
    }
}

class TestStore: jpWeatherServiceWeekDataStore {
    var numberOfCallsDelete: Int = 0
    var numberOfCallsLocation: Int = 0
    var numberOfCallsWeatherData: Int = 0
    
    func deleteAllData() -> Void {
        XCTAssert(numberOfCallsDelete == 0)
        numberOfCallsDelete += 1
    }
    
    func saveLocationData(appName: String, name: String, country: String, id: Int, latitude: Double, longitude: Double) -> Void {
        XCTAssert(appName == "Cupertino, United States")
        XCTAssert(name == "Cupertino")
        XCTAssert(country == "US")
        XCTAssert(id == 5341145)
        XCTAssert(latitude == 37.3213765)
        XCTAssert(longitude == -122.03186554)
        
        XCTAssert(numberOfCallsLocation == 0)
        numberOfCallsLocation += 1
    }
    
    func saveWeatherDataForTime(datetime: Int, temperature: Double, wearherDesc: String, wearherIcon: String, wearherText: String) -> Void {
        switch numberOfCallsWeatherData {
        case 0:
            XCTAssert(datetime == 1490972400)
            XCTAssert(temperature == 10.59)
            XCTAssert(wearherDesc == "Clear")
            XCTAssert(wearherIcon == "TodayWeatherIconImageViewSunny")
            XCTAssert(wearherText == "Clear Sky")
            break
        case 1:
            XCTAssert(datetime == 1490983200)
            XCTAssert(temperature == 14.98)
            XCTAssert(wearherDesc == "Clear")
            XCTAssert(wearherIcon == "TodayWeatherIconImageViewSunny")
            XCTAssert(wearherText == "Clear Sky")
            break
        case 2:
            XCTAssert(datetime == 1490994000)
            XCTAssert(temperature == 18.23)
            XCTAssert(wearherDesc == "Clear")
            XCTAssert(wearherIcon == "TodayWeatherIconImageViewSunny")
            XCTAssert(wearherText == "Clear Sky")
            break
        case 3:
            XCTAssert(datetime == 1491004800)
            XCTAssert(temperature == 18.89)
            XCTAssert(wearherDesc == "Clear")
            XCTAssert(wearherIcon == "TodayWeatherIconImageViewSunny")
            XCTAssert(wearherText == "Clear Sky")
            break
        case 4:
            XCTAssert(datetime == 1491015600)
            XCTAssert(temperature == 16.01)
            XCTAssert(wearherDesc == "Clear")
            XCTAssert(wearherIcon == "TodayWeatherIconImageViewSunny")
            XCTAssert(wearherText == "Clear Sky")
            break
        default:
            XCTFail("To much data!")
        }
        numberOfCallsWeatherData += 1
    }
}
