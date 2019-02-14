//
//  CSFieldSetTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSFieldSetTests: XCTestCase {

    var field: String!
    var relation: String!
    
    override func setUp() {
        super.setUp()
        field = "Field"
        relation = "Relation"
    }
    
    override func tearDown() {
        field = nil
        relation = nil
        super.tearDown()
    }
    
    func testDescription() {
        let fieldSet: CSFieldSet = CSFieldSet.forRead().withField(field)
        XCTAssertEqual(fieldSet.description, field)
    }
    
    func testWithField() {
        let fieldSet: CSFieldSet = CSFieldSet.forRead().withField(field)
        XCTAssertEqual(fieldSet.array, [field])
    }
    
    func testWithRelationField() {
        let fieldSet: CSFieldSet = CSFieldSet.forRead().withRelationField(relation, name: field)
        XCTAssertEqual(fieldSet.array, ["\(relation).\(field)"])
    }
    
    func testExcludeField() {
        let fieldSet: CSFieldSet = CSFieldSet.forRead().withField(field).excludeField(field)
        XCTAssertTrue(fieldSet.array.isEmpty)
    }
    
}
