//
//  Utilities.swift
//  Test App - Forecast
//
//  Created by Jakub on 10.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit

class Utilities{
    /**
     Show alert popup if ViewController exists
     
     - Parameter viewController: ViewController where popup will by displayed.
     - Parameter title: Title of popup.
     - Parameter text: Text in popup.
     */
    public static func showAlert(in viewController: UIViewController?, withTitle title: String, andText text: String) -> Void{
        if let vc = viewController {
            let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("WARNING_POPUPS_DISMISS_BUTTON", comment: "OK"), style: UIAlertActionStyle.destructive, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
