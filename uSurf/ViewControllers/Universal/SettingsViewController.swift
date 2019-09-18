//
//  SettingsViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 9/13/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsViewController: UIViewController {
    @IBOutlet var runningVersion: UILabel!
    @IBOutlet var newestVersion: UILabel!
    @IBOutlet var newsLabel: UILabel!
    @IBOutlet var adBanner: GADBannerView!
    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var infoBox: UITextView!
    let savedData = SavedDataHandler()
    let appInfo = VersionHandler()
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //AD Setup:
        adBanner.adUnitID = "ca-app-pub-7714978111013265/7436233905"
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
        //Labels:
        internetLabels()
        runningVersion.text = appInfo.getAppVersion()
        infoBox.text = appInfo.getUpdateInformation()
        infoBox.contentOffset = .zero
        //Do some theme stuff
        theming()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.removeFromParent()
        if UI_USER_INTERFACE_IDIOM() == .phone {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
    }
    func internetLabels() {  //This is going to go to my github and parse the data on the versions
        if let url = URL(string: "https://matthewjagiela.github.io/uApps-HTML/") {
            do {
                let contents = try String(contentsOf: url)
                let newLineSet = NSCharacterSet.newlines
                let lines = contents.components(separatedBy: newLineSet)
                newestVersion.text = lines[1] //This is the uSurf new version holder
                newsLabel.text = lines[4]
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
    }
    //swiftlint:disable force_unwrapping
    @IBAction func ShareApp(_ sender: Any) {
        let shareURL = URL(string: "https://itunes.apple.com/us/app/utime-universal/id1125889944?ls=1&mt=8")
        let shareString = "I am using uSurf as my new iOS Web Browser! Check it out!"
        let activityViewController = UIActivityViewController(activityItems: [shareString, shareURL!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        present(activityViewController, animated: true, completion: nil)
    }
    //swiftlint:enable force_unwrapping
    // MARK: - Theme
    @IBAction func SelectTheme(_ sender: Any) {
        let alert = UIAlertController(title: "Theme", message: "Choose A Theme", preferredStyle: .actionSheet) //make an action sheet for it
        if #available(iOS 13, *) {
            alert.addAction(UIAlertAction(title: "System", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "System")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Dark", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "Dark")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
            }))
            alert.addAction(UIAlertAction(title: "Light", style: .default, handler: { (_) in
                self.savedData.setTheme(theme: "Light")
                self.theming()
                self.setNeedsStatusBarAppearanceUpdate()
            }))
        }
        alert.addAction(UIAlertAction(title: "Red", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Red")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        alert.addAction(UIAlertAction(title: "Purple", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Purple")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        alert.addAction(UIAlertAction(title: "Green", style: .default, handler: { (_) in
            self.savedData.setTheme(theme: "Green")
            self.theming()
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        if let popoverController = alert.popoverPresentationController { //For iPad it needs to present as a popover so we need to make one!!
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }
        self.present(alert, animated: true, completion: nil) //Present the actual alert
    }
    func theming() {
        let theme = ThemeHandler()
        self.navBar.barTintColor = theme.getBarTintColor()
        self.navBar.tintColor = theme.getTintColor()
        let textAttributes = [NSAttributedString.Key.foregroundColor: theme.getTintColor()]
        navBar.titleTextAttributes = textAttributes //Make the title the same color as the buttons
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
            return false
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
