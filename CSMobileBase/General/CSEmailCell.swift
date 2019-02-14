//
//  CSEmailCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

open class CSEmailCell: CSFieldCell, UITextFieldDelegate {
    
    @IBOutlet fileprivate weak var textField: UITextField!

    fileprivate lazy var toolBar: UIToolbar = self.initToolBar()
    
    open override var isEditable: Bool { didSet { refreshTextField() } }
    open override var isRequired: Bool { didSet { refreshTextField() } }
    
    open var value: String? { didSet { refreshTextField() } }
    open var length: Int = 15
    
    @IBAction open override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    open override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = isEditable || value == nil ? theme.textColor : theme.hintColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("EMAIL_PLACEHOLDER", ""), theme: theme) : nil
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable == false && value != nil {
            let alertController: UIAlertController = initAlertController()
            alertController.popoverPresentationController?.sourceView = textField
            alertController.popoverPresentationController?.sourceRect = textField.frame
            delegate?.view.endEditing(true)
            delegate?.present(alertController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.inputAccessoryView = toolBar
        delegate?.activeCell = self
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        if value ?? "" != textField.text ?? "" {
            value = textField.text
            delegate?.valueDidChange(cell: self)
        }
        delegate?.activeCell = nil
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let count: Int = textField.text?.characters.count {
            return count + string.characters.count <= length
        }
        return true
    }

    fileprivate func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let value: String = value {
            let attributes: [String : Int]? = isEditable ? nil : [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
            textField.attributedText = NSAttributedString(string: value, attributes: attributes)
        }
        else {
            textField.attributedText = isEditable ? nil : NSAttributedString(string: empty)
        }
    }
    
    fileprivate func initAlertController() -> UIAlertController {
        if let value: String = value, let url: URL = URL(forEmail: value) {
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            alertController.addAction(UIAlertAction(title: SFLocalizedString("SEND_EMAIL_PLACEHOLDER", ""), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                UIApplication.shared.openURL(url as URL)
            }))
            alertController.addAction(UIAlertAction(title: SFLocalizedString("CANCEL", ""), style: UIAlertActionStyle.cancel, handler: nil))
            return alertController
        }
        let alertController: UIAlertController = UIAlertController(title: SFLocalizedString("INVALID_VALUE", ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: SFLocalizedString("DISMISS", ""), style: UIAlertActionStyle.cancel, handler: nil))
        return alertController
    }

}
