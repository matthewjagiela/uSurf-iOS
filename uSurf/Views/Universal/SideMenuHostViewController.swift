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
    var type: ClassType?
    weak var homeDelegate: HomeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for view in HostingView.subviews {
            view.removeFromSuperview()
        }
        
        switch type {
        case .bookmark:
            self.generateBookmarkView()
        case .history:
            self.generateHistoryView()
        case .tabs:
            self.generateTabView()
        case .none:
            self.generateHistoryView()
        }

    }
    
    func generateBookmarkView() {
        let storyboard = UIStoryboard(name: "iPhoneStory", bundle: nil)
        guard let embededController = storyboard.instantiateViewController(withIdentifier: "BookmarkView") as? BookmarkTableViewController else { return }
        embededController.homeDelegate = homeDelegate
        embededController.view.frame = HostingView.frame
        addChild(embededController)
        HostingView.addSubview(embededController.view)
        embededController.didMove(toParent: self)
    }
    
    func generateHistoryView() {
        let storyboard = UIStoryboard(name: "iPhoneStory", bundle: nil)
        guard let embededController = storyboard.instantiateViewController(withIdentifier: "HistoryView") as? HistoryViewController else { return }
        embededController.homeDelegate = homeDelegate
        embededController.view.frame = HostingView.frame
        addChild(embededController)
        HostingView.addSubview(embededController.view)
        embededController.didMove(toParent: self)
    }
    
    func generateTabView() {
        let storyboard = UIStoryboard(name: "iPhoneStory", bundle: nil)
        guard let embeddedController = storyboard.instantiateViewController(withIdentifier: "iPhoneTab") as? TabViewController else { return }
        embeddedController.homeDelegate = self.homeDelegate
        embeddedController.view.frame = HostingView.frame
        addChild(embeddedController)
        HostingView.addSubview(embeddedController.view)
        embeddedController.didMove(toParent: self)
    }

}
