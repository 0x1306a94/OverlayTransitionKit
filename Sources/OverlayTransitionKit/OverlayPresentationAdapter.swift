import UIKit

package final class OverlayPresentationAdapter: NSObject {
    package weak var delegate: OverlayTransitionDelegate?

    package convenience init(delegate: OverlayTransitionDelegate) {
        self.init()
        self.delegate = delegate
    }
}

extension OverlayPresentationAdapter: UIViewControllerTransitioningDelegate {
    package func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self
    }

    package func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self
    }
}

extension OverlayPresentationAdapter: UIViewControllerAnimatedTransitioning {
    package func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.25
    }

    package func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let delegate else {
            assertionFailure("must be set delegate")
            transitionContext.completeTransition(false)
            return
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        let isPresenting = fromViewController.presentedViewController == toViewController

        let animator: UIViewImplicitlyAnimating
        if isPresenting {
            toView?.frame = containerView.bounds
            toView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toView?.setNeedsLayout()
            toView?.layoutIfNeeded()
            animator = delegate.overlayTransitionAnimatorForShowing(from: fromViewController, to: toViewController)

            if let toView {
                containerView.addSubview(toView)
            }
        } else {
            animator = delegate.overlayTransitionAnimatorForHiding(from: fromViewController, to: toViewController)
        }

        animator.addCompletion? { _ in
            if !isPresenting {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        animator.startAnimation()
    }
}
