//
//  ShareSDKJSBridge.m
//  ShareSDKForJavaScript
//
//  Created by 刘 靖煌 on 15/11/2.
//  Copyright © 2015年 mob.com. All rights reserved.
//

#import "ShareSDKJSBridge.h"
#import <ShareSDK/ShareSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKUI/ShareSDKUI.h>

#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDK/NSMutableDictionary+SSDKShare.h>
#import <ShareSDKExtension/SSEFriendsPaging.h>

#import <ShareSDKConfigFile/ShareSDK+XML.h>
#import <objc/message.h>
static NSString *const initSDKAndSetPlatfromConfig = @"initSDKAndSetPlatfromConfig";
static NSString *const authorize = @"authorize";
static NSString *const cancelAuthorize = @"cancelAuthorize";
static NSString *const isAuthorizedValid = @"isAuthorizedValid";
static NSString *const isClientValid = @"isClientValid";

static NSString *const getUserInfo = @"getUserInfo";
static NSString *const getAuthInfo = @"getAuthInfo";
static NSString *const shareContent = @"shareContent";
static NSString *const oneKeyShareContent = @"oneKeyShareContent";
static NSString *const showShareMenu = @"showShareMenu";

static NSString *const showShareView = @"showShareView";
static NSString *const getFriendList = @"getFriendList";
static NSString *const addFriend = @"addFriend";
static NSString *const shareWithConfigurationFile = @"shareWithConfigurationFile";
static NSString *const showShareMenuWithConfigurationFile = @"showShareMenuWithConfigurationFile";

static NSString *const showShareViewWithConfigurationFile = @"showShareViewWithConfigurationFile";
static ShareSDKJSBridge *_instance = nil;
static UIView *_refView = nil;

#ifdef DEBUG

@interface UIWebView (JavaScriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

@end

@implementation UIWebView (JavaScriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    NSLog(@"%@", message);
}

@end

#endif

@interface ShareSDKJSBridge ()
{
@private
    id<UIWebViewDelegate> _webViewDelegate;
}

@end

@implementation ShareSDKJSBridge



- (id)initWithWebView:(UIWebView *)webView
{
    if (self = [super init])
    {
        _webViewDelegate = webView.delegate;
        webView.delegate = self;
    }
    
    return self;
}

- (BOOL)captureRequest:(NSURLRequest *)request webView:(UIWebView *)webView
{
    if ([request.URL.scheme isEqual:@"sharesdk"])
    {
        if ([request.URL.host isEqual:@"init"])
        {
            //初始化
            [webView stringByEvaluatingJavaScriptFromString:@"window.$sharesdk.initSDK(2)"];
        }
        else if ([request.URL.host isEqual:@"call"])
        {
            //调用接口
            NSDictionary *params = [MOBFString parseURLParametersString:request.URL.query];
            NSString *methodName = [params objectForKey:@"methodName"];
            NSString *seqId = [params objectForKey:@"seqId"];
            
            NSDictionary *paramsDict = nil;
            NSString *paramsStr = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$sharesdk.getParams(%@)",seqId]];
        
            if (paramsStr)
            {
                paramsDict = [MOBFJson objectFromJSONString:paramsStr];
            }
            
            if ([methodName isEqualToString:initSDKAndSetPlatfromConfig])
            {
                //初始化和设置平台信息
                [self openWithSeqId:seqId
                             params:paramsDict
                            webView:webView];
            }
            else if ([methodName isEqualToString:authorize])
            {
                //授权
                [self authorizeWithSeqId:seqId
                                  params:paramsDict
                                 webView:webView];
            }
            else if ([methodName isEqualToString:cancelAuthorize])
            {
                //取消授权
                [self cancelAuthWithSeqId:seqId
                                   params:paramsDict
                                  webView:webView];
            }
            else if ([methodName isEqualToString:isAuthorizedValid])
            {
                //是否授权
                [self hasAuthWithSeqId:seqId
                                params:paramsDict
                               webView:webView];
            }
            else if([methodName isEqualToString:isClientValid])
            {
                //客户端是否安装
                [self isClientInstalledWithSeqId:seqId
                                          params:paramsDict
                                         webView:webView];
            }
            else if ([methodName isEqualToString:getUserInfo])
            {
                //获取用户信息
                [self getUserInfoWithSeqId:seqId
                                    params:paramsDict
                                   webView:webView];
            }
            else if ([methodName isEqualToString:getAuthInfo])
            {
                //获取授权信息
                [self getAuthInfoWithSeqId:seqId
                                    params:paramsDict
                                   webView:webView];
            }
            else if ([methodName isEqualToString:shareContent])
            {
                //分享内容
                [self shareContentWithSeqId:seqId
                                     params:paramsDict
                                    webView:webView];
            }
            else if ([methodName isEqualToString:oneKeyShareContent])
            {
                //一键分享
                [self oneKeyShareContentWithSeqId:seqId
                                           params:paramsDict
                                          webView:webView];
            }
            else if ([methodName isEqualToString:showShareMenu])
            {
                //显示分享菜单
                [self showShareMenuWithSeqId:seqId
                                      params:paramsDict
                                     webView:webView];
            }
            else if ([methodName isEqualToString:showShareView])
            {
                //显示分享视图
                [self showShareViewWithSeqId:seqId
                                      params:paramsDict
                                     webView:webView];
            }
            else if ([methodName isEqualToString:getFriendList])
            {
                //获取好友列表
                [self getFriendListWithSeqId:seqId
                                      params:paramsDict
                                     webView:webView];
            }
            else if ([methodName isEqualToString:addFriend])
            {
                //关注好友
                [self addFriendWithSeqId:seqId
                                  params:paramsDict
                                 webView:webView];
            }
            else if([methodName isEqualToString:shareWithConfigurationFile])
            {
                //使用配置文件分享
                [self shareWithSeqId:seqId
                              params:paramsDict
                             webView:webView];
            }
            else if([methodName isEqualToString:showShareMenuWithConfigurationFile])
            {
                //使用配置文件＋显示分享菜单栏方式分享
                [self shareUsingShareMenuWithSeqId:seqId
                                            params:paramsDict
                                           webView:webView];
            }
            else if ([methodName isEqualToString:showShareViewWithConfigurationFile])
            {
                //使用配置文件＋显示分享编辑方式分享
                [self shareUsingShareViewWithSeqId:seqId
                                            params:paramsDict
                                           webView:webView];
            }
        }
        
        return YES;
    }
    
    return NO;
}

+ (ShareSDKJSBridge *)sharedBridge
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil)
        {
            _instance = [[ShareSDKJSBridge alloc] init];
        }
    });
    return _instance;
}

