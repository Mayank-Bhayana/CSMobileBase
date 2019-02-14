//
//  CSAddressCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

open class CSAddressCell: CSFieldCell, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet fileprivate weak var streetTextField: UITextField!
    @IBOutlet fileprivate weak var cityTextField: UITextField!
    @IBOutlet fileprivate weak var stateCodeTextField: UITextField!
    @IBOutlet fileprivate weak var postalCodeTextField: UITextField!
    @IBOutlet fileprivate weak var countryCodeTextField: UITextField!
    
    fileprivate lazy var toolBar: UIToolbar = self.initToolBar()
    fileprivate lazy var statePickerView: UIPickerView = self.initPickerView()
    fileprivate lazy var countryPickerView: UIPickerView = self.initPickerView()
    
    fileprivate var filteredPickListValues: [CSPickListValue]?
    
    open override var isEditable: Bool { didSet { refreshTextFields() } }
    open override var isRequired: Bool { didSet { refreshTextFields() } }
    
    open var value: CSAddress? { didSet { refreshTextFields() } }
    open var statePickListValues: [CSPickListValue]? { didSet { refreshTextFields() } }
    open var countryPickListValues: [CSPickListValue]? { didSet { refreshTextFields() } }

    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        applyThemeToTextField(streetTextField, theme: theme)
        applyThemeToTextField(cityTextField, theme: theme)
        applyThemeToTextField(stateCodeTextField, theme: theme)
        applyThemeToTextField(postalCodeTextField, theme: theme)
        applyThemeToTextField(countryCodeTextField, theme: theme)
        streetTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("STREET_PLACEHOLDER", ""), theme: theme) : nil
        cityTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("CITY_PLACEHOLDER", ""), theme: theme) : nil
        stateCodeTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("STATE_PLACEHOLDER", ""), theme: theme) : nil
        postalCodeTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("POSTAL_CODE_PLACEHOLDER", ""), theme: theme) : nil
        countryCodeTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("COUNTRY_PLACEHOLDER", ""), theme: theme) : nil
        
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == stateCodeTextField && countryCodeTextField.text?.isEmpty ?? true {
            return false
        }
        return isEditable
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputAccessoryView = toolBar
        if textField == stateCodeTextField {
            textField.inputView = statePickerView
            if let value: String = value?.stateCode, let index: Int = indexForValue(value, pickListValues: filteredPickListValues) {
                statePickerView.selectRow(index + 1, inComponent: 0, animated: false)
            }
            else {
                statePickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }
        if textField == countryCodeTextField {
            textField.inputView = countryPickerView
            if let value: String = value?.countryCode, let index: Int = indexForValue(value, pickListValues: countryPickListValues) {
                countryPickerView.selectRow(index + 1, inComponent: 0, animated: false)
            }
            else {
                countryPickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }
        delegate?.activeCell = self
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        var address: CSAddress = CSAddress(dictionary: value?.dictionary as NSDictionary? ?? [:])
        if textField == streetTextField {
            address.street = textField.text
        }
        if textField == cityTextField {
            address.city = textField.text
        }
        if textField == postalCodeTextField {
            address.postalCode = textField.text
        }
        value = address
        delegate?.valueDidChange(cell: self)
        delegate?.activeCell = nil
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == statePickerView {
            return (filteredPickListValues?.count ?? 0) + 1
        }
        if pickerView == countryPickerView {
            return (countryPickListValues?.count ?? 0) + 1
        }
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return empty
        }
        if pickerView == statePickerView {
            return filteredPickListValues?[row - 1].label
        }
        if pickerView == countryPickerView {
            return countryPickListValues?[row - 1].label
        }
        return nil
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var address: CSAddress = CSAddress(dictionary: value?.dictionary as NSDictionary? ?? [:])
        if pickerView == statePickerView {
            if row == 0 {
                address.stateCode = nil
            }
            else {
                address.stateCode = filteredPickListValues?[row - 1].value
            }
        }
        if pickerView == countryPickerView {
            if row == 0 {
                address.countryCode = nil
            }
            else {
                address.countryCode = countryPickListValues?[row - 1].value
                let index: Int = pickerView.selectedRow(inComponent: 0) - 1
                filteredPickListValues = statePickListValues?.filter{ isValidForIndex(index, validFor: $0.validFor ?? "") }
            }
            address.stateCode = nil
        }
        value = address
        delegate?.valueDidChange(cell: self)
    }
    
    fileprivate func refreshTextFields() {
        refreshTextField(streetTextField, component: value?.street)
        refreshTextField(cityTextField, component: value?.city)
        refreshTextField(stateCodeTextField, component: value?.stateCode)
        refreshTextField(postalCodeTextField, component: value?.postalCode)
        refreshTextField(countryCodeTextField, component: value?.countryCode)
        if value?.street == nil && value?.city == nil && value?.stateCode == nil && value?.postalCode == nil && value?.countryCode == nil {
            streetTextField.text = isEditable ? nil : empty
            streetTextField.isHidden = false
        }
    }
    
    fileprivate func refreshTextField(_ textField: UITextField, component: String?) {
        if let component: String = component {
            if textField == stateCodeTextField, let index: Int = indexForValue(component, pickListValues: filteredPickListValues) {
                textField.text = filteredPickListValues?[index].label
            }
            else if textField == countryCodeTextField, let index: Int = indexForValue(component, pickListValues: countryPickListValues) {
                textField.text = countryPickListValues?[index].label
            }
            else {
                textField.text = component
            }
            textField.isHidden = false
        }
        else {
            textField.text = nil
            textField.isHidden = !isEditable
        }
    }
    
    fileprivate func applyThemeToTextField(_ textField: UITextField, theme: CSTheme) {
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = theme.textColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
    }
    
    fileprivate func indexForValue(_ value: String, pickListValues: [CSPickListValue]?) -> Int? {
        if let pickListValues: [CSPickListValue] = pickListValues {
            for index: Int in 0..<pickListValues.count {
                if pickListValues[index].value == value {
                    return index
                }
            }
        }
        return nil
    }
    
    fileprivate func isValidForIndex(_ index: Int, validFor: String) -> Bool {
        let options: NSData.Base64DecodingOptions = NSData.Base64DecodingOptions.ignoreUnknownCharacters
        if let data: Data = Data(base64Encoded: validFor, options: options) {
            let count: Int = data.count / MemoryLayout<Int8>.size
            var bytes: [Int8] = [Int8](repeating: 0, count: count)
            (data as NSData).getBytes(&bytes, length: count * MemoryLayout<Int8>.size)
            let byte: Int = index / 8
            let bit: Int8 = Int8(7) - Int8(index % 8)
            if bytes.count > byte {
                return bytes[byte] >> bit == 1
            }
        }
        return false
    }
    
    fileprivate func initPickerView() -> UIPickerView {
        let pickerView: UIPickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }
    
}
