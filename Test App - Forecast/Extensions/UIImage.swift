//
//  UIImageExtension.swift
//  Test App - Forecast
//
//  Created by Jakub on 06.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Scale UIImage to new width
     - Parameter newWidth: new width value
     - Returns: Image in new width
     */
    func scaleImage(toWidth newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
