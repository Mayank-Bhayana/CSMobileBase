//
//  CSReferenceCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/20/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import Foundation
import DesignSystem

public class CSReferenceCell: CSFieldCell, UITextFieldDelegate {
    
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    
    private lazy var recordLookupViewController: CSRecordLookupViewController = self.initRecordLookupViewController()
    
    public override var isEditable: Bool { didSet { refreshTextField() } }
    public override var isRequired: Bool { didSet { refreshTextField() } }
    
    public var value: CSRecord? { didSet { refreshTextField() } }
    public var relationshipField: String? { didSet { refreshTextField() } }
    public var relationshipName: String? { didSet { refreshTextField() } }
    public var referenceTo: String?
    
    @IBAction public override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        recordLookupViewController.theme = theme
        textField.borderStyle = isEditable ? UITextBorderStyle.roundedRect : UITextBorderStyle.none
        textField.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textField.textColor = theme.textColor
        textField.font = theme.subheadingFont
        textField.layer.borderColor = theme.accentColor.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 2
        textField.attributedPlaceholder = isEditable ? placeholder(text: SFLocalizedString("ADD_VALUE_PLACEHOLDER", ""), theme: theme) : nil
        indicatorImageView.backgroundColor = theme.navigationBarColor
        indicatorImageView.image = UIImage.sldsIconUtility(SLDSIconUtilType.utilityChevronright, with: theme.hintColor, andSize: 15)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable, let referenceTo: String = referenceTo {
            let segueIdentifier = "ShowReferenceSegue"
            let segues = delegate?.navigationController?.value(forKey: "storyboardSegueTemplates") as? [NSObject]
            if let filtered = segues?.filter({ $0.value(forKey: "identifier") as? String == segueIdentifier }) {
                delegate?.navigationController?.performSegue(withIdentifier: segueIdentifier, sender: self)
            } else {
                recordLookupViewController.objectType = referenceTo
                recordLookupViewController.pageLayout = nil
                recordLookupViewController.records = []
                recordLookupViewController.tableView.reloadData()
                delegate?.navigationController?.pushViewController(recordLookupViewController, animated: true)
            }
        }
        return false
    }
    
    private func refreshTextField() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        indicatorImageView.isHidden = isEditable == false || value != nil
        if let value: CSRecord = value, let relationshipField: String = relationshipField {
            textField.text = value.getString(relationshipField)
        }
        else {
            textField.text = isEditable ? nil : empty
        }
    }
    
    private func initRecordLookupViewController() -> CSRecordLookupViewController {
        let lookupRecordViewController: CSRecordLookupViewController = CSRecordLookupViewController()
        lookupRecordViewController.delegate = self
        return lookupRecordViewController
    }
    
}

extension CSReferenceCell: CSRecordLookupDelegate {
    
    public func didSelectRecord(_ record: CSRecord) {
        value = record
        delegate?.valueDidChange(cell: self)
        delegate?.navigationController?.popViewController(animated: true)
        textField.layer.borderWidth = 0
    }
}
