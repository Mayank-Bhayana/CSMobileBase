//
//  CSGeolocation.swift
//  CSMobileBase
//

import Foundation
import SwiftyJSON
import CoreLocation

public struct CSGeolocation {
    
    public var description: String
    public var coordinate: CLLocationCoordinate2D? {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
        }
        set {
            latitude = coordinate?.latitude
            longitude = coordinate?.longitude
        }
    }
    
    public var latitude: Double?
    public var longitude: Double?
    
    internal enum Name: String {
        case latitude = "latitude"
        case longitude = "longitude"
        case latitudeS = "__Latitude__s"
        case longitudeS = "__Longitude__s"
    }
    
    internal var dictionary: [String : AnyObject] {
        var dictionary: [String : AnyObject] = [:]
        dictionary[Name.latitude.rawValue] = latitude as AnyObject?
        dictionary[Name.longitude.rawValue] = longitude as AnyObject?
        return dictionary
    }
    
    internal init(json: JSON) {
        description = json.description
        latitude = json[Name.latitude.rawValue].double
        longitude = json[Name.longitude.rawValue].double
    }
    
    internal init(dictionary: NSDictionary) {
        self.init(json: JSON(dictionary))
    }
    
    public init() {
        description = ""
        latitude = 0.0
        longitude = 0.0
    }
    
    public init(location: CLLocation) {
        description = ""
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}
