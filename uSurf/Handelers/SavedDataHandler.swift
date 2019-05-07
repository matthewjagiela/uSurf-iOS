//
//  SavedDataHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/17/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class SavedDataHandler: NSObject {
    var savedData = UserDefaults()
    
    override init() { //Whenever the class is initially called we are going to set the group so we can get data
        savedData = UserDefaults.init(suiteName: "group.com.uapps.usurf")!
    }
    func getHistoryArray() -> NSMutableArray{ //If we need the history array in a different class for whatever reason this is the method to get it
        if(savedData.array(forKey: "historyArray") == nil){
            return NSMutableArray()
        }
        else{
            return NSMutableArray(array: savedData.array(forKey: "historyArray")!)
        }
       
    }
    func addToHistoryArray(_ item:String){ //When a new website is loaded this method will be called to add the website to history
        let historyArray = getHistoryArray()
        print("History item adding: \(item)")
        if(!historyArray.contains(item)){ //The item has not been navigated to before SOOO let us just insert it at the top
            historyArray.insert(item, at: 0)
            
        }
        else{
            historyArray.removeObject(at: historyArray.index(of: item))
            historyArray.insert(item, at: 0)
        }
        saveHistoryArray(historyArray: historyArray)
        //printHistory() //Used to test ordering and if the actual checks work for the history array
    }
    func saveHistoryArray(historyArray:NSMutableArray){ //This will save a copy of the users history to the device.
       
        savedData.set(historyArray, forKey: "historyArray")
        
    }
    func getTheme()->String{
        if(savedData.string(forKey: "iPhoneTheme") == nil){
            return "Dark"
        }
        else{
            return savedData.string(forKey: "iPhoneTheme")! //This is still iPhone theme just to keep in tact with older versions
        }
    }
    func setTheme(theme:String) { //Save the theme for the device. This will be for both iPhone and iPad but is called iPhone theme to correlate with already existing data
        savedData.set(theme, forKey: "iPhoneTheme")
    }
    func setLastViewedPage(lastPage:String){
        savedData.set(lastPage, forKey: "lastPage")
    }
    func getLastViewedPages()->String{
        if let lastPage = savedData.string(forKey: "lastPage"){
            print("Last Page = \(lastPage)")
            return lastPage
        }
        else{
            return "https://uappsios.com"
        }
    }
    func setRightWebPage(URL: String){
        savedData.set(URL, forKey: "rightPage")
    }
    func setLeftWebPage(URL: String){
        savedData.set(URL, forKey: "leftPage")
    }
    func getRightWebPage()->String{
        return savedData.string(forKey: "rightPage") ?? "https://uappsios.com"
    }
    func getLeftWebPage()-> String{
        return savedData.string(forKey: "leftPage") ?? "https://uappsios.com"
    }
    private func printHistory(){
        print("Saved data handler: History Array \(getHistoryArray())")
        print("Get history array count: \(getHistoryArray().count)")
        let historyArray = getHistoryArray()
        print("A different approach history: \(historyArray)")
        print("History item 0: \(historyArray.object(at: 0) as! String)")
    }
    


}
