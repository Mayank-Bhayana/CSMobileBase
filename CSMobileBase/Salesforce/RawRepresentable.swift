//
//  RawRepresntable.swift
//  Pods
//
//  Created by Mayank Bhayana on 4/6/18.
//
//

import Foundation

public extension RawRepresentable where RawValue == String {
    var platformSpecificRawValue: String {
        return rawValue
    }
}

public extension String {
    var platformCaseStringValue: String {
        return self
    }
}
