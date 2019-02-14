//
//  CSDateCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import THCalendarDatePicker

public class CSDateCell: CSFieldCell, UITextFieldDelegate, THDatePickerDelegate {
    
    @IBOutlet private weak var textField: UITextField!
    
    private lazy var datePicker: THDatePickerViewController = self.initDatePicker()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: Date? { didSet { refreshTextField() } }
    
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
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("DATE_PLACEHOLDER", ""), theme: theme) : nil
        datePicker.selectedBackgroundColor = theme.accentColor
        datePicker.currentDateColorSelected = theme.textColor
        datePicker.currentDateColor = theme.positiveColor
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable {
            textField.layer.borderWidth = 2
            delegate?.view.endEditing(true)
            delegate?.presentSemiViewController(datePicker, withOptions: [
                KNSemiModalOptionKeys.pushParentBack.takeRetainedValue() : NSNumber(value: false),
                KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.3),
                KNSemiModalOptionKeys.shadowOpacity.takeRetainedValue() : NSNumber(value: 0)
            ])
        }
        return false
    }
    
    public func datePickerDidHide(datePicker: THDatePickerViewController!) {
        textField.layer.borderWidth = 0
    }
    
    public func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        value = datePicker.date as Date?
        datePicker.dismissSemiModalView()
        delegate?.valueDidChange(cell: self)
    }
    
    public func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        datePicker.dismissSemiModalView()
    }
    
    private func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let value = value, let date: Date = value as Date {
            textField.text = DateFormatter.localizedString(from: date as Date, dateStyle: .medium, timeStyle: .none)
            datePicker.date = date as Date!
        }
        else {
            textField.text = isEditable ? nil : empty
            datePicker.setAllowClearDate(true)
        }
    }
    
    private func initDatePicker() -> THDatePickerViewController {
        let datePicker: THDatePickerViewController = THDatePickerViewController.datePicker()
        datePicker.delegate = self
        datePicker.setAllowClearDate(true)
        return datePicker
    }
    
}
