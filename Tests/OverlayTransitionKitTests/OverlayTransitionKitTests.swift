import Testing
import UIKit
@testable import OverlayTransitionKit

private final class OverlayViewController: UIViewController, OverlayTransitionDelegate {
    func overlayTransitionAnimatorForShowing(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating {
        UIViewPropertyAnimator(duration: 0, curve: .linear)
    }

    func overlayTransitionAnimatorForHiding(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating {
        UIViewPropertyAnimator(duration: 0, curve: .linear)
    }
}

@MainActor
@Test func exposesOverlayPresentationApis() {
    func compileApis(parentViewController: UIViewController, overlayViewController: OverlayViewController) {
        parentViewController.presentOverlay(overlayViewController)
        parentViewController.showChildOverlay(overlayViewController)
        parentViewController.showChildOverlay(overlayViewController) {}
        parentViewController.dismissChildOverlay()
        parentViewController.dismissChildOverlay {}
        parentViewController.dismissChildOverlay(overlayViewController)
        parentViewController.dismissChildOverlay(overlayViewController) {}
    }

    _ = compileApis
}
