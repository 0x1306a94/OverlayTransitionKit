# OverlayTransitionKit

`OverlayTransitionKit` 是一个轻量的 iOS 覆盖层转场工具。它提供两种展示方式：

- `presentOverlay`：基于系统 `present` / `dismiss` 机制。
- `showChildOverlay`：基于 `addChild` / `removeFromParent` 机制。

适用于需要在当前页面展示全屏覆盖弹框，或者全屏覆盖面板的场景。

两种方式共用同一套动画协议，调用方只需要关心显示动画和隐藏动画。

## 要求

- iOS 15.0+
- Swift 6

## 安装

通过 Swift Package Manager 添加本仓库：

```swift
.package(url: "https://github.com/0x1306a94/OverlayTransitionKit", branch: "master")
```

然后在 target 中依赖：

```swift
.product(name: "OverlayTransitionKit", package: "OverlayTransitionKit")
```

## 基本用法

先让要展示的控制器实现 `OverlayTransitionDelegate`：

```swift
import OverlayTransitionKit
import UIKit

final class AlertViewController: UIViewController, OverlayTransitionDelegate {
    func overlayTransitionAnimatorForShowing(
        from fromViewController: UIViewController,
        to toViewController: UIViewController
    ) -> UIViewImplicitlyAnimating {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            self.view.alpha = 1
        }
    }

    func overlayTransitionAnimatorForHiding(
        from fromViewController: UIViewController,
        to toViewController: UIViewController
    ) -> UIViewImplicitlyAnimating {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            self.view.alpha = 0
        }
    }
}
```

## 使用系统 present 展示

```swift
let alertViewController = AlertViewController()

presentOverlay(alertViewController) {
    print("presentOverlay completion")
}
```

关闭时使用系统 dismiss：

```swift
alertViewController.dismiss(animated: true) {
    print("dismiss completion")
}
```

## 使用 addChild 展示

```swift
let alertViewController = AlertViewController()

showChildOverlay(alertViewController) {
    print("showChildOverlay completion")
}
```

关闭 child overlay 有三种方式：

```swift
// 1. 由父控制器关闭最后展示的 child overlay
dismissChildOverlay {
    print("dismissChildOverlay completion")
}

// 2. 由父控制器关闭指定 child overlay
dismissChildOverlay(alertViewController) {
    print("dismissChildOverlay completion")
}

// 3. 由 child overlay 自己关闭
alertViewController.dismissChildOverlay {
    print("dismissChildOverlay completion")
}
```

## Objective-C 调用

协议在 Objective-C 中暴露为 `OTKOverlayTransitionDelegate`。

```objc
@import OverlayTransitionKit;

[self otk_presentOverlay:alertViewController completion:^{
    NSLog(@"otk_presentOverlay completion");
}];

[self otk_showChildOverlay:alertViewController completion:^{
    NSLog(@"otk_showChildOverlay completion");
}];

[alertViewController otk_dismissChildOverlay:^{
    NSLog(@"otk_dismissChildOverlay completion");
}];
```

## 示例

仓库内包含两个示例 target：

- `Sample`：Swift 示例。
- `SampleOC`：Objective-C 示例。

示例展示了同一个弹窗控制器分别通过 `presentOverlay` 和 `showChildOverlay` 展示，并复用同一套 showing / hiding 动画。

## 示例工程签名配置

示例工程通过 `Sample/Configuration/Config.xcconfig` 提供默认签名配置，并在末尾使用：

```xcconfig
#include? "Developer.xcconfig"
```

`#include?` 表示可选包含。仓库可以保留一份通用默认值，开发者可在 `Sample/Configuration/Developer.xcconfig` 中覆盖本机签名信息，例如：

```xcconfig
BASE_PRODUCT_BUNDLE_IDENTIFIER = com.example.OverlayTransitionKitSample
DEVELOPMENT_TEAM = YOURTEAMID
CODE_SIGN_IDENTITY = Apple Development
CODE_SIGN_IDENTITY[config=Release] = Apple Distribution
PROVISIONING_PROFILE_SPECIFIER = match Development com.example.*
PROVISIONING_PROFILE_SPECIFIER[config=Release] = match AdHoc com.example.*
```

Swift 示例的 bundle id 会拼接为 `$(BASE_PRODUCT_BUNDLE_IDENTIFIER).swift`，Objective-C 示例会拼接为 `$(BASE_PRODUCT_BUNDLE_IDENTIFIER).oc`。如果只做模拟器构建，也可以继续在命令中传入 `CODE_SIGNING_ALLOWED=NO`。

## 验证命令

```sh
xcodebuild test -scheme OverlayTransitionKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild -project Sample/Sample.xcodeproj -scheme Sample -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Sample/Sample.xcodeproj -scheme SampleOC -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO build
```
