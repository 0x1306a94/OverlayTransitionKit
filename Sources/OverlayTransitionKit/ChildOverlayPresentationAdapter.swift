import UIKit

@MainActor
package final class ChildOverlayPresentationAdapter: NSObject {
    package weak var delegate: OverlayTransitionDelegate?
    package private(set) weak var targetViewController: UIViewController?
    package private(set) weak var parentViewController: UIViewController?

    private var activeAnimator: UIViewImplicitlyAnimating?

    package convenience init(delegate: OverlayTransitionDelegate) {
        self.init()
        self.delegate = delegate
    }

    package func show(target: UIViewController & OverlayTransitionDelegate, parent: UIViewController, completion: ((Bool) -> Void)? = nil) {
        guard let delegate else {
            assertionFailure("must be set delegate")
            completion?(false)
            return
        }

        guard target.parent == nil || target.parent === parent else {
            assertionFailure("target already has a different parent")
            completion?(false)
            return
        }

        guard target.parent == nil else {
            targetViewController = target
            parentViewController = parent
            completion?(true)
            return
        }

        activeAnimator?.stopAnimation(true)
        activeAnimator = nil

        parent.addChild(target)
        target.view.frame = parent.view.bounds
        target.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        target.view.setNeedsLayout()
        target.view.layoutIfNeeded()
        targetViewController = target
        parentViewController = parent

        let animator = delegate.overlayTransitionAnimatorForShowing(from: parent, to: target)
        activeAnimator = animator

        parent.view.addSubview(target.view)

        animator.addCompletion? { [weak self, weak target, weak parent] position in
            guard let self else { return }
            self.activeAnimator = nil

            guard position == .end, let target, let parent else {
                target?.view.removeFromSuperview()
                target?.removeFromParent()
                completion?(false)
                return
            }

            target.didMove(toParent: parent)
            completion?(true)
        }

        animator.startAnimation()
    }

    package func dismiss(completion: ((Bool) -> Void)? = nil) {
        guard let delegate else {
            assertionFailure("must be set delegate")
            completion?(false)
            return
        }

        guard let target = targetViewController else {
            completion?(true)
            return
        }

        activeAnimator?.stopAnimation(true)
        activeAnimator = nil

        target.willMove(toParent: nil)

        let animator = delegate.overlayTransitionAnimatorForHiding(from: target, to: parentViewController ?? target)
        activeAnimator = animator

        animator.addCompletion? { [weak self, weak target] position in
            guard let self else { return }
            self.activeAnimator = nil

            guard position == .end, let target else {
                completion?(false)
                return
            }

            target.view.removeFromSuperview()
            target.removeFromParent()
            self.targetViewController = nil
            self.parentViewController = nil
            completion?(true)
        }

        animator.startAnimation()
    }
}
