//
//  iCloudHandler.swift
//  uSurf
//
//  Created by Matthew Jagiela on 6/17/18.
//  Copyright © 2018 Matthew Jagiela. All rights reserved.
//

import UIKit

class iCloudHandler: NSObject {
    func getiPhoneTabArray() -> NSMutableArray { //This is going to return the newest value of the iPhone Tabs
        if(NSUbiquitousKeyValueStore.default.array(forKey: "iPhoneTabArray") == nil) {
            return NSMutableArray()
        } else {
            return NSMutableArray(array: NSUbiquitousKeyValueStore.default.array(forKey: "iPhoneTabArray")!)
        }
    }
    func getiPadTabArray() -> NSMutableArray { //This is going to return the newest value of all iPad Tabs
        if(NSUbiquitousKeyValueStore.default.array(forKey: "iPadTabArray") == nil) {
            return NSMutableArray()
        } else {
            return NSMutableArray(array: NSUbiquitousKeyValueStore.default.array(forKey: "iPadTabArray")!)
        }
    }
    func getBookmarkArray() -> NSMutableArray { //This is going to return the newest value of all stored bookmarks
        if(NSUbiquitousKeyValueStore.default.array(forKey: "bookmarkArray") == nil) {
            return NSMutableArray()
        } else {
             return NSMutableArray(array: NSUbiquitousKeyValueStore.default.array(forKey: "bookmarkArray")!)
        }
    }
    func getBookmarkNameArray() -> NSMutableArray { //This is going to retrun the newest value of the names of all bookmarks
        if(NSUbiquitousKeyValueStore.default.array(forKey: "nameArray") == nil) {
            return NSMutableArray()
        } else {
             return NSMutableArray(array: NSUbiquitousKeyValueStore.default.array(forKey: "nameArray")!)
        }
    }
    func setiPhoneTabArray(iPhoneTabArray: NSMutableArray) { //Upload the iPhone Tab Array To iCloud
        NSUbiquitousKeyValueStore.default.set(iPhoneTabArray, forKey: "iPhoneTabArray")
    }
    func setiPadTabArray(iPadTabArray: NSMutableArray) { //Upload the iPad Tab Array to iCloud
        NSUbiquitousKeyValueStore.default.set(iPadTabArray, forKey: "iPadTabArray")
    }
    func setBookmarkArray(bookmarkArray: NSMutableArray) { //Upload The Array Of Bookmarks to iCloud
        NSUbiquitousKeyValueStore.default.set(bookmarkArray, forKey: "bookMarkArray")
    }
    func setBookmarkNameArray(bookmarkNameArray: NSMutableArray) { //Upload the Array Of Bookmark Names to iCloud
        NSUbiquitousKeyValueStore.default.set(bookmarkNameArray, forKey: "nameArray")
    }
    func setBookmarkArrays(bookmarkNameArray: NSMutableArray, bookmarkArray: NSMutableArray) {
        NSUbiquitousKeyValueStore.default.set(bookmarkNameArray, forKey: "nameArray")
        NSUbiquitousKeyValueStore.default.set(bookmarkArray, forKey: "bookmarkArray")
    }
    func getObjectOfiPhoneTabArray(index: Int) -> String { //Return the object at the passed index from the iPhone Tab Array
        return getiPhoneTabArray().object(at: index) as? String ?? "https://uappsios.com"
    }
    func getObjectOfiPadTabArray(index: Int) -> String { //Return the object at the passed index from the iPad Tab Array
        return getiPadTabArray().object(at: index) as? String ?? "https://uappsios.com"
    }
    func getBookmark(index: Int) -> String { //Return the object at the passed index from the bookmark array
        return getBookmarkArray().object(at: index) as? String ?? "https://uappsios.com"
    }
    func getBookmarkName(index: Int) -> String { //Return the object at the passed index from the bookmark name array
        return getBookmarkNameArray().object(at: index) as? String ?? "New Bookmark"
    }
    func addToiPhoneTabArray(_ item: String) { //Add an item to  the iPhone Tab Array and save the changes to iCloud
        let iPhoneTabArray = getiPhoneTabArray()
        iPhoneTabArray.add(item)
        setiPhoneTabArray(iPhoneTabArray: iPhoneTabArray)
    }
    func addToiPadTabArray(_ item: String) { //Add an item to the iPad Tab Array and save the changes to iCloud
        let iPadTabArray = getiPadTabArray()
        iPadTabArray.add(item)
        setiPadTabArray(iPadTabArray: iPadTabArray)
    }
    func addToBookmarkArray(_ item: String) { //Add an item to the bookmark Array and save the changes to iCloud
        let bookmarkArray = getBookmarkArray()
        bookmarkArray.add(item)
        setBookmarkArray(bookmarkArray: bookmarkArray)
    }
    func addToBookmarkNameArray(_ item: String) { //Add an item to the bookmark Name Array and save the changes to iCloud
        let bookmarkNameArray = getBookmarkNameArray()
        bookmarkNameArray.add(item)
        setBookmarkArray(bookmarkArray: bookmarkNameArray)
    }
    func addToBookmarkArray(name: String, address: String) { //This is going to handle adding both the name and bookmark to the array...
        let bookmarkNameArray = getBookmarkNameArray()
        let bookmarkArray = getBookmarkArray()
        bookmarkNameArray.add(name)
        bookmarkArray.add(address)
        setBookmarkArrays(bookmarkNameArray: bookmarkNameArray, bookmarkArray: bookmarkArray)
        
    }
    func printTabArray() {
        let tabArray = self.getiPhoneTabArray()
        print(tabArray)
    }
    func printBookmarkArray() {
        let bookmarkArray = getBookmarkArray()
        let bookmarkNameArray = getBookmarkNameArray()
        print("BOOKMARKS: \(bookmarkArray)")
        print("BOOKMARKS NAME: \(bookmarkNameArray)")
    }

}
