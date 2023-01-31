//
//  SettingsViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 9/13/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit
import GoogleMobileAds
import uAppsLibrary
import Combine
import AppTrackingTransparency

protocol SettingsDelegate: AnyObject {
    func reloadInternetLabels(information: InternetInformation)
    func refreshTheme()
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var particleBackground: UIView!
    @IBOutlet var runningVersion: UILabel!
    @IBOutlet var newestVersion: UILabel!
    @IBOutlet var newsLabel: UILabel!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var infoBox: UITextView!
    let savedData = SavedDataHandler()
    var vm: SettingsViewModel = SettingsViewModel(settingsDelegate: nil)
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.settingsDelegate = self
        // Do any additional setup after loading the view.
        // AD Setup:
        adBanner.adUnitID = "ca-app-pub-7714978111013265/7436233905"
        adBanner.rootViewController = self
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
                DispatchQueue.main.async {
                    self?.adBanner.load(GADRequest())
                }
            }
        } else {
            self.adBanner.load(GADRequest())
        }
        // Labels:
        runningVersion.text = vm.getCurrentVersion()
        infoBox.text = vm.getChanges()
        infoBox.contentOffset = .zero
        // Do some theme stuff
        theming()
        snowFall()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        vm.theme.regenTheme()
        self.refreshTheme()
    }
    
    func snowFall() {
        let snow = SnowHandler()
        if snow.shouldShowSnow() {
            snow.generateSnowScene(snowView: particleBackground, size: view.bounds.size)
        } else {
            particleBackground.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.removeFromParent()
        if UI_USER_INTERFACE_IDIOM() == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            infoBox.contentOffset = .zero
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    @IBAction func ShareApp(_ sender: Any) {
        guard let shareURL = vm.getShareURL() else { return }
        let activityViewController = UIActivityViewController(activityItems: [vm.getShareString(), shareURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - Theme
    @IBAction func SelectTheme(_ sender: Any) {
        let alert = UIAlertController(title: "Theme", message: "Choose A Theme", preferredStyle: .actionSheet) // make an action sheet for it
        
        if #available(iOS 13, *) {
            alert.addAction(UIAlertAction(title: Theme.System.rawValue, style: .default, handler: { [weak self] _ in
                self?.vm.setTheme(theme: Theme.System)
            }))
        } else {
            alert.addAction(UIAlertAction(title: Theme.Dark.rawValue, style: .default, handler: { [weak self] _ in
                self?.vm.setTheme(theme: Theme.Dark)
            }))
            
            alert.addAction(UIAlertAction(title: Theme.Light.rawValue, style: .default, handler: { [weak self] _ in
                self?.vm.setTheme(theme: Theme.Light)
            }))
        }
        
        for theme in vm.selectableThemes() {
            alert.addAction(UIAlertAction(title: theme.rawValue, style: .default, handler: { [weak self] _ in
                self?.vm.setTheme(theme: theme)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController { // For iPad it needs to present as a popover so we need to make one!!
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }
        self.present(alert, animated: true, completion: nil) // Present the actual alert
    }
    func theming() {
        self.navBar.barTintColor = vm.theme.getBarTintColor()
        self.navBar.tintColor = vm.theme.getTintColor()
        let textAttributes = [NSAttributedString.Key.foregroundColor: vm.theme.getTintColor()]
        navBar.titleTextAttributes = textAttributes // Make the title the same color as the buttons
        self.view.backgroundColor = vm.theme.getBarTintColor()
    }
    
    // MARK: - ACTIONS
    
    @IBAction func ViewPrivacyPolicy(_ sender: Any) {
        vm.homeViewDelegate?.refreshWeb(url: "https://uappsios.com/usurf-privacy-policy")
        self.dismiss(animated: true)
    }
    @IBAction func supportButton(_ sender: Any) {
        vm.homeViewDelegate?.refreshWeb(url: "https://uappsios.com/usurf-support")
        self.dismiss(animated: true)
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return vm.theme.getStatusBarColor()
    }
    
    override var shouldAutorotate: Bool {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return true
        } else {
            return true
        }
    }

}

extension SettingsViewController: SettingsDelegate {
    func refreshTheme() {
        self.theming()
    }
    
    func reloadInternetLabels(information: InternetInformation) {
        if let uSurfVersion = information.uSurfVersion {
            self.newestVersion.text = "\(uSurfVersion)"
        } else {
            self.newestVersion.text = "Unable to Load"
        }
        self.newsLabel.text = information.uAppsNews
    }
}
