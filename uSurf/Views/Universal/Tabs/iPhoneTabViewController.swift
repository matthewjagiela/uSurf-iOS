//
//  iPhoneTabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/7/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit


class TabViewModel {
    let tabHandler = TabHandler()
    var tabs: [Tab] = []
    init() {
        self.tabs = tabHandler.iPhoneTabs
    }
}

class iPhoneTabViewController: UIViewController {
    @IBOutlet weak var TestImageView: UIView!
    @IBOutlet weak var WebAddressHolderImage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
