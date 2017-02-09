//
//  jpTodayWeatherViewController.swift
//  Test App - Forecast
//
//  Created by Jakub on 03.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class jpTodayWeatherViewController: UIViewController {
    
    @IBOutlet weak var imageViewWeather: UIImageView!
    @IBOutlet weak var labelPosition: UILabel!
    @IBOutlet weak var labelWeather: UILabel!
    @IBOutlet weak var labelCloudness: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelPressure: UILabel!
    @IBOutlet weak var labelWindSpeed: UILabel!
    @IBOutlet weak var labelWindDirection: UILabel!
    
    /// Share button URL.
    private var outputUrl: URL = URL(string:"http://openweathermap.org/weathermap")!
    /// Share button text.
    private var outputText: String = NSLocalizedString("SHARE_DEFAULT_MESSAGE", comment: "Default share msg")
    /// Dispose bag for deallocating of observers.
    private let disposeBag = DisposeBag()

    /** 
     Constructor - init VC, set title and create two observers to values of weather and location authorization
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = NSLocalizedString("TODAY_VIEW_CONTROLLER_TITLE", comment: "Today VC title");
        
        let locationService = jpLocationService.instance
        locationService.getAuthorizationDriver().drive(onNext:{n in
            if(n == jpLocationServiceStatus.disallow){
                self.showAlert(title: NSLocalizedString("WARNING_POPUPS_LOCALIZATION_DISABLED_TITLE", comment: "Error title"), text: NSLocalizedString("WARNING_POPUPS_LOCALIZATION_DISABLED_TEXT", comment: "Error text"))
            }
        }).addDisposableTo(disposeBag)
        
        let weatherService = jpWeatherService.instance
        weatherService.getTodayForecastObservable(cityTest: true).observeOn(MainScheduler.instance).subscribe(onNext:{n in
            self.imageViewWeather.image = UIImage(named: n.weatherImg)
            self.labelPosition.text = n.cityName
            self.labelWeather.text = n.tempWeather
            self.labelCloudness.text = n.cloudness
            self.labelHumidity.text = n.humidity
            self.labelPressure.text = n.pressure
            self.labelWindSpeed.text = n.windSpeed
            self.labelWindDirection.text = n.windDirection
            self.outputUrl = n.mapUrl
            self.outputText = String(format: "%@: %@ - %@", NSLocalizedString("SHARE_MESSAGE_PREFIX", comment: "Share msg prefix"), n.cityName, n.tempWeather)
        },onError:{n in
            if let err = n as? jpWeatherServiceError {
                switch err {
                    case .noNetworkConnection:
                        self.showAlert(title: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), text: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_NETWORK_TEXT", comment: "Error text"))
                        return
                    default:
                        break;
                }
            }

            self.showAlert(title: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), text: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TEXT", comment: "Error text"))
        }).addDisposableTo(disposeBag)
    }
    
    /**
     Show alert popup
     
     - Parameter title: Title of popup.
     - Parameter text: Text in popup.
     */
    private func showAlert(title: String, text: String) -> Void{
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("WARNING_POPUPS_DISMISS_BUTTON", comment: "OK"), style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Share actual text and URL via UIActivityViewController
    @IBAction func shareButtonTouchUp(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [self.outputText, self.outputUrl], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
