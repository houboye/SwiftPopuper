# SwiftPopuper
hll-popupsmanager-ios 的swift版本   
[hll-popupsmanager-ios](https://github.com/HuolalaTech/hll-popupsmanager-ios)   
[hll-popupsmanager-ios技术文档](https://juejin.cn/post/7243975451181285435)

# Install
```pod
pod 'SwiftPopuper'
```

# 使用
## 创建自定义View，并且遵循`SwiftPopuperProtocol`
```Swift
class CustomPopView: UIView, SwiftPopuperProtocol {
    func supplyCustomPopupView() -> UIView {
        return self
    }
    
    func layout(with superView: UIView) {
        // layout
    }
}
```
## 配置弹窗并弹出
```
func showPopup() {
    var config = PopuperConfig(identifier: "popupName")
    config.sceneStyle = .center
    config.clickOutsideDismiss = true
    config.cornerRadius = 8
    config.popAnimationStyle = .scale
    config.isAloneMode = true
    let customPopView = CustomPopView()
    SwiftPopuper.addPopup(customPopView, options: config)
}
```