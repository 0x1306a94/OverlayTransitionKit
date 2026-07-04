//
//  ViewController.swift
//  Sample
//
//  Created by KK on 2026/7/4.
//

import OverlayTransitionKit
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func presentButtonAction(_ sender: UIButton) {
        let alertViewController = SampleAlertViewController()
        alertViewController.didTapCloseHandler = { [weak self] alertViewController in
            // 1.
            // self?.dismiss(animated: true) {
            //
            // }

            // 2.
            alertViewController.dismiss(animated: true) {}
        }
        print("presentOverlay begin")
        presentOverlay(alertViewController) {
            print("presentOverlay completion")
        }
    }

    @IBAction func showChildButtonAction(_ sender: UIButton) {
        let alertViewController = SampleAlertViewController()
        alertViewController.didTapCloseHandler = { [weak self] alertViewController in
            print("dismissChildOverlay begin")

            // 1.
            // self?.dismissChildOverlay {
            //     print("dismissChildOverlay completion")
            // }

            // 2.
            // self?.dismissChildOverlay(alertViewController) {
            //     print("dismissChildOverlay completion")
            // }

            // 3.
            alertViewController.dismissChildOverlay {
                print("dismissChildOverlay completion")
            }
        }
        print("showChildOverlay begin")
        showChildOverlay(alertViewController) {
            print("showChildOverlay completion")
        }
    }
}
