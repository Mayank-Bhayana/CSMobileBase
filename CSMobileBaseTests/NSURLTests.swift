//
//  NSURLTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/15/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class NSURLTests: XCTestCase {

    var phone: String!
    var email: String!
    
    override func setUp() {
        super.setUp()
        phone = "123-456-7890"
        email = "someone@somewhere.com"
    }
    
    override func tearDown() {
        phone = nil
        email = nil
        super.tearDown()
    }

    func testInitForCall() {
        let url: NSURL? = NSURL(forCall: phone)
        XCTAssertNotNil(url)
    }
    
    func testInitForCallInvalid() {
        let url: NSURL? = NSURL(forCall: "")
        XCTAssertNil(url)
    }

    func testInitForMessage() {
        let url: NSURL? = NSURL(forMessage: phone)
        XCTAssertNotNil(url)
    }
    
    func testNilInitForMessageInvalid() {
        let url: NSURL? = NSURL(forMessage: "")
        XCTAssertNil(url)
    }
    
    func testInitForEmail() {
        let url: NSURL? = NSURL(forEmail: email)
        XCTAssertNotNil(url)
    }
    
    func testInitForEmailInvalid() {
        let url: NSURL? = NSURL(forEmail: "")
        XCTAssertNil(url)
    }

}
