//
//  iPhoneTabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/7/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit

enum TabState: String {
    case neutral = "Edit"
    case editing = "Done"
    case delete = "Delete"
}

protocol TabTableDelegate: AnyObject {
    func changeState(state: TabState)
}

class TabViewCell: UITableViewCell {
    @IBOutlet weak var WebPreviewImage: UIImageView!
    @IBOutlet weak var WebNameLabel: UILabel!
    @IBOutlet weak var WebAddressLabel: UILabel!
    
}

class TabViewModel {
    let tabHandler = TabHandler()
    var tabs: [TabData] = []
    var tableState: TabState = .neutral
    
    lazy var selectedTabs = [TabData]()
    lazy var selectedIP = [IndexPath]()
    
    weak var tableViewDelegate: uAppsTableDelegate?
    weak var tabTableDelegate: TabTableDelegate?
    
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
    
    func tabSelected(at indexPath: IndexPath) -> Bool {
        var tabExists = false
        var index = indexPath.row
        let tabData = tabs[index]
        let foundTab = selectedTabs.filter { TabData in
            TabData.identifier == tabData.identifier
        }
        
        if foundTab.isEmpty {
            //does not exist
            selectedTabs.append(tabData)
            selectedIP.append(indexPath)
        } else {
            //does exist
            selectedTabs.removeAll { TabData in
                TabData.identifier == tabData.identifier
            }
            selectedIP.removeAll { arrayPath in
                arrayPath == indexPath
            }
            tabExists = true
        }
        
        
        tableState = selectedTabs.isEmpty ? .editing: .delete
        tabTableDelegate?.changeState(state: tableState)
        return tabExists
    }
    
    
    func deleteTabs() {
        tabHandler.deleteLocalTabs(tabs: selectedTabs) { [weak self] error in
            guard let self = self else { fatalError("Somehow self is nil...") }
            if let error {
                fatalError("Error with core data deletion \(error)")
            }
            
            self.tableViewDelegate?.removeRows(at: self.selectedIP)
            self.refresh()
        }
    }
    
    @objc private func iCloudUpdate(notification: NSNotification) {
        self.refresh()
    }
}

class iPhoneTabViewController: UIViewController, TabTableDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var stateButton: UIBarButtonItem!
    @IBOutlet weak var NavBar: UINavigationBar!
    
    weak var homeDelegate: HomeViewDelegate?
    
    var vm = TabViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.vm.tableViewDelegate = self
        self.vm.tabTableDelegate = self
    }
    
    
    @IBAction func stateButtonTapped(_ sender: Any) {
        switch vm.tableState {
        case .neutral:
            vm.tableState = .editing
        case .editing:
            vm.tableState = .neutral
            self.tableView.reloadData()
        case .delete:
            vm.tableState = .editing
            vm.deleteTabs()
        }
        stateButton.title = vm.tableState.rawValue
    }
    
    func changeState(state: TabState) {
        self.stateButton.title = state.rawValue
    }
}


extension iPhoneTabViewController: uAppsTableDelegate {
    func removeRows(at indexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: indexPath, with: .fade)
        }
    }
    
    func updateTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension iPhoneTabViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Do the loading of the tab and such here.
        
        if vm.tableState == .editing || vm.tableState == .delete {
            let cell = tableView.cellForRow(at: indexPath)
            //Add to array if not already present
            let exists = vm.tabSelected(at: indexPath)
            cell?.backgroundColor = exists ? UIColor.white: UIColor.systemRed
        } else {
            if let homeDelegate = self.homeDelegate, let iPhoneController = sideMenuController {
                homeDelegate.refreshWeb(url: vm.tabs[indexPath.row].url)
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
        if #available(iOS 13.0, *) {
            cell.backgroundColor = UIColor.systemBackground
        } else {
            cell.backgroundColor = UIColor.white
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
