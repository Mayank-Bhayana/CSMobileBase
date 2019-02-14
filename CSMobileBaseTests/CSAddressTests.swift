//
//  CSAddressTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/22/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSAddressTests: XCTestCase {

    var street: String!
    var city: String!
    var stateCode: String!
    var postalCode: String!
    var countryCode: String!
    
    override func setUp() {
        super.setUp()
        street = "Street"
        city = "City"
        stateCode = "StateCode"
        postalCode = "PostalCode"
        countryCode = "CountryCode"
    }
    
    override func tearDown() {
        street = nil
        city = nil
        stateCode = nil
        postalCode = nil
        countryCode = nil
        super.tearDown()
    }
    
    func testInit() {
        let dictionary: [String : AnyObject] = [
            "street" : street as AnyObject,
            "city" : city as AnyObject,
            "stateCode" : stateCode as AnyObject,
            "postalCode" : postalCode as AnyObject,
            "countryCode" : countryCode as AnyObject
        ]
        let address: CSAddress = CSAddress(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(address.street, street)
        XCTAssertEqual(address.city, city)
        XCTAssertEqual(address.stateCode, stateCode)
        XCTAssertEqual(address.postalCode, postalCode)
        XCTAssertEqual(address.countryCode, countryCode)

    }

}
