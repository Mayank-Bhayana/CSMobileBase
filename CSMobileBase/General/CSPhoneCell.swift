//
//  CSPhoneCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public class CSPhoneCell: CSFieldCell, UITextFieldDelegate {
 
    @IBOutlet private weak var textField: UITextField!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: String? { didSet { refreshTextField() } }
    public var length: Int = 40
    
    @IBAction public override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = isEditable || value == nil ? theme.textColor : theme.hintColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("PHONE_PLACEHOLDER", ""), theme: theme) : nil
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable == false && value != nil {
            let alertController: UIAlertController = initAlertController()
            alertController.popoverPresentationController?.sourceView = textField
            alertController.popoverPresentationController?.sourceRect = textField.frame
            delegate?.view.endEditing(true)
            delegate?.present(alertController, animated: true, completion: nil)
            return false
        }
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
            let attributes: [String : Any]? = isEditable ? nil : [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
            textField.attributedText = NSAttributedString(string: value, attributes: attributes)
        }
        else {
            textField.attributedText = isEditable ? nil : NSAttributedString(string: empty)
        }
    }
    
    private func initAlertController() -> UIAlertController {
        if let value: String = value {
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            if let url: URL = URL(forCall: value) {
                alertController.addAction(UIAlertAction(title: SFLocalizedString("CALL", ""), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    UIApplication.shared.openURL(url as URL)
                }))
            }
            if let url: URL = URL(forMessage: value) {
                alertController.addAction(UIAlertAction(title: SFLocalizedString("SEND_MESSAGE", ""), style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    UIApplication.shared.openURL(url as URL)
                }))
            }
            alertController.addAction(UIAlertAction(title: SFLocalizedString("CANCEL", ""), style: UIAlertActionStyle.cancel, handler: nil))
            return alertController
        }
        let alertController: UIAlertController = UIAlertController(title: SFLocalizedString("INVALID_VALUE", ""), message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: SFLocalizedString("DISMISS", ""), style: UIAlertActionStyle.cancel, handler: nil))
        return alertController
    }
    
}
