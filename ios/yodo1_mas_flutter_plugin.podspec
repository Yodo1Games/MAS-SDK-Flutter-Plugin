#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint yodo1_mas_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'yodo1_mas_flutter_plugin'
  s.version          = '0.0.9'
  s.summary          = 'Flutter plugin for Yodo1 MAS SDK.'
  s.description      = <<-DESC
Flutter plugin for Yodo1 MAS SDK 4.12+.
                       DESC
  s.homepage         = 'https://yodo1.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nitesh Oswal' => 'niteshoswal@yodo1.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.dependency 'Yodo1MasFull', '4.15.1'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'yodo1_mas_flutter_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
