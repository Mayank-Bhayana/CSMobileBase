//
//  CSRecordCell.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/14/18.
//  Copyright © 2018 Mayank Bhayana. All rights reserved.
//

import UIKit

open class CSRecordCell: UITableViewCell {
    
    @IBOutlet private weak var stackView: UIStackView!
    
    open func applyTheme(theme: CSTheme) {
        backgroundColor = theme.backgroundColor
        tintColor = theme.hintColor
        if let label: UILabel = stackView.arrangedSubviews.first as? UILabel {
            label.textColor = theme.textColor
            label.font = theme.subheadingFont
        }
        if stackView.arrangedSubviews.count > 1 {
            if let label: UILabel = stackView.arrangedSubviews[1] as? UILabel {
                label.textColor = theme.hintColor
                label.font = theme.bodyFont
            }
        }
        if stackView.arrangedSubviews.count > 2 {
            for index: Int in 2..<stackView.arrangedSubviews.count {
                if let label: UILabel = stackView.arrangedSubviews[index] as? UILabel {
                    label.textColor = theme.accentColor
                    label.font = theme.labelFont
                }
            }
        }
    }
    
    public func addLabelsForPageLayout(pageLayout: CSPageLayout, settings: CSSettings, record: CSRecord) {
        for view: UIView in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        if let layoutSection: CSLayoutSection = pageLayout.highlightsPanelLayoutSection {
            for layoutRow: CSLayoutRow in layoutSection.layoutRows {
                for layoutItems: CSLayoutItem in layoutRow.layoutItems {
                    if let layoutComponent: CSLayoutComponent = layoutItems.layoutComponents.first {
                        addLabelForLayoutComponent(layoutComponent: layoutComponent, settings: settings, record: record)
                    }
                }
            }
        }
        else {
            for layoutSection: CSLayoutSection in pageLayout.detailLayoutSections ?? [] {
                for layoutRow: CSLayoutRow in layoutSection.layoutRows {
                    for layoutItem: CSLayoutItem in layoutRow.layoutItems {
                        for layoutComponent: CSLayoutComponent in layoutItem.layoutComponents {
                            if stackView.arrangedSubviews.count < 3 {
                                addLabelForLayoutComponent(layoutComponent: layoutComponent, settings: settings, record: record)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addLabelForLayoutComponent(layoutComponent: CSLayoutComponent, settings: CSSettings, record: CSRecord) {
        if layoutComponent.type == "Field", let value: String = layoutComponent.value {
            let label: UILabel = UILabel()
            if let fieldDetail: CSFieldDetail = layoutComponent.detail {
                if fieldDetail.type == CSFieldType.Reference, let referenceTo: String = fieldDetail.referenceTo.first, let relationshipName: String = fieldDetail.relationshipName {
                    if let object: CSObject = settings.object(referenceTo), let nameField: String = object.nameField {
                        label.text = record.getReference(relationshipName)?.getString(nameField)
                    }
                    else {
                        label.text = value
                    }
                }
                else {
                    label.text = record.getString(value.platformCaseStringValue) ?? " "
                }
            }
            stackView.addArrangedSubview(label)
        }
    }


}
