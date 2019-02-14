//
//  CSQueryBuilder.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 10/01/19.
//


import Foundation

open class CSQueryBuilder {
    
    enum Field: String {
        case soup = "_soup"
        case soupEntryId = "_soupEntryId"
        case soupLastModifiedDate = "_soupLastModifiedDate"
        case local = "__local__"
        case locallyDeleted = "__locally_deleted__"
    }
    
    fileprivate let soupName: String
    
    fileprivate var wheres: [[String]] = [[]]
    fileprivate var orderBys: [String] = []
    
    open static func forSoupName(_ soupName: String) -> CSQueryBuilder {
        return CSQueryBuilder(soupName: soupName)
    }
    
    fileprivate init(soupName: String) {
        self.soupName = soupName
    }
    
    open func or() -> CSQueryBuilder {
        wheres.append([])
        return self
    }
    
    open func isNull(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IS NULL")
        return self
    }
    
    open func isNotNull(_ field: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IS NOT NULL")
        return self
    }
    
    open func isEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} = '\(value)'")
        return self
    }
    
    open func isNotEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} != '\(value)'")
        return self
    }
    
    open func isLess(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} < '\(value)'")
        return self
    }
    
    open func isGreater(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} > '\(value)'")
        return self
    }
    
    open func isLessOrEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} <= '\(value)'")
        return self
    }
    
    open func isGreaterOrEqual(_ field: String, value: String) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} >= '\(value)'")
        return self
    }
    
    open func isIn(_ field: String, values: [String]) -> CSQueryBuilder {
        wheres[wheres.count - 1].append("{\(soupName):\(field)} IN ('\(values.joined(separator: "','"))')")
        return self
    }
    
    open func orderByAscending(_ orderBy: String) -> CSQueryBuilder {
        orderBys.append("{\(soupName)}.{\(soupName):\(orderBy)} ASC")
        return self
    }
    
    open func orderByDescending(_ orderBy: String) -> CSQueryBuilder {
        orderBys.append("{\(soupName)}.{\(soupName):\(orderBy)} DESC")
        return self
    }
    
    open func build() -> String {
        var query: String = "SELECT {\(soupName):\(Field.soup.rawValue)} FROM {\(soupName)}"
        query.append(" WHERE {\(soupName):\(Field.locallyDeleted.rawValue)} != 1")
        if let whereClause: String = whereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = whereClause(or) {
                query.append(" OR ({\(soupName):\(Field.locallyDeleted.rawValue)} != 1")
                query.append(" AND \(whereClause))")
            }
        }
        if let orderByClause: String = orderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    open func buildSearchForText(_ text: String) -> String {
        var query: String = "SELECT {\(soupName):_soup} FROM {\(soupName)}, {\(soupName)}_fts"
        query.append(" WHERE {\(soupName)}_fts.docid = {\(soupName):\(Field.soupEntryId.rawValue)}")
        query.append(" AND {\(soupName)}_fts MATCH '\(text)*'")
        query.append(" AND {\(soupName):\(Field.locallyDeleted.rawValue)} != 1")
        if let whereClause: String = whereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = whereClause(or) {
                query.append(" OR ({\(soupName)}_fts.docid = {\(soupName):\(Field.soupEntryId.rawValue)}")
                query.append(" AND {\(soupName)}_fts MATCH '\(text)*'")
                query.append(" AND {\(soupName):\(Field.locallyDeleted.rawValue)} != 1")
                query.append(" AND \(whereClause))")
            }
        }
        if let orderByClause: String = orderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    open func buildCleanupForDate(_ date: String) -> String {
        var query: String = "SELECT {\(soupName):\(Field.soupEntryId.rawValue)} FROM {\(soupName)}"
        query.append(" WHERE {\(soupName):\(Field.local.rawValue)} != 1")
        query.append(" AND {\(soupName):\(Field.soupLastModifiedDate.rawValue)} < \(date)")
        if let whereClause: String = whereClause() {
            query.append(" AND \(whereClause)")
        }
        for or: Int in 1..<wheres.count {
            if let whereClause: String = whereClause(or) {
                query.append(" OR ({\(soupName):\(Field.local.rawValue)} != 1")
                query.append(" AND {\(soupName):\(Field.soupLastModifiedDate.rawValue)} < \(date)")
                query.append(" AND \(whereClause))")
            }
        }
        if let orderByClause: String = orderByClause() {
            query.append(" \(orderByClause)")
        }
        return query
    }
    
    fileprivate func whereClause(_ or: Int = 0) -> String? {
        if wheres[or].count > 0 {
            return "\(wheres[or].joined(separator: " AND "))"
        }
        return nil
    }
    
    fileprivate func orderByClause() -> String? {
        if orderBys.count > 0 {
            return "ORDER BY \(orderBys.joined(separator: " "))"
        }
        return nil
    }
    
}

