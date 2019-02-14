//
//  CSRecordLookupCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/20/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import DesignSystem

public protocol CSRecordLookupCellDelegate {
    func onButtonTouched(cell: CSRecordLookupCell)
}

public class CSRecordLookupCell: CSRecordCell {
    
    @IBOutlet public weak var button: UIButton!
    
    public var delegate: CSRecordLookupCellDelegate?
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        let image: UIImage = UIImage.sldsIconUtility(SLDSIconUtilType.utilityAdd, with: theme.textColor, andSize: 20)
        button.setImage(image, for: UIControlState.normal)
        button.backgroundColor = theme.tabBarColor
        button.tintColor = theme.textColor
        button.titleLabel?.textColor = theme.textColor
        button.titleLabel?.font = theme.subheadingFont
        button.layer.borderColor = theme.accentColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 2
    }
        
    @IBAction func onButtonTouchUpInside(_ sender: Any) {
        delegate?.onButtonTouched(cell: self)
    }
}
