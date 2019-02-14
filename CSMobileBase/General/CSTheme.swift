//
//  CSTheme.swift
//  CSMobileBase
//
//  Created by Mayank Bhayana on 7/8/18.
//  Copyright © 2018 Textron Inc.. All rights reserved.
//

import UIKit

public protocol CSTheme {
    var positiveColor: UIColor { get }
    var negativeColor: UIColor { get }
    var neutralColor: UIColor { get }
    var navigationBarColor: UIColor { get }
    var tabBarColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var separatorColor: UIColor { get }
    var accentColor: UIColor { get }
    var textColor: UIColor { get }
    var hintColor: UIColor { get }
    var headingFont: UIFont { get }
    var subheadingFont: UIFont { get }
    var hintFont: UIFont { get }
    var bodyFont: UIFont { get }
    var labelFont: UIFont { get }
    var tabFont: UIFont { get }
}
