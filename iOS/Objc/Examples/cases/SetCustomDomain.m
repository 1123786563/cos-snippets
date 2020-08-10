#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface SetCustomDomain : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation SetCustomDomain

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1253653367";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];

    // 脚手架用于获取临时密钥
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.experationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
        initWithCredential:credential];
    continueBlock(creator, nil);
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 设置默认加速域名
 */
- (void)setCdnDomain {
    //.cssg-snippet-body-start:[objc-set-cdn-domain]
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc] initWithLiteralURL:[NSURL URLWithString:@"cdnDomain"]];
    
    //.cssg-snippet-body-end
}

/**
 * 设置自定义加速域名
 */
- (void)setCdnCustomDomain {
    //.cssg-snippet-body-start:[objc-set-cdn-custom-domain]
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.suffix = @"file.myqcloud.com";
    //.cssg-snippet-body-end
}

/**
 * 设置自定义域名
 */
- (void)setCustomDomain {
    //.cssg-snippet-body-start:[objc-set-custom-domain]
    NSString *customDomain = @"exampledomain.com"; // 自定义加速域名
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc] initWithLiteralURL:[NSURL URLWithString:customDomain]];
    //.cssg-snippet-body-end
}

/**
 * 设置全球加速域名
 */
- (void)setAccelerateDomain {
    //.cssg-snippet-body-start:[objc-set-accelerate-domain]
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc]init];
    endpoint.suffix = @"cos.accelerate.myqcloud.com";
    //.cssg-snippet-body-end
}

/**
 * 设置请求域名后缀
 */
- (void)setEndpointSuffix {
    //.cssg-snippet-body-start:[objc-set-endpoint-suffix]
    QCloudCOSXMLEndPoint *endpoint = [[QCloudCOSXMLEndPoint alloc]init];
    endpoint.suffix = @"exampledomain.com";
    //.cssg-snippet-body-end
}



// .cssg-methods-pragma

- (void)testSetCustomDomain {
    // 设置默认加速域名
    [self setCdnDomain];
        
    // 设置自定义加速域名
    [self setCdnCustomDomain];
        
    // 设置自定义域名
    [self setCustomDomain];

    // 设置全球加速域名
    [self setAccelerateDomain];

    // 设置请求域名后缀
    [self setEndpointSuffix];
        
        
        
    // .cssg-methods-pragma
}

@end
