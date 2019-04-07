/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waiting = true;
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;
static UIViewController *loadingViewController = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
    if (!addedJsLoadErrorObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsLoadError:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
        addedJsLoadErrorObserver = true;
    }

    while (waiting) {
        NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop mainRunLoop] runUntilDate:later];
    }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
    if (!loadingView) {
        loadingView = [[[NSBundle mainBundle] loadNibNamed:splashScreen owner:self options:nil] objectAtIndex:0];
        CGRect frame = rootView.frame;
        frame.origin = CGPointMake(0, 0);
        loadingView.frame = frame;
    }
    waiting = false;
    
    [rootView addSubview:loadingView];
}

+ (void)showSplashViewController:(UIViewController *)splashViewController inRootViewController:(UIViewController *)rootViewController {
   if (loadingViewController != nil) {
      return;
   }
   loadingViewController = splashViewController;
   waiting = false;
   
   [rootViewController addChildViewController:splashViewController];
   loadingViewController.view.translatesAutoresizingMaskIntoConstraints = false;
   [rootViewController.view addSubview:loadingViewController.view];
   UIView *loadingView = loadingViewController.view;
   UIView *rootView = rootViewController.view;
   [rootView addConstraint:[NSLayoutConstraint
                            constraintWithItem:loadingView
                            attribute:NSLayoutAttributeLeading
                            relatedBy:NSLayoutRelationEqual
                            toItem:rootView
                            attribute:NSLayoutAttributeLeading
                            multiplier:1 constant:0]];
   [rootView addConstraint:[NSLayoutConstraint
                            constraintWithItem:loadingView
                            attribute:NSLayoutAttributeTrailing
                            relatedBy:NSLayoutRelationEqual
                            toItem:rootView
                            attribute:NSLayoutAttributeTrailing
                            multiplier:1 constant:0]];
   [rootView addConstraint:[NSLayoutConstraint
                            constraintWithItem:loadingView
                            attribute:NSLayoutAttributeTop
                            relatedBy:NSLayoutRelationEqual
                            toItem:rootView
                            attribute:NSLayoutAttributeTop
                            multiplier:1 constant:0]];
   [rootView addConstraint:[NSLayoutConstraint
                            constraintWithItem:loadingView
                            attribute:NSLayoutAttributeBottom
                            relatedBy:NSLayoutRelationEqual
                            toItem:rootView
                            attribute:NSLayoutAttributeBottom
                            multiplier:1 constant:0]];
   [loadingViewController didMoveToParentViewController:rootViewController];
}

+ (void)hide {
   if (waiting) {
      dispatch_async(dispatch_get_main_queue(), ^{
         waiting = false;
      });
   } else {
      if (loadingView != nil) {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [loadingView removeFromSuperview];
         });
      }
      else {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [loadingViewController willMoveToParentViewController:nil];
            [loadingViewController.view removeFromSuperview];
            [loadingViewController removeFromParentViewController];
         });
      }
   }
}

+ (void) jsLoadError:(NSNotification*)notification
{
    // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise the splash screen will remain forever, which is a hassle to debug.
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

@end
