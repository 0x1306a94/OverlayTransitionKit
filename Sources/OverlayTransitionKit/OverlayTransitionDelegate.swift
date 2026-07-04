import UIKit

@MainActor
@objc(OTKOverlayTransitionDelegate)
public protocol OverlayTransitionDelegate: AnyObject {
    func overlayTransitionAnimatorForShowing(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating

    func overlayTransitionAnimatorForHiding(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating
}
