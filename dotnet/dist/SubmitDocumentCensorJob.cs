using COSXML.Model.CI;
using COSXML.Auth;
using System;
using System.Threading;
using COSXML;

namespace COSSnippet
{
    public class SubmitDocumentCensorJobModel {

      private CosXml cosXml;

      SubmitDocumentCensorJobModel() {
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

      /// 提交文档审核任务
      public string SubmitDocumentCensorJob()
      {
        //.cssg-snippet-body-start:[SubmitAudioCensorJob]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        SubmitDocumentCensorJobRequest request = new SubmitDocumentCensorJobRequest(bucket);
        request.SetUrl("url"); // 审核文档的URL，需要替换成具体需要审核的文档URL
        // 审核的场景类型，有效值：Porn（涉黄）、Terrorism（涉暴恐）、Politics（政治敏感）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Terrorism
        request.SetDetectType("Porn,Terrorism");
        // 执行请求
        SubmitCensorJobResult result = cosXml.SubmitDocumentCensorJob(request);
        Console.WriteLine(result.GetResultInfo());
        Console.WriteLine(result.censorJobsResponse.JobsDetail.JobId);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.State);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.CreationTime);
        return result.censorJobsResponse.JobsDetail.JobId;
        //.cssg-snippet-body-end
      }

      /// 查询文档审核任务结果
      public void GetDocumentCensorJobResult(string JobId)
      {
        //.cssg-snippet-body-start:[GetTextCensorJobResult]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        GetDocumentCensorJobRequest request = new GetDocumentCensorJobRequest(bucket, JobId);
        // 执行请求
        GetDocumentCensorJobResult result = cosXml.GetDocumentCensorJob(request);
        Console.WriteLine(result.GetResultInfo());

        // 读取审核结果
        Console.WriteLine(result.resultStruct.JobsDetail.State);
        Console.WriteLine(result.resultStruct.JobsDetail.JobId);
        Console.WriteLine(result.resultStruct.JobsDetail.Suggestion);
        Console.WriteLine(result.resultStruct.JobsDetail.CreationTime);
        Console.WriteLine(result.resultStruct.JobsDetail.Url);
        Console.WriteLine(result.resultStruct.JobsDetail.PageCount);
        Console.WriteLine(result.resultStruct.JobsDetail.Labels);
        Console.WriteLine(result.resultStruct.JobsDetail.Labels.PornInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.Labels.PornInfo.Score);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.Url);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.Text);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.PageNumber);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.PornInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.PornInfo.SubLabel);
        Console.WriteLine(result.resultStruct.JobsDetail.PageSegment.Results.PornInfo.Score);
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        SubmitDocumentCensorJobModel m = new SubmitDocumentCensorJobModel();
        /// 提交审核任务
        string JobId = m.SubmitDocumentCensorJob();
        Thread.Sleep(50000);
        m.GetDocumentCensorJobResult(JobId);
        // .cssg-methods-pragma
      }
    }
}
