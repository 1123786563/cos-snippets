using COSXML.Model.Tag;
using COSXML.Auth;
using COSXML.Transfer;
using System;
using COSXML;
using System.Threading.Tasks;

namespace COSSnippet
{
    public class TransferCopyObjectModel {

      private CosXml cosXml;

      TransferCopyObjectModel() {
        CosXmlConfig config = new CosXmlConfig.Builder()
          .SetRegion("COS_REGION") // 设置默认的区域, COS 地域的简称请参照 https://cloud.tencent.com/document/product/436/6224
          .Build();
        
        string secretId = "SECRET_ID";   // 云 API 密钥 SecretId, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        string secretKey = "SECRET_KEY"; // 云 API 密钥 SecretKey, 获取 API 密钥请参照 https://console.cloud.tencent.com/cam/capi
        long durationSecond = 600;          //每次请求签名有效时长，单位为秒
        QCloudCredentialProvider qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, 
          secretKey, durationSecond);
        
        this.cosXml = new CosXmlServer(config, qCloudCredentialProvider);
      }

      /// 高级接口拷贝对象
      public async Task TransferCopyObject()
      {
        TransferConfig transferConfig = new TransferConfig();
        //手动设置分块复制阈值，小于阈值的对象使用简单复制，大于阈值的对象使用分块复制，不设定则默认为5MB
        transferConfig.DdivisionForCopy = 5242880;
        //手动设置高级接口的自动分块大小，不设定则默认为2MB
        transferConfig.SliceSizeForCopy = 2097152;
        
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXml, transferConfig);

        //.cssg-snippet-body-start:[transfer-copy-object]
        string sourceAppid = "1250000000"; //账号 appid
        string sourceBucket = "sourcebucket-1250000000"; //"源对象所在的存储桶
        string sourceRegion = "COS_REGION"; //源对象的存储桶所在的地域
        string sourceKey = "sourceObject"; //源对象键
        //构造源对象属性
        CopySourceStruct copySource = new CopySourceStruct(sourceAppid, sourceBucket, 
            sourceRegion, sourceKey);

        string bucket = "examplebucket-1250000000"; //目标存储桶，格式：BucketName-APPID
        string key = "exampleobject"; //目标对象的对象键

        COSXMLCopyTask copytask = new COSXMLCopyTask(bucket, key, copySource);
        
        try {
          COSXML.Transfer.COSXMLCopyTask.CopyTaskResult result = await 
            transferManager.CopyAsync(copytask);
          Console.WriteLine(result.GetResultInfo());
          string eTag = result.eTag;
        }
        catch (COSXML.CosException.CosClientException clientEx)
        {
          //请求失败
          Console.WriteLine("CosClientException: " + clientEx);
        }
        catch (COSXML.CosException.CosServerException serverEx)
        {
          //请求失败
          Console.WriteLine("CosServerException: " + serverEx.GetInfo());
        }
        
        //.cssg-snippet-body-end
      }

      // .cssg-methods-pragma

      static void Main(string[] args)
      {
        TransferCopyObjectModel m = new TransferCopyObjectModel();

        /// 高级接口拷贝对象
        m.TransferCopyObject().Wait();
        // .cssg-methods-pragma
      }
    }
}
