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
        do {
            self.tabs = try tabHandler.getiPhoneTabs()
        } catch {
            //TODO: Change to handle errors in UX
            fatalError("Tabs fetch failed \(error)")
        }
    }
}

class iPhoneTabViewController: UIViewController {
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var WebAddressHolderLabel: UILabel!
    
    weak var homeDelegate: HomeViewDelegate?
    
    var vm = TabViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let firstTab = vm.tabs.first {
            WebAddressHolderLabel.text = firstTab.name
            self.testImageView.image = UIImage(data: firstTab.image)
        } else {
            WebAddressHolderLabel.text = "NIL"
        }
        
        
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
