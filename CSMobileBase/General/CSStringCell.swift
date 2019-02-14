//
//  CSStringCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public class CSStringCell: CSFieldCell, UITextFieldDelegate {
    
    @IBOutlet private weak var textField: UITextField!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: String? { didSet { refreshTextField() } }
    public var length: Int = 255
    
    @IBAction public override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = theme.textColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("TEXT_PLACEHOLDER", ""), theme: theme) : nil
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputAccessoryView = toolBar
        delegate?.activeCell = self
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        if value ?? "" != textField.text ?? "" {
            value = textField.text
            delegate?.valueDidChange(cell: self)
        }
        delegate?.activeCell = nil
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let count: Int = textField.text?.characters.count {
            return count + string.characters.count <= length
        }
        return true
    }
    
    private func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let value: String = value {
            textField.text = value
        }
        else {
            textField.text = isEditable ? nil : empty
        }
    }
    
}
