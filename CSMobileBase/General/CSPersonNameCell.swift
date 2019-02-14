//
//  CSPersonNameCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 8/8/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import UIKit

public class CSPersonNameCell: CSFieldCell, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private weak var salutationTextField: UITextField!
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    private lazy var pickerView: UIPickerView = self.initPickerView()
    
    public override var isEditable: Bool { didSet { refreshTextFields() } }
    public override var isRequired: Bool { didSet { refreshTextFields() } }
    
    public var value: CSPersonName? { didSet { refreshTextFields() } }
    public var pickListValues: [CSPickListValue]? { didSet { refreshTextFields() } }
    public var length: Int = 255
    
    @IBAction public override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        applyThemeToTextField(textField: salutationTextField, theme: theme)
        applyThemeToTextField(textField: firstNameTextField, theme: theme)
        applyThemeToTextField(textField: lastNameTextField, theme: theme)
        salutationTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("TITLE_PLACEHOLDER", ""), theme: theme) : nil
        firstNameTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("FIRST_NAME_PLACEHOLDER", ""), theme: theme) : nil
        lastNameTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("LAST_NAME_PLACEHOLDER", ""), theme: theme) : nil
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditable
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputAccessoryView = toolBar
        if textField == salutationTextField {
            textField.inputView = pickerView
            if let value: String = value?.salutation, let index: Int = indexForValue(value: value) {
                pickerView.selectRow(index + 1, inComponent: 0, animated: false)
            }
            else {
                pickerView.selectRow(0, inComponent: 0, animated: false)
            }
        }
        
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        var personName: CSPersonName = value ?? CSPersonName(record: nil)
        if textField == firstNameTextField {
            personName.firstName = textField.text
        }
        if textField == lastNameTextField {
            personName.lastName = textField.text
        }
        value = personName
        delegate?.valueDidChange(cell: self)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let count: Int = textField.text?.characters.count {
            return count + string.characters.count <= length
        }
        return true
    }
    
    public func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickListValues?.count ?? 0) + 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return empty
        }
        return pickListValues?[row - 1].label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var personName: CSPersonName = value ?? CSPersonName(record: nil)
        if row == 0 {
            personName.salutation = nil
        }
        else {
            personName.salutation = pickListValues?[row - 1].value
        }
        value = personName
        delegate?.valueDidChange(cell: self)
    }
    
    private func refreshTextFields() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        refreshTextField(textField: salutationTextField, component: value?.salutation)
        refreshTextField(textField: firstNameTextField, component: value?.firstName)
        refreshTextField(textField: lastNameTextField, component: value?.lastName)
    }
    
    private func refreshTextField(textField: UITextField, component: String?) {
        if let component: String = component {
            if textField == salutationTextField, let index: Int = indexForValue(value: component) {
                textField.text = pickListValues?[index].label
                textField.isHidden = false
            }
            else {
                textField.text = component
                textField.isHidden = false
            }
        }
        else {
            textField.text = nil
            textField.isHidden = isEditable == false
        }
    }
    
    private func applyThemeToTextField(textField: UITextField, theme: CSTheme) {
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = theme.textColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
    }
    
    private func indexForValue(value: String) -> Int? {
        if let pickListValues: [CSPickListValue] = pickListValues {
            for index: Int in 0..<pickListValues.count {
                if pickListValues[index].value == value {
                    return index
                }
            }
        }
        return nil
    }
    
    private func initPickerView() -> UIPickerView {
        let pickerView: UIPickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }
    
}
