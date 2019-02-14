//
//  CSQueryBuilder.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 6/28/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import SmartStore
import SmartSync

open class CSQueryBuilder {
    
    open let soupName: String
    
    fileprivate var selects: [String] = []
    open var wheres: [[String]] = [[]]
    fileprivate var groupBys: [String] = []
    fileprivate var orderBys: [String] = []
    
    open static func forSoupName(_ soupName: String) -> CSQueryBuilder {
        return CSQueryBuilder(soupName: soupName)
    }
    
    fileprivate init(soupName: String) {
        self.soupName = soupName
    }
    
    open func select(_ field: String) -> CSQueryBuilder {
        selects.append("{\(soupName):\(field)}")
        return self
    }
    
    open func count(_ field: String) -> CSQueryBuilder {
        selects.append("COUNT({\(soupName)}.{\(soupName):\(field)})")
        return self
    }

    open func sum(_ field: String) -> CSQueryBuilder {
        selects.append("SUM({\(soupName)}.{\(soupName):\(field)})")
        return self
    }
    
    open func average(_ field: String) -> CSQueryBuilder {
        selects.append("AVG({\(soupName)}.{\(soupName):\(field)})")
        return self
    }
    
    open func or() -> CSQueryBuilder {
        wheres.append([])
        return self
    }
    
    open func whereNull(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IS NULL")
        return self
    }
    
    open func whereNotNull(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IS NOT NULL")
        return self
    }
    
    open func whereEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} = '\(value)'")
        return self
    }
    
    open func whereEqual(_ field: String, value: Int) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} = \(value)")
        return self
    }
    
    open func whereNotEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} != '\(value)'")
        return self
    }

    open func whereTrue(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} = 1")
        return self
    }
    
    open func whereFalse(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} = 0")
        return self
    }
    
    open func whereLess(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} < '\(value)'")
        return self
    }
    
    open func whereGreater(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} > '\(value)'")
        return self
    }
    
    open func whereLessOrEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} <= '\(value)'")
        return self
    }
    
    open func whereGreaterOrEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} >= '\(value)'")
        return self
    }
    
    open func whereIn(_ field: String, values: [String]) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IN ('\(values.joined(separator: "','"))')")
        return self
    }
    
    open func groupBy(_ field: String) -> CSQueryBuilder {
        groupBys.append("{\(soupName):\(field)}")
        return self
    }
    
    open func orderBy(_ field: String, isDescending: Bool = false) -> CSQueryBuilder {
        if isDescending {
            orderBys.append("{\(soupName)}.{\(soupName):\(field)} DESC")
        }
        else {
            orderBys.append("{\(soupName)}.{\(soupName):\(field)} ASC")
        }
        return self
    }

    open func orderByCount(_ field: String, isDescending: Bool = false) -> CSQueryBuilder {
        if isDescending {
            orderBys.append("COUNT({\(soupName)}.{\(soupName):\(field)}) DESC")
        }
        else {
            orderBys.append("COUNT({\(soupName)}.{\(soupName):\(field)}) ASC")
        }
        return self
    }

    open func orderBySum(_ field: String, isDescending: Bool = false) -> CSQueryBuilder {
        if isDescending {
            orderBys.append("SUM({\(soupName)}.{\(soupName):\(field)}) DESC")
        }
        else {
            orderBys.append("SUM({\(soupName)}.{\(soupName):\(field)}) ASC")
        }
        return self
    }

    open func orderByAverage(_ field: String, isDescending: Bool = false) -> CSQueryBuilder {
        if isDescending {
            orderBys.append("AVG({\(soupName)}.{\(soupName):\(field)}) DESC")
        }
        else {
            orderBys.append("AVG({\(soupName)}.{\(soupName):\(field)}) ASC")
        }
        return self
    }
    
    open func build() -> String {
        var query: String = buildSelectClause()
        if let whereClause: String = buildWhereClause() {
            query.append(" WHERE \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = buildWhereClause(or) {
                query.append(" OR (\(whereClause))")
            }
        }
        if let groupByClause: String = buildGroupByClause() {
            query.append(" \(groupByClause)")
        }
        if let orderByClause: String = buildOrderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    open func buildRead() -> String {
        var query: String = buildSelectClause()
        query.append(" WHERE {\(soupName):\(kSyncManagerLocallyDeleted)} != 1")
        if let whereClause: String = buildWhereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = buildWhereClause(or) {
                query.append(" OR ({\(soupName):\(kSyncManagerLocallyDeleted)} != 1")
                query.append(" AND \(whereClause))")
            }
        }
        if let groupByClause: String = buildGroupByClause() {
            query.append(" \(groupByClause)")
        }
        if let orderByClause: String = buildOrderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    open func buildSearchForText(_ text: String) -> String {
        var query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)}, {\(soupName)}_fts"
        query.append(" WHERE {\(soupName)}_fts.docid = {\(soupName):\(SOUP_ENTRY_ID)}")
        query.append(" AND {\(soupName)}_fts MATCH '\(text)*'")
        query.append(" AND {\(soupName):\(kSyncManagerLocallyDeleted)} != 1")
        if let whereClause: String = buildWhereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = buildWhereClause(or) {
                query.append(" OR ({\(soupName)}_fts.docid = {\(soupName):\(SOUP_ENTRY_ID)}")
                query.append(" AND {\(soupName)}_fts MATCH '\(text)*'")
                query.append(" AND {\(soupName):\(kSyncManagerLocallyDeleted)} != 1")
                query.append(" AND \(whereClause))")
            }
        }
        if let orderByClause: String = buildOrderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    open func buildCleanupForDate(_ date: String) -> String {
        var query: String = "SELECT {\(soupName):\(SOUP_ENTRY_ID)} FROM {\(soupName)}"
        query.append(" WHERE {\(soupName):\(kSyncManagerLocal)} != 1")
        query.append(" AND {\(soupName):\(SOUP_LAST_MODIFIED_DATE)} < \(date)")
        if let whereClause: String = buildWhereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = buildWhereClause(or) {
                query.append(" OR ({\(soupName):\(kSyncManagerLocal)} != 1")
                query.append(" AND {\(soupName):\(SOUP_LAST_MODIFIED_DATE)} < \(date)")
                query.append(" AND \(whereClause))")
            }
        }
        if let orderByClause: String = buildOrderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    fileprivate func buildSelectClause() -> String {
        if selects.count > 0 {
            return "SELECT \(selects.joined(separator: ", ")) FROM {\(soupName)}"
        }
        return "SELECT {\(soupName):_soup} FROM {\(soupName)}"
    }
    
    fileprivate func buildWhereClause(_ or: Int = 0) -> String? {
        if wheres[or].count > 0 {
            return "\(wheres[or].joined(separator: " AND "))"
        }
        return nil
    }
    
    fileprivate func buildGroupByClause() -> String? {
        if groupBys.count > 0 {
            return "GROUP BY \(groupBys.joined(separator: " "))"
        }
        return nil
    }
    
    fileprivate func buildOrderByClause() -> String? {
        if orderBys.count > 0 {
            return "ORDER BY \(orderBys.joined(separator: " "))"
        }
        return nil
    }
    
}
