//
//  CSPickListCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import DesignSystem

public class CSPickListCell: CSFieldCell, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    private lazy var pickerView: UIPickerView = self.initPickerView()
    
    private var invalid: String?
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: String? { didSet { refreshTextField() } }
    public var pickListValues: [CSPickListValue]? { didSet { refreshTextField() } }
    
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
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("SELECT_OPTION", ""), theme: theme) : nil
        indicatorImageView.backgroundColor = theme.navigationBarColor
        indicatorImageView.image = UIImage.sldsIconUtility(SLDSIconUtilType.utilityDown, with: theme.hintColor, andSize: 15)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let value: String = value, indexForValue(value: value) == nil {
            invalid = value
        }
        else {
            invalid = nil
        }
        return isEditable
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
        if invalid != nil && isRequired {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
        else if invalid != nil && isRequired == false {
            pickerView.selectRow(1, inComponent: 0, animated: false)
        }
        else if value == nil && isRequired && pickerView.selectedRow(inComponent: 0) >= 0 {
            value = pickListValues?[pickerView.selectedRow(inComponent: 0)].value
            delegate?.valueDidChange(cell: self)
        }
        else if let value: String = value, let index: Int = indexForValue(value: value) {
            if isRequired {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            else {
                pickerView.selectRow(index + 1, inComponent: 0, animated: false)
            }
        }
        delegate?.activeCell = self
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        delegate?.activeCell = nil
    }
    
    public func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isRequired == false || invalid != nil {
            return (pickListValues?.count ?? 0) + 1
        }
        if isRequired == false && invalid != nil {
            return (pickListValues?.count ?? 0) + 2
        }
        return pickListValues?.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 && isRequired == false {
            return empty
        }
        if row == 0 && invalid != nil {
            return invalid
        }
        if row == 1 && invalid != nil && isRequired == false {
            return invalid
        }
        if row > 0 && (isRequired == false || invalid != nil) {
            return pickListValues?[row - 1].label
        }
        if row > 1 && isRequired == false && invalid != nil {
            return pickListValues?[row - 2].label
        }
        return pickListValues?[row].label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 && isRequired == false {
            value = nil
        }
        else if row == 0 && invalid != nil {
            value = invalid
        }
        else if row == 1 && invalid != nil && isRequired == false {
            value = invalid
        }
        else if row > 0 && (isRequired == false || invalid != nil) {
            value = pickListValues?[row - 1].value
        }
        else if row > 1 && isRequired == false && invalid != nil {
            value = pickListValues?[row - 2].value
        }
        else {
            value = pickListValues?[row].value
        }
        delegate?.valueDidChange(cell: self)
    }
    
    private func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        indicatorImageView.isHidden = isEditable == false || value != nil
        if let value: String = value {
            if let index: Int = indexForValue(value: value) {
                textField.text = pickListValues?[index].label
            }
            else {
                textField.text = value
            }
        }
        else {
            textField.text = isEditable ? nil : empty
        }
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
