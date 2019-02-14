//
//  CSFieldCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import Foundation
import DesignSystem

public protocol CSFieldCellDelegate {
    var view: UIView! { get }
    var navigationController: UINavigationController? { get }
    var activeCell: CSFieldCell? { get set }
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func presentSemiViewController(_ vc: UIViewController!, withOptions options: [AnyHashable : Any]!)
    func valueDidChange(cell: CSFieldCell)
}

open class CSFieldCell: UITableViewCell {
    
    @IBOutlet public weak var label: UILabel!
    @IBOutlet weak var typeNotSupportedLabel: UILabel!
    @IBOutlet public weak var requiredLabel: UILabel!
    @IBOutlet public weak var clearButton: UIButton?
    
    public let empty: String = "(\(SFLocalizedString("NONE", "")))"
    
    public var delegate: CSFieldCellDelegate?
    public var isEditable: Bool = false {
        didSet {
            requiredLabel.isHidden = isRequired == false || isEditable == false
        }
    }
    public var isRequired: Bool = false {
        didSet {
            requiredLabel.isHidden = isRequired == false || isEditable == false
        }
    }
    
    @IBAction public func onClearButtonTouched(sender: AnyObject) {
        clearButton?.isHidden = true
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        requiredLabel.isHidden = isRequired == false || isEditable == false
    }
    
    public func applyTheme(theme: CSTheme) {
        isUserInteractionEnabled = true
        selectionStyle = UITableViewCellSelectionStyle.none
        backgroundColor = theme.backgroundColor
        tintColor = theme.hintColor
        label.textColor = theme.accentColor
        label.font = theme.labelFont
        requiredLabel.textColor = theme.hintColor
        requiredLabel.font = theme.tabFont
        requiredLabel.text = SFLocalizedString("REQUIRED", "").localizedUppercase
        requiredLabel.isHidden = isRequired == false || isEditable == false
        typeNotSupportedLabel?.text = SFLocalizedString("TYPE_NOT_SUPPORTED", "")
        let image: UIImage = UIImage.sldsIconUtility(SLDSIconUtilType.utilityClear, with: theme.hintColor, andSize: 20)
        clearButton?.setImage(image, for: UIControlState.normal)
    }
    
    public func placeholder(text: String, theme: CSTheme) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName : theme.hintColor,
            NSFontAttributeName : theme.hintFont
        ])
    }
    
    internal func initToolBar() -> UIToolbar {
        let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let button: UIBarButtonItem = UIBarButtonItem(title: SFLocalizedString("DONE", ""), style: UIBarButtonItemStyle.plain, target: delegate?.view, action: #selector(UIView.endEditing(_:)))
        let toolBar = UIToolbar()
        toolBar.setItems([space, button], animated: false)
        toolBar.sizeToFit()
        return toolBar
    }
    
}
