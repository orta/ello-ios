source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

pod '1PasswordExtension', '~> 1.2.0'
pod 'FLAnimatedImage', '~> 1.0.0'
pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController.git'
pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser.git'
pod 'MBProgressHUD', '~> 0.9.0'
pod 'SDWebImage', '~> 3.7'
pod 'SSPullToRefresh', '~> 1.2'
pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit', branch: '2.x'
pod 'TimeAgoInWords', '~> 0.1.0'
pod 'YapDatabase', git: 'https://github.com/ello/YapDatabase.git'
pod 'LUKeychainAccess', '~> 1.2.4'

pod 'NewRelicAgent', '~> 4.186'

# swift pods
pod 'Alamofire', '~> 1.2.0'
pod 'Moya', git: "https://github.com/ello/Moya", branch: 'cg-hybrid'
pod 'SwiftyJSON', '~> 2.2.0'
pod 'SwiftyUserDefaults', '~> 1.1.0'
pod 'WebLinking', '~> 0.2.0'
pod 'Result', '~> 0.4.0'

target 'Specs' do
  pod 'Quick', '~> 0.3.0'
  pod 'Nimble', '~> 0.4.0'
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
