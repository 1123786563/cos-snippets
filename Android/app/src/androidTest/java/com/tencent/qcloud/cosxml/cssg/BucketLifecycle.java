package com.tencent.qcloud.cosxml.cssg;

import android.support.annotation.Nullable;

import com.tencent.cos.xml.*;
import com.tencent.cos.xml.common.*;
import com.tencent.cos.xml.exception.*;
import com.tencent.cos.xml.listener.*;
import com.tencent.cos.xml.model.*;
import com.tencent.cos.xml.model.object.*;
import com.tencent.cos.xml.model.bucket.*;
import com.tencent.cos.xml.model.tag.*;
import com.tencent.cos.xml.transfer.*;
import com.tencent.qcloud.core.auth.*;
import com.tencent.qcloud.core.common.*;
import com.tencent.qcloud.core.http.*;
import com.tencent.cos.xml.model.service.*;


import android.content.Context;
import android.util.Log;
import android.support.test.InstrumentationRegistry;

import org.junit.Test;

import java.net.*;
import java.util.*;
import java.nio.charset.Charset;
import java.io.*;

public class BucketLifecycle {

    private Context context;
    private CosXmlService cosXmlService;

    public static class ServerCredentialProvider extends BasicLifecycleCredentialProvider {

        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials() throws QCloudClientException {

            // 首先从您的临时密钥服务器获取包含了密钥信息的响应
			// 临时密钥生成和使用指引参见https://cloud.tencent.com/document/product/436/14048

            // 然后解析响应，获取密钥信息
            String tmpSecretId = "临时密钥 secretId";
            String tmpSecretKey = "临时密钥 secretKey";
            String sessionToken = "临时密钥 TOKEN";
            long expiredTime = 1556183496L;//临时密钥有效截止时间戳，单位是秒

            /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
            // 返回服务器时间作为签名的起始时间
            long startTime = 1556182000L; //临时密钥有效起始时间，单位是秒

            // 最后返回临时密钥信息对象
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey,
                    sessionToken, startTime, expiredTime);
        }
    }

    /**
     * 设置存储桶生命周期
     */
    private void putBucketLifecycle() {
        //.cssg-snippet-body-start:[put-bucket-lifecycle]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        PutBucketLifecycleRequest putBucketLifecycleRequest =
                new PutBucketLifecycleRequest(bucket);

        // 声明周期配置规则信息
        LifecycleConfiguration.Rule rule = new LifecycleConfiguration.Rule();
        rule.id = "Lifecycle ID";
        LifecycleConfiguration.Filter filter = new LifecycleConfiguration.Filter();
        // 指定规则所适用的前缀
        filter.prefix = "dir/";
        rule.filter = filter;
        // 指明规则是否启用
        rule.status = "Enabled";
        // 指明规则对应的动作在对象最后的修改日期过后多少天操作
        LifecycleConfiguration.Transition transition =
                new LifecycleConfiguration.Transition();
        transition.days = 100;
        transition.storageClass = COSStorageClass.STANDARD.getStorageClass();
        rule.transition = transition;

        putBucketLifecycleRequest.setRuleList(rule);

        cosXmlService.putBucketLifecycleAsync(putBucketLifecycleRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                PutBucketLifecycleResult putBucketLifecycleResult =
                        (PutBucketLifecycleResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //.cssg-snippet-body-end
    }

    /**
     * 获取存储桶生命周期
     */
    private void getBucketLifecycle() {
        //.cssg-snippet-body-start:[get-bucket-lifecycle]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        GetBucketLifecycleRequest getBucketLifecycleRequest =
                new GetBucketLifecycleRequest(bucket);

        cosXmlService.getBucketLifecycleAsync(getBucketLifecycleRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                GetBucketLifecycleResult getBucketLifecycleResult =
                        (GetBucketLifecycleResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //.cssg-snippet-body-end
    }

    /**
     * 删除存储桶生命周期
     */
    private void deleteBucketLifecycle() {
        //.cssg-snippet-body-start:[delete-bucket-lifecycle]
        // 存储桶名称，由bucketname-appid 组成，appid必须填入，可以在COS控制台查看存储桶名称。 https://console.cloud.tencent.com/cos5/bucket
        String bucket = "examplebucket-1250000000";
        DeleteBucketLifecycleRequest deleteBucketLifecycleRequest =
                new DeleteBucketLifecycleRequest(bucket);

        cosXmlService.deleteBucketLifecycleAsync(deleteBucketLifecycleRequest,
                new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                DeleteBucketLifecycleResult deleteBucketLifecycleResult =
                        (DeleteBucketLifecycleResult) result;
            }

            // 如果您使用 kotlin 语言来调用，请注意回调方法中的异常是可空的，否则不会回调 onFail 方法，即：
            // clientException 的类型为 CosXmlClientException?，serviceException 的类型为 CosXmlServiceException?
            @Override
            public void onFail(CosXmlRequest cosXmlRequest,
                               @Nullable CosXmlClientException clientException,
                               @Nullable CosXmlServiceException serviceException) {
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });

        //.cssg-snippet-body-end
    }
    // .cssg-methods-pragma

    private void initService() {
        // 存储桶region可以在COS控制台指定存储桶的概览页查看 https://console.cloud.tencent.com/cos5/bucket/ ，关于地域的详情见 https://cloud.tencent.com/document/product/436/6224
        String region = "ap-guangzhou";

        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(region)
                .isHttps(true) // 使用 HTTPS 请求，默认为 HTTP 请求
                .builder();

        context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        cosXmlService = new CosXmlService(context, serviceConfig,
                new ServerCredentialProvider());
    }

    @Test
    public void testBucketLifecycle() {
        initService();

        // 设置存储桶生命周期
        putBucketLifecycle();

        // 获取存储桶生命周期
        getBucketLifecycle();

        // 删除存储桶生命周期
        deleteBucketLifecycle();
        // .cssg-methods-pragma

    }
}
