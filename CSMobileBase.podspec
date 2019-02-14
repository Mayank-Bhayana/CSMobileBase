Pod::Spec.new do |s|
  s.name = 'CSMobileBase'
  s.version = '3.1.0'
  s.summary = 'Offline and customization platform built on Salesforce Mobile SDK for iOS'
  s.homepage = 'https://github.com/MayankBhayana/CSMobileBase'
  s.license = { :type => "Salesforce", :file => "LICENSE.md" }
  s.author = { "Mayank Bhayana" => "mbhayana@textron.com" }
  s.source = { :git => "https://github.com/MayankBhayana/CSMobileBase.git", :tag => "#{s.version}" }
  s.platform = :ios, '9.0'
  s.requires_arc = true
  s.default_subspec = 'Salesforce'

  s.subspec 'General' do |g|
    g.public_header_files = 'CSMobileBase/General/*.h'
    g.source_files = 'CSMobileBase/General/*.{swift,h,m}', 'CSMobileBase/Salesforce/*.{swift,h,m}', 'CSMobileBase/Heroku/HerokuSyncUpTarget.swift', 'CSMobileBase/Heroku/CSMobileBase_Heroku.h', 'CSMobileBase/Heroku/CSMobileBase copy-Info.plist', 'CSMobileBase/Heroku/HerokuSyncDownTarget.swift'
    g.resources = 'CSMobileBase/General/*.{xib}' 
  #  g.dependency 'CSMobileBase/Salesforce'
  #  g.dependency 'CSMobileBase/Heroku'
    g.dependency 'CocoaLumberjack', '= 2.4.0'
    g.dependency 'KNSemiModalViewController_hons82', '= 0.4.5'
    g.dependency 'SQLCipher', '= 3.4.1'
    g.dependency 'SalesforceAnalytics', '= 5.0.1'
    g.dependency 'SalesforceSDKCore', '= 5.0.1'
    g.dependency 'SmartStore', '= 5.0.1'
    g.dependency 'SmartSync', '= 5.0.1'
    g.dependency 'DesignSystem', '= 2.0.8'
    g.dependency 'SwiftyJSON', '= 3.1.4'
    g.dependency 'MUPullToRefresh', '1.0.1'
    g.dependency 'THCalendarDatePicker', '1.2.8'
    g.dependency 'RxSwift', '= 3.4.0'
    g.dependency 'ReachabilitySwift', '= 3.0.0'
  end

  s.subspec 'Salesforce' do |sf|
    sf.source_files = 'CSMobileBase/Salesforce/*.{swift,h,m}'
    sf.dependency 'CSMobileBase/General'
  end

 # s.subspec 'Heroku' do |hk|
 #   hk.source_files = 'CSMobileBase/Heroku/*.{swift,h,m}'
 #   hk.dependency 'CSMobileBase/General'
 # end
end
