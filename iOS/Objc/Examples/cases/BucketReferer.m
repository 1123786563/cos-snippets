#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface BucketReferer : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation BucketReferer

- (void)setUp {
    // 注册默认的 COS 服务
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = @"1250000000";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-guangzhou";//服务地域名称，可用的地域请参考注释
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
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator,
                                               NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

/**
 * 设置存储桶 Referer
 */
- (void)putBucketReferer {
    
    //.cssg-snippet-body-start:[objc-put-bucket-referer]
    
    QCloudPutBucketRefererRequest* request = [QCloudPutBucketRefererRequest new];

    // 防盗链类型，枚举值：Black-List、White-List
    reqeust.refererType = QCloudBucketRefererTypeBlackList;

    // 是否开启防盗链，枚举值：Enabled、Disabled
    reqeust.status = QCloudBucketRefererStatusEnabled;

    // 是否允许空 Referer 访问，枚举值：Allow、Deny，默认值为 Deny
    reqeust.configuration = QCloudBucketRefererConfigurationDeny;

    // 生效域名列表， 支持多个域名且为前缀匹配， 支持带端口的域名和 IP， 支持通配符*，做二级域名或多级域名的通配
    reqeust.domainList = @[@"*.com",@"*.qq.com"];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    [request setFinishBlock:^(id outputObject, NSError *error) {
        if (error){
            // 添加防盗链失败
        }else{
            // 添加防盗链失败
        }

    }];
    [[QCloudCOSXMLService defaultCOSXML] PutBucketReferer:request];
    
    //.cssg-snippet-body-end
    
}

/**
 * 查询存储桶 Referer
 */
- (void)getBucketReferer {
    
    //.cssg-snippet-body-start:[objc-get-bucket-referer]
    QCloudGetBucketRefererRequest* request = [QCloudGetBucketRefererRequest new];

    // 存储桶名称，格式为 BucketName-APPID
    request.bucket = @"examplebucket-1250000000";

    [request setFinishBlock:^(QCloudBucketRefererInfo * outputObject, NSError *error) {
        // outputObject 请求到的防盗链，详细字段请查看api文档或者SDK源码
        // QCloudBucketRefererInfo 类；
    }];
    [[QCloudCOSXMLService defaultCOSXML] GetBucketReferer:request];
    
    //.cssg-snippet-body-end
    
}

// .cssg-methods-pragma

- (void)testBuketReferer {
    // 设置存储桶 Referer
    [self putBucketReferer];

    // 查询存储桶 Referer
    [self getBucketReferer];
  
    // .cssg-methods-pragma
}
@end