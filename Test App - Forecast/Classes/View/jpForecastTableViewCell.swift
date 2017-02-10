//
//  jpForecastTableViewCell.swift
//  Test App - Forecast
//
//  Created by Jakub on 10.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit

class jpForecastTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    public func fillTableViewCell(object: jpWeatherServiceForecast){
        self.weatherImageView.image = UIImage(named: object.weatherImg)
        self.dayOfWeekLabel.text = object.dayOfWeek
        self.weatherDescriptionLabel.text = object.weatherDesc
        self.temperatureLabel.text = object.tempreature
    }
}
