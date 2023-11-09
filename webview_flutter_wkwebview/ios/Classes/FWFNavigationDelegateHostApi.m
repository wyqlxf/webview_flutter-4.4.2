// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFNavigationDelegateHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFNavigationDelegateFlutterApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (long)identifierForDelegate:(FWFNavigationDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)didFinishNavigationForDelegate:(FWFNavigationDelegate *)instance
                               webView:(WKWebView *)webView
                                   URL:(NSString *)URL
                            completion:(void (^)(FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  [self didFinishNavigationForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                                   webViewIdentifier:webViewIdentifier
                                                 URL:URL
                                          completion:completion];
}

- (void)didStartProvisionalNavigationForDelegate:(FWFNavigationDelegate *)instance
                                         webView:(WKWebView *)webView
                                             URL:(NSString *)URL
                                      completion:(void (^)(FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  [self didStartProvisionalNavigationForDelegateWithIdentifier:@([self
                                                                   identifierForDelegate:instance])
                                             webViewIdentifier:webViewIdentifier
                                                           URL:URL
                                                    completion:completion];
}

- (void)
    decidePolicyForNavigationActionForDelegate:(FWFNavigationDelegate *)instance
                                       webView:(WKWebView *)webView
                              navigationAction:(WKNavigationAction *)navigationAction
                                    completion:
                                        (void (^)(FWFWKNavigationActionPolicyEnumData *_Nullable,
                                                  FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  FWFWKNavigationActionData *navigationActionData =
      FWFWKNavigationActionDataFromNativeWKNavigationAction(navigationAction);
  [self
      decidePolicyForNavigationActionForDelegateWithIdentifier:@([self
                                                                   identifierForDelegate:instance])
                                             webViewIdentifier:webViewIdentifier
                                              navigationAction:navigationActionData
                                                    completion:completion];
}

- (void)didFailNavigationForDelegate:(FWFNavigationDelegate *)instance
                             webView:(WKWebView *)webView
                               error:(NSError *)error
                          completion:(void (^)(FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  [self didFailNavigationForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                                 webViewIdentifier:webViewIdentifier
                                             error:FWFNSErrorDataFromNativeNSError(error)
                                        completion:completion];
}

- (void)didFailProvisionalNavigationForDelegate:(FWFNavigationDelegate *)instance
                                        webView:(WKWebView *)webView
                                          error:(NSError *)error
                                     completion:(void (^)(FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  [self
      didFailProvisionalNavigationForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                                          webViewIdentifier:webViewIdentifier
                                                      error:FWFNSErrorDataFromNativeNSError(error)
                                                 completion:completion];
}

- (void)webViewWebContentProcessDidTerminateForDelegate:(FWFNavigationDelegate *)instance
                                                webView:(WKWebView *)webView
                                             completion:
                                                 (void (^)(FlutterError *_Nullable))completion {
  NSNumber *webViewIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:webView]);
  [self webViewWebContentProcessDidTerminateForDelegateWithIdentifier:
            @([self identifierForDelegate:instance])
                                                    webViewIdentifier:webViewIdentifier
                                                           completion:completion];
}
@end

// mychange
@interface FWFNavigationDelegate ()
// url need Parameter.
@property(nonatomic, strong) NSMutableDictionary *needBaseParameter;
@end

@implementation FWFNavigationDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _navigationDelegateAPI =
        [[FWFNavigationDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];
  }
  return self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [self.navigationDelegateAPI didFinishNavigationForDelegate:self
                                                     webView:webView
                                                         URL:webView.URL.absoluteString
                                                  completion:^(FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                  }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [self.navigationDelegateAPI didStartProvisionalNavigationForDelegate:self
                                                               webView:webView
                                                                   URL:webView.URL.absoluteString
                                                            completion:^(FlutterError *error) {
                                                              NSAssert(!error, @"%@", error);
                                                            }];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // mychange
    NSURL *originalURL = navigationAction.request.URL;
    NSString *originalURLString = originalURL.absoluteString;
    NSLog(@"WebLog：原始url = %@", originalURLString);
    // 根据传入的URL判断是否为591域名
    if (![originalURL.host containsString:@"www.facebook.com/sharer/sharer.php?u="] && ![originalURL.host containsString:@"whatsapp://send"] && [originalURL.host containsString:@"591.com.hk"]) {
        if(!self.needBaseParameter){
            NSLog(@"WebLog：needBaseParameter = 初始化"); // 只会初始化一次
            self.needBaseParameter = [[NSMutableDictionary alloc]init];
            self.needBaseParameter[@"project"] = @"";
            self.needBaseParameter[@"device"] = @"";
            self.needBaseParameter[@"idcode"] = @"";
            self.needBaseParameter[@"app_id"] = @"";
            self.needBaseParameter[@"version"] = @"";
            self.needBaseParameter[@"status_bar_height"] = @"";
            self.needBaseParameter[@"hide_app_bar"] = @"";
        }

        // 记录基础参数
        if(self.needBaseParameter){
            // url中的参数
            NSDictionary *currentUrlParameter = [self getParametersWithUrlStr:originalURLString];
            NSArray *currentUrlKeyArr = self.needBaseParameter.allKeys;
            // 需要的参数
            NSArray *needBaseParameter = @[@"project",@"device",@"idcode",@"app_id",@"version",@"status_bar_height",@"hide_app_bar"];
            // 添加
            [currentUrlKeyArr enumerateObjectsUsingBlock:^(NSString *keyStr, NSUInteger idx, BOOL * _Nonnull stop) {
               // 需要的参数在url中是否存在，存在则记录
                if([needBaseParameter containsObject:keyStr]){
                    NSString *valueStr = [NSString stringWithFormat:@"%@", currentUrlParameter[keyStr]];
                    if(valueStr.length > 0 && ![valueStr containsString:@"null"]){
                        self.needBaseParameter[keyStr] = valueStr;
                        //NSLog(@"WebLog：添加基础参数 = %@", keyStr);
                    }

                }
           }];

        }

        //NSLog(@"WebLog：记录基础参数 = %@", self.needBaseParameter);
        NSArray *recordBaseArr = self.needBaseParameter.allKeys;
        NSMutableDictionary *addDic = [[NSMutableDictionary alloc]init];
        if(recordBaseArr.count >0){
            // 检查URL中没有包含哪些必须参数，给他加上
            [recordBaseArr enumerateObjectsUsingBlock:^(NSString *recordKeyStr, NSUInteger idx, BOOL * _Nonnull stop) {
                if(![originalURLString containsString:recordKeyStr]){
                    addDic[recordKeyStr] = [NSString stringWithFormat:@"%@", self.needBaseParameter[recordKeyStr]];
                }
            }];
        }

        if(addDic.count > 0){
            NSLog(@"WebLog：记录基础参数 = %@", self.needBaseParameter);
            NSLog(@"WebLog：需要添加的基础参数 = %@", addDic);
            NSLog(@"WebLog：添加基础参-前Url = %@", originalURLString);
            // 取消导航
            decisionHandler(WKNavigationActionPolicyCancel);
            NSString *newUrlStr = [self handeUrl:originalURLString addParameters:addDic];
            NSLog(@"WebLog：添加基础参-后Url = %@", newUrlStr);
            NSURL *newURL = [NSURL URLWithString:newUrlStr];
            NSMutableURLRequest *modifiedRequest = [navigationAction.request mutableCopy];
            modifiedRequest.URL = newURL;
            [webView loadRequest:modifiedRequest];
            return;
        }else{
//            decisionHandler(WKNavigationActionPolicyAllow);
            // 原逻辑
            NSLog(@"WebLog：原逻-1");
            [self.navigationDelegateAPI
                decidePolicyForNavigationActionForDelegate:self
                                                   webView:webView
                                          navigationAction:navigationAction
                                                completion:^(FWFWKNavigationActionPolicyEnumData *policy,
                                                             FlutterError *error) {
                                                  NSAssert(!error, @"%@", error);
                                                  decisionHandler(
                                                      FWFNativeWKNavigationActionPolicyFromEnumData(policy));
                                                }];
        }


    }else{
       // 原逻辑
        NSLog(@"WebLog：原逻-2");
        [self.navigationDelegateAPI
            decidePolicyForNavigationActionForDelegate:self
                                               webView:webView
                                      navigationAction:navigationAction
                                            completion:^(FWFWKNavigationActionPolicyEnumData *policy,
                                                         FlutterError *error) {
                                              NSAssert(!error, @"%@", error);
                                              decisionHandler(
                                                  FWFNativeWKNavigationActionPolicyFromEnumData(policy));
                                            }];
    }
    
  
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [self.navigationDelegateAPI didFailNavigationForDelegate:self
                                                   webView:webView
                                                     error:error
                                                completion:^(FlutterError *error) {
                                                  NSAssert(!error, @"%@", error);
                                                }];
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [self.navigationDelegateAPI didFailProvisionalNavigationForDelegate:self
                                                              webView:webView
                                                                error:error
                                                           completion:^(FlutterError *error) {
                                                             NSAssert(!error, @"%@", error);
                                                           }];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  [self.navigationDelegateAPI
      webViewWebContentProcessDidTerminateForDelegate:self
                                              webView:webView
                                           completion:^(FlutterError *error) {
                                             NSAssert(!error, @"%@", error);
                                           }];
}
    
#pragma mark - 解析url中的参数
- (NSDictionary *)getParametersWithUrlStr:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    // 使用 NSURLComponents 解析 URL
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    // 获取查询参数部分
    NSArray *queryItems = urlComponents.queryItems;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    // 遍历查询参数并输出
    for (NSURLQueryItem *queryItem in queryItems) {
        NSString *key = [NSString stringWithFormat:@"%@",queryItem.name];
        NSString *value = [NSString stringWithFormat:@"%@",queryItem.value];
        parameters[key] = value;
    }
//    NSLog(@"解析网址中的参数 = %@", parameters);
    return parameters;
}
 

#pragma mark - url拼接参数
- (NSString *)handeUrl:(NSString *)baseUrlStr addParameters:(NSDictionary *)newParameters{
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:baseUrlStr];
    NSMutableArray *queryItems = [NSMutableArray array];
    // 保留现有url参数
    if(urlComponents.queryItems.count > 0){
        [queryItems addObjectsFromArray:urlComponents.queryItems];
    }
    // 添加新参数
    for (NSString *key in newParameters.allKeys) {
        NSString *value = [NSString stringWithFormat:@"%@",newParameters[key]];
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:value];
        [queryItems addObject:queryItem];
    }
    urlComponents.queryItems = queryItems;
    NSURL *finalUrl = urlComponents.URL;
//    NSLog(@"url拼接参数后 = %@", finalUrl.absoluteString);
    return finalUrl.absoluteString;
}

@end

@interface FWFNavigationDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFNavigationDelegate *)navigationDelegateForIdentifier:(NSNumber *)identifier {
  return (FWFNavigationDelegate *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFNavigationDelegate *navigationDelegate =
      [[FWFNavigationDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:navigationDelegate
                                withIdentifier:identifier.longValue];
}
@end
