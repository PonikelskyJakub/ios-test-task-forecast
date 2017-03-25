//
//  jpForecastViewController.swift
//  Test App - Forecast
//
//  Created by Jakub on 10.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData
import UIKit

class jpForecastViewController: UIViewController {

    @IBOutlet weak var forecastTableView: UITableView!
    
    /// Dispose bag for deallocating of observers.
    private let disposeBag = DisposeBag()

    /**
     Init VC, check location change (change title, start weather data obtaining task), check CoreData entity anc actualize tableView.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        let weatherService = jpWeatherService.instance
        let locationService = jpLocationService.instance
        
        locationService.actualCityData.asObservable().subscribe(onNext: { n in
            if let data = n {
                self.tabBarController?.title = locationService.actualCityData.value?.name;

                weatherService.getWeekForecastObservable(cityData: data).observeOn(MainScheduler.instance).subscribe(onError:{n in
                    if let err = n as? jpWeatherServiceError {
                        switch err {
                        case .noNetworkConnection:
                            Utilities.showAlert(in: self, withTitle: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), andText: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_NETWORK_TEXT", comment: "Error text"))
                            return
                        default:
                            break;
                        }
                    }
                    
                    Utilities.showAlert(in: self, withTitle: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TITLE", comment: "Error title"), andText: NSLocalizedString("WARNING_POPUPS_DATA_CANNOT_BE_LOADED_TEXT", comment: "Error text"))
                }, onCompleted: {
                }).addDisposableTo(self.disposeBag)
            }
        }).addDisposableTo(self.disposeBag)
        
        jpCoreDataService.instance.managedObjectContext.rx.entities(ForecastTimemark.self,
                                         sortDescriptors: [NSSortDescriptor(key: "datetime", ascending: true)])
            .bindTo(forecastTableView.rx.items(cellIdentifier: "jpForecastTableViewCell")) { row, event, cell in
                let cell = cell as! jpForecastTableViewCell
                cell.fillTableViewCell(object: event)
            }
            .addDisposableTo(self.disposeBag)
    }
    
    /// Changes title of screen when VC is active
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let locationService = jpLocationService.instance
        self.tabBarController?.title = locationService.actualCityData.value?.name;
    }
}
