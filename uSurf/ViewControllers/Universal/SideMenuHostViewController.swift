//
//  SideMenuHostViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 12/13/21.
//  Copyright © 2021 Matthew Jagiela. All rights reserved.
//

import UIKit

enum ClassType {
    case bookmark
    case history
    case tabs
}

class SideMenuHostViewController: UIViewController {

    @IBOutlet weak var HostingView: UIView!
    var type: ClassType = .bookmark
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
