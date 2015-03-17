source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

pod 'SDWebImage', '~> 3.7'
pod 'SSPullToRefresh', '~> 1.2'
# lock this at 1.9 to support SVGKit using `DDLogC` methods
pod 'CocoaLumberjack', '~> 1.9'
pod 'SVGKit', git: "https://github.com/SVGKit/SVGKit", branch: "2.x"

# swift pods
pod 'SwiftyJSON', :git => "https://github.com/orta/SwiftyJSON", :branch => "podspec"
pod 'Alamofire', :git => "https://github.com/Alamofire/Alamofire.git"
pod 'LlamaKit', :git => "https://github.com/AshFurrow/LlamaKit", :branch => "rac_podspec"
pod 'Moya', :git => "https://github.com/ello/Moya"
pod 'WebLinking', '~> 0.1'

target 'Specs' do
    pod 'Quick', '~> 0.2.2'
    pod 'Nimble', '~> 0.3.0'
end

plugin 'cocoapods-keys', {
  :project => "Ello",
  :target => "Ello",
  :keys => [
    "Salt",
  ]
}
