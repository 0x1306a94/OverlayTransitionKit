//
//  SampleAlertViewController.h
//  SampleOC
//
//  Created by KK on 2026/7/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@import OverlayTransitionKit;
@interface SampleAlertViewController : UIViewController <OTKOverlayTransitionDelegate>
@property (nonatomic, strong, nullable) void (^didTapCloseHandler)(SampleAlertViewController *alertViewController);
@end

NS_ASSUME_NONNULL_END
