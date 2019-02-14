//
//  NSURL.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/11/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation

public extension URL {
    
    public init?(forCall: String) {
        let characterSet: CharacterSet = CharacterSet.decimalDigits.inverted
        let forCall: String = forCall.components(separatedBy: characterSet).joined(separator: "")
        if forCall.characters.count > 0 {
            self = NSURL(string: "tel:\(forCall)") as! URL
        }
        else {
            return nil
        }
    }
    
    public init?(forMessage: String) {
        let characterSet: CharacterSet = CharacterSet.decimalDigits.inverted
        let forMessage: String = forMessage.components(separatedBy: characterSet).joined(separator: "")
        if forMessage.characters.count > 0 {
            self = NSURL(string: "sms:\(forMessage)") as! URL
        }
        else {
            return nil
        }
    }
    
    public init?(forEmail: String) {
        if forEmail.characters.count > 0 {
            self = NSURL(string: "mailto:\(forEmail)") as! URL
        }
        else {
            return nil
        }
    }
    
}
