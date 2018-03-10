#import <UIKit/_UIBackdropViewSettings.h>
#import <UIKit/_UIBackdropView.h>

#pragma mark - Interfaces

@interface SBNotificationCenterController : NSObject

@property (weak, readonly, nonatomic) UIWindow *window;
@property (assign, nonatomic) NSInteger presentedState;

// Added property
@property (strong, nonatomic) _UIBackdropView *backdropView;

@end

#pragma mark - Hooks

%hook SBNotificationCenterController
%property (retain, nonatomic) _UIBackdropView *backdropView;

- (void)_setupForPresentationWithTouchLocation:(CGPoint)location {
    %orig;

    // Create and add blur view
    _UIBackdropViewSettings *blurSettings = [_UIBackdropViewSettings settingsForStyle:2030 graphicsQuality:100];
    self.backdropView = [[_UIBackdropView alloc] initWithFrame:self.window.bounds autosizesToFitSuperview:YES settings:blurSettings];
    self.backdropView.alpha = 0.0;
    [self.window insertSubview:self.backdropView atIndex:0];
}

- (void)updateTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity {
    // Update view alpha
    CGFloat yValue = location.y;
    CGFloat height = CGRectGetHeight(self.window.bounds) - 100;
    CGFloat percentage = yValue / height;

    self.backdropView.alpha = percentage;

    %orig;
}

- (void)endTransitionWithVelocity:(CGPoint)velocity wasCancelled:(BOOL)cancelled completion:(void(^)(void))completion {
    %orig;

    // Update alpha for full present / dismissal
    [UIView animateWithDuration:0.35 animations:^{
        self.backdropView.alpha = (cancelled || (self.presentedState == 2)) ? 0.0 : 1.0;
    }];
}

%end
