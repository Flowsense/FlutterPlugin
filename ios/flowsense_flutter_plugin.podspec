#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flowsense_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.homepage         = 'https://flowsense.com.br'
  # s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flowsense' => 'tech@flowsense.com.br' }
  s.source           = { :path => '.' }
  s.vendored_frameworks = 'FlowsenseSDK.framework', 'AWSCore.framework', 'AWSKinesis.framework'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

