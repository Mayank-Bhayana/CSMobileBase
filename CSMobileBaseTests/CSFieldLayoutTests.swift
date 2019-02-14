//
//  CSFieldLayoutTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/7/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSFieldLayoutTests: XCTestCase {

    var strings: [String]!
    var names: [String]!
    var labels: [String]!
    var length: Int!
    var scale: Int!
    
    override func setUp() {
        super.setUp()
        strings = ["String1"]
        names = ["Name1"]
        labels = ["Label1"]
        length = 1
        scale = 1
    }
    
    override func tearDown() {
        strings = nil
        names = nil
        labels = nil
        length = nil
        scale = nil
        super.tearDown()
    }

    func testInitString() {
        let dictionary: [String : AnyObject] = [
            "Name" : names[0],
            "Label" : labels[0],
            "Type" : CSFieldType.String.rawValue,
            "DefaultValue" : strings[0],
            "Required" : true,
            "Createable" : true,
            "Updateable" : true,
            "Length" : length
        ]
        let fieldLayout: CSFieldLayout = CSFieldLayout(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(fieldLayout.name, names[0])
        XCTAssertEqual(fieldLayout.label, labels[0])
        XCTAssertEqual(fieldLayout.type, CSFieldType.String)
        XCTAssertEqual(fieldLayout.defaultValue, strings[0])
        XCTAssertTrue(fieldLayout.isRequired)
        XCTAssertTrue(fieldLayout.isCreateable)
        XCTAssertTrue(fieldLayout.isUpdateable)
        XCTAssertEqual(fieldLayout.length, length)
        XCTAssertNil(fieldLayout.scale)
        XCTAssertNil(fieldLayout.options)
        XCTAssertNil(fieldLayout.referenceTo)
        XCTAssertNil(fieldLayout.relationshipName)
        XCTAssertNil(fieldLayout.relationshipField)
        XCTAssertNil(fieldLayout.stateOptions)
        XCTAssertNil(fieldLayout.countryOptions)
        XCTAssertNil(fieldLayout.streetField)
        XCTAssertNil(fieldLayout.cityField)
        XCTAssertNil(fieldLayout.stateCodeField)
        XCTAssertNil(fieldLayout.postalCodeField)
        XCTAssertNil(fieldLayout.countryCodeField)
    }
    
    func testInitPickList() {
        let dictionary: [String : AnyObject] = [
            "Name" : names[0],
            "Label" : labels[0],
            "Type" : CSFieldType.PickList.rawValue,
            "DefaultValue" : strings[0],
            "Required" : true,
            "Createable" : true,
            "Updateable" : true,
            "PicklistValues" : [[:]]
        ]
        let fieldLayout: CSFieldLayout = CSFieldLayout(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(fieldLayout.name, names[0])
        XCTAssertEqual(fieldLayout.label, labels[0])
        XCTAssertEqual(fieldLayout.type, CSFieldType.PickList)
        XCTAssertEqual(fieldLayout.defaultValue, strings[0])
        XCTAssertTrue(fieldLayout.isRequired)
        XCTAssertTrue(fieldLayout.isCreateable)
        XCTAssertTrue(fieldLayout.isUpdateable)
        XCTAssertNil(fieldLayout.length)
        XCTAssertNil(fieldLayout.scale)
        XCTAssertNotNil(fieldLayout.options)
        XCTAssertNil(fieldLayout.referenceTo)
        XCTAssertNil(fieldLayout.relationshipName)
        XCTAssertNil(fieldLayout.relationshipField)
        XCTAssertNil(fieldLayout.stateOptions)
        XCTAssertNil(fieldLayout.countryOptions)
        XCTAssertNil(fieldLayout.streetField)
        XCTAssertNil(fieldLayout.cityField)
        XCTAssertNil(fieldLayout.stateCodeField)
        XCTAssertNil(fieldLayout.postalCodeField)
        XCTAssertNil(fieldLayout.countryCodeField)
    }
    
}
