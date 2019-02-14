//
//  RawRepresntable.swift
//  Pods
//
//  Created by Nicholas McDonald on 4/6/17.
//
//

import Foundation

public extension RawRepresentable where RawValue == String {
    var platformSpecificRawValue: String {
        return rawValue.lowercased()
    }
}

public extension String {
    var platformCaseStringValue: String {
        return self.lowercased()
    }
}
