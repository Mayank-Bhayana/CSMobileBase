//
//  CSDoubleCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

open class CSDoubleCell: CSFieldCell, UITextFieldDelegate {
    
    @IBOutlet fileprivate weak var textField: UITextField!
    
    fileprivate lazy var toolBar: UIToolbar = self.initToolBar()
    
    open override var isEditable: Bool { didSet { refreshTextField() } }
    open override var isRequired: Bool { didSet { refreshTextField() } }

    open var value: Double? { didSet { refreshTextField() } }
    open var scale: Int = 0 { didSet { refreshTextField() } }
    open var length: Int = 10

    @IBAction open override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }

    open override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textField.keyboardType = scale > 0 ? UIKeyboardType.decimalPad : UIKeyboardType.numberPad
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = theme.textColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("NUMBER_PLACEHOLDER", ""), theme: theme) : nil
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputAccessoryView = toolBar
        delegate?.activeCell = self
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        let double: Double? = textField.text == nil ? nil : Double(textField.text!)
        if value != double {
            value = double
            delegate?.valueDidChange(cell: self)
        }
        delegate?.activeCell = nil
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text: String = textField.text {
            let replacementText: String = (text as NSString).replacingCharacters(in: range, with: string)
            let components: [String] = replacementText.components(separatedBy: ".")
            if components.count == 1 {
                return components[0].characters.count <= length
            }
            if components.count == 2 {
                return components[0].characters.count <= length && components[1].characters.count <= scale
            }
            return components.count == 0
        }
        return true
    }
    
    fileprivate func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let value: Double = value {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = scale
            textField.text = formatter.string(from: NSNumber(value: value))
        }
        else {
            textField.text = isEditable ? nil : empty
        }
    }
    
}
