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

class SettingsViewController: UIViewController {
    @IBOutlet weak var particleBackground: UIView!
    @IBOutlet var runningVersion: UILabel!
    @IBOutlet var newestVersion: UILabel!
    @IBOutlet var newsLabel: UILabel!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var infoBox: UITextView!
    let savedData = SavedDataHandler()
    @available(iOS 13.0, *)
    lazy var subscriptions: Set<AnyCancellable> = []
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // AD Setup:
        adBanner.adUnitID = "ca-app-pub-7714978111013265/7436233905"
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
        // Labels:
        internetLabels()
        let info = AppInformation()
        runningVersion.text = info.getAppVersion()
        infoBox.text = info.getChanges()
        infoBox.contentOffset = .zero
        // Do some theme stuff
        theming()
        snowFall()
    }
    
    func snowFall() {
        let snow = SnowHandler()
        if snow.shouldShowSnow() {
//            snow.setupSnowScene(view: particleBackground, size: view.bounds.size)
            snow.generateSnowScene(snowView: particleBackground, size: view.bounds.size)
        } else {
            particleBackground.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.removeFromParent()
        if UI_USER_INTERFACE_IDIOM() == .phone {
            print("Force rotation")
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            infoBox.contentOffset = .zero
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
    }
    // MARK: - Internet Labels
    func internetLabels() {
        let labels = InternetLabelsManager()
        if #available(iOS 13.0, *) {
            labels.fetchLabels().receive(on: RunLoop.main).sink { completion in
                switch completion {
                case .failure(let error):
                    self.newestVersion.text = "Could Not Fetch"
                    self.newsLabel.text = "Could Not Fetch"
                    print("ERROR FETCHING \(error) + \(error.localizedDescription)")
                case .finished: print("Labels Finished Fetching")
                }
            } receiveValue: { [weak self] info in
                self?.newestVersion.text = "Newest Version: \(info.uSurfVersion ?? "")"
                self?.newsLabel.text = info.uAppsNews
            }.store(in: &subscriptions)
        } else {
            labels.legacyFetchLabels { (InternetInformation) in
                self.newestVersion.text = "Newest Version: \(InternetInformation.uSurfVersion ?? "")"
                self.newsLabel.text = InternetInformation.uAppsNews
            }
        }
    }
    // swiftlint:disable force_unwrapping
    @IBAction func ShareApp(_ sender: Any) {
        let shareURL = URL(string: "https://itunes.apple.com/us/app/utime-universal/id1125889944?ls=1&mt=8")
        let shareString = "I am using uSurf as my new iOS Web Browser! Check it out!"
        let activityViewController = UIActivityViewController(activityItems: [shareString, shareURL!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        present(activityViewController, animated: true, completion: nil)
    }
    // swiftlint:enable force_unwrapping
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
        let theme = ThemeHandler()
        self.navBar.barTintColor = theme.getBarTintColor()
        self.navBar.tintColor = theme.getTintColor()
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()]
        navBar.titleTextAttributes = textAttributes // Make the title the same color as the buttons
        self.view.backgroundColor = theme.getBarTintColor()
    }
    // MARK: ACTIONS
    @IBAction func ViewPrivacyPolicy(_ sender: Any) {
        savedData.setLastViewedPage(lastPage: "https://uappsios.com/usurf-privacy")
        self.performSegue(withIdentifier: "goHome", sender: self)
    }
    @IBAction func supportButton(_ sender: Any) {
        savedData.setLastViewedPage(lastPage: "https://uappsios.com/usurf-support")
        if #available(iOS 13, *) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }
    @IBAction func goHome(_ sender: Any) {
        if #available(iOS 13, *) {
            self.dismiss(animated: true) {
                print("Settings Dismissed")
            }
        } else {
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let theme = ThemeHandler()
        return theme.getStatusBarColor()
    }
    
    override var shouldAutorotate: Bool {
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return true
        } else {
            return true
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
