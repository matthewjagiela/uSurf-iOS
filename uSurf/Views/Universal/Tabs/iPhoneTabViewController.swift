//
//  iPhoneTabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/7/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit

class TabViewCell: UITableViewCell {
    @IBOutlet weak var WebPreviewImage: UIImageView!
    @IBOutlet weak var WebNameLabel: UILabel!
    @IBOutlet weak var WebAddressLabel: UILabel!
    
}

class TabViewModel {
    let tabHandler = TabHandler()
    var tabs: [TabData] = []
    weak var tableViewDelegate: uAppsTableDelegate?
    init() {
        self.refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudUpdate(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    func refresh() {
        do {
            self.tabs = tabHandler.getLocalTabs()
            self.tableViewDelegate?.updateTable()
        }
        
    }
    
    @objc private func iCloudUpdate(notification: NSNotification) {
        self.refresh()
    }
}

class iPhoneTabViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holderView: UIView!
    
    weak var homeDelegate: HomeViewDelegate?
    
    var vm = TabViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.vm.tableViewDelegate = self
    }
}


extension iPhoneTabViewController: uAppsTableDelegate {
    func updateTable() {
        self.vm.refresh()
    }
}

extension iPhoneTabViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Do the loading of the tab and such here.
        if let homeDelegate = self.homeDelegate {
            homeDelegate.refreshWeb(url: vm.tabs[indexPath.row].url)
            
            if let iPhoneController = sideMenuController {
                iPhoneController.hideMenu()
            }
        }
    }
    
}

extension iPhoneTabViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.tabs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "iPhoneTabCell", for: indexPath) as? TabViewCell else {
            return UITableViewCell()
        }
        let tab = vm.tabs[indexPath.row]
        cell.WebAddressLabel.text = tab.url
        cell.WebNameLabel.text = tab.name
        cell.WebPreviewImage.image = UIImage(data: tab.image ?? Data())
        
        return cell
    }
    
    
}
