# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ExampleLiveKit' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'LiveKit', :git => "https://github.com/baveku/LiveKit"
  # Pods for ExampleLiveKit

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
