//
//  CSBooleanCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import DesignSystem

public class CSBooleanCell: CSFieldCell {

    @IBOutlet private weak var button: UIButton!
    
    public override var isEditable: Bool { didSet { refreshButton() } }
    public override var isRequired: Bool { didSet { refreshButton() } }

    public var value: Bool = false { didSet { refreshButton() } }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        button.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        button.tintColor = theme.textColor
        button.layer.cornerRadius = 2
        button.layer.borderWidth = 2
        button.layer.borderColor = theme.accentColor.cgColor
        let image: UIImage = UIImage.sldsIconUtility(SLDSIconUtilType.utilityCheck, with: theme.textColor, andSize: 20)
        button.setImage(image, for: UIControlState.selected)
    }
    
    @IBAction internal func onButtonTouched(sender: AnyObject) {
        if isEditable {
            value = !button.isSelected
            delegate?.valueDidChange(cell: self)
        }
    }
    
    private func refreshButton() {
        button.isSelected = value
    }
    
}
