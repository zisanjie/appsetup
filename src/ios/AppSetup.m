#import "AppSetup.h"
#import <WebKit/WebKit.h>
#import "MainViewController.h"
#import "CDVThemeableBrowser.h"
#import "hotshare-Swift.h"
static BOOL applicationIsActive;

@implementation AppSetup

-(void)pluginInitialize{
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appSetupPluginOnApplicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appSetupPluginDidEnterBackgroundNotification:)
                                                name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
}

- (void)appSetupPluginDidEnterBackgroundNotification:(NSNotification *)notification{
    
    NSLog(@"appSetupPluginDidEnterBackgroundNotification!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    WKWebView *webview = (WKWebView *)self.webView;
    NSLog(@"webview url:%@",webview.URL.absoluteString);
    [defaults setObject:webview.URL.absoluteString forKey:@"webViewURL"];
    [defaults synchronize];
}


- (void)appSetupPluginOnApplicationDidBecomeActive:(NSNotification *)notification {
    
    NSLog(@"appSetupPluginOnApplicationDidBecomeActive!");
    
    BOOL isBlankScreen = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[self getTopPresentedViewController] isKindOfClass:[MainViewController class]]) {
        
        MainViewController *rootViewController = (MainViewController *)[self getTopPresentedViewController];
        
        if (rootViewController.webView) {
            
            if (applicationIsActive) {
                
             [rootViewController.view bringSubviewToFront:rootViewController.webView];
            }
            if ([rootViewController.webView isKindOfClass:[WKWebView class]]) {
                    
                WKWebView *webview = (WKWebView *)rootViewController.webView;
                    
                if (webview.URL) {
                        
                    NSLog(@"WKWebView is load：%@",webview.URL);
                    
                    //[defaults setObject:webview.URL.absoluteString forKey:@"webViewURL"];
                    //[defaults synchronize];
                    
                    isBlankScreen = NO;
                    
                }
                else{
                    
                    [self showAlertControllerWith:@"load a null url！Reloading" type:@"url"];
                    //重新加载
                    NSString *urlStr = [defaults objectForKey:@"webViewURL"];
                    
                    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
                    
                }
            }
        }
        else{
            [self showAlertControllerWith:@"WKWebView has been killed!" type:@"killed"];
        }
    }
    else{
        if ([[self getTopPresentedViewController] isKindOfClass:[CDVThemeableBrowserViewController class]]) {
            
            return;
        }
        [self showAlertControllerWith:@"MainViewController has been covered!" type:@"covered"];
    }
    
    applicationIsActive = YES;
}

-(void)showAlertControllerWith:(NSString *)message type:(NSString *)type{
    //提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([type isEqualToString:@"covered"]) {
            
            [[self getTopPresentedViewController] dismissViewControllerAnimated:NO completion:nil];
            
            [[self getTopPresentedViewController] presentViewController:self.viewController animated:NO completion:nil];
        }
        
    }];
    
    [alertController addAction:okAction];
    
    [[self getTopPresentedViewController] presentViewController:alertController animated:YES completion:^{
        
    }];
    
}

-(UIViewController *)getTopPresentedViewController {
    UIViewController *presentingViewController = self.viewController;
    while(presentingViewController.presentedViewController != nil)
    {
        presentingViewController = presentingViewController.
        presentedViewController;
    }
    return presentingViewController;
}

-(void)getVersion:(CDVInvokedUrlCommand*)command{
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end