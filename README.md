# SwiftPopuper

A lightweight popup scheduling and management framework for iOS. It manages the entire lifecycle of popup views within your app, supporting priority queuing, multiple scene styles, grouping, animations, keyboard adaptation, and auto-dismiss countdowns.

## Features

- Priority-based popup scheduling (higher priority popups override lower ones)
- 4 scene styles: center, half-page (bottom sheet), top notice bar, full-screen
- Group-based isolation (popups in different groups don't interfere)
- Auto-dismiss with countdown timer
- Keyboard-aware positioning
- Customizable animations (fade, scale, slide from top/bottom)
- Click-outside-to-dismiss support
- Swipe-to-dismiss for top notice bars

## Requirements

- iOS 13.0+
- Swift 5.0+

## Installation

### CocoaPods

```ruby
pod 'SwiftPopuper'
```

### Manual

Copy the `SwiftPopuper/Classes/` directory into your project.

## Architecture

```
SwiftPopuper/Classes/
├── SwiftPopuper.swift          # Core scheduler — manages popup queue, priority sorting, show/dismiss logic
├── SwiftPopuperProtocol.swift  # Protocol your popup views must conform to
├── PopuperConfig.swift         # Configuration struct (scene, animation, priority, callbacks, etc.)
├── PopuperModel.swift          # Internal model — holds state per popup (timer, keyboard, gestures)
└── PopuperViewBgView.swift     # Background overlay view with hit-test pass-through support
```

**Flow:**

```
addPopup() → build PopuperModel → priority sort → check AloneMode/TerminatorMode
    → dismiss lower-priority popups in same group → add bgView to container → layout → animate in
```

## Usage

### 1. Create a custom popup view conforming to `SwiftPopuperProtocol`

```swift
import SwiftPopuper

class MyPopupView: UIView, SwiftPopuperProtocol {
    func supplyCustomPopupView() -> UIView {
        return self
    }
    
    func layout(with superView: UIView) {
        // Use Auto Layout or frame-based layout relative to superView
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(200)
        }
    }
}
```

### 2. Show a popup

```swift
// Simple — uses default config
let popup = MyPopupView()
SwiftPopuper.addPopup(popup)

// With priority
SwiftPopuper.addPopup(popup, priority: 100)

// With full config
var config = PopuperConfig(identifier: "myPopup")
config.sceneStyle = .center
config.isClickOutsideDismiss = true
config.cornerRadius = 12
config.popAnimationStyle = .scale
SwiftPopuper.addPopup(popup, options: config)
```

### 3. Dismiss a popup

```swift
// By popup reference
SwiftPopuper.dismiss(with: popup)

// By identifier
SwiftPopuper.dismissPopup(wtih: "myPopup")

// Remove all popups
SwiftPopuper.removeAllPopup()

// Remove all popups from a specific container
SwiftPopuper.removeAllPopup(from: someView)
```

## Scene Styles

### Center (`.center`)

```swift
var config = PopuperConfig(identifier: "center")
config.sceneStyle = .center
config.popAnimationStyle = .scale  // .fade, .fallTop, .riseBottom, .scale
config.isClickOutsideDismiss = true
config.cornerRadius = 8
```

### Bottom Sheet (`.halfPage`)

```swift
var config = PopuperConfig(identifier: "bottomSheet")
config.sceneStyle = .halfPage
config.isClickOutsideDismiss = true
config.cornerRadius = 16
config.rectCorners = [.topLeft, .topRight]
```

### Top Notice Bar (`.topNoticeView`)

```swift
var config = PopuperConfig(identifier: "notice")
config.sceneStyle = .topNoticeView
config.dismissDuration = 3  // auto-dismiss after 3 seconds
config.cornerRadius = 8
```

Top notice bars automatically get their own group, have a transparent background, and support swipe-up to dismiss.

### Full Screen (`.full`)

```swift
var config = PopuperConfig(identifier: "fullAd")
config.sceneStyle = .full
config.dismissDuration = 5
config.isAloneMode = true
```

## Configuration Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `identifier` | `String` | required | Unique identifier for the popup |
| `sceneStyle` | `PopupScene` | `.center` | Scene type: `.center`, `.halfPage`, `.topNoticeView`, `.full` |
| `priority` | `CGFloat` | `0` | Priority (0~1000). Higher priority popups display first |
| `isClickOutsideDismiss` | `Bool` | `false` | Tap background to dismiss |
| `containerView` | `UIView?` | `nil` (keyWindow) | Custom container view |
| `dismissDuration` | `TimeInterval` | `0` | Auto-dismiss countdown (0 = no auto-dismiss) |
| `isAloneMode` | `Bool` | `false` | Clears all same-group popups before showing |
| `isTerminatorMode` | `Bool` | `false` | Clears ALL popups (all groups) before showing |
| `popAnimationStyle` | `PopAnimationStyle` | `.fade` | Pop animation: `.fade`, `.fallTop`, `.riseBottom`, `.scale` |
| `dismissAnimationStyle` | `DismissAnimationStyle` | `.fade` | Dismiss animation: `.fade`, `.none` |
| `backgroundColor` | `UIColor` | `.black` | Background overlay color |
| `backgroundAlpha` | `CGFloat` | `0.25` | Background overlay alpha |
| `groupID` | `String?` | `nil` | Group ID — popups in different groups are independent |
| `cornerRadius` | `CGFloat` | `0` | Corner radius of content view |
| `rectCorners` | `UIRectCorner` | `.allCorners` | Which corners to round |
| `isHiddenBackgroundView` | `Bool` | `false` | Hide background (touch passes through) |
| `keyboardVSpace` | `CGFloat` | `10` | Vertical spacing between popup and keyboard |
| `isNeedNoticeBarPanGesture` | `Bool` | `true` | Enable swipe-up to dismiss for top notice |

## Protocol Reference

```swift
@objc public protocol SwiftPopuperProtocol: NSObjectProtocol {
    // Required
    func supplyCustomPopupView() -> UIView
    func layout(with superView: UIView)
    
    // Optional
    @objc optional func executeCustomAnimation()
    @objc optional func needSetCornerRadiusView() -> UIView?
    @objc optional func countTime(with count: TimeInterval)
    @objc optional func popupViewDidAppear()
    @objc optional func popupViewDidDisappear()
}
```

## Advanced Usage

### Priority Scheduling

When multiple popups are in the same group, only the highest-priority one is visible. Lower-priority popups are queued and shown after the current one is dismissed.

```swift
// Show a low-priority popup
var config1 = PopuperConfig(identifier: "low")
config1.priority = 10
SwiftPopuper.addPopup(lowPopup, options: config1)

// A higher-priority popup will override it
var config2 = PopuperConfig(identifier: "high")
config2.priority = 100
SwiftPopuper.addPopup(highPopup, options: config2)
// lowPopup is hidden; when highPopup is dismissed, lowPopup reappears
```

### Grouping

Use `groupID` to create independent popup channels:

```swift
var toastConfig = PopuperConfig(identifier: "toast")
toastConfig.groupID = "toasts"
toastConfig.sceneStyle = .topNoticeView

var dialogConfig = PopuperConfig(identifier: "dialog")
dialogConfig.groupID = "dialogs"
dialogConfig.sceneStyle = .center
// These two popups can coexist — they don't affect each other
```

### Keyboard Adaptation

Popups automatically move up when the keyboard appears. Use `keyboardVSpace` to adjust spacing, and keyboard callbacks for custom handling:

```swift
var config = PopuperConfig(identifier: "input")
config.sceneStyle = .halfPage
config.keyboardVSpace = 0
config.keyboardWillShowCallback = { print("keyboard will show") }
config.keyboardFrameWillChange = { beginFrame, endFrame, duration in
    // Custom keyboard tracking
}
```

### Custom Animations

Implement `executeCustomAnimation()` in your popup view to bypass built-in animations:

```swift
class MyPopup: UIView, SwiftPopuperProtocol {
    func executeCustomAnimation() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
            self.transform = .identity
        }
    }
}
```

### Countdown Timer

```swift
var config = PopuperConfig(identifier: "ad")
config.dismissDuration = 5  // 5 second countdown

class AdView: UIView, SwiftPopuperProtocol {
    func countTime(with count: TimeInterval) {
        label.text = "Closing in \(Int(count))s"
    }
    
    func popupViewDidDisappear() {
        // Cleanup after dismiss
    }
}
```

## License

MIT
