#
# Be sure to run `pod lib lint TTPhysicalAuthorize.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPhysicalAuthorize'
  s.version          = '0.0.1'
  s.summary          = 'TTPhysicalAuthorize 是对iOS物理鉴权Face ID和Touch ID的调用封装'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        TTPhysicalAuthorize 是对iOS物理鉴权Face ID和Touch ID的调用封装，
                        提供开发者通过简单的方式使用设备的物理鉴权API
                       DESC

  s.homepage         = 'https://github.com/Lincktang/TTPhysicalAuthorize'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lincktang' => 'Lincktang@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/Lincktang/TTPhysicalAuthorize.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTPhysicalAuthorize/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TTPhysicalAuthorize' => ['TTPhysicalAuthorize/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'LocalAuthentication'
  # s.dependency 'AFNetworking', '~> 2.3'
end
