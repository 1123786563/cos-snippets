#import <XCTest/XCTest.h>
#import <QCloudCOSXML/QCloudCOSXML.h>
#import <QCloudCOSXML/QCloudUploadPartRequest.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadRequest.h>
#import <QCloudCOSXML/QCloudAbortMultipfartUploadRequest.h>
#import <QCloudCOSXML/QCloudMultipartInfo.h>
#import <QCloudCOSXML/QCloudCompleteMultipartUploadInfo.h>


@interface ListObjectsVersioning : XCTestCase <QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@end

@implementation ListObjectsVersioning {
    
    QCloudListVersionsResult* prevPageResult;
}

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

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue
requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的 secretID，secretKey，expiretionDate 和 token 参数
    credential.secretID = @"COS_SECRETID";
    credential.secretKey = @"COS_SECRETKEY";
    credential.token = @"COS_TOKEN";
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [[[NSDateFormatter alloc] init] dateFromString:@"startTime"]; // 单位是秒
    credential.expirationDate = [[[NSDateFormatter alloc] init] dateFromString:@"expiredTime"];
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
 * 获取对象多版本列表第一页数据
 */
- (void)listObjectsVersioning {
    
    //.cssg-snippet-body-start:[objc-list-objects-versioning]
    
    QCloudListObjectVersionsRequest* listObjectVersionsRequest =
        [[QCloudListObjectVersionsRequest alloc] init];
    
    // 存储桶名称
    listObjectVersionsRequest.bucket = @"bucketname";
    
    // 一页请求数据条目数，默认 1000
    listObjectVersionsRequest.maxKeys = 100;
    
    [listObjectVersionsRequest setFinishBlock:^(QCloudListVersionsResult * _Nonnull result,
                                                NSError * _Nonnull error) {
        // 已删除的文件
        NSArray<QCloudDeleteMarker*> *deleteMarker = result.deleteMarker;
        
        // 对象版本条目
        NSArray<QCloudVersionContent*> *versionContent = result.versionContent;
        
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] ListObjectVersions:listObjectVersionsRequest];
    //.cssg-snippet-body-end
}

/**
 * 获取对象多版本列表下一页数据
 */
- (void)listObjectsVersioningNextPage {

    //.cssg-snippet-body-start:[objc-list-objects-versioning-next-page]
    
    QCloudListObjectVersionsRequest* listObjectVersionsRequest = [[QCloudListObjectVersionsRequest alloc] init];
    
    // 存储桶名称
    listObjectVersionsRequest.bucket = @"bucketname";
    
    // 一页请求数据条目数，默认 1000
    listObjectVersionsRequest.maxKeys = 100;
    
    //从当前key列出剩余的条目
    listObjectVersionsRequest.keyMarker = prevPageResult.nextKeyMarker;
    //从当前key的某个版本列出剩余的条目
    listObjectVersionsRequest.versionIdMarker = prevPageResult.nextVersionIDMarkder;
    [listObjectVersionsRequest setFinishBlock:^(QCloudListVersionsResult * _Nonnull result,
                                                NSError * _Nonnull error) {
        
        // 已删除的文件
        NSArray<QCloudDeleteMarker*> *deleteMarker = result.deleteMarker;
        
        // 对象版本条目
        NSArray<QCloudVersionContent*> *versionContent = result.versionContent;
        
        if (result.isTruncated) {
            // 表示数据被截断，需要拉取下一页数据
            self->prevPageResult = result;
        }
    
        
    }];
    
    [[QCloudCOSXMLService defaultCOSXML] ListObjectVersions:listObjectVersionsRequest];
    //.cssg-snippet-body-end
    
}
// .cssg-methods-pragma

- (void)testListObjectsVersioning {
    // 获取对象多版本列表第一页数据
    [self listObjectsVersioning];
    
    // 获取对象多版本列表下一页数据
    [self listObjectsVersioningNextPage];
    // .cssg-methods-pragma
    
}

@end
