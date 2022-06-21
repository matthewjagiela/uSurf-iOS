//
//  iPadSplitViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 5/5/19.
//  Copyright © 2019 Matthew Jagiela. All rights reserved.
//

import UIKit
import WebKit

protocol SplitViewDelegate: AnyObject {
    func refresh(url: String, side: BrowserSide)
}

class iPadSplitViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var leftProgressBar: UIProgressView!
    @IBOutlet var leftAddressBar: UITextField!
    @IBOutlet var leftNavBar: UINavigationBar!
    @IBOutlet var leftGoBack: UIBarButtonItem!
    @IBOutlet var leftGoForward: UIBarButtonItem!
    @IBOutlet var leftRefresh: UIBarButtonItem!
    @IBOutlet var leftHistory: UIBarButtonItem!
    @IBOutlet var leftBookmark: UIBarButtonItem!
    @IBOutlet var leftTab: UIBarButtonItem!
    @IBOutlet var leftTabBar: UIToolbar!
    @IBOutlet var leftWebHolder: UIView!
    @IBOutlet var rightNavBar: UINavigationBar!
    @IBOutlet var rightAddressBar: UITextField!
    @IBOutlet var rightBack: UIBarButtonItem!
    @IBOutlet var rightForward: UIBarButtonItem!
    @IBOutlet var rightRefresh: UIBarButtonItem!
    @IBOutlet var rightAdd: UIBarButtonItem!
    @IBOutlet var rightTabBar: UIToolbar!
    @IBOutlet var rightHistory: UIBarButtonItem!
    @IBOutlet var rightBookmarks: UIBarButtonItem!
    @IBOutlet var rightTabs: UIBarButtonItem!
    @IBOutlet var rightWebHolder: UIView!
    @IBOutlet var singleView: UIBarButtonItem!
    @IBOutlet weak var rightProgressBar: UIProgressView!
    @IBOutlet var leftLongPress: UILongPressGestureRecognizer!
    @IBOutlet var rightLongPress: UILongPressGestureRecognizer!
    
    // Variables
    // Objects
    let web = WebHandler()
    let savedData = SavedDataHandler()
    let iCloud = iCloudHandler()
    var theme = ThemeHandler()
    // Other Variables:
    var rightWebView: WKWebView!
    var leftWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // TextField setup:
        leftAddressBar.delegate = self
        rightAddressBar.delegate = self
        // webKit setup...
        handleWebKit()
        theming()
        widenTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(rightWebRefresh), name: NSNotification.Name(rawValue: "rightWeb"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftWebRefresh), name: NSNotification.Name(rawValue: "leftWeb"), object: nil)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
           super.traitCollectionDidChange(previousTraitCollection)
           theme = ThemeHandler()
           theming()
           
       }
    @objc func rightWebRefresh() {
        loadRightURL(savedData.getRightWebPage())
    }
    @objc func leftWebRefresh() {
        loadLeftURL(savedData.getLeftWebPage())
    }
    func handleWebKit() {
        let webConfiguration = WKWebViewConfiguration() // This can work for both of them...
        
        // Lets work on making the left web view first...
        leftWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        leftWebView.uiDelegate = self
        leftWebView.navigationDelegate = self
        leftWebView.translatesAutoresizingMaskIntoConstraints = false
        leftWebHolder.addSubview(leftWebView)
        // Add a touch of auto layout...
        leftWebView.centerXAnchor.constraint(equalTo: leftWebHolder.centerXAnchor).isActive = true
        leftWebView.centerYAnchor.constraint(equalTo: leftWebHolder.centerYAnchor).isActive = true
        leftWebView.widthAnchor.constraint(equalTo: leftWebHolder.widthAnchor).isActive = true
        leftWebView.heightAnchor.constraint(equalTo: leftWebHolder.heightAnchor).isActive = true
        leftWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        leftWebView.allowsBackForwardNavigationGestures = true
        leftWebView.tag = BrowserSide.left.rawValue
        // HOLDER TO LOAD URL
        // Right Web View
        rightWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        rightWebView.uiDelegate = self
        rightWebView.navigationDelegate = self
        rightWebView.translatesAutoresizingMaskIntoConstraints = false
        rightWebHolder.addSubview(rightWebView)
        rightWebView.tag = BrowserSide.right.rawValue
        // Add a touch of autolayout
        rightWebView.centerXAnchor.constraint(equalTo: rightWebHolder.centerXAnchor).isActive = true
        rightWebView.centerYAnchor.constraint(equalTo: rightWebHolder.centerYAnchor).isActive = true
        rightWebView.widthAnchor.constraint(equalTo: rightWebHolder.widthAnchor).isActive = true
        rightWebView.heightAnchor.constraint(equalTo: rightWebHolder.heightAnchor).isActive = true
         rightWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        loadLeftURL(savedData.getLeftWebPage())
        loadRightURL(savedData.getRightWebPage())
    }
    private func loadLeftURL(_ url: String) { // Give this method a string and it is going to bring the left web view to it
        leftWebView.load(web.determineURL(userInput: url))
    }
    private func loadRightURL(_ url: String) { // Give this method a string and it is going to bring the right web view to it.
        rightWebView.load(web.determineURL(userInput: url))
    }
    
    // MARK: - Theming 
    
    func theming() { // Oh shit here we go again...
        // Left theming:
        leftNavBar.barTintColor = theme.getBarTintColor()
        leftNavBar.tintColor = theme.getTintColor()
        leftAddressBar.backgroundColor = theme.getTextBarBackgroundColor()
        leftAddressBar.textColor = theme.getTextColor()
        leftTabBar.barTintColor = theme.getBarTintColor()
        leftTabBar.tintColor = theme.getTintColor()
        // Alright now lets work on the right...
        rightNavBar.barTintColor = theme.getBarTintColor()
        rightNavBar.tintColor = theme.getTintColor()
        rightAddressBar.backgroundColor = theme.getTextBarBackgroundColor()
        rightAddressBar.textColor = theme.getTextColor()
        rightTabBar.barTintColor = theme.getBarTintColor()
        rightTabBar.tintColor = theme.getTintColor()
        view.backgroundColor = theme.getBarTintColor()
        
    }
    private func widenTextField() {
        var frame1 = leftAddressBar.frame
        var frame2 = rightAddressBar.frame
        frame1.size.width = 10000
        frame2.size.width = 10000
        leftAddressBar.frame = frame1
        rightAddressBar.frame = frame2
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            
        } else {
            
            print("Portrait")
        }
        self.widenTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        switch textField.tag {
        case 0: // Left
            loadLeftURL(textField.text ?? "https://uappsios.com")
        default:
            loadRightURL(textField.text ?? "https://uappsios.com")
        }
        return true
    }
    @IBAction func leftAddTab(_ sender: Any) {
        iCloud.addToiPadTabArray(leftWebView.url?.absoluteString ?? "https://uappsios.com")
    }
    @IBAction func rightAddTab(_ sender: Any) {
        iCloud.addToiPadTabArray(rightWebView.url?.absoluteString ?? "https://uappsios.com")
    }
    // swiftlint:disable force_unwrapping
    @IBAction func leftAddBookmark(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Bookmark", message: "", preferredStyle: .alert)
        // Add the bookmark:
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let bookmarkName = alertController.textFields![0] as UITextField
            let bookmarkAddress = alertController.textFields![1] as UITextField
            if !(bookmarkName.text?.isEmpty ?? true) && !(bookmarkAddress.text?.isEmpty ?? true) {
                // Save
                print("Saving")
                self.iCloud.addToBookmarkArray(name: bookmarkName.text!, address: bookmarkAddress.text!)
            } else {
                // Do something with the error
                print("There is something wrong so we cannot add this")
            }
        }))
        // The user does not want to add the bookmark:
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            print("User has cancelled")
        }))
        // Add textfields
        alertController.addTextField { (textField) in // This is going to be the title
            textField.text = self.leftWebView.title
            textField.textAlignment = .center
        }
        alertController.addTextField { (textField) in // This is the web address
            textField.text = self.leftWebView.url?.absoluteString
            textField.textAlignment = .center
        }
        
        self.present(alertController, animated: true) {
            print("Displayed")
        }
    }
    // swiftlint:disable force_unwrapping
    @IBAction func rightAddBookmark(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Bookmark", message: "", preferredStyle: .alert)
        // Add the bookmark:
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let bookmarkName = alertController.textFields![0] as UITextField
            let bookmarkAddress = alertController.textFields![1] as UITextField
            if !(bookmarkName.text?.isEmpty ?? true) && !(bookmarkAddress.text?.isEmpty ?? true) {
                // Save
                print("Saving")
                self.iCloud.addToBookmarkArray(name: bookmarkName.text!, address: bookmarkAddress.text!)
            } else {
                // Do something with the error
                print("There is something wrong so we cannot add this")
            }
        }))
        // The user does not want to add the bookmark:
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            print("User has cancelled")
        }))
        // Add textfields
        alertController.addTextField { (textField) in // This is going to be the title
            textField.text = self.rightWebView.title
            textField.textAlignment = .center
        }
        alertController.addTextField { (textField) in // This is the web address
            textField.text = self.rightWebView.url?.absoluteString
            textField.textAlignment = .center
        }
        
        self.present(alertController, animated: true) {
            print("Displayed")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) { // This is to update the loading bar....
        if keyPath == "estimatedProgress" && object as? NSObject == leftWebView {
           leftProgressBar.progress = Float(leftWebView.estimatedProgress)
            
        } else {
            rightProgressBar.progress = Float(rightWebView.estimatedProgress)
        }
    }
    
    // swiftlint:enable force_unwrapping
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let theme = ThemeHandler()
        return theme.getStatusBarColor()
    }
    @IBAction func leftHistory(_ sender: Any) {
        // browserTag = leftHistory.ta
    }
    @IBAction func leftBookmark(_ sender: Any) {
    }
    @IBAction func leftTab(_ sender: Any) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //TODO: Reimplement with new architecture type
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "leftHistory":
            guard let vc = segue.destination as? HistoryViewController else { fatalError("Load Failed") }
            vc.splitDelegate = self
            vc.vm = HistoryViewModel(browserSide: .left)
        case "leftTabs":
            let vc = segue.destination as? LegacyTabViewController
            vc?.browserTag = .left
        case "leftBookmarks":
            guard let vc = segue.destination as? BookmarkTableViewController else { fatalError("Load Failed") }
            vc.splitDelegate = self
            vc.vm = BookmarkViewModel(iCloudDelegate: nil, browserSide: .left)
        case "rightHistory":
            guard let vc = segue.destination as? HistoryViewController else { fatalError("Load Failed") }
            vc.splitDelegate = self
            vc.vm = HistoryViewModel(browserSide: .right)
        case "rightTabs":
            let vc = segue.destination as? LegacyTabViewController
            vc?.browserTag = .right
        case "rightBookmarks":
            guard let vc = segue.destination as? BookmarkTableViewController else { fatalError("Load Failed") }
            vc.splitDelegate = self
            vc.vm = BookmarkViewModel(iCloudDelegate: nil, browserSide: .right)
        default:
            print("DEBUG: SPLIT CONTROLLER SEGUE NOT FOUND")
        }
    }
    @objc func canRotate() {}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - WKNavigationDelegate
extension iPadSplitViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // The web view has finished loading so we want to hide
        let webURL = webView.url?.absoluteString ?? "https://uappsios.com"
        savedData.addToHistoryArray(webURL)
        if webView.tag == BrowserSide.left.rawValue { // Left web view finished
            leftProgressBar.isHidden = true
            savedData.setLeftWebPage(URL: webURL)
            leftAddressBar.text = webURL
        } else { // Right web view finished
            rightProgressBar.isHidden = true
            savedData.setRightWebPage(URL: webURL)
            rightAddressBar.text = webURL
        }
        savedData.setLastViewedPage(lastPage: webURL)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.tag == BrowserSide.left.rawValue { // left
            leftProgressBar.isHidden = false
        } else { // right
            rightProgressBar.isHidden = false
        }
    }
}

// MARK: - WKUIDelegate
extension iPadSplitViewController: WKUIDelegate {
    
}

extension iPadSplitViewController: SplitViewDelegate {
    func refresh(url: String, side: BrowserSide) {
        switch side {
        case .single:
            print("No single side")
        case .right:
            loadRightURL(url)
        case .left:
            loadLeftURL(url)
        }
    }
}
