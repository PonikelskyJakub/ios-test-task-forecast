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
     Constructor - init VC, set title and create observer for city change and actualise weather info, when city change and city data are available
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.title = NSLocalizedString("TODAY_VIEW_CONTROLLER_TITLE", comment: "Today VC title");
        
        let weatherService = jpWeatherService.instance
        let locationService = jpLocationService.instance
        
        locationService.actualCityData.asObservable().subscribe(onNext: { n in
            if let data = n {
                weatherService.getTodayForecastObservable(cityData: data).observeOn(MainScheduler.instance).subscribe(onNext:{n in
                    let attachment:NSTextAttachment = NSTextAttachment()
                    attachment.image = UIImage(named: "TodayLocationLabelImage");
                    let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
                    let labelPositionString: NSMutableAttributedString = NSMutableAttributedString(string: " \(n.cityName)")
                    labelPositionString.insert(attachmentString, at: 0)
                    self.labelPosition.attributedText = labelPositionString
                    self.imageViewWeather.image = UIImage(named: n.weatherImg)
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
                            Utilities.showAlert(viewController: self, title: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), text: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_NETWORK_TEXT", comment: "Error text"))
                            return
                        default:
                            break;
                        }
                    }
                    
                    Utilities.showAlert(viewController: self, title: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), text: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TEXT", comment: "Error text"))
                }, onCompleted: {
                }).addDisposableTo(self.disposeBag)
            }
        }).addDisposableTo(self.disposeBag)
    }
    
    /// Changes title of screen when VC is active
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.title = NSLocalizedString("TODAY_VIEW_CONTROLLER_TITLE", comment: "Today VC title");
    }
    
    /// Share actual text and URL via UIActivityViewController
    @IBAction func shareButtonTouchUp(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [self.outputText, self.outputUrl], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
