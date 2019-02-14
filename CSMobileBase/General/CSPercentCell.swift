//
//  CSPercentCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public class CSPercentCell: CSFieldCell, UITextFieldDelegate {

    @IBOutlet private weak var textField: UITextField!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }

    public var value: Double? { didSet { refreshTextField() } }
    public var scale: Int = 0 { didSet { refreshTextField() } }
    public var length: Int = 10
    
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
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("PERCENT_PLACEHOLDER", ""), theme: theme) : nil
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
        let double: Double? = textField.text == nil ? nil : Double(textField.text!)
        if value != double {
            value = double
            delegate?.valueDidChange(cell: self)
        }
        delegate?.activeCell = nil
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    
    private func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        textField.keyboardType = scale > 0 ? UIKeyboardType.decimalPad : UIKeyboardType.numberPad
        if let value: Double = value {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = scale
            if isEditable == false {
                formatter.numberStyle = NumberFormatter.Style.percent
                textField.text = formatter.string(from: NSNumber(value: value / 100))
            }
            else {
                textField.text = formatter.string(from: NSNumber(value: value))
            }
        }
        else {
            textField.text = isEditable ? nil : empty
        }
    }
    
}
