source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Yep.
inhibit_all_warnings!

# Opt into framework support (required for Swift support in CocoaPods RC1)
use_frameworks!

pod '1PasswordExtension', git: 'https://github.com/ello/onepassword-app-extension'
pod 'Analytics/Segmentio'
pod 'CRToast', git: 'https://github.com/ello/CRToast'
pod 'Crashlytics', '~> 3.3'
pod 'FLAnimatedImage', git: 'https://github.com/ello/FLAnimatedImage'
pod 'Fabric', '~> 1.5'
pod 'JTSImageViewController', git: 'https://github.com/ello/JTSImageViewController'
pod 'KINWebBrowser', git: 'https://github.com/ello/KINWebBrowser'
pod 'LUKeychainAccess', '~> 1.2.4'
pod 'MBProgressHUD', '~> 0.9.0'
pod 'PINRemoteImage', '~> 1.1'
pod 'SSPullToRefresh', '~> 1.2'
pod 'SVGKit', git: 'https://github.com/SVGKit/SVGKit'
pod 'YapDatabase', git: 'https://github.com/ello/YapDatabase'
pod 'iRate', '~> 1.11'

# debug only
pod 'Firebase', configurations: ['Debug','CrashlyticsProduction','CrashlyticsStaging']

# swift pods
pod 'Alamofire', '~> 2.0'
pod 'Moya', '~> 2.2'
pod 'Result', '0.6-beta.1'
pod 'SwiftyJSON', git: 'https://github.com/ello/SwiftyJSON', branch: 'Swift-2.0'
pod 'SwiftyUserDefaults', '~> 1.3.0'
pod 'TimeAgoInWords', git: 'https://github.com/ello/TimeAgoInWords'
pod 'WebLinking', '~> 1.0'

target 'Specs' do
  pod 'Nimble', git: 'https://github.com/Quick/Nimble', branch: 'xcode7.1'
  pod 'OHHTTPStubs', '~> 4.3'
  pod 'Quick', git: 'https://github.com/Quick/Quick', branch: 'xcode7.1'
end

plugin 'cocoapods-keys', {
  project: 'Ello',
  keys: [
    'ClientKey',
    'ClientSecret',
    'CrashlyticsKey',
    'Domain',
    'FirebaseKey',
    'HttpProtocol',
    'Salt',
    'SegmentKey',
  ]
}
