//
//  iPhoneTabViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 8/7/22.
//  Copyright © 2022 Matthew Jagiela. All rights reserved.
//

import UIKit
import Toast

enum TabState: String {
    case neutral = "Edit"
    case editing = "Done"
    case delete = "Delete"
}

protocol TabTableDelegate: AnyObject {
    func changeState(state: TabState)
    func showError(error: String?)
}

class TabViewCell: UITableViewCell {
    @IBOutlet weak var WebPreviewImage: UIImageView!
    @IBOutlet weak var WebNameLabel: UILabel!
    @IBOutlet weak var WebAddressLabel: UILabel!
    
}
class TabViewController: UIViewController, TabTableDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var stateButton: UIBarButtonItem!
    @IBOutlet weak var NavBar: UINavigationBar!
     
    weak var homeDelegate: HomeViewDelegate?
    weak var splitDelegate: SplitViewDelegate?
    
    var vm = TabViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.vm.tableViewDelegate = self
        self.vm.tabTableDelegate = self
        self.tableView.backgroundColor = UIColor.systemGray4
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
    
    func showError(error: String?) {
        var message = "An Error Has Occured"
        if let error {
            message = error
        }
        let toast = Toast.default(image: UIImage(), title: message)
        DispatchQueue.main.async {
            toast.show(haptic: .error)
        }
    }
    
}

extension TabViewController: uAppsTableDelegate {
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

extension TabViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do the loading of the tab and such here.
        
        if vm.tableState == .editing || vm.tableState == .delete {
            let cell = tableView.cellForRow(at: indexPath)
            // Add to array if not already present
            let exists = vm.tabSelected(at: indexPath)
            cell?.backgroundColor = exists ? UIColor.white: UIColor.systemRed
        } else {
            if let homeDelegate = self.homeDelegate {
                homeDelegate.refreshWeb(url: vm.tabs[indexPath.row].url)
            }
            
            if let splitDelegate = splitDelegate {
                splitDelegate.refresh(url: vm.tabs[indexPath.row].url, side: vm.browserSide)
            }
            
            if let iPhoneController = sideMenuController {
                iPhoneController.hideMenu()
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { _ in
                self.vm.deleteTab(at: indexPath)
            }
            return UIMenu(children: [deleteAction])
        }
    }
    
}

extension TabViewController: UITableViewDataSource {
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
