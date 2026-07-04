# Repository Guidelines

## 项目结构与模块组织

`OverlayTransitionKit` 是仅支持 iOS 的 Swift Package。核心源码位于 `Sources/OverlayTransitionKit/`，每个文件负责一个清晰角色：

- `OverlayTransitionDelegate.swift`：公开动画协议。
- `OverlayPresentationAdapter.swift`：系统 `present` / `dismiss` 转场适配。
- `ChildOverlayPresentationAdapter.swift`：`addChild` / `removeFromParent` 转场适配。
- `UIViewController+OverlayTransition.swift`：`UIViewController` 公开扩展与 adapter 保活逻辑。

测试位于 `Tests/OverlayTransitionKitTests/`。示例工程在 `Sample/`：`Sample/Sample/` 是 Swift 示例，`Sample/SampleOC/` 是 Objective-C 示例，`Sample/Configuration/` 存放共享构建配置。资源文件和 `Info.plist` 应保留在所属 sample target 目录内。

## 构建、测试与开发命令

本仓库依赖 UIKit，优先使用 Xcode 的 iOS Simulator 环境验证：

```sh
xcodebuild test -scheme OverlayTransitionKit -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' -derivedDataPath /private/tmp/OverlayTransitionKitDerivedData
xcodebuild -project Sample/Sample.xcodeproj -scheme Sample -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' -derivedDataPath /private/tmp/OverlayTransitionKitSampleDerivedData build
xcodebuild -project Sample/Sample.xcodeproj -scheme SampleOC -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' -derivedDataPath /private/tmp/OverlayTransitionKitSampleOCDerivedData build
```

第一条命令运行 Swift Package 测试。修改示例代码时，至少构建对应 sample target。提交前运行 `git diff --check`，检查空白错误和冲突标记。

## 代码风格与命名约定

Swift 使用 4 空格缩进，公开 API 显式标注访问级别，保持一个主要类型对应一个文件。变量命名避免缩写，简短且语义明确。

公开 API 需要兼顾 Swift 与 Objective-C。Swift API 使用清晰的领域名，例如 `presentOverlay(_:completion:)`、`showChildOverlay(_:completion:)`、`dismissChildOverlay(completion:)`；Objective-C 暴露名使用 `otk_` 前缀。协议暴露为 `OTKOverlayTransitionDelegate`。

内部 adapter 优先保持 `package` 或更小访问级别。不要把保活用的 associated object key 或 helper 暴露为公开 API。

Objective-C 示例使用 ARC 风格和清晰属性命名。引用 Swift 暴露类型时以生成头为准，例如 `OTKOverlayTransitionDelegate`。

## 测试规范

测试使用 Swift Testing（`import Testing`）。测试名描述行为，例如 `exposesOverlayPresentationApis`。修改公开 API、转场生命周期、adapter 保活或 Objective-C 暴露名时，应补充聚焦测试。

涉及可视转场或示例交互时，还需要构建 Swift 与 Objective-C 两个示例。由于包只支持 iOS，不要用 macOS 下的 `swift test` 作为主要验证依据。

## 提交与 PR 规范

提交信息使用简短祈使句，每次提交聚焦一个逻辑变更。

PR 应包含变更摘要、已运行的验证命令；如果影响弹框或面板的视觉转场效果，附截图或录屏。修改公开 Swift API 时，说明 Objective-C 兼容性影响。

## Agent 注意事项

保持变更小且局限在仓库内。除非确实需要 target membership 或构建配置，不要修改 `Sample/Sample.xcodeproj/project.pbxproj`。新增源码优先放入现有 package 或 sample 目录。
