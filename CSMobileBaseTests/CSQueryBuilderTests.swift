//
//  CSQueryBuilderTests.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import XCTest

class CSQueryBuilderTests: XCTestCase {
    
    var store: String!
    var text: String!
    var date: String!
    var fields: [String]!
    var values: [String]!
    
    override func setUp() {
        super.setUp()
        store = "Store"
        text = "Text"
        date = "0"
        fields = ["Field1","Field2"]
        values = ["Value1","Value2"]
    }
    
    override func tearDown() {
        store = nil
        text = nil
        date = nil
        fields = nil
        values = nil
        super.tearDown()
    }
    
    func testForStore() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store)
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)}")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date)")
    }
    
    func testSelect() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).select(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):\(fields[0])} FROM {\(store)}")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):\(fields[0])} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1")
    }
    
    func testCount() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).count(fields[0])
        XCTAssertEqual(query.build(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)}")
        XCTAssertEqual(query.buildRead(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1")
    }
    
    func testWhereNull() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereNull(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} IS NULL")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NULL")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NULL")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} IS NULL")
    }
    
    func testWhereNotNull() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereNotNull(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} IS NOT NULL")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NOT NULL")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NOT NULL")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} IS NOT NULL")
    }
    
    func testWhereEqual() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereEqual(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} = '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} = '\(values[0])'")
    }

    func testWhereNotEqual() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereNotEqual(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} != '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} != '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} != '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} != '\(values[0])'")
    }

    func testWhereTrue() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereTrue(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} = 1")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = 1")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = 1")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} = 1")
    }

    func testWhereFalse() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereFalse(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} = 0")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = 0")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} = 0")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} = 0")
    }

    func testWhereLess() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereLess(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} < '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} < '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} < '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} < '\(values[0])'")
    }
    
    func testWhereGreater() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereGreater(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} > '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} > '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} > '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} > '\(values[0])'")
    }
    
    func testWhereLessOrEqual() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereLessOrEqual(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} <= '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} <= '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} <= '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} <= '\(values[0])'")
    }
    
    func testWhereGreaterOrEqual() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereGreaterOrEqual(fields[0], value: values[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} >= '\(values[0])'")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} >= '\(values[0])'")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} >= '\(values[0])'")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} >= '\(values[0])'")
    }
    
    func testWhereIn() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereIn(fields[0], values: values)
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} IN ('\(values[0])','\(values[1])')")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IN ('\(values[0])','\(values[1])')")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IN ('\(values[0])','\(values[1])')")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} IN ('\(values[0])','\(values[1])')")
    }
    
    func testGroupBy() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).groupBy(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} GROUP BY {\(store):\(fields[0])}")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 GROUP BY {\(store):\(fields[0])}")
    }

    func testOrderBy() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).orderBy(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} ORDER BY {\(store)}.{\(store):\(fields[0])} ASC")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY {\(store)}.{\(store):\(fields[0])} ASC")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 ORDER BY {\(store)}.{\(store):\(fields[0])} ASC")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) ORDER BY {\(store)}.{\(store):\(fields[0])} ASC")
    }
    
    func testOrderByDescending() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).orderBy(fields[0], isDescending: true)
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} ORDER BY {\(store)}.{\(store):\(fields[0])} DESC")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY {\(store)}.{\(store):\(fields[0])} DESC")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 ORDER BY {\(store)}.{\(store):\(fields[0])} DESC")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) ORDER BY {\(store)}.{\(store):\(fields[0])} DESC")
    }

    func testOrderByCount() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).count(fields[0]).orderByCount(fields[0])
        XCTAssertEqual(query.build(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY COUNT({\(store)}.{\(store):\(fields[0])}) ASC")
        XCTAssertEqual(query.buildRead(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY COUNT({\(store)}.{\(store):\(fields[0])}) ASC")
    }
    
    func testOrderByCountDescending() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).count(fields[0]).orderByCount(fields[0], isDescending: true)
        XCTAssertEqual(query.build(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY COUNT({\(store)}.{\(store):\(fields[0])}) DESC")
        XCTAssertEqual(query.buildRead(), "SELECT COUNT({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY COUNT({\(store)}.{\(store):\(fields[0])}) DESC")
    }
    
    func testOrderBySum() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).sum(fields[0]).orderBySum(fields[0])
        XCTAssertEqual(query.build(), "SELECT SUM({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY SUM({\(store)}.{\(store):\(fields[0])}) ASC")
        XCTAssertEqual(query.buildRead(), "SELECT SUM({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY SUM({\(store)}.{\(store):\(fields[0])}) ASC")
    }
    
    func testOrderBySumDescending() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).sum(fields[0]).orderBySum(fields[0], isDescending: true)
        XCTAssertEqual(query.build(), "SELECT SUM({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY SUM({\(store)}.{\(store):\(fields[0])}) DESC")
        XCTAssertEqual(query.buildRead(), "SELECT SUM({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY SUM({\(store)}.{\(store):\(fields[0])}) DESC")
    }
    
    func testOrderByAverage() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).average(fields[0]).orderByAverage(fields[0])
        XCTAssertEqual(query.build(), "SELECT AVG({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY AVG({\(store)}.{\(store):\(fields[0])}) ASC")
        XCTAssertEqual(query.buildRead(), "SELECT AVG({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY AVG({\(store)}.{\(store):\(fields[0])}) ASC")
    }
    
    func testOrderByAverageDescending() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).average(fields[0]).orderByAverage(fields[0], isDescending: true)
        XCTAssertEqual(query.build(), "SELECT AVG({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} ORDER BY AVG({\(store)}.{\(store):\(fields[0])}) DESC")
        XCTAssertEqual(query.buildRead(), "SELECT AVG({\(store)}.{\(store):\(fields[0])}) FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 ORDER BY AVG({\(store)}.{\(store):\(fields[0])}) DESC")
    }
    
    func testOr() {
        let query: CSQueryBuilder = CSQueryBuilder.forSoupName(store).whereNull(fields[0]).or().whereNotNull(fields[0])
        XCTAssertEqual(query.build(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):\(fields[0])} IS NULL OR ({\(store):\(fields[0])} IS NOT NULL)")
        XCTAssertEqual(query.buildRead(), "SELECT {\(store):_soup} FROM {\(store)} WHERE {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NULL OR ({\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NOT NULL)")
        XCTAssertEqual(query.buildSearchForText(text), "SELECT {\(store):_soup} FROM {\(store)}, {\(store)}_fts WHERE {\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NULL OR ({\(store)}_fts.docid = {\(store):_soupEntryId} AND {\(store)}_fts MATCH '\(text)*' AND {\(store):__locally_deleted__} != 1 AND {\(store):\(fields[0])} IS NOT NULL)")
        XCTAssertEqual(query.buildCleanupForDate(date), "SELECT {\(store):_soupEntryId} FROM {\(store)} WHERE {\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} IS NULL OR ({\(store):__local__} != 1 AND {\(store):_soupLastModifiedDate} < \(date) AND {\(store):\(fields[0])} IS NOT NULL)")
    }
}