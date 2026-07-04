//
//  SampleAlertViewController.swift
//  Sample
//
//  Created by KK on 2026/7/4.
//

import OverlayTransitionKit
import UIKit

class SampleAlertViewController: UIViewController, OverlayTransitionDelegate {
    var didTapCloseHandler: ((SampleAlertViewController) -> Void)?

    private var contentView: UIView!
    private var closeButton: UIButton!
    private var contentViewHeightLayoutConstraint: NSLayoutConstraint!

    #if DEBUG
    deinit {
        print("\(self) deinit")
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        setupViews()
    }

    private func setupViews() {
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.title = "关闭"

        closeButton = UIButton(configuration: configuration, primaryAction: nil)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)

        view.addSubview(contentView)
        contentView.addSubview(closeButton)

        contentViewHeightLayoutConstraint = contentView.heightAnchor.constraint(equalToConstant: 100)

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 320),
            contentViewHeightLayoutConstraint,
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
        ])
    }

    @objc
    private func closeButtonAction(_ sender: UIButton) {
        didTapCloseHandler?(self)
    }

    // MARK: - OverlayTransitionDelegate

    func overlayTransitionAnimatorForShowing(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating {
        contentViewHeightLayoutConstraint.constant = 200
        view.setNeedsLayout()
        view.layoutIfNeeded()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)

        contentView.isHidden = false
        contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)

        return UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) { [weak self] in
            self?.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self?.contentView.transform = .identity
        }
    }

    func overlayTransitionAnimatorForHiding(from fromViewController: UIViewController, to toViewController: UIViewController) -> UIViewImplicitlyAnimating {
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) { [weak self] in
            self?.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self?.contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }

        animator.addAnimations({ [weak self] in
            self?.contentView.alpha = 0.0
        }, delayFactor: 0.15)

        return animator
    }
}
