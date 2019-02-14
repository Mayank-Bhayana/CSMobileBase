//
//  CSTextAreaCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public class CSTextAreaCell: CSFieldCell, UITextViewDelegate {
    
    @IBOutlet private weak var textView: UITextView!
    
    private lazy var toolBar: UIToolbar = self.initToolBar()
    
    public override var isEditable: Bool { didSet { refreshTextView() } }
    public override var isRequired: Bool { didSet { refreshTextView() } }
    
    public var value: String? { didSet { refreshTextView() } }
    public var length: Int = 131072
    
    @IBAction public override func onClearButtonTouched(sender: AnyObject) {
        super.onClearButtonTouched(sender: sender)
        value = nil
        delegate?.valueDidChange(cell: self)
    }
    
    public override func applyTheme(theme: CSTheme) {
        super.applyTheme(theme: theme)
        textView.isEditable = isEditable
        textView.clipsToBounds = true
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = isEditable ? 8 : 0
        textView.backgroundColor = isEditable ? theme.navigationBarColor : UIColor.clear
        textView.textColor = theme.textColor
        textView.font = theme.subheadingFont
        textView.layer.borderColor = theme.accentColor.cgColor
        textView.layer.borderWidth = 0
        textView.layer.cornerRadius = 2
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return isEditable
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
        textView.inputAccessoryView = toolBar
        delegate?.activeCell = self
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
        delegate?.activeCell = nil
        if value ?? "" != textView.text {
            value = textView.text.isEmpty ? nil : textView.text
            delegate?.valueDidChange(cell: self)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let count: Int = textView.text.characters.count {
            return count + text.characters.count <= length
        }
        return true
    }
    
    private func refreshTextView() {
        clearButton?.isHidden = isRequired || isEditable == false || value == nil
        if let value: String = value {
            textView.text = value
        }
        else {
            textView.text = isEditable ? nil : empty
        }
    }
    
}
