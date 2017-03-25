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

extension jpLocationServiceCityAndLocation: Equatable {
    /// Comparation of two jpLocationServiceCityAndLocation struct
    public static func == (lhs: jpLocationServiceCityAndLocation, rhs: jpLocationServiceCityAndLocation) -> Bool {
        let areEqual = lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.name == rhs.name
        return areEqual
    }
}

enum jpLocationServiceStatus {
    case allow, disallow, unknown
}

enum jpLocationServiceError: Error {
    case noNetworkConnection
    case unknownCity
    case unknownCountry
    case dataProblem
}

class jpLocationService: NSObject {
    
    /// Actual position variable
    private (set) var actualCityData: Variable<jpLocationServiceCityAndLocation?> = Variable(nil)
    
    /// Dispose bag for deallocating of observers.
    private let disposeBag = DisposeBag()

    /// Singleton instance of jpLocationService
    static let instance = jpLocationService()
    
    internal let locationManager = CLLocationManager()

    /// Private constructor - CLLocationManager params
    private override init(){
        super.init();

        self.locationManager.distanceFilter = Config.locationManager.distanceFilter
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    /**
     Create observers for location authorization and location reading, when observable is complete or error localization is stopped
     */
    public func checkCurrentPosition() -> Void {
        self.startUpdatingLocation()
        
        self.getAuthorizationDriver().drive(onNext:{n in
            if(n == jpLocationServiceStatus.disallow){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Utilities.showAlert(in: appDelegate.window?.rootViewController, withTitle: NSLocalizedString("WARNING_POPUPS_LOCALIZATION_DISABLED_TITLE", comment: "Error title"), andText: NSLocalizedString("WARNING_POPUPS_LOCALIZATION_DISABLED_TEXT", comment: "Error text"))
            }
        }).addDisposableTo(disposeBag)
        
        self.getCityAndLocationObservable().subscribe(onNext: { n in
            if(self.actualCityData.value?.name != n.name){
                self.actualCityData.value = n
            }
        },onError: { n in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let err = n as? jpLocationServiceError {
                switch err {
                case .noNetworkConnection:
                    Utilities.showAlert(in: appDelegate.window?.rootViewController, withTitle: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), andText: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_NETWORK_TEXT", comment: "Error text"))
                    return
                default:
                    break;
                }
            }
            
            Utilities.showAlert(in: appDelegate.window?.rootViewController, withTitle: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), andText: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TEXT", comment: "Error text"))
            self.stopUpdatingLocation()
        },onCompleted: {
            self.stopUpdatingLocation()
        }).addDisposableTo(disposeBag)
    }
    
    /// Start location tracking
    public func startUpdatingLocation() -> Void {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    /// Stop location tracking
    public func stopUpdatingLocation() -> Void {
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
     
     Simply check internet connection and get observable for detecting city name via CLGeocoder or empty observable.
     
     Returns:
     - onNext: jpLocationServiceCityAndLocation object
     - onError: jpLocationServiceError object
     */
    public func mapLocationToCityName() -> Observable<jpLocationServiceCityAndLocation> {
        return self.flatMap { n in
            return Observable<jpLocationServiceCityAndLocation>.create{ observer in
                let geoCoder = CLGeocoder()
                guard Reachability.connectedToNetwork() else {
                    observer.on(.error(jpLocationServiceError.noNetworkConnection))
                    return Disposables.create {
                    }
                }
                
                geoCoder.reverseGeocodeLocation(n, completionHandler: { (placemarks, error) -> Void in
                    // Place details
                    var plaMark: CLPlacemark?
                    plaMark = placemarks?[0]
                    
                    guard let placeMark = plaMark else{
                        observer.on(.error(jpLocationServiceError.dataProblem))
                        return
                    }
                    
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
                    observer.on(.completed)
                })
                
                return Disposables.create {
                    geoCoder.cancelGeocode()
                }
            }
        }
    }
}
