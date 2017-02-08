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
    
    static let instance = jpLocationService()
    
    private let locationManager = CLLocationManager()

    private override init(){
        super.init();
        
        self.locationManager.distanceFilter = 10.0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    public func startUpdatingLocation (){
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation (){
        self.locationManager.stopUpdatingLocation()
    }
    
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
    
    public func getLocationDriver() -> Driver<CLLocation> {
        return locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
    }
    
    public func getCityAndLocationObservable() -> Observable<jpLocationServiceCityAndLocation> {
        return self.getLocationDriver().asObservable().mapLocationToCityName();
    }
}

extension Observable where Element: CLLocation {
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
