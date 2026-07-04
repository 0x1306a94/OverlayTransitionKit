//
//  ViewController.m
//  SampleOC
//
//  Created by KK on 2026/7/4.
//

#import "ViewController.h"

#import "SampleAlertViewController.h"

@import OverlayTransitionKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)presentButtonAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    SampleAlertViewController *alertViewController = [SampleAlertViewController new];
    alertViewController.didTapCloseHandler = ^(SampleAlertViewController *_Nonnull alertViewController) {
        // 1.
        //        [weakSelf dismissViewControllerAnimated:YES completion:^{
        //
        //        }];

        // 2.
        [alertViewController dismissViewControllerAnimated:YES completion:^{

        }];
    };
    NSLog(@"otk_presentOverlay begin");
    [self otk_presentOverlay:alertViewController completion:^{
        NSLog(@"otk_presentOverlay completion");
    }];
}

- (IBAction)showChildButtonAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    SampleAlertViewController *alertViewController = [SampleAlertViewController new];
    alertViewController.didTapCloseHandler = ^(SampleAlertViewController *_Nonnull alertViewController) {
        NSLog(@"otk_dismissChildOverlay begin");

        // 1.
        //        [weakSelf otk_dismissChildOverlay:^{
        //            NSLog(@"otk_dismissChildOverlay completion");
        //        }];

        // 2.
        //        [weakSelf otk_dismissChildOverlay:alertViewController completion:^{
        //            NSLog(@"otk_dismissChildOverlay completion");
        //        }];

        // 3.
        [alertViewController otk_dismissChildOverlay:^{
            NSLog(@"otk_dismissChildOverlay completion");
        }];
    };
    NSLog(@"otk_showChildOverlay begin");
    [self otk_showChildOverlay:alertViewController completion:^{
        NSLog(@"otk_showChildOverlay completion");
    }];
}
@end
