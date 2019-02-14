//
//  CSObjectTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/12/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSObjectTests: XCTestCase {

    var ids: [String]!
    var labels: [String]!
    var names: [String]!
    var fields: [String]!
    
    override func setUp() {
        super.setUp()
        ids = ["012000000000000AAA"]
        labels = ["Label1","Label2","Label3"]
        names = ["Name1"]
        fields = ["Field1","Field2"]
    }
    
    override func tearDown() {
        ids = nil
        labels = nil
        names = nil
        fields = nil
        super.tearDown()
    }
    
    func testInit() {
        let dictionary: [String : AnyObject] = [
            "Label" : labels[0],
            "LabelPlural" : labels[1],
            "Accessible" : true,
            "Createable" : true,
            "Updateable" : true,
            "Deletable" : true,
            "Searchable" : true,
            "NameField" : fields[0],
            "RecordTypeInfo" : [
                ids[0] : ["Label" : labels[2]]
            ],
            "FieldInfo" : [
                ["Name" : names[0]]
            ],
            "SearchableFields" : [
                fields[1]
            ]
        ]
        let object: CSObject = CSObject(dictionary: dictionary as NSDictionary)
        XCTAssertEqual(object.label, labels[0])
        XCTAssertEqual(object.labelPlural, labels[1])
        XCTAssertTrue(object.isAccessible)
        XCTAssertTrue(object.isCreateable)
        XCTAssertTrue(object.isUpdateable)
        XCTAssertTrue(object.isDeletable)
        XCTAssertTrue(object.isSearchable)
        XCTAssertEqual(object.nameField, fields[0])
        XCTAssertEqual(object.recordTypes.first?.label, labels[2])
        XCTAssertEqual(object.fields.first?.name, names[0])
        XCTAssertEqual(object.searchFields.first, fields[1])
    }

}
