//
//  CSDateTimeCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import THCalendarDatePicker

open class CSDateTimeCell: CSFieldCell, UITextFieldDelegate, THDatePickerDelegate {
    
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    @IBOutlet fileprivate weak var timeTextField: UITextField!
    
    fileprivate lazy var toolBar: UIToolbar = self.initToolBar()
    fileprivate lazy var datePicker: THDatePickerViewController = self.initDatePicker()
    fileprivate lazy var timePicker: UIDatePicker = self.initTimePicker()
    
    open override var isEditable: Bool { didSet { refreshTextFields() } }
    open override var isRequired: Bool { didSet { refreshTextFields() } }
    
    open var value: Date? { didSet { refreshTextFields() } }
    
    @IBAction open override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    open override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        applyThemeToTextField(dateTextField, theme: theme)
        applyThemeToTextField(timeTextField, theme: theme)
        dateTextField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("DATE_PLACEHOLDER", ""), theme: theme) : nil
        datePicker.selectedBackgroundColor = theme.accentColor
        datePicker.currentDateColorSelected = theme.textColor
        datePicker.currentDateColor = theme.positiveColor
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable {
            textField.layer.borderWidth = 2
            if textField == dateTextField {
                delegate?.view.endEditing(true)
                delegate?.presentSemiViewController(datePicker, withOptions: [
                    KNSemiModalOptionKeys.pushParentBack.takeRetainedValue() : NSNumber(value: false as Bool),
                    KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.3 as Float),
                    KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue() : NSNumber(value: 0 as Float)
                ])
            }
            else if textField == timeTextField {
                textField.inputView = timePicker
                textField.inputAccessoryView = toolBar
                return true
            }
        }
        return false
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
    open func datePickerDidHide(_ datePicker: THDatePickerViewController!) {
        dateTextField.layer.borderWidth = 0
    }
    
    open func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        value = datePicker.date
        datePicker.dismissSemiModalView()
        delegate?.valueDidChange(cell: self)
    }
    
    open func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        datePicker.dismissSemiModalView()
    }
    
    func valueDidChange(_ sender: UIDatePicker) {
        value = sender.date
        delegate?.valueDidChange(cell: self)
    }
    
    fileprivate func refreshTextFields() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let date: Date = value {
            dateTextField.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            timeTextField.text = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            timeTextField.isHidden = false
            datePicker.date = date
            timePicker.date = date
        }
        else {
            dateTextField.text = isEditable ? nil : empty
            timeTextField.text = nil
//            timeTextField.isHidden = true
            datePicker.setAllowClearDate(true)
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
    
    fileprivate func initDatePicker() -> THDatePickerViewController {
        let datePicker: THDatePickerViewController = THDatePickerViewController.datePicker()
        datePicker.delegate = self
        datePicker.setAllowClearDate(true)
        return datePicker
    }
    
    fileprivate func initTimePicker() -> UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.time
        datePicker.addTarget(self, action: #selector(CSDateTimeCell.valueDidChange(_:)), for: UIControlEvents.valueChanged)
        return datePicker
    }
    
}
