//
//  CSRecordTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/27/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSRecordTests: XCTestCase {

    var ids: [String]!
    var externalIds: [String]!
    var names: [String]!
    var strings: [String]!
    var integer: Int!
    var double: Double!
    var date: NSDate!
    var address: CSAddress!
    var reference: CSRecord!
    
    override func setUp() {
        super.setUp()
        ids = ["012000000000000AAA","012000000000000BBB"]
        externalIds = [NSUUID().uuidString,NSUUID().uuidString]
        names = ["Name1","Name2","Name3","Name4","Name5","Name6"]
        strings = ["Value1","Value2","Value3","Value4","Value5"]
        integer = 1
        double = 0.1
        address = CSAddress(dictionary: [
            "street" : strings[0],
            "city" : strings[1],
            "stateCode" : strings[2],
            "postalCode" : strings[3],
            "countryCode" : strings[4]
        ])
        reference = CSRecord(dictionary: [
            "Id" : strings[0],
        ])
    }
    
    override func tearDown() {
        ids = nil
        externalIds = nil
        names = nil
        strings = nil
        integer = nil
        double = nil
        date = nil
        address = nil
        reference = nil
        super.tearDown()
    }
    
    func testString() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setString(names[0], value: strings[0])
        XCTAssertEqual(record.getString(names[0]), strings[0])
    }
    
    func testNilString() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setString(names[0], value: strings[0])
        record.setString(names[0], value: nil)
        XCTAssertNil(record.getString(names[0]))
    }
    
    func testSetInteger() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setInteger(names[0], value: integer)
        XCTAssertEqual(record.getInteger(names[0]), integer)
    }
    
    func testNilInteger() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setInteger(names[0], value: integer)
        record.setInteger(names[0], value: nil)
        XCTAssertNil(record.getInteger(names[0]))
    }
    
    func testDouble() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setDouble(names[0], value: double)
        XCTAssertEqual(record.getDouble(names[0]), double)
    }
    
    func testNilDouble() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setDouble(names[0], value: double)
        record.setDouble(names[0], value: nil)
        XCTAssertNil(record.getDouble(names[0]))
    }
    
    func testBoolean() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setBoolean(names[0], value: true)
        XCTAssertTrue(record.getBoolean(names[0]))
    }
    
    func testNilBoolean() {
        let record: CSRecord = CSRecord(objectType: "Object")
        XCTAssertFalse(record.getBoolean(names[0]))
    }
    
    func testDateTime() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setDateTime(names[0], value: date as Date?)
        XCTAssertEqual(record.getDateTime(names[0]), date)
    }
    
    func testNilDateTime() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setDateTime(names[0], value: date as Date?)
        XCTAssertNil(record.getDateTime(names[0]))
    }
    
    func testAddress() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setAddress(names[0], value: address, streetField: names[1], cityField: names[2], stateCodeField: names[3], postalCodeField: names[4], countryCodeField: names[5])
        XCTAssertNotNil(record.getAddress(names[0]))
        XCTAssertEqual(record.getString(names[1]), address.street)
        XCTAssertEqual(record.getString(names[2]), address.city)
        XCTAssertEqual(record.getString(names[3]), address.stateCode)
        XCTAssertEqual(record.getString(names[4]), address.postalCode)
        XCTAssertEqual(record.getString(names[5]), address.countryCode)
    }
    
    func testNilAddress() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setAddress(names[0], value: address, streetField: names[1], cityField: names[2], stateCodeField: names[3], postalCodeField: names[4], countryCodeField: names[5])
        XCTAssertNotNil(record.getAddress(names[0]))
        record.setAddress(names[0], value: nil, streetField: names[1], cityField: names[2], stateCodeField: names[3], postalCodeField: names[4], countryCodeField: names[5])
        XCTAssertNil(record.getAddress(names[0]))
        XCTAssertNil(record.getString(names[1]))
        XCTAssertNil(record.getString(names[2]))
        XCTAssertNil(record.getString(names[3]))
        XCTAssertNil(record.getString(names[4]))
        XCTAssertNil(record.getString(names[5]))
    }
    
    func testReference() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setReference(names[0], value: reference, relationshipName: names[1])
        XCTAssertEqual(record.getString(names[0]), strings[0])
        XCTAssertNotNil(record.getReference(names[1]))
        XCTAssertEqual(record.getReference(names[1])?.getString(CSRecord.Field.id.rawValue), strings[0])
    }
    
    func testNilReference() {
        let record: CSRecord = CSRecord(objectType: "Object")
        record.setReference(names[0], value: reference, relationshipName: names[1])
        record.setReference(names[0], value: nil, relationshipName: names[1])
        XCTAssertNil(record.getString(names[0]))
        XCTAssertNil(record.getReference(names[1]))
    }
    
    func testOperatorEqualTo() {
        let record1: CSRecord = CSRecord(dictionary: [:])
        let record2: CSRecord = CSRecord(dictionary: [:])
        let record3: CSRecord? = nil
        XCTAssertFalse(record1 == record2)
        XCTAssertFalse(record1 == record3)
        XCTAssertFalse(record2 == record3)
    }
    
    func testOperatorEqualToTrue() {
        let record1: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.id.rawValue : ids[0],
            CSRecord.Field.externalId.rawValue : externalIds[0]
        ])
        let record2: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.id.rawValue : ids[0],
        ])
        let record3: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.externalId.rawValue : externalIds[0]
        ])
        XCTAssertTrue(record1 == record2)
        XCTAssertTrue(record1 == record3)
    }
    
    func testOperatorEqualToFalse() {
        let record1: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.id.rawValue : ids[1],
            CSRecord.Field.externalId.rawValue : externalIds[1]
        ])
        let record2: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.id.rawValue : ids[0]
        ])
        let record3: CSRecord = CSRecord(dictionary: [
            CSRecord.Field.externalId.rawValue : externalIds[0]
        ])
        XCTAssertFalse(record1 == record2)
        XCTAssertFalse(record1 == record3)
        XCTAssertFalse(record2 == record3)
    }

}
