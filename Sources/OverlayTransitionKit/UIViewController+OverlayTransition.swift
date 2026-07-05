import ObjectiveC
import UIKit

private nonisolated(unsafe) var overlayPresentationAdapterKey: UInt8 = 0
private nonisolated(unsafe) var childOverlayTargetAdapterKey: UInt8 = 0
private nonisolated(unsafe) var childOverlayParentAdaptersKey: UInt8 = 0

@MainActor
private func setOverlayPresentationAdapter(_ adapter: OverlayPresentationAdapter, for viewController: UIViewController) {
    objc_setAssociatedObject(
        viewController,
        &overlayPresentationAdapterKey,
        adapter,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
}

@MainActor
private func childOverlayTargetAdapter(for viewController: UIViewController?) -> ChildOverlayPresentationAdapter? {
    guard let viewController else { return nil }
    return objc_getAssociatedObject(viewController, &childOverlayTargetAdapterKey) as? ChildOverlayPresentationAdapter
}

@MainActor
private func setChildOverlayTargetAdapter(_ adapter: ChildOverlayPresentationAdapter, for viewController: UIViewController?) {
    guard let viewController else { return }
    objc_setAssociatedObject(
        viewController,
        &childOverlayTargetAdapterKey,
        adapter,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
}

@MainActor
private func clearChildOverlayTargetAdapter(for viewController: UIViewController?) {
    guard let viewController else { return }
    objc_setAssociatedObject(
        viewController,
        &childOverlayTargetAdapterKey,
        nil,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
}

@MainActor
private func childOverlayParentAdapters(for viewController: UIViewController?) -> [ChildOverlayPresentationAdapter] {
    guard let viewController else { return [] }
    return objc_getAssociatedObject(viewController, &childOverlayParentAdaptersKey) as? [ChildOverlayPresentationAdapter] ?? []
}

@MainActor
private func setChildOverlayParentAdapters(_ adapters: [ChildOverlayPresentationAdapter], for viewController: UIViewController?) {
    guard let viewController else { return }
    objc_setAssociatedObject(
        viewController,
        &childOverlayParentAdaptersKey,
        adapters,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    )
}

@MainActor
private func appendChildOverlayParentAdapter(_ adapter: ChildOverlayPresentationAdapter, for viewController: UIViewController?) {
    guard let viewController else { return }
    var adapters = childOverlayParentAdapters(for: viewController).filter { $0 !== adapter }
    adapters.append(adapter)
    setChildOverlayParentAdapters(adapters, for: viewController)
}

@MainActor
private func removeChildOverlayParentAdapter(_ adapter: ChildOverlayPresentationAdapter, from viewController: UIViewController?) {
    guard let viewController else { return }
    let adapters = childOverlayParentAdapters(for: viewController).filter { $0 !== adapter }
    setChildOverlayParentAdapters(adapters, for: viewController)
}

@MainActor
private func lastChildOverlayParentAdapter(for viewController: UIViewController?) -> ChildOverlayPresentationAdapter? {
    childOverlayParentAdapters(for: viewController).last
}

@MainActor
private func childOverlayParentAdapter(for target: UIViewController, in parent: UIViewController?) -> ChildOverlayPresentationAdapter? {
    childOverlayParentAdapters(for: parent).first { $0.targetViewController === target }
}

@MainActor
private func clearChildOverlayAdapterReferences(_ adapter: ChildOverlayPresentationAdapter) {
    clearChildOverlayTargetAdapter(for: adapter.targetViewController)
    removeChildOverlayParentAdapter(adapter, from: adapter.parentViewController)
}

@MainActor
public extension UIViewController {
    /// Presents a full-screen overlay using UIKit's presentation system.
    ///
    /// Use this method when the overlay should participate in UIKit modal
    /// presentation and dismissal. The overlay view controller provides its
    /// show and hide animations by conforming to `OverlayTransitionDelegate`.
    ///
    /// - Parameters:
    ///   - viewController: The overlay view controller to present.
    ///   - completion: The block to execute after the presentation finishes.
    @objc(otk_presentOverlay:completion:)
    func presentOverlay(_ viewController: UIViewController & OverlayTransitionDelegate, completion: (() -> Void)? = nil) {
        let adapter = OverlayPresentationAdapter(delegate: viewController)
        setOverlayPresentationAdapter(adapter, for: viewController)

        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = adapter
        present(viewController, animated: true, completion: completion)
    }

    /// Shows a full-screen overlay as a child view controller.
    ///
    /// Use this method when the overlay should stay inside the current view
    /// controller hierarchy instead of using UIKit modal presentation. The
    /// visual transition is driven by the same `OverlayTransitionDelegate`
    /// methods used by `presentOverlay(_:completion:)`.
    ///
    /// - Parameters:
    ///   - viewController: The overlay view controller to add as a child.
    ///   - completion: The block to execute after the show transition finishes.
    @objc(otk_showChildOverlay:completion:)
    func showChildOverlay(_ viewController: UIViewController & OverlayTransitionDelegate, completion: (() -> Void)? = nil) {
        if let adapter = childOverlayTargetAdapter(for: viewController), adapter.parentViewController === self {
            appendChildOverlayParentAdapter(adapter, for: self)
            completion?()
            return
        }

        let adapter = ChildOverlayPresentationAdapter(delegate: viewController)
        setChildOverlayTargetAdapter(adapter, for: viewController)
        appendChildOverlayParentAdapter(adapter, for: self)

        adapter.show(target: viewController, parent: self) { finished in
            if !finished {
                clearChildOverlayAdapterReferences(adapter)
            }
            completion?()
        }
    }

    /// Dismisses the current child overlay.
    ///
    /// When called on a parent view controller, this dismisses the latest child
    /// overlay shown by that parent. When called on an overlay view controller,
    /// this dismisses the overlay itself.
    ///
    /// - Parameter completion: The block to execute after the dismissal finishes.
    @objc(otk_dismissChildOverlay:)
    func dismissChildOverlay(completion: (() -> Void)? = nil) {
        guard let adapter = lastChildOverlayParentAdapter(for: self) ?? childOverlayTargetAdapter(for: self) else {
            completion?()
            return
        }

        adapter.dismiss { finished in
            if finished {
                clearChildOverlayAdapterReferences(adapter)
            }
            completion?()
        }
    }

    /// Dismisses a specific child overlay from the receiver.
    ///
    /// Use this method when the parent view controller manages more than one
    /// child overlay and the target overlay is known.
    ///
    /// - Parameters:
    ///   - viewController: The child overlay view controller to dismiss.
    ///   - completion: The block to execute after the dismissal finishes.
    @objc(otk_dismissChildOverlay:completion:)
    func dismissChildOverlay(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let adapter = childOverlayParentAdapter(for: viewController, in: self) else {
            completion?()
            return
        }

        adapter.dismiss { finished in
            if finished {
                clearChildOverlayAdapterReferences(adapter)
            }
            completion?()
        }
    }
}
