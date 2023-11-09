// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFUIDelegateHostApi.h"
#import "FWFDataConverters.h"
#import <UIKit/UIKit.h>
@interface FWFUIDelegateFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFUIDelegateFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
    _webViewConfigurationFlutterApi =
        [[FWFWebViewConfigurationFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                               instanceManager:instanceManager];
  }
  return self;
}

- (long)identifierForDelegate:(FWFUIDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)onCreateWebViewForDelegate:(FWFUIDelegate *)instance
                           webView:(WKWebView *)webView
                     configuration:(WKWebViewConfiguration *)configuration
                  navigationAction:(WKNavigationAction *)navigationAction
                        completion:(void (^)(FlutterError *_Nullable))completion {
  if (![self.instanceManager containsInstance:configuration]) {
    [self.webViewConfigurationFlutterApi createWithConfiguration:configuration
                                                      completion:^(FlutterError *error) {
                                                        NSAssert(!error, @"%@", error);
                                                      }];
  }

  NSNumber *configurationIdentifier =
      @([self.instanceManager identifierWithStrongReferenceForInstance:configuration]);
  FWFWKNavigationActionData *navigationActionData =
      FWFWKNavigationActionDataFromNativeWKNavigationAction(navigationAction);

  [self onCreateWebViewForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                               webViewIdentifier:
                                   @([self.instanceManager
                                       identifierWithStrongReferenceForInstance:webView])
                         configurationIdentifier:configurationIdentifier
                                navigationAction:navigationActionData
                                      completion:completion];
}

- (void)requestMediaCapturePermissionForDelegateWithIdentifier:(FWFUIDelegate *)instance
                                                       webView:(WKWebView *)webView
                                                        origin:(WKSecurityOrigin *)origin
                                                         frame:(WKFrameInfo *)frame
                                                          type:(WKMediaCaptureType)type
                                                    completion:
                                                        (void (^)(WKPermissionDecision))completion
    API_AVAILABLE(ios(15.0)) {
  [self
      requestMediaCapturePermissionForDelegateWithIdentifier:@([self
                                                                 identifierForDelegate:instance])
                                           webViewIdentifier:
                                               @([self.instanceManager
                                                   identifierWithStrongReferenceForInstance:
                                                       webView])
                                                      origin:
                                                          FWFWKSecurityOriginDataFromNativeWKSecurityOrigin(
                                                              origin)
                                                       frame:
                                                           FWFWKFrameInfoDataFromNativeWKFrameInfo(
                                                               frame)
                                                        type:
                                                            FWFWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
                                                                type)
                                                  completion:^(
                                                      FWFWKPermissionDecisionData *decision,
                                                      FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                    completion(
                                                        FWFNativeWKPermissionDecisionFromData(
                                                            decision));
                                                  }];
}
@end

@implementation FWFUIDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _UIDelegateAPI = [[FWFUIDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                                  instanceManager:instanceManager];
  }
  return self;
}

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  [self.UIDelegateAPI onCreateWebViewForDelegate:self
                                         webView:webView
                                   configuration:configuration
                                navigationAction:navigationAction
                                      completion:^(FlutterError *error) {
                                        NSAssert(!error, @"%@", error);
                                      }];
  return nil;
}

- (void)webView:(WKWebView *)webView
    requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin
                          initiatedByFrame:(WKFrameInfo *)frame
                                      type:(WKMediaCaptureType)type
                           decisionHandler:(void (^)(WKPermissionDecision))decisionHandler
    API_AVAILABLE(ios(15.0)) {
  [self.UIDelegateAPI
      requestMediaCapturePermissionForDelegateWithIdentifier:self
                                                     webView:webView
                                                      origin:origin
                                                       frame:frame
                                                        type:type
                                                  completion:^(WKPermissionDecision decision) {
                                                    decisionHandler(decision);
                                                  }];
}
// mychange：处理网页弹窗
//alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    if (!message || message.length == 0) {
        completionHandler();
        return;
    }
    // 创建UIAlertController并显示alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"溫馨提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"返回"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(); // 完成处理，以便继续JavaScript操作
    }];
    
    [alertController addAction:okAction];
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:alertController animated:YES completion:nil];
}

//confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    if (!message || message.length == 0) {
        completionHandler(NO);
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"溫馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];

    UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];

    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:alertController animated:YES completion:nil];
     
}

@end

@interface FWFUIDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFUIDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFUIDelegate *)delegateForIdentifier:(NSNumber *)identifier {
  return (FWFUIDelegate *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable *_Nonnull)error {
  FWFUIDelegate *uIDelegate = [[FWFUIDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:uIDelegate withIdentifier:identifier.longValue];
}
@end
