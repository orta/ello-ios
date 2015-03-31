//
//  ElloS3
//  Ello
//
//  Created by Colin Gray on 3/3/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// creds = AmazonCredentials(...)
// data = NSData()
// uploader = ElloS3(credentials: credentials, data: data)
//   .onSuccess() { (response : NSData) in }
//   .onFailure() { (error : NSError) in }
//   // NOT yet supported:
//   //.onProgress() { (progress : Float) in }
//   .start()


@objc
class ElloS3 {
    let filename : String
    let data : NSData
    let contentType : String
    let credentials : AmazonCredentials

    typealias SuccessHandler = ((response : NSData) -> ())
    typealias FailureHandler = ((error : NSError) -> ())
    typealias ProgressHandler = ((progress : Float) -> ())

    private var successHandler : SuccessHandler?
    private var failureHandler : FailureHandler?
    private var progressHandler : ProgressHandler?

    init(credentials: AmazonCredentials, filename: String, data: NSData, contentType: String) {
        self.filename = filename
        self.data = data
        self.contentType = contentType
        self.credentials = credentials
    }

    func onSuccess(handler : SuccessHandler) -> Self {
        self.successHandler = handler
        return self
    }

    func onFailure(handler : FailureHandler) -> Self {
        self.failureHandler = handler
        return self
    }

    func onProgress(handler : ProgressHandler) -> Self {
        self.progressHandler = handler
        return self
    }

    // this is just the uploading code, the initialization and handler code is
    // mostly the same
    func start() -> Self {
        let key = "\(credentials.prefix)/\(filename)"
        let url = NSURL(string: credentials.endpoint)!

        let builder = MultipartRequestBuilder(url: url, capacity: data.length)
        builder.addParam("key", value: key)
        builder.addParam("AWSAccessKeyId", value: credentials.accessKey)
        builder.addParam("acl", value: "public-read")
        builder.addParam("success_action_status", value: "201")
        builder.addParam("policy", value: credentials.policy)
        builder.addParam("signature", value: credentials.signature)
        builder.addParam("Content-Type", value: self.contentType)
        // builder.addParam("Content-MD5", value: md5(data))
        builder.addFile("file", filename: filename, data: data, contentType: contentType)
        let request = builder.buildRequest()

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data : NSData?, response : NSURLResponse?, error : NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                var httpResponse = response as? NSHTTPURLResponse
                if let error = error {
                    self.failureHandler?(error: error)
                }
                else if httpResponse?.statusCode >= 200 && httpResponse?.statusCode < 300 {
                    if let data = data {
                        let message = NSString(data: data, encoding: NSUTF8StringEncoding)!
                        self.successHandler?(response: data)
                    }
                    else {
                        self.failureHandler?(error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                    }
                }
                else {
                    self.failureHandler?(error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                }
            }
        }
        task.resume()

        return self
    }

}
