//
//  CSCurrencyCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public class CSCurrencyCell: CSFieldCell, UITextFieldDelegate {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var isoCodeLabel: UILabel!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    private lazy var numberFormatter = NumberFormatter()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: Double? { didSet { refreshTextField() } }
    public var isoCode: String? { didSet { refreshTextField() } }
    public var scale: Int = 0 { didSet { refreshTextField() } }
    public var length: Int = 10
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.font = theme.subheadingFont
        textField.textColor = theme.textColor
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("AMOUNT_PLACEHOLDER", ""), theme: theme) : nil
        isoCodeLabel.font = theme.hintFont
        isoCodeLabel.textColor = theme.hintColor
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
        numberFormatter.numberStyle = isoCode == nil ? NumberFormatter.Style.currency : NumberFormatter.Style.decimal
        textField.keyboardType = scale > 0 ? UIKeyboardType.decimalPad : UIKeyboardType.numberPad
        isoCodeLabel.text = isoCode
        isoCodeLabel.isHidden = isoCode == nil || (isEditable == false && value == nil)
        if let value: Double = value {
            numberFormatter.minimumFractionDigits = scale
            textField.text = numberFormatter.string(from: NSNumber(value: value))
        }
        else {
            textField.text = isEditable ? nil : empty
        }
    }
    
}
