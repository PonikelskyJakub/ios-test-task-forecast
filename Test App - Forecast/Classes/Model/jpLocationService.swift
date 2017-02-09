//
//  jpLocationService.swift
//  Test App - Forecast
//
//  Created by Jakub on 16.01.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

public struct jpLocationServiceCityAndLocation {
    var name: String
    var latitude: Double
    var longitude: Double
}

enum jpLocationServiceStatus {
    case allow, disallow, unknown
}

enum jpLocationServiceError: Error {
    case noNetworkConnection
    case unknownCity
    case unknownCountry
}

class jpLocationService: NSObject {
    
    /// Singleton instance of jpLocationService
    static let instance = jpLocationService()
    
    private let locationManager = CLLocationManager()

    /// Private constructor - CLLocationManager params
    private override init(){
        super.init();
        
        self.locationManager.distanceFilter = 10.0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    /// Start location tracking
    public func startUpdatingLocation (){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    /// Stop location tracking
    public func stopUpdatingLocation (){
        self.locationManager.stopUpdatingLocation()
    }
    
    /**
     Create Driver for CLLocationManager status (jpLocationServiceStatus struct).
     - Returns: Driver
     */
    public func getAuthorizationDriver() -> Driver<jpLocationServiceStatus> {
        return Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else{
                return Observable.just(status)
            }
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map{
                switch $0 {
                case .authorizedAlways, .authorizedWhenInUse:
                    return jpLocationServiceStatus.allow;
                case .denied, .restricted:
                    return jpLocationServiceStatus.disallow;
                default:
                    return jpLocationServiceStatus.unknown;
                }
        }

    }
    
    /**
     Create Driver for CLLocation of device
     - Returns: Driver
     */
    public func getLocationDriver() -> Driver<CLLocation> {
        return locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
    }
    
    /**
     Create Observable for city where device is
     - Returns: Observable jpLocationServiceCityAndLocation
     */
    public func getCityAndLocationObservable() -> Observable<jpLocationServiceCityAndLocation> {
        return self.getLocationDriver().asObservable().mapLocationToCityName();
    }
}

extension Observable where Element: CLLocation {
    
    /**
     Change Observer from CLLocation to jpLocationServiceCityAndLocation.
     
     Simply check internet connection and get city name via CLGeocoder.
     
     Returns:
     - onNext: jpLocationServiceCityAndLocation object
     - onError: jpLocationServiceError object
     */
    public func mapLocationToCityName() -> Observable<jpLocationServiceCityAndLocation> {
        return Observable<jpLocationServiceCityAndLocation>.create{ observer in
            let location = jpLocationService.instance.getLocationDriver();
            let geoCoder = CLGeocoder()
            
            let disposableLocation = location.drive(onNext: { n in
                guard Reachability.connectedToNetwork() else {
                    observer.on(.error(jpLocationServiceError.noNetworkConnection))
                    return
                }
                
                geoCoder.reverseGeocodeLocation(n, completionHandler: { (placemarks, error) -> Void in
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    
                    guard let city = placeMark.addressDictionary!["City"] as? String else {
                        observer.on(.error(jpLocationServiceError.unknownCity))
                        return
                    }
                    
                    guard let country = placeMark.addressDictionary!["Country"] as? String else {
                        observer.on(.error(jpLocationServiceError.unknownCountry))
                        return
                    }
                    
                    let newValue = jpLocationServiceCityAndLocation(name: "\(city), \(country)", latitude: n.coordinate.latitude, longitude: n.coordinate.longitude);
                    observer.on(.next(newValue))
                })
            })
            
            return Disposables.create {
                geoCoder.cancelGeocode()
                disposableLocation.dispose()
            }
        }
    }
}
