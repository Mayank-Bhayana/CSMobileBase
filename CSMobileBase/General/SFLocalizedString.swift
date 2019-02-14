//
//  SFLocalizedString.swift
//  CPG-FieldSales
//
//  Created by David Vieser on 12/15/18.
//  Copyright © 2018 FieldSalesOrginization. All rights reserved.
//

import Foundation
import SwiftyJSON

public let SFLocalizedString = LocalizedString.sharedInstance.getString
public let SFDynamicLocalizedString = LocalizedString.sharedInstance.getString

class LocalizedString : NSObject {
    static let sharedInstance = LocalizedString()
    private let notificationCenter: NotificationCenter = NotificationCenter.default

    private lazy var stringsDictionary:Dictionary<String, JSON> = CSSettingsStore.instance.read().localizedStrings.dictionaryValue
    
    private override init () {
        super.init()
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
        notificationCenter.addObserver(self, selector: settingsDidChange, name: NSNotification.Name(rawValue: CSSettingsChangedNotification), object: nil)
    }
    
    private let settingsDidChange: Selector = #selector(settingsDidChange(notification:))

    func settingsDidChange(notification: NSNotification) {
        self.stringsDictionary = CSSettingsStore.instance.read().localizedStrings.dictionaryValue
    }
    

    func getString(_ key: String, comment: String = "") -> String {
        if let keyValue = self.stringsDictionary[key.platformCaseStringValue] {
            return keyValue.stringValue
        }
        return key
    }
}
