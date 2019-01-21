#
# Be sure to run `pod lib lint JIRAMobileKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JIRAMobileKit'
  s.version          = '4.2.3'
  s.summary          = 'JIRA bug reporting for iOS written in swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Create and raise bugs in JIRA direct from device with in built auto completion of environment and screenshot.
                       DESC

  s.homepage         = 'https://github.com/willpowell8/JIRAMobileKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'willpowell8' => 'willpowell8@gmail.com' }
  s.source           = { :git => 'https://github.com/willpowell8/JIRAMobileKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/willpowelluk'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

  s.source_files = 'JIRAMobileKit/Classes/**/*'
  
  s.resource_bundles = {
    'JIRAMobileKit' => ['JIRAMobileKit/Assets/{*.png,*.xib}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MBProgressHUD'
end
