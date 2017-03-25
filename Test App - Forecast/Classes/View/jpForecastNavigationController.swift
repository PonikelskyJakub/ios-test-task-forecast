//
//  jpForecastNavigationController.swift
//  Test App - Forecast
//
//  Created by Jakub on 06.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit

class jpForecastNavigationController: UINavigationController {
    
    /**
     Constructor - init NVC, set bar design
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(named: "NavigationItemBackgroundImage"), for: .default)
        let shadow = UIImage(named: "NavigationItemShadowImage")?.scaleImage(toWidth: UIScreen.main.bounds.width)
        self.navigationBar.shadowImage = shadow
    }
}
