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
pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit', branch: '2.x'
pod 'FLAnimatedImage', git: 'https://github.com/ello/FLAnimatedImage.git'

# swift pods
pod 'SwiftyJSON', git: "https://github.com/SwiftyJSON/SwiftyJSON", branch: "xcode6.3"
pod 'Alamofire', git: "https://github.com/Alamofire/Alamofire.git", branch: "xcode-6.3"
pod 'LlamaKit', git: "https://github.com/LlamaKit/LlamaKit", commit: "e28d7f6e82fbd5dcd5388b36e2acf4eedb44b4e8"
# pod 'Moya', git: "https://github.com/ello/Moya"
pod 'Moya', path: "/Users/s/work/Libraries/Moya"
pod 'WebLinking', '~> 0.1'

target 'Specs' do
    pod 'Quick', git: "git@github.com:Quick/Quick.git", tag: "v0.3.0"
    pod 'Nimble', git: "git@github.com:Quick/Nimble.git", tag: "v0.4.1"
end

plugin 'cocoapods-keys', {
  project: "Ello",
  keys: [
    'Salt',
    'ClientKey',
    'ClientSecret',
    'Domain',
  ]
}
