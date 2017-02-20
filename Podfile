# cocoapods version 1.1.1

source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

def all_pods
    pod 'AFNetworking', '~> 3.1.0'
    pod 'UIAlertView+Blocks', '~> 0.8'
    pod 'LUKeychainAccess', '~> 2.0.2'
    pod 'RNCryptor', '~> 2.2'
    pod 'Google/CloudMessaging'
    pod 'MRProgress', '~> 0.4.3'
    pod 'AHKActionSheet', :git => 'https://github.com/haaakon/AHKActionSheet.git', :commit => '84f116697e8187fb7f654d771df64690dd8860eb'
    pod 'Alamofire', '~> 4.2.0'
    pod 'SingleLineKeyboardResize', :git => 'https://github.com/haaakon/SingleLineKeyboardResize', :commit => '0f4e598d44922b2f291797edd4beff0f8a1ce99e'
    pod 'Cartography', '~> 1.0.1'
end

target 'Digipost' do
    all_pods
end

target 'DigipostQA' do
    all_pods
end

