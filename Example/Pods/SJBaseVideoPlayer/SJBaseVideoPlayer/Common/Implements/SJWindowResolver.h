//
//  SJWindowResolver.h
//  SJBaseVideoPlayer
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIWindow * _Nullable SJPreferredWindowForView(UIView * _Nullable view);
UIWindowScene * _Nullable SJWindowSceneForView(UIView * _Nullable view) API_AVAILABLE(ios(13.0));
UIViewController * _Nullable SJRootViewControllerForView(UIView * _Nullable view);
UIViewController * _Nullable SJTopViewControllerForView(UIView * _Nullable view);
UIEdgeInsets SJSafeAreaInsetsForView(UIView * _Nullable view);

NS_ASSUME_NONNULL_END
