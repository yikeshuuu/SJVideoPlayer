//
//  SJWindowResolver.m
//  SJBaseVideoPlayer
//

#import "SJWindowResolver.h"

NS_ASSUME_NONNULL_BEGIN

static UIWindow * _Nullable _SJPreferredWindowInScene(UIWindowScene *scene) API_AVAILABLE(ios(13.0));
static UIWindowScene * _Nullable _SJActiveWindowScene(void) API_AVAILABLE(ios(13.0));
static UIViewController * _Nullable _SJTopViewController(UIViewController * _Nullable viewController);

UIWindow * _Nullable SJPreferredWindowForView(UIView * _Nullable view) {
    UIWindow *window = view.window;
    if ( window != nil ) return window;

    if ( @available(iOS 13.0, *) ) {
        UIWindowScene *scene = SJWindowSceneForView(view);
        if ( scene != nil ) return _SJPreferredWindowInScene(scene);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
    if ( [delegate respondsToSelector:@selector(window)] ) {
        return delegate.window;
    }
#pragma clang diagnostic pop
    return nil;
}

UIWindowScene * _Nullable SJWindowSceneForView(UIView * _Nullable view) {
    if ( @available(iOS 13.0, *) ) {
        UIWindowScene *scene = view.window.windowScene;
        if ( scene != nil ) return scene;
        return _SJActiveWindowScene();
    }
    return nil;
}

UIViewController * _Nullable SJRootViewControllerForView(UIView * _Nullable view) {
    return SJPreferredWindowForView(view).rootViewController;
}

UIViewController * _Nullable SJTopViewControllerForView(UIView * _Nullable view) {
    return _SJTopViewController(SJRootViewControllerForView(view));
}

UIEdgeInsets SJSafeAreaInsetsForView(UIView * _Nullable view) {
    UIWindow *window = SJPreferredWindowForView(view);
    if ( window != nil ) {
        if ( @available(iOS 11.0, *) ) {
            return window.safeAreaInsets;
        }
    }
    return UIEdgeInsetsZero;
}

static UIWindowScene * _Nullable _SJActiveWindowScene(void) {
    if ( @available(iOS 13.0, *) ) {
        UIWindowScene *candidate = nil;
        for ( UIScene *scene in UIApplication.sharedApplication.connectedScenes ) {
            if ( ![scene isKindOfClass:UIWindowScene.class] ) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if ( scene.activationState == UISceneActivationStateForegroundActive ) {
                UIWindow *window = _SJPreferredWindowInScene(windowScene);
                if ( window != nil ) return windowScene;
                if ( candidate == nil ) candidate = windowScene;
            }
            else if ( candidate == nil && scene.activationState == UISceneActivationStateForegroundInactive ) {
                candidate = windowScene;
            }
        }
        if ( candidate != nil ) return candidate;
        for ( UIScene *scene in UIApplication.sharedApplication.connectedScenes ) {
            if ( [scene isKindOfClass:UIWindowScene.class] ) return (UIWindowScene *)scene;
        }
    }
    return nil;
}

static UIWindow * _Nullable _SJPreferredWindowInScene(UIWindowScene *scene) {
    for ( UIWindow *window in scene.windows ) {
        if ( window.isKeyWindow ) return window;
    }
    for ( UIWindow *window in scene.windows ) {
        if ( !window.hidden && window.windowLevel == UIWindowLevelNormal ) return window;
    }
    return scene.windows.firstObject;
}

static UIViewController * _Nullable _SJTopViewController(UIViewController * _Nullable viewController) {
    if ( [viewController isKindOfClass:UITabBarController.class] ) {
        return _SJTopViewController(((UITabBarController *)viewController).selectedViewController ?: viewController);
    }
    if ( [viewController isKindOfClass:UINavigationController.class] ) {
        return _SJTopViewController(((UINavigationController *)viewController).visibleViewController ?: viewController);
    }
    UIViewController *presentedViewController = viewController.presentedViewController;
    if ( presentedViewController != nil ) {
        return _SJTopViewController(presentedViewController);
    }
    return viewController;
}

NS_ASSUME_NONNULL_END
