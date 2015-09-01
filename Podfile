source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

pod '1PasswordExtension', '~> 1.2.0'
pod 'Analytics/Segmentio'
pod 'CRToast', git: 'https://github.com/ello/CRToast'
pod 'Crashlytics', '~> 3.1.0'
pod 'FLAnimatedImage', git: 'https://github.com/ello/FLAnimatedImage'
pod 'Fabric', '~> 1.2.0'
pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController'
pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser'
pod 'LUKeychainAccess', '~> 1.2.4'
pod 'MBProgressHUD', '~> 0.9.0'
# pod 'SDWebImage', '~> 3.7'
pod 'SSPullToRefresh', '~> 1.2'
pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit'
pod 'YapDatabase', git: 'https://github.com/ello/YapDatabase'
pod 'PINRemoteImage', '~> 1.1'

# debug only
pod 'Firebase', configurations: ['Debug']

# swift pods
pod 'Alamofire', '~> 1.3.0'
pod 'Moya', '~> 2.1.0'
pod 'Result', '~> 0.4.0'
pod 'SwiftyJSON', git: 'https://github.com/ello/SwiftyJSON'
pod 'SwiftyUserDefaults', '~> 1.3.0'
pod 'TimeAgoInWords', '~> 0.1.0'
pod 'WebLinking', '~> 0.2.0'

target 'Specs' do
  pod 'Nimble', '~> 1.0.0'
  pod 'OHHTTPStubs', '~> 4.1.0'
  pod 'Quick', '~> 0.3.0'
end

plugin 'cocoapods-keys', {
  project: 'Ello',
  keys: [
    'ClientKey',
    'ClientSecret',
    'CrashlyticsKey',
    'Domain',
    'HttpProtocol',
    'Salt',
    'SegmentKey',
    'FirebaseKey',
  ]
}
