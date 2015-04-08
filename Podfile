source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

pod 'TimeAgoInWords', '~> 0.1.0'
pod 'SDWebImage', '~> 3.7'
pod 'SSPullToRefresh', '~> 1.2'
pod 'MBProgressHUD', '~> 0.9'
pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit', branch: '2.x'
pod 'FLAnimatedImage', git: 'https://github.com/ello/FLAnimatedImage.git'
pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController.git'
pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser.git'
pod '1PasswordExtension', '~> 1.2'

# swift pods
pod 'SwiftyJSON', git: "https://github.com/SwiftyJSON/SwiftyJSON", branch: "xcode6.3"
pod 'Alamofire', git: "https://github.com/Alamofire/Alamofire.git", branch: "xcode-6.3"
pod 'LlamaKit', git: "https://github.com/ello/LlamaKit.git"
pod 'Moya', git: "https://github.com/ello/Moya", branch: 'cg-hybrid'
pod 'WebLinking', git: "https://github.com/kylef/WebLinking.swift.git", branch: "swift-1.2"

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
