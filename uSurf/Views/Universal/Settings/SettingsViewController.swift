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
    weak var homeDelegate: HomeViewDelegate?
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
            alert.addAction(UIAlertAction(title: "System", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "System")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "Dark")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
            }))
            alert.addAction(UIAlertAction(title: "Light", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "Light")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Red", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Red")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Purple", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Purple")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Green", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Green")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
        }))
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
        homeDelegate?.refreshWeb(url: "https://uappsios.com/usurf-privacy-policy/")
        self.dismiss(animated: true)
    }
    @IBAction func supportButton(_ sender: Any) {
        homeDelegate?.refreshWeb(url: "https://uappsios.com/usurf-support/")
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
    func reloadInternetLabels(information: InternetInformation) {
        if let uSurfVersion = information.uSurfVersion {
            self.newestVersion.text = "\(uSurfVersion)"
        } else {
            self.newestVersion.text = "Unable to Load"
        }
        self.newsLabel.text = information.uAppsNews
    }
}
