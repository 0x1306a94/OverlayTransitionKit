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
    @objc(otk_presentOverlay:completion:)
    func presentOverlay(_ viewController: UIViewController & OverlayTransitionDelegate, completion: (() -> Void)? = nil) {
        let adapter = OverlayPresentationAdapter(delegate: viewController)
        setOverlayPresentationAdapter(adapter, for: viewController)

        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = adapter
        present(viewController, animated: true, completion: completion)
    }

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
