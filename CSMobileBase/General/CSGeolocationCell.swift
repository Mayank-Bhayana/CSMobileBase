//
//  CSGeolocationCell.swift
//  CSMobileBase
//

import UIKit
import MapKit

public class CSGeolocationCell: CSFieldCell {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    
    public override var isEditable: Bool { didSet { refreshMapView() } }
    public override var isRequired: Bool { didSet { refreshMapView() } }
    
    public var value: CSGeolocation? { didSet { refreshMapView() } }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
    }
    
    private func refreshMapView() {
        if let coordinate: CLLocationCoordinate2D = value?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
}
