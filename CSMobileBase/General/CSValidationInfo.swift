//
//  CSValidationInfo.swift
//  CSMobileBase
//
//  Created by David Vieser on 4/10/17.
//
//

import Foundation
import SwiftyJSON

public struct CSValidationInfo: CustomStringConvertible {
    
    public var description: String

    public var errorMessage: String?
    public var errorFormula: String?
        
    internal enum Name: String {
        case errorMessage = "ErrorMessage"
        case errorFormula = "ErrorConditionFormula"
        case records = "Records"
        case metaData = "MetaData"
    }
    
    public init(json: JSON) {
        description = json.description
        errorMessage = json[Name.metaData.platformSpecificRawValue][Name.errorMessage.platformSpecificRawValue].string
        errorFormula = json[Name.metaData.platformSpecificRawValue][Name.errorFormula.platformSpecificRawValue].string
    }
    
    public func parseValidation(record: CSRecord) -> (Bool,String?) {
        if let errorFormula = self.errorFormula {
            var firstProperty, secondProperty: NSString?
            var function: Character
            let scanner = Scanner(string: errorFormula)
            
            let op: CharacterSet = CharacterSet(charactersIn: "<>")
            scanner.charactersToBeSkipped = CharacterSet(charactersIn: "<> ")
            scanner.scanUpToCharacters(from: op, into: &firstProperty)
            
            function = errorFormula[errorFormula.index(errorFormula.startIndex, offsetBy: scanner.scanLocation)]
            
            scanner.scanUpToCharacters(from: op, into: &secondProperty)
        
            if let firstValue = record.getDateTime((firstProperty! as String).trimmingCharacters(in: .whitespaces)),
                let secondValue = record.getDateTime((secondProperty! as String).trimmingCharacters(in: .whitespaces)) {
            
                switch function {
                case "<":
                    return (!(firstValue < secondValue), errorMessage)
                case ">":
                    return (!(firstValue > secondValue), errorMessage)
                default:
                    return (false, errorMessage)
                }
            }
        }
        return (false, errorMessage)
    }
    
}
