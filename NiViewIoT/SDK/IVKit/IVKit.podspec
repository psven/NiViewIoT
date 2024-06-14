#
# Be sure to run `pod lib lint IVKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name          = 'IVKit'
  spec.version       = '1.4'
  spec.summary       = "IoTVideoKit"
  spec.homepage      = "tencentcs.iotvideo.com"
  # spec.license       = { :type => "MIT", :file => "LICENSE" }
  spec.author        = { "iotvideo" => "iotvideo@tencentcs.com" }

  spec.platform      = :ios, "9.0"
  spec.source        = { :git => "https://tencentcs.iotvideo.com/#{spec.name}.git", :tag => "#{spec.version}" }
  spec.static_framework = true
  spec.libraries     = 'c++'#,'z','bz2','iconv'
  spec.frameworks    = 'AudioToolbox','VideoToolbox','CoreMedia'

  spec.subspec 'IoTVideo' do |ss|
    ss.dependency            'IVKit/IVP2P'
    ss.vendored_framework  = 'IoTVideo.framework'
  end

  spec.subspec 'IVVAS' do |ss|
    ss.vendored_framework  = 'IVVAS.framework'
  end

  spec.subspec 'IVP2P' do |ss|
    ss.vendored_libraries  = 'IVP2P/**/*.a'
  end

  spec.subspec 'IVFFmpeg' do |ss|
    ss.source_files        = 'IVFFmpeg/**/*.h'
    ss.vendored_libraries  = 'IVFFmpeg/**/*.a'
  end

end
