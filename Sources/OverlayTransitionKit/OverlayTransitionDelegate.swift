import UIKit

/// Provides custom overlay show and hide animations.
///
/// The presented or child overlay view controller adopts this protocol and
/// returns the same animation style for both `presentOverlay` and
/// `showChildOverlay`.
@MainActor
@objc(OTKOverlayTransitionDelegate)
public protocol OverlayTransitionDelegate: AnyObject {
    /// Returns the animator used when showing an overlay.
    ///
    /// - Parameters:
    ///   - fromViewController: The view controller currently visible below the overlay.
    ///   - toViewController: The overlay view controller being shown.
    /// - Returns: An animator that drives the show transition.
    func overlayTransitionAnimatorForShowing(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating

    /// Returns the animator used when hiding an overlay.
    ///
    /// - Parameters:
    ///   - fromViewController: The overlay view controller being hidden.
    ///   - toViewController: The view controller revealed below the overlay.
    /// - Returns: An animator that drives the hide transition.
    func overlayTransitionAnimatorForHiding(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating
}
