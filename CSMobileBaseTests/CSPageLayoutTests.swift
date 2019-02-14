//
//  CSPageLayoutTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/11/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSPageLayoutTests: XCTestCase {

    var ids: [String]!
    var names: [String]!
    
    override func setUp() {
        super.setUp()
        ids = ["012000000000000AAA"]
        names = ["Name1","Name2"]
    }
    
    override func tearDown() {
        ids = nil
        names = nil
        super.tearDown()
    }

    func testInit() {
        let dictionary: [String : AnyObject] = [
            "RecordTypeId" : ids[0],
            "RecordTypeName" : names[0],
            "FieldLayouts" : [
                ["Name" : names[1]]
            ]
        ]
        let pageLayout: CSPageLayout = CSPageLayout(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(pageLayout.recordTypeId, ids[0])
        XCTAssertEqual(pageLayout.recordTypeName, names[0])
        XCTAssertEqual(pageLayout.fieldLayouts.first?.name, names[1])
    }
    
}
