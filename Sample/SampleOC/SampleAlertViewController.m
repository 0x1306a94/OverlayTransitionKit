//
//  SampleAlertViewController.m
//  SampleOC
//
//  Created by KK on 2026/7/4.
//

#import "SampleAlertViewController.h"

@interface SampleAlertViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeightLayoutConstraint;
@end

@implementation SampleAlertViewController
#if DEBUG
- (void)dealloc {
    NSLog(@"[%@(%p) dealloc]", NSStringFromClass(self.class), self);
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.75];

    [self setupViews];
}

- (void)setupViews {
    _contentView = [UIView new];
    _contentView.backgroundColor = UIColor.whiteColor;
    _contentView.layer.cornerRadius = 12;
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;

    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.title = @"关闭";

    _closeButton = [UIButton buttonWithConfiguration:configuration primaryAction:nil];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_contentView];
    [_contentView addSubview:_closeButton];

    _contentViewHeightLayoutConstraint = [_contentView.heightAnchor constraintEqualToConstant:100];

    [NSLayoutConstraint activateConstraints:@[
        [_contentView.widthAnchor constraintEqualToConstant:320],
        _contentViewHeightLayoutConstraint,
        [_contentView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_contentView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],

        [_closeButton.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-20],
        [_closeButton.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:20],
    ]];
}

- (void)closeButtonAction:(UIButton *)sender {
    !self.didTapCloseHandler ?: self.didTapCloseHandler(self);
}

#pragma mark - OTKOverlayTransitionDelegate
- (id<UIViewImplicitlyAnimating>)overlayTransitionAnimatorForShowingFrom:(UIViewController *)fromViewController to:(UIViewController *)toViewController {

    self.contentViewHeightLayoutConstraint.constant = 200;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];

    self.contentView.hidden = NO;
    self.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);

    __weak typeof(self) weakSelf = self;
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.25 curve:UIViewAnimationCurveEaseInOut animations:^{
        weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        weakSelf.contentView.transform = CGAffineTransformIdentity;
    }];

    return animator;
}

- (id<UIViewImplicitlyAnimating>)overlayTransitionAnimatorForHidingFrom:(UIViewController *)fromViewController to:(UIViewController *)toViewController {
    __weak typeof(self) weakSelf = self;
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.25 curve:UIViewAnimationCurveEaseInOut animations:^{
        weakSelf.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        weakSelf.contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];

    /* clang-format off */
      [animator addAnimations:^{
          weakSelf.contentView.alpha = 0.0;
      } delayFactor:0.15];
    /* clang-format on */

    return animator;
}

@end
