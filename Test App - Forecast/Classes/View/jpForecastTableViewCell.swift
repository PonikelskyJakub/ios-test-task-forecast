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
    
    /**
     Fill all labels and images in cell
     */
    public func fillTableViewCell(object: ForecastTimemark){
        self.dayOfWeekLabel.text = "\(object.getDateInFormat())"
        self.weatherImageView.image = UIImage(named: object.weather_icon)
        self.weatherDescriptionLabel.text = object.weather_text
        self.temperatureLabel.text = "\(object.getTemperatureString())"
    }
}
