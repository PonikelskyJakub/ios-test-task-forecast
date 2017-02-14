//
//  jpForecastViewController.swift
//  Test App - Forecast
//
//  Created by Jakub on 10.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class jpForecastViewController: UIViewController {

    @IBOutlet weak var forecastTableView: UITableView!
    
    /// Variable with tableView data
    fileprivate var forecastData: Variable<Array<jpWeatherServiceForecast>> = Variable(Array())
    
    /// Dispose bag for deallocating of observers.
    private let disposeBag = DisposeBag()

    /**
     Init VC, create observer for data visible in tableview, fill table view with test data, change title
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.forecastData.asObservable().subscribe(onNext: { n in
            self.forecastTableView.reloadData()
        }).addDisposableTo(self.disposeBag)
        
        let locationService = jpLocationService.instance
        locationService.actualCityData.asObservable().subscribe(onNext: { n in
            self.tabBarController?.title = locationService.actualCityData.value?.name;

            self.forecastData.value.append(jpWeatherServiceForecast(weatherImg: "ForecastWeatherIconImageViewCloudy", dayOfWeek: "Monday1", weatherDesc: "Cloudy", tempreature: "5°C"))
            self.forecastData.value.append(jpWeatherServiceForecast(weatherImg: "ForecastWeatherIconImageViewCloudy", dayOfWeek: "Monday2", weatherDesc: "Cloudy", tempreature: "5°C"))
            self.forecastData.value.append(jpWeatherServiceForecast(weatherImg: "ForecastWeatherIconImageViewCloudy", dayOfWeek: "Monday3", weatherDesc: "Cloudy", tempreature: "5°C"))
        }).addDisposableTo(self.disposeBag)
    }
    
    /// Changes title of screen when VC is active
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let locationService = jpLocationService.instance
        self.tabBarController?.title = locationService.actualCityData.value?.name;
    }
}

// MARK: - Table View Data Source

extension jpForecastViewController: UITableViewDataSource {
    /**
     Returns count of data objects
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecastData.value.count
    }
    
    /**
     Return filled cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jpForecastTableViewCell") as! jpForecastTableViewCell
        cell.fillTableViewCell(object: self.forecastData.value[indexPath.row])
        return cell
    }
}

// MARK: - Table View Delegate

extension jpForecastViewController: UITableViewDelegate {
    /**
     Nothing - unselectable cells
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}



