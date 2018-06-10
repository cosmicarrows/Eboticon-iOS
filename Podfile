platform :ios, ‘10.0’

inhibit_all_warnings!
use_frameworks!


project 'Eboticon1.2.xcodeproj'

target 'Eboticon1.2' do
    pod 'CHCSVParser', '~> 2.0.7'
    pod 'CocoaLumberjack', '~> 1.9'
    pod 'iRate', '~> 1.10'
    pod 'SIAlertView', '~> 1.3'
    pod 'Harpy', '~> 3.3'
    pod 'GPUImage', '~> 0.1'
    pod 'TTSwitch', '~> 0.0.5'
    pod 'Toast'
    pod 'FLAnimatedImage', '~> 1.0'
    pod 'DFImageManager'
    pod 'DFImageManager/GIF'
    pod 'DFImageManager/AFNetworking'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'lottie-ios'
    pod 'ImageSlideshow', '~> 1.3'
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'EboticonKeyboard' do
    pod 'Toast'
    pod 'CHCSVParser', '~> 2.0.7'
    pod 'DFImageManager'
    pod 'DFImageManager/GIF'
    pod 'DFImageManager/AFNetworking'
    pod 'TTSwitch', '~> 0.0.5'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Fabric'
    pod 'Crashlytics'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

