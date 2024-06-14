#
# Be sure to run `pod lib lint NiViewIoT.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NiViewIoT'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NiViewIoT.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/psven/NiViewIoT'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'psven' => 'onthewayjoey@gmail.com' }
  s.source           = { :git => 'https://github.com/psven/NiViewIoT.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'NiViewIoT/Classes/**/*'
  
  s.static_framework = true
  s.libraries     = 'c++'#,'z','bz2','iconv'
  s.frameworks    = 'AudioToolbox','VideoToolbox','CoreMedia'
  
  # 导入 .a 静态库
  s.vendored_libraries = "NiViewIoT/SDK/IVKit/**/*.a"

  # 导入 .framework
  s.vendored_frameworks = "NiViewIoT/SDK/IVKit/**/*.framework"

  # 导入头文件
  s.preserve_paths = "NiViewIoT/SDK/IVKit/**/*.h"

  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(PODS_ROOT)/#{s.name}/SDK/Frameworks" }
  s.xcconfig = { "CLANG_CXX_LANGUAGE_STANDARD" => "c++11", "CLANG_CXX_LIBRARY" => "libc++" }

  
#  s.dependency 'TIoTLinkKit', :path => 'NiViewIoT/SDK/IoT_2'
#  s.dependency 'TIoTLinkKit/LinkRTC', :path => 'NiViewIoT/SDK/IoT_2'
#  s.dependency 'TIoTLinkVideo', '2.4.40'
#  s.dependency 'TIoTLinkKit_GVoiceSE', '1.0.7'
#  s.dependency 'TIoTLinkKit_IJKPlayer', '2.0.13'

  # s.resource_bundles = {
  #   'NiViewIoT' => ['NiViewIoT/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
  s.dependency 'Alamofire',              '~> 5.4.4'
  s.dependency 'CryptoSwift',            '~> 1.0'
  s.dependency 'AFNetworking'
  s.dependency 'HandyJSON'
end
