platform :ios, '9.0'
use_frameworks!

source 'ssh://git@github.com/forcedotcom/SalesforceMobileSDK-iOS-Specs.git'
source 'ssh://git@github.com/CocoaPods/Specs.git'

def installed_pods
  pod 'CocoaLumberjack', '= 2.4.0'
  pod 'KNSemiModalViewController_hons82', '= 0.4.5'
  pod 'SQLCipher', '= 3.4.1'
  pod 'SalesforceAnalytics', '= 5.0.1'
  pod 'SalesforceSDKCore', '= 5.0.1'
  pod 'SmartStore', '= 5.0.1'
  pod 'SmartSync', '= 5.0.1'
  pod 'DesignSystem', '= 2.0.8'
  pod 'SwiftyJSON', '= 3.1.4'
  pod 'MUPullToRefresh', '1.0.1'
  pod 'THCalendarDatePicker', '1.2.8'
  pod 'RxSwift', '= 3.4.0'
  pod 'ReachabilitySwift', '= 3.0.0'
end

target 'CSMobileBase' do
  installed_pods
end

target 'CSMobileBase_Heroku' do
  installed_pods
end

target 'CSMobileBaseTests' do
  installed_pods
end
