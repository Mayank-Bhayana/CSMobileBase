//
//  CSRecordTypeTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/7/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSRecordTypeTests: XCTestCase {
    
    var ids: [String]!
    var labels: [String]!

    override func setUp() {
        super.setUp()
        ids = ["012000000000000AAA"]
        labels = ["Label1"]
    }
    
    override func tearDown() {
        ids = nil
        labels = nil
        super.tearDown()
    }

    func testInit() {
        let dictionary: [String : AnyObject] = [
            "Id" : ids[0],
            "Label" : labels[0],
            "IsAvailable" : true
        ]
        let recordType: CSRecordType = CSRecordType(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(recordType.id, ids[0])
        XCTAssertEqual(recordType.label, labels[0])
        XCTAssertTrue(recordType.isAvailable)
    }

}
