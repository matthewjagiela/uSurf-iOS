//
//  iPadHomeViewController.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/15/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit
import WebKit

class iPadHomeViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate {
    
    // All of the outlets on the view:
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet var webKitHolderView: UIView!
    @IBOutlet var dynamicField: UITextField!
    @IBOutlet var rewindButton: UIBarButtonItem!
    @IBOutlet var fastForward: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var stopLoading: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var tabsButton: UIBarButtonItem!
    // All the variables we are going to need:
    var webView: WKWebView!
    let savedData = SavedDataHandler()
    let iCloud = iCloudHandler()
    let webHandler = WebHandler()
    var browserTag = 1
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ViewDidLoad")
        // Do any additional setup after loading the view.
        
        dynamicField.delegate = self // This allows us to use enter to search!
        theming()
        if webView == nil {
            print("ViewDidLoad NIL")
            handleWebKit()
        }
        widenTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(notificationLoad(_:)), name: NSNotification.Name(rawValue: "refreshWeb"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(theming), name: NSNotification.Name(rawValue: "themeRefresh"), object: nil)
    }
    private func widenTextField() {
        var frame = self.dynamicField.frame
        frame.size.width = 10000
        self.dynamicField.frame = frame
    }
    @objc func notificationLoad(_ : Notification) {
        loadURL(savedData.getLastViewedPage())
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            
        } else {
            
            print("Portrait")
        }
        self.widenTextField()
    }
    override func viewWillDisappear(_ animated: Bool) {
         webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       // handleWebKit()
        theming()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loadURL(textField.text ?? "https://uappsios.com") // Go to the URL / Search term
        return true
    }
    private func handleWebKit() { // WebKit was broken in earlier versions of iOS so we need to add it manually or uSurf wont make sense to have still active
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webKitHolderView.addSubview(webView)
        // Make some autolayout stuff happen
        webView.centerXAnchor.constraint(equalTo: webKitHolderView.centerXAnchor).isActive = true
        webView.centerYAnchor.constraint(equalTo: webKitHolderView.centerYAnchor).isActive = true
        webView.widthAnchor.constraint(equalTo: webKitHolderView.widthAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webKitHolderView.heightAnchor).isActive = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil) // This is going to be tracking the progress for the webkit view
        webView.allowsBackForwardNavigationGestures = true // Allow swiping back and forth for navigating page... Better than the old gesture recognizer
        loadURL(savedData.getLastViewedPage())
    }
    private func loadURL(_ url: String) { // This method takes a string of an adress and makes the web view load it!
        webView.load(webHandler.determineURL(userInput: url))
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { // There is something loading so we want to show the navigation bar
        progressBar.isHidden = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // The web view has finished loading so we want to hide
        progressBar.isHidden = true
        let webURL = webView.url?.absoluteString
        print(webURL ?? "https://uappsios.com")
        savedData.addToHistoryArray(webURL ?? "https://uappsios.com")// This is going to add the website to history (when private mode is added this will not be a thing...)
        savedData.setLastViewedPage(lastPage: webURL ?? "https://uappsios.com")
        print("HISTORY: \(savedData.getHistoryArray())")
        dynamicField.text = webURL
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) { // This is to update the loading bar....
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView.estimatedProgress)
            
        }
    }
    
    @objc func theming() {
        let theme = ThemeHandler()
        self.navigationBar.barTintColor = theme.getBarTintColor()
        self.navigationBar.tintColor = theme.getTintColor()
        self.dynamicField.backgroundColor = theme.getTextBarBackgroundColor()
        self.dynamicField.textColor = theme.getTextColor()
        self.view.backgroundColor = theme.getBarTintColor()
    }
    @IBAction func addButtonPressed(_ sender: Any) { // This is going to give the option of either adding a tab or a bookmark
        iCloud.addToiPadTabArray(self.webView.url?.absoluteString ?? "https://uappsios.com")
        iCloud.printTabArray()
        
    }
    // swiftlint:disable force_unwrapping
    @IBAction func longPress(_ sender: Any) { // A long press is going to be for adding a bookmark
        print("LongPress")
        let alertController = UIAlertController(title: "Add Bookmark", message: "", preferredStyle: .alert)
        // Add the bookmark:
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let bookmarkName = alertController.textFields![0] as UITextField
            let bookmarkAddress = alertController.textFields![1] as UITextField
            if !(bookmarkName.text?.isEmpty ?? true) && !(bookmarkAddress.text?.isEmpty ?? true) {
                // Save
                print("Saving")
                self.iCloud.addToBookmarkArray(name: bookmarkName.text!, address: bookmarkAddress.text!)
                self.iCloud.printBookmarkArray()
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
            textField.text = self.webView.title
            textField.textAlignment = .center
        }
        alertController.addTextField { (textField) in // This is the web address
            textField.text = self.webView.url?.absoluteString
            textField.textAlignment = .center
        }
        
        self.present(alertController, animated: true) {
            print("Displayed")
        }
    }
    // swiftlint:enable force_unwrapping
    @IBAction func shareWebsite(_ sender: Any) {
        let shareURL = self.webView.url?.absoluteURL // This is going to be the URL the user wants to share
        let shareString = self.webView.title // This is going to be the title the user wants to share
        let activityViewController = UIActivityViewController(activityItems: [shareURL as Any, shareString as Any], applicationActivities: nil) // Make the share sheet
        activityViewController.popoverPresentationController?.barButtonItem = shareButton // Present the popover with the source being a button
        present(activityViewController, animated: true, completion: nil)
    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goSplit" {
            savedData.setLeftWebPage(URL: savedData.getLastViewedPage())
        }
    }
    
    @IBAction func backPage(_ sender: Any) {
        self.webView.goBack()
        
    }
    @IBAction func forwardPage(_ sender: Any) {
        self.webView.goForward()
    }
    @IBAction func refreshPage(_ sender: Any) {
        self.webView.reload()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let theme = ThemeHandler()
        return theme.getStatusBarColor()
    }
    @objc func canRotate() {}

}
