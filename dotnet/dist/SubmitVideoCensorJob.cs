using COSXML.Model.CI;
using COSXML.Auth;
using System;
using System.Threading;
using COSXML;

namespace COSSnippet
{
    public class SubmitVideoCensorJobModel {

      private CosXml cosXml;

      SubmitVideoCensorJobModel() {
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

      /// 提交视频审核任务
      public string SubmitVideoCensorJob()
      {
        //.cssg-snippet-body-start:[SubmitVideoCensorJob]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        SubmitVideoCensorJobRequest request = new SubmitVideoCensorJobRequest(bucket);
        request.SetCensorObject("video.mp4"); // 媒体文件的对象键，需要替换成桶内存在的媒体文件的对象键
        // 审核的场景类型，有效值：Porn（涉黄）、Terrorism（涉暴恐）、Politics（政治敏感）、Ads（广告），可以传入多种类型，不同类型以逗号分隔，例如：Porn,Terrorism
        request.SetDetectType("Porn,Terrorism");
        // 视频画面的审核通过视频截帧能力截取出一定量的截图，通过对截图逐一审核而实现的，该参数用于指定视频截帧的配置。
        request.SetSnapshotMode("Average"); // 截帧模式。Interval 表示间隔模式；Average 表示平均模式；Fps 表示固定帧率模式。
        request.SetSnapshotCount("100"); // 视频截帧数量，范围为(0, 10000]
        request.SetSnapshotTimeInterval("1.0"); // 视频截帧频率，范围为(0, 60]，单位为秒，支持 float 格式，执行精度精确到毫秒
        // 执行请求
        SubmitCensorJobResult result = cosXml.SubmitVideoCensorJob(request);
        Console.WriteLine(result.GetResultInfo());
        Console.WriteLine(result.censorJobsResponse.JobsDetail.JobId);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.State);
        Console.WriteLine(result.censorJobsResponse.JobsDetail.CreationTime);
        return result.censorJobsResponse.JobsDetail.JobId;
        //.cssg-snippet-body-end
      }

      /// 查询视频审核任务结果
      public void GetVideoCensorJobResult(string JobId)
      {
        //.cssg-snippet-body-start:[GetVideoCensorJobResult]
        // 存储桶名称，此处填入格式必须为 bucketname-APPID, 其中 APPID 获取参考 https://console.cloud.tencent.com/developer
        string bucket = "examplebucket-1250000000"; // 注意：此操作需要 bucket 开通内容审核相关功能
        GetVideoCensorJobRequest request = new GetVideoCensorJobRequest(bucket, JobId);
        // 执行请求
        GetVideoCensorJobResult result = cosXml.GetVideoCensorJob(request);
        Console.WriteLine(result.GetResultInfo());

        // 读取审核结果
        Console.WriteLine(result.resultStruct.JobsDetail.JobId);
        Console.WriteLine(result.resultStruct.JobsDetail.State);
        Console.WriteLine(result.resultStruct.JobsDetail.CreationTime);
        Console.WriteLine(result.resultStruct.JobsDetail.Object);
        Console.WriteLine(result.resultStruct.JobsDetail.SnapshotCount);
        Console.WriteLine(result.resultStruct.JobsDetail.Result);

        Console.WriteLine(result.resultStruct.JobsDetail.PornInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.PornInfo.Count);
                
        Console.WriteLine(result.resultStruct.JobsDetail.TerrorismInfo.HitFlag);
        Console.WriteLine(result.resultStruct.JobsDetail.TerrorismInfo.Count);

        // 审核视频截图内容
        for(int i = 0; i < result.resultStruct.JobsDetail.Snapshot.Count; i++)
        {
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].Url);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].Text);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].SnapshotTime);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].PornInfo.HitFlag);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].PornInfo.Score);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].PornInfo.Label);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].PornInfo.SubLabel);

            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].TerrorismInfo.HitFlag);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].TerrorismInfo.Score);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].TerrorismInfo.Label);
            Console.WriteLine(result.resultStruct.JobsDetail.Snapshot[i].TerrorismInfo.SubLabel);
        }
        //.cssg-snippet-body-end
      }

      static void Main(string[] args)
      {
        SubmitVideoCensorJobModel m = new SubmitVideoCensorJobModel();
        /// 提交审核任务
        string JobId = m.SubmitVideoCensorJob();
        Thread.Sleep(120000);
        m.GetVideoCensorJobResult(JobId);
        // .cssg-methods-pragma
      }
    }
}