+ (ShareSDKJSBridge *)bridgeWithWebView:(UIWebView *)webView
{
    return [[ShareSDKJSBridge alloc] initWithWebView:webView];
}

#pragma mark - Private

/**
 *	@brief	返回数据
 *
 *	@param 	data 	回复数据
 */
- (void)resultWithData:(NSDictionary *)data webView:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$sharesdk.callback(%@)", [MOBFJson jsonStringFromObject:data]]];
}

/**
 *	@brief	初始化SDK
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)openWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    NSMutableDictionary *config_tmp = nil;
    
    if ([[params objectForKey:@"platformConfig"] isKindOfClass:[NSDictionary class]])
    {
        config_tmp = [[params objectForKey:@"platformConfig"] mutableCopy];
    }
    
    NSArray *plat = [config_tmp allKeys];
    
    //保存成NSNumber类型
    NSMutableArray *activePlatforms = [NSMutableArray array];
    [plat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSNumber class]])
        {
            NSNumber *platNum = @([[NSString stringWithFormat:@"%@",obj] integerValue]);
            [activePlatforms addObject:platNum];
        }
        else
        {
            [activePlatforms addObject:obj];
        }
    }];
    
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    for (NSNumber *platNum in activePlatforms)
    {
        config[[NSString stringWithFormat:@"%@",platNum]] = [config_tmp[[NSString stringWithFormat:@"%@",platNum]] mutableCopy];
    }
    
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        NSMutableDictionary *dic = platformsRegister.platformsInfo;
        [dic addEntriesFromDictionary:config];
    }];
    
    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : initSDKAndSetPlatfromConfig,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess]};
    [self resultWithData:responseDict webView:webView];
}

/**
 *	@brief	设置平台配置
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)setPlatformConfigWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    NSMutableDictionary *config = nil;
    
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    if ([[params objectForKey:@"config"] isKindOfClass:[NSDictionary class]])
    {
        config = [NSMutableDictionary dictionaryWithDictionary:[params objectForKey:@"config"]];
    }
    
    switch (type)
    {
        case SSDKPlatformSubTypeWechatSession:
            [config setObject:[NSNumber numberWithInt:0] forKey:@"scene"];
            break;
        case SSDKPlatformSubTypeWechatTimeline:
            [config setObject:[NSNumber numberWithInt:1] forKey:@"scene"];
            break;
        case SSDKPlatformSubTypeWechatFav:
            [config setObject:[NSNumber numberWithInt:2] forKey:@"scene"];
            break;
        default:
            break;
    }
    
    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : initSDKAndSetPlatfromConfig,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                   @"platform" : [NSNumber numberWithInteger:type]};
    [self resultWithData:responseDict webView:webView];
}

/**
 *	@brief	用户授权
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)authorizeWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK authorize:type
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             //返回
             NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                                  @"seqId",
                                                  authorize,
                                                  @"method",
                                                  [NSNumber numberWithInteger:state],
                                                  @"state",
                                                  [NSNumber numberWithInteger:type],
                                                  @"platform",
                                                  callback,
                                                  @"callback",
                                                  nil];
             if (error)
             {
                 [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:[error code]],
                                          @"error_code",
                                          [error userInfo],
                                          @"error_msg",
                                          nil]
                                  forKey:@"error"];
             }
             
             [self resultWithData:responseDict webView:webView];
         }];
}

- (void)cancelAuthWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    [ShareSDK cancelAuthorize:type result:nil];
    
    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : cancelAuthorize,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                   @"platform" : [NSNumber numberWithInteger:type]};
    [self resultWithData:responseDict webView:webView];
}

- (void)hasAuthWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    BOOL ret = [ShareSDK hasAuthorized:type];
    
    //返回
    NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                  @"seqId",
                                  isAuthorizedValid,
                                  @"method",
                                  [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                  @"state",
                                  [NSNumber numberWithInteger:type],
                                  @"platform",
                                  [NSNumber numberWithBool:ret],
                                  @"data",
                                  callback,
                                  @"callback",
                                  nil];
    
    [self resultWithData:responseDict webView:webView];
}

- (void)isClientInstalledWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    BOOL ret = [ShareSDK isClientInstalled:type];
    
    //返回
    NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                  @"seqId",
                                  isClientValid,
                                  @"method",
                                  [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                  @"state",
                                  [NSNumber numberWithInteger:type],
                                  @"platform",
                                  [NSNumber numberWithBool:ret],
                                  @"data",
                                  callback,
                                  @"callback",
                                  nil];
    
    [self resultWithData:responseDict webView:webView];
}

- (void)getUserInfoWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK getUserInfo:type
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               //返回
               NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:[seqId integerValue]],
                                                    @"seqId",
                                                    getUserInfo,
                                                    @"method",
                                                    @(state),
                                                    @"state",
                                                    [NSNumber numberWithInteger:type],
                                                    @"platform",
                                                    callback,
                                                    @"callback",
                                                    nil];
               if (error)
               {
                   [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:[error code]],
                                            @"error_code",
                                            [error userInfo],
                                            @"error_msg",
                                            nil]
                                    forKey:@"error"];
               }
               
               if ([user rawData])
               {
                   [responseDict setObject:[user rawData] forKey:@"data"];
               }
               
               [self resultWithData:responseDict webView:webView];
           }];
}

- (void)getAuthInfoWithSeqId:(NSString *)seqId params:(NSDictionary *)params webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK getUserInfo:type
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               //返回
               NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:[seqId integerValue]],
                                                    @"seqId",
                                                    getAuthInfo,
                                                    @"method",
                                                    @(state),
                                                    @"state",
                                                    [NSNumber numberWithInteger:type],
                                                    @"platform",
                                                    callback,
                                                    @"callback",
                                                    nil];
               if (error)
               {
                   [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:[error code]],
                                            @"error_code",
                                            [error userInfo],
                                            @"error_msg",
                                            nil]
                                    forKey:@"error"];
               }
               
               NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
               
               if (user.credential)
               {
                   if (user.credential.uid)
                   {
                       [authInfo setObject:user.credential.uid forKey:@"uid"];
                   }
                   
                   if (user.credential.token)
                   {
                       [authInfo setObject:user.credential.token forKey:@"access_token"];
                   }
                   
                   if (user.credential.expired)
                   {
                       [authInfo setObject:@(user.credential.expired) forKey:@"expires_in"];
                   }
               }
               
               if ([user rawData])
               {
                   [responseDict setObject:authInfo forKey:@"data"];
               }
               
               [self resultWithData:responseDict webView:webView];
           }];
}


-(NSUInteger)convertJSShareTypeToIOSShareType:(NSUInteger)JSShareType
{
    switch (JSShareType)
    {
        case 1:
            return SSDKContentTypeText;
        case 2:
        case 9:
            return SSDKContentTypeImage;
        case 4:
            return SSDKContentTypeWebPage;
        case 5:
            return SSDKContentTypeAudio;
        case 6:
            return SSDKContentTypeVideo;
        case 7:
            return SSDKContentTypeApp;
        case 0:
        case 8:
            return SSDKContentTypeAuto;
        case 10:
            return SSDKContentTypeMiniProgram;
        default:
            return SSDKContentTypeAuto;
            break;
    }
}

- (NSMutableDictionary *)contentWithDict:(NSDictionary *)dict
{
    NSString *message = nil;
    id image = nil;
    NSString *title = nil;
    NSString *url = nil;
    NSString *desc = nil;
    SSDKContentType type = SSDKContentTypeAuto;
    BOOL clientShare = NO;
    BOOL advancedShare = NO;

    BOOL sina_linkCard = NO;
    NSString *sina_cardTitle = nil;
    NSString *sina_cardSummary = nil;

    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    
    if (dict)
    {
        if ([[dict objectForKey:@"text"] isKindOfClass:[NSString class]])
        {
            message = [dict objectForKey:@"text"];
        }
        
        if ([dict objectForKey:@"imageUrl"])
        {
            image = [dict objectForKey:@"imageUrl"];
        }
        
        if ([[dict objectForKey:@"title"] isKindOfClass:[NSString class]])
        {
            title = [dict objectForKey:@"title"];
        }
        
        if ([[dict objectForKey:@"titleUrl"] isKindOfClass:[NSString class]])
        {
            url = [dict objectForKey:@"titleUrl"];
        }
        
        if ([[dict objectForKey:@"description"] isKindOfClass:[NSString class]])
        {
            desc = [dict objectForKey:@"description"];
        }
        
        if ([[dict objectForKey:@"client_share"] isKindOfClass:[NSNumber class]])
        {
            clientShare = [[dict objectForKey:@"client_share"] boolValue];
        }
        
        if ([[dict objectForKey:@"advanced_share"] isKindOfClass:[NSNumber class]])
        {
            advancedShare = [[dict objectForKey:@"advanced_share"] boolValue];
        }
        
        if ([[dict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
        {
            type = [self convertJSShareTypeToIOSShareType:[[dict objectForKey:@"type"] unsignedIntegerValue]];
        }

        if ([[dict objectForKey:@"sina_linkCard"] isKindOfClass:[NSNumber class]] && [[dict objectForKey:@"sina_linkCard"] unsignedIntegerValue] > 0)
        {
            sina_linkCard = YES;
        }

        if ([[dict objectForKey:@"sina_cardTitle"] isKindOfClass:[NSString class]])
        {
            sina_cardTitle = [dict objectForKey:@"sina_cardTitle"];
        }

        if ([[dict objectForKey:@"sina_cardSummary"] isKindOfClass:[NSString class]])
        {
            sina_cardSummary = [dict objectForKey:@"sina_cardSummary"];
        }

    }
    
    [para SSDKSetupShareParamsByText:message
                              images:image
                                 url:[NSURL URLWithString:url]
                               title:title
                                type:type];

    if (sina_linkCard == YES)
    {
      [para setObject:@(sina_linkCard) forKey:@"sina_linkCard"];
      [para setObject:[MobSDK appKey] forKey:@"mob_appkey"];
      if (sina_cardTitle != nil)
      {
        [para setObject:sina_cardTitle forKey:@"sina_cardTitle"];
      }
      if (sina_cardSummary != nil)
      {
        [para setObject:sina_cardSummary forKey:@"sina_cardSummary"];
      }
    }

    if (dict)
    {
        NSString *siteUrlStr = nil;
        NSString *siteStr = nil;
        
        NSString *siteUrl = [dict objectForKey:@"siteUrl"];
        if ([siteUrl isKindOfClass:[NSString class]])
        {
            siteUrlStr = siteUrl;
        }
        
        NSString *site = [dict objectForKey:@"site"];
        if ([site isKindOfClass:[NSString class]])
        {
            siteStr = site;
        }
    }
    
    return para;
}

- (void)shareContentWithSeqId:(NSString *)seqId
                       params:(NSDictionary *)params
                      webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    NSLog(@"%@",content);
    [ShareSDK share:type
         parameters:content
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         
         //返回
         NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:[seqId integerValue]],
                                              @"seqId",
                                              shareContent,
                                              @"method",
                                              [NSNumber numberWithInteger:state],
                                              @"state",
                                              [NSNumber numberWithInteger:type],
                                              @"platform",
                                              callback,
                                              @"callback",
                                              nil];
         if (error)
         {
             NSLog(@"%@",error);
             [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:[error code]],
                                      @"error_code",
                                      [error userInfo],
                                      @"error_msg",
                                      nil]
                              forKey:@"error"];
         }
         
         if ([contentEntity rawData])
         {
             [responseDict setObject:[contentEntity rawData] forKey:@"data"];
         }
         
         [self resultWithData:responseDict webView:webView];
     }];
}

- (void)shareUsingShareMenuWithSeqId:(NSString *)seqId
                              params:(NSDictionary *)params
                             webView:(UIWebView *)webView
{
    NSArray *types = nil;
    if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
    {
        types = [params objectForKey:@"platforms"];
    }
    
    CGFloat x = 0;
    if ([[params objectForKey:@"x"] isKindOfClass:[NSNumber class]])
    {
        x = [[params objectForKey:@"x"] floatValue];
    }
    
    CGFloat y = 0;
    if ([[params objectForKey:@"y"] isKindOfClass:[NSNumber class]])
    {
        y = [[params objectForKey:@"y"] floatValue];
    }
    
    UIViewController *vc = [MOBFViewController currentViewController];
    if ([MOBFDevice isPad])
    {
        if (!_refView)
        {
            _refView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 1, 1)];
        }
        else
        {
            _refView.frame = CGRectMake(x, y, 1, 1);
        }
        
        [vc.view addSubview:_refView];
    }
    
    NSString *contentName = nil;
    if ([[params objectForKey:@"contentName"] isKindOfClass:[NSString class]])
    {
        contentName = [params objectForKey:@"contentName"];
    }

    NSMutableDictionary *customFields = nil;
    if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
    {
        customFields = [params objectForKey:@"customFields"];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    NSDictionary *shareParams = [ShareSDK getShareParamsWithContentName:contentName customFields:customFields];
    
    [ShareSDK showShareActionSheet:_refView
                       customItems:types
                       shareParams:shareParams.mutableCopy
                sheetConfiguration:nil
                    onStateChanged:^(SSDKResponseState state,
                                     SSDKPlatformType platformType,
                                     NSDictionary *userData,
                                     SSDKContentEntity *contentEntity,
                                     NSError *error, BOOL end) {
        //返回
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:[seqId integerValue]],
                                             @"seqId",
                                             showShareMenu,
                                             @"method",
                                             [NSNumber numberWithInteger:state],
                                             @"state",
                                             [NSNumber numberWithInteger:platformType],
                                             @"platform",
                                             [NSNumber numberWithBool:end],
                                             @"end",
                                             callback,
                                             @"callback",
                                             nil];
        if (error)
        {
            [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:[error code]],
                                     @"error_code",
                                     [error userInfo],
                                     @"error_msg",
                                     nil]
                             forKey:@"error"];
        }
        
        if ([contentEntity rawData])
        {
            [responseDict setObject:[contentEntity rawData] forKey:@"data"];
        }
        
        [self resultWithData:responseDict webView:webView];
        
        if (_refView)
        {
            [_refView removeFromSuperview];
        }
    }];
}

- (void)shareUsingShareViewWithSeqId:(NSString *)seqId
                              params:(NSDictionary *)params
                             webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSString *contentName = nil;
    if ([[params objectForKey:@"contentName"] isKindOfClass:[NSString class]])
    {
        contentName = [params objectForKey:@"contentName"];
    }
    
    NSMutableDictionary *customFields = nil;
    if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
    {
        customFields = [params objectForKey:@"customFields"];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    NSDictionary *shareParams = [ShareSDK getShareParamsWithContentName:contentName customFields:customFields];
    [ShareSDK showShareEditor:type
               otherPlatforms:nil
                  shareParams:shareParams.mutableCopy
          editorConfiguration:nil
               onStateChanged:^(SSDKResponseState state,
                                SSDKPlatformType platformType,
                                NSDictionary *userData,
                                SSDKContentEntity *contentEntity,
                                NSError *error,
                                BOOL end) {
        
        //返回
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:[seqId integerValue]],
                                             @"seqId",
                                             showShareView,
                                             @"method",
                                             [NSNumber numberWithInteger:state],
                                             @"state",
                                             @(platformType),
                                             @"platform",
                                             [NSNumber numberWithBool:end],
                                             @"end",
                                             callback,
                                             @"callback",
                                             nil];
        if (error)
        {
            [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:[error code]],
                                     @"error_code",
                                     [error userInfo],
                                     @"error_msg",
                                     nil]
                             forKey:@"error"];
        }
        
        if ([contentEntity rawData])
        {
            [responseDict setObject:[contentEntity rawData] forKey:@"data"];
        }
        
        [self resultWithData:responseDict webView:webView];
    }];
}

- (void)shareWithSeqId:(NSString *)seqId
                params:(NSDictionary *)params
               webView:(UIWebView *)webView
{
    NSString *contentName = nil;
    if ([[params objectForKey:@"contentName"] isKindOfClass:[NSString class]])
    {
        contentName = [params objectForKey:@"contentName"];
    }
    
    SSDKPlatformType type = SSDKPlatformTypeAny;
    
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSMutableDictionary *customFields = nil;
    if ([[params objectForKey:@"customFields"] isKindOfClass:[NSDictionary class]])
    {
        customFields = [params objectForKey:@"customFields"];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK shareWithContentName:contentName
                          platform:type
                      customFields:customFields
                    onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                        //返回
                        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithInteger:[seqId integerValue]],
                                                             @"seqId",
                                                             shareContent,
                                                             @"method",
                                                             [NSNumber numberWithInteger:state],
                                                             @"state",
                                                             [NSNumber numberWithInteger:type],
                                                             @"platform",
                                                             callback,
                                                             @"callback",
                                                             nil];
                        if (error)
                        {
                            [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithInteger:[error code]],
                                                     @"error_code",
                                                     [error userInfo],
                                                     @"error_msg",
                                                     nil]
                                             forKey:@"error"];
                        }
                        
                        if ([contentEntity rawData])
                        {
                            [responseDict setObject:[contentEntity rawData] forKey:@"data"];
                        }
                        
                        [self resultWithData:responseDict webView:webView];
                    }];
}

- (void)oneKeyShareContentWithSeqId:(NSString *)seqId
                             params:(NSDictionary *)params
                            webView:(UIWebView *)webView
{
    NSLog(@"Method deprecate !");
}

- (void)showShareMenuWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       webView:(UIWebView *)webView
{
    NSArray *types = nil;
    if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
    {
        types = [params objectForKey:@"platforms"];
    }
    
    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }
    
    CGFloat x = 0;
    if ([[params objectForKey:@"x"] isKindOfClass:[NSNumber class]])
    {
        x = [[params objectForKey:@"x"] floatValue];
    }
    
    CGFloat y = 0;
    if ([[params objectForKey:@"y"] isKindOfClass:[NSNumber class]])
    {
        y = [[params objectForKey:@"y"] floatValue];
    }

    UIViewController *vc = [MOBFViewController currentViewController];
    if ([MOBFDevice isPad])
    {
        if (!_refView)
        {
            _refView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 1, 1)];
        }
        else
        {
            _refView.frame = CGRectMake(x, y, 1, 1);
        }
        
        [vc.view addSubview:_refView];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK showShareActionSheet:_refView customItems:types shareParams:content sheetConfiguration:nil onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        //返回
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:[seqId integerValue]],
                                             @"seqId",
                                             showShareMenu,
                                             @"method",
                                             [NSNumber numberWithInteger:state],
                                             @"state",
                                             [NSNumber numberWithInteger:platformType],
                                             @"platform",
                                             [NSNumber numberWithBool:end],
                                             @"end",
                                             callback,
                                             @"callback",
                                             nil];
        if (error)
        {
            [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:[error code]],
                                     @"error_code",
                                     [error userInfo],
                                     @"error_msg",
                                     nil]
                             forKey:@"error"];
        }
        
        if ([contentEntity rawData])
        {
            [responseDict setObject:[contentEntity rawData] forKey:@"data"];
        }
        
        [self resultWithData:responseDict webView:webView];
        
        if (_refView)
        {
            [_refView removeFromSuperview];
        }
    }];
}

- (void)showShareViewWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK showShareEditor:type otherPlatforms:nil shareParams:content editorConfiguration:nil onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        //返回
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:[seqId integerValue]],
                                             @"seqId",
                                             showShareView,
                                             @"method",
                                             [NSNumber numberWithInteger:state],
                                             @"state",
                                             @(platformType),
                                             @"platform",
                                             [NSNumber numberWithBool:end],
                                             @"end",
                                             callback,
                                             @"callback",
                                             nil];
        if (error)
        {
            [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:[error code]],
                                     @"error_code",
                                     [error userInfo],
                                     @"error_msg",
                                     nil]
                             forKey:@"error"];
        }
        
        if ([contentEntity rawData])
        {
            [responseDict setObject:[contentEntity rawData] forKey:@"data"];
        }
        
        [self resultWithData:responseDict webView:webView];
    }];
}

- (void)getFriendListWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    NSUInteger page = 1;
    if ([params objectForKey:@"page"])
    {
        page = [[params objectForKey:@"page"] unsignedIntegerValue];
    }
    
    NSUInteger count = 10;
    if ([params objectForKey:@"count"])
    {
        count = [[params objectForKey:@"count"] unsignedIntegerValue];
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }
    
    [ShareSDK getFriends:type
                  cursor:page
                    size:count
          onStateChanged:^(SSDKResponseState state, SSEFriendsPaging *paging, NSError *error) {
              
              //返回
              NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInteger:[seqId integerValue]],
                                                   @"seqId",
                                                   getFriendList,
                                                   @"method",
                                                   [NSNumber numberWithInteger:state],
                                                   @"state",
                                                   [NSNumber numberWithInteger:type],
                                                   @"platform",
                                                   callback,
                                                   @"callback",
                                                   nil];
              if (error)
              {
                  [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:[error code]],
                                           @"error_code",
                                           [error userInfo],
                                           @"error_msg",
                                           nil]
                                   forKey:@"error"];
              }
              
              if (paging.users)
              {
                  [responseDict setObject:paging.users forKey:@"data"];
              }
              
              [self resultWithData:responseDict webView:webView];
          }];
}

- (void)addFriendWithSeqId:(NSString *)seqId
                    params:(NSDictionary *)params
                   webView:(UIWebView *)webView
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    
    SSDKUser *user = [[SSDKUser alloc] init];
    
    if ([[params objectForKey:@"friendName"] isKindOfClass:[NSString class]])
    {
        if (type == SSDKPlatformTypeTencentWeibo)
        {
            user.nickname = [params objectForKey:@"friendName"];
        }
        else
        {
            user.uid = [params objectForKey:@"friendName"];
        }
    }
    
    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK addFriend:type
                   user:user
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             //返回
             NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                                  @"seqId",
                                                  addFriend,
                                                  @"method",
                                                  [NSNumber numberWithInteger:state],
                                                  @"state",
                                                  [NSNumber numberWithInteger:type],
                                                  @"platform",
                                                  callback,
                                                  @"callback",
                                                  nil];
             if (error)
             {
                 [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:[error code]],
                                          @"error_code",
                                          [error userInfo],
                                          @"error_msg",
                                          nil]
                                  forKey:@"error"];
             }
             
             if (user.rawData)
             {
                 [responseDict setObject:user.rawData forKey:@"data"];
             }
             
             [self resultWithData:responseDict webView:webView];
         }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([self captureRequest:request webView:webView])
    {
        //捕获请求
        return NO;
    }
    
    if ([_webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        return [_webViewDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [_webViewDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [_webViewDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [_webViewDelegate webView:webView didFailLoadWithError:error];
    }
}


@end

__attribute__((constructor)) static void _SSDKJavaScriptiOSApplicationExcImp(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL sel = sel_registerName("addChannelWithSdkName:channel:");
        Method method = class_getClassMethod([MobSDK class],sel) ;
        if (method && method_getImplementation(method) != _objc_msgForward) {
        ((void (*)(id, SEL,id,id))objc_msgSend)([MobSDK class],sel,@"SHARESDK",@"3");
        }
    });
}
