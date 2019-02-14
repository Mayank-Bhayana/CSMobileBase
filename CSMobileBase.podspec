#
# Be sure to run `pod lib lint CSMobileBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CSMobileBase'
  s.version          = '3.0.5'
  s.summary          = 'A convenience CocoaPod that extends the SmartStore and SmartSync functionality.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'CSMobileBase is a CocoaPod that uses the storing and syncing of data offline and online features by extending the functionality of SmartStore and SmartSync.'
                       DESC

  s.homepage         = 'https://github.com/MayankBhayana/CSMobileBase'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mbhayana@textron.com' => 'mbhayana@textron.com' }
  s.source           = { :git => 'https://github.com/MayankBhayana/CSMobileBase.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

#  s.source_files = 'CSMobileBase/Classes/**/*'
   s.source_files = 'CSMobileBase/Classes/*.{swift,h,m}'
  
  # s.resource_bundles = {
  #   'CSMobileBase' => ['CSMobileBase/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CocoaLumberjack', '~> 2.3.0'
  s.dependency 'SwiftyJSON', '~> 3.0.0'
  s.dependency 'SmartSync', '~> 4.3.0'
  s.dependency 'SmartStore', '~> 4.3.0'
  s.dependency 'SalesforceSDKCore', '~> 4.3.0'
  s.dependency 'SalesforceRestAPI', '~> 4.3.0'
  s.dependency 'SalesforceNetwork', '~> 4.3.0'
  s.dependency 'SQLCipher', '~> 3.4.2'
end
