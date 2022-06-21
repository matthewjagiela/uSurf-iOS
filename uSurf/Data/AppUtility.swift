//
//  AppUtility.swift
//  uSurf
//
//  Created by Matthew Jagiela on 9/15/19.
//  Copyright © 2019 Matthew Jagiela. All rights reserved.
//

import UIKit

class AppUtility: NSObject {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}
