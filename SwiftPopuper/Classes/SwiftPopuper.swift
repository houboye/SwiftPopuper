//
//  SwiftPopuper.swift
//  SwiftPopuper
//
//  Created by BY H on 2023/8/3.
//

import UIKit

/// SwiftPopuper: 一个负责管理APP整个生命周期内，所有以弹窗样式展示的视图。
public class SwiftPopuper: NSObject {
    private static let `default` = SwiftPopuper()
    
    /// 当前所有队列中的弹窗
    public private(set) var allPopups: [SwiftPopuperProtocol] = []
    
    /// window弹窗存放的缓存队列
    private var windowQueue: [PopuperModel] = []
    
    private var waitRemovePool = NSHashTable<PopuperModel>(options: .weakMemory)
    
    /// 增加弹窗 （快速调用API方法，优先级和配置对象都采用默认）
    /// - Parameter popup: 一个遵守了指定协议的类，该类不限制是否是UIView的子类，只要业务代码中保证实现了协议中的必选方法即可，在方法中告诉弹窗调度你真正的内容视图对象即可
    public static func addPopup(_ popup: SwiftPopuperProtocol) {
        SwiftPopuper.default.addPopup(popup,
                                      priority: 0,
                                      options: nil)
    }
    
    /// 增加弹窗
    /// - Parameters:
    ///   - popup: target popup
    ///   - priority: 优先级：弹窗调度会根据不同优先级的弹窗来决定是否需要立即展示，高优先级的弹窗总是会先于低优先级的弹窗展示
    public static func addPopup(_ popup: SwiftPopuperProtocol,
                         priority: PopupStrategyPriority) {
        SwiftPopuper.default.addPopup(popup,
                                      priority: priority,
                                      options: nil)
    }
    
    /// 增加弹窗
    /// - Parameters:
    ///   - popup: target popup
    ///   - options: configure：一个弹窗配置对象，里面提供了涵哥各种弹窗场景的属性供调用者设置
    public static func addPopup(_ popup: SwiftPopuperProtocol,
                         options: PopuperConfig?) {
        SwiftPopuper.default.addPopup(popup,
                                      priority: 0,
                                      options: options)
    }
    
    /// 移除指定弹窗
    /// - Parameter popup: 触发弹窗时传入的遵守协议的对象
    public static func dismiss(with popup: SwiftPopuperProtocol) {
        if checkMainThread() == false {
            return
        }
        let model = SwiftPopuper.default.getModel(with: popup)
        if let model = model {
            SwiftPopuper.default.dismiss(with: model)
        }
    }
    
    /// 移除指定弹窗
    /// - Parameter identifier: 业务调用中设置的唯一标识符
    public static func dismissPopup(wtih identifier: String) {
        if identifier.count < 1 || checkMainThread() == false {
            return
        }
        let model = SwiftPopuper.default.getModel(with: identifier)
        if let model = model {
            SwiftPopuper.default.dismiss(with: model)
        }
    }
    
    /// 从指定容器中移除所有的弹窗
    /// - Parameter containerView: 指定容器，传nil则移除当前APP的keywindow上的
    public static func removeAllPopup(from containerView: UIView?) {
        if checkMainThread() == false {
            return
        }
        var view = containerView
        if view == nil {
            view = SwiftPopuper.default.getKeyWindow()
        }
        let array = SwiftPopuper.default.getAllPopView(from: containerView)
        if array.count < 1 {
            return
        }
        var waitRemoveArr = array
        // 移除之前所有的弹窗
        while waitRemoveArr.count > 0 {
            if let model = waitRemoveArr.last {
                model.popupObj.popupViewDidDisappear?()
                model.popuperBgView.removeFromSuperview()
                waitRemoveArr.removeLast()
            }
        }
        // 移除model
        SwiftPopuper.default.windowQueue.removeAll { model in
            array.contains(model)
        }
    }
    
    /// 移除调度管理中之前加入的所有弹窗
    public static func removeAllPopup() {
        var array = [PopuperModel]()
        for itemModel in SwiftPopuper.default.windowQueue {
            // 剔除通知条类型的
            if itemModel.config.sceneStyle != .topNoticeView {
                array.append(itemModel)
            }
        }
        var waitRemoveArr = array
        // 移除之前所有的弹窗
        while waitRemoveArr.count > 0 {
            if let model = waitRemoveArr.last {
                model.popupObj.popupViewDidDisappear?()
                model.popuperBgView.removeFromSuperview()
                waitRemoveArr.removeLast()
            }
        }
        // 移除model
        SwiftPopuper.default.windowQueue.removeAll { model in
            array.contains(model)
        }
    }
    
    public static func getAllPopupCount(from containerView: UIView?) -> Int {
        if checkMainThread() == false {
            return 0
        }
        var view = containerView
        if view == nil {
            view = SwiftPopuper.default.getKeyWindow()
        }
        let array = SwiftPopuper.default.getAllPopView(from: containerView)
        return array.count
    }
    
    public static func getTotalPopupCount() -> Int {
        if checkMainThread() == false {
            return 0
        }
        return SwiftPopuper.default.windowQueue.count
    }
    
    static func checkMainThread() -> Bool {
        let isMainThread = Thread.current.isMainThread
        if isMainThread == false {
            debugPrint("⚠️弹窗调度使用必须在主线程中进行")
        }
        return isMainThread
    }
    
    private func addPopup(_ popup: SwiftPopuperProtocol,
                          priority: PopupStrategyPriority,
                          options: PopuperConfig?) {
        if SwiftPopuper.checkMainThread() == false {
            return
        }
        // 弹窗配置对象
        var config = PopuperConfig(identifier: UUID().uuidString)
        if let options = options {
            config = options
        } else {
            if priority != 0 {
                config.priority = priority
            }
        }
        config.configureDefaultParams()
        if config.containerView == nil {
            config.containerView = getKeyWindow()
        }
        var popupFrame = config.containerView?.bounds ?? .zero
        if popupFrame == .zero {
            let size = UIScreen.main.bounds.size
            popupFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        // 弹窗数据模型
        let popuperBgView = PopuperViewBgView(frame: popupFrame)
        popuperBgView.backgroundColor = config.backgroundColor
        popuperBgView.isHiddenBg = config.isHiddenBackgroundView
        let model = PopuperModel(popuperBgView: popuperBgView, config: config, popupObj: popup)
        
        // 将弹窗内容视图添加到弹窗背景视图中
        model.popuperBgView.addSubview(popup.supplyCustomPopupView())
        // 增加相关手势处理
        model.addGestureRecognizer()
        // 适配键盘
        model.addKeyboardMonitor()
        // pop
        pop(with: model, isRecover: false)
    }
    
    private func getModel(with popup: SwiftPopuperProtocol) -> PopuperModel? {
        for itemModel in windowQueue {
            if itemModel.popupObj == popup {
                return itemModel
            }
        }
        return nil
    }
    
    private func getModel(with identifirer: String) -> PopuperModel? {
        if identifirer.count < 1 {
            return nil
        }
        for itemModel in windowQueue {
            if itemModel.config.identifier == identifirer {
                return itemModel
            }
        }
        return nil
    }
    
    // 获取同一个容器中的所有未移除的弹窗（包含所有Group）
    private func getAllPopView(from containerView: UIView?) -> [PopuperModel] {
        var toArr = [PopuperModel]()
        for item in windowQueue {
            if item.config.containerView == containerView {
                toArr.append(item)
            }
        }
        return toArr
    }
    
    private func getKeyWindow() -> UIView? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    // MARK: Pop
    private func pop(with model: PopuperModel, isRecover: Bool) {
        if model.isValidModel() == false {
            return
        }
        // 移除掉前面指定数组内的弹窗
        func clearAgoPopsBlock(_ list: [PopuperModel]) {
            if list.count < 1 {
                return
            }
            var waitRemoveArr = list
            // 移除之前所有的弹窗
            while waitRemoveArr.count > 0 {
                dismiss(with: model)
                waitRemoveArr.removeLast()
            }
        }
        
        // isAloneMode模式只会把相同的Group下的弹窗移除
        if model.config.isAloneMode {
            let popupsList = getPopupsFromAllPopups(with: model.config.groupID)
            clearAgoPopsBlock(popupsList)
        }
        
        // isTerminatorMode模式把不同的Group下的弹窗都给移除
        if model.config.isTerminatorMode {
            let popupsList = windowQueue
            clearAgoPopsBlock(popupsList)
        } else {
            // 根据优先级叠加展示，被叠加的弹窗会隐藏看不到,无论是加到哪个容器里面的弹窗都会放到一起进行优先级比对
            let allPopModelArr = getPopupsFromAllPopups(with: model.config.groupID)
            if allPopModelArr.count > 0 && isRecover == false {
                let laseModel = allPopModelArr.last
                // 如果新进来的弹窗优先级比当前展示的弹窗优先级高
                if model.config.priority >= (laseModel?.config.priority ?? 0) {
                    if let laseModel = laseModel {
                        laseModel.popuperBgView.endEditing(true)
                        // 当前组展示的弹窗被优先级高的顶替掉了
                        dismiss(with: laseModel, isRemoveQueue: false)
                    }
                } else {
                    enterPopWindsQueue(with: model)
                    return
                }
            }
        }
        if model.popuperBgView.superview == nil {
            model.config.containerView?.addSubview(model.popuperBgView)
            model.config.containerView?.bringSubviewToFront(model.popuperBgView)
        }
        // 弹窗内容自定义布局
        model.popupObj.layout(with: model.popuperBgView)
        // 获取到业务中ContentView的frame
        model.popuperBgView.layoutIfNeeded()
        // 缓存弹窗内容的原始frame
        model.originalFrame = model.popupObj.supplyCustomPopupView().frame
        // 开启定时器
        if model.config.dismissDuration >= 1 {
            model.startCountTime()
        }
        // pop动画
        popAnimation(with: model, isNeedAnimation: true)
        // 入列
        if isRecover == false {
            enterPopWindsQueue(with: model)
        }
        // 配置圆角
        model.setupCustomViewCorners()
        // 将要展示回调
        model.config.popViewDidShowCallback?()
        model.popupObj.popupViewDidAppear?()
    }
    
    // 执行pop动画
    private func popAnimation(with model: PopuperModel, isNeedAnimation: Bool) {
        if isNeedAnimation == false {
            // 不需要动画就基础渐隐展示即可
            baseAlphaChange(with: model, isPop: true)
            return
        }
        if model.popupObj.responds(to: #selector(SwiftPopuperProtocol.executeCustomAnimation)) {
            baseAlphaChange(with: model, isPop: true)
            model.popupObj.executeCustomAnimation?()
            return
        }
        // 背景动画执行
        model.popuperBgView.backgroundColor = drawBackgroundViewColor(with: model.config.backgroundColor,
                                                                      alpha: 0,
                                                                      withModel: model)
        model.contentView().alpha = 1
        UIView.animate(withDuration: model.config.popAnimationTime) { [weak self] in
            guard let self = self else { return }
            model.popuperBgView.backgroundColor = self.drawBackgroundViewColor(with: model.config.backgroundColor,
                                                                          alpha: model.config.backgroundAlpha,
                                                                          withModel: model)
        }
        let popViewSize = model.originalFrame.size
        let originPoint = model.originalFrame.origin
        let startPosition = CGPoint(x: originPoint.x + (popViewSize.width / 2),
                                    y: originPoint.y + (popViewSize.height / 2))
        switch model.config.sceneStyle {
        case.halfPage:
            let contentView = model.contentView()
            contentView.layer.position = CGPoint(x: contentView.layer.position.x, y: CGRectGetMaxY(model.popuperBgView.frame) + model.originalFrame.size.height * 0.5)
            UIView.animate(withDuration: model.config.popAnimationTime,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut) {
                contentView.layer.position = startPosition
            } completion: { _ in
                
            }
        case .topNoticeView:
            let contentView = model.contentView()
            contentView.layer.position = CGPoint(x: contentView.layer.position.x, y: -(model.originalFrame.size.height / 2))
            UIView.animate(withDuration: model.config.popAnimationTime,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut) {
                contentView.layer.position = startPosition
            } completion: { _ in
                
            }
        case .center:
            handlePopAnimaationForCenterScene(with: model)
        case .full:
            break
        }
    }
    
    // 执行center scene 类型的配置动画
    private func handlePopAnimaationForCenterScene(with model: PopuperModel) {
        let contentView = model.contentView()
        let startPosition = contentView.layer.position
        switch model.config.popAnimationStyle {
        case .fade:
            baseAlphaChange(with: model, isPop: true)
            return
        case .fallTop:
            contentView.layer.position = CGPoint(x: contentView.layer.position.x,
                                                 y: CGRectGetMidY(model.popuperBgView.frame) - model.originalFrame.size.height / 2)
        case .riseBottom:
            contentView.layer.position = CGPoint(x: contentView.layer.position.x,
                                                 y: CGRectGetMaxY(model.popuperBgView.frame) + model.originalFrame.size.height / 2)
        case .scale:
            baseAlphaChange(with: model, isPop: true)
            // 先变大后恢复至原始大小
            animation(with: model.contentView().layer,
                      duration: model.config.popAnimationTime,
                      values: [0, 1.2, 1])
        }
        
        UIView.animate(withDuration: model.config.popAnimationTime,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            contentView.layer.position = startPosition
        } completion: { _ in
            
        }
    }
    
    private func animation(with layer: CALayer, duration: CGFloat, values: [CGFloat]) {
        let popAnimation = CAKeyframeAnimation(keyPath: "transform")
        popAnimation.duration = duration
        popAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1)), NSValue(caTransform3D: CATransform3DIdentity)]
        popAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        layer.add(popAnimation, forKey: nil)
    }
    
    // 搭配动画展示
    private func baseAlphaChange(with model: PopuperModel, isPop: Bool) {
        if isPop {
            model.popuperBgView.backgroundColor = drawBackgroundViewColor(with: model.config.backgroundColor,
                                                                          alpha: 0,
                                                                          withModel: model)
            model.contentView().alpha = 0
            UIView.animate(withDuration: model.config.popAnimationTime) { [weak self] in
                guard let self = self else { return }
                model.popuperBgView.backgroundColor = self.drawBackgroundViewColor(with: model.config.backgroundColor,
                                                                                   alpha: model.config.backgroundAlpha,
                                                                                   withModel: model)
                model.contentView().alpha = 1
            }
        } else {
            UIView.animate(withDuration: model.config.dismissDuration) { [weak self] in
                guard let self = self else { return }
                model.popuperBgView.backgroundColor = self.drawBackgroundViewColor(with: model.config.backgroundColor,
                                                                                   alpha: 0,
                                                                                   withModel: model)
                model.contentView().alpha = 0
            }
        }
    }
    
    // MARK: Dismiss
    private func dismiss(with model: PopuperModel, isRemoveQueue: Bool = true) {
        if isRemoveQueue {
            // 存放入待移除的队列中
            divertToWaitRemoveQueue(with: model)
        }
        let queueCount = getPopupsFromAllPopups(with: model.config.groupID).count
        if model.config.isAloneMode == false && (isRemoveQueue && queueCount >= 1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + model.config.dismissAnimationTime) { [weak self] in
                guard let self = self else { return }
                if queueCount >= 1 {
                    // 如果当前移除的弹窗之前还有被覆盖的，则把之前的重新展示出来
                    let allArr = getPopupsFromAllPopups(with: model.config.groupID)
                    
                    if let lastItem = allArr.last {
                        // 开启定时器
                        if lastItem.config.dismissDuration >= 1 {
                            lastItem.startCountTime()
                        }
                        // pop动画
                        popAnimation(with: lastItem, isNeedAnimation: true)
                    }
                }
            }
        }
        // 执行动画
        var needDismissAnimation = true
        if (model.config.sceneStyle == .topNoticeView || model.config.sceneStyle == .center) && isRemoveQueue {
            needDismissAnimation = false
        }
        dismissAnimation(with: model, isNeedAnimation: needDismissAnimation)
        if model.config.dismissDuration > 0 {
            model.closeTimer()
        }
        
        if isRemoveQueue {
            DispatchQueue.main.asyncAfter(deadline: .now() + model.config.dismissAnimationTime) {
                model.config.popViewDidDismissCallback?()
                model.popupObj.popupViewDidDisappear?()
                model.closeTimer()
                model.popuperBgView.removeFromSuperview()
            }
        }
    }
    
    private func dismissAnimation(with model: PopuperModel, isNeedAnimation: Bool) {
        baseAlphaChange(with: model, isPop: false)
        if isNeedAnimation {
            return
        }
        switch model.config.sceneStyle {
        case .halfPage:
            let contentView = model.contentView()
            UIView.animate(withDuration: model.config.dismissAnimationTime) {
                contentView.layer.position = CGPoint(x: contentView.layer.position.x,
                                                     y: CGRectGetMaxY(model.popuperBgView.frame) + model.originalFrame.size.height / 2)
            }
        case .topNoticeView:
            let contentView = model.contentView()
            UIView.animate(withDuration: model.config.dismissAnimationTime) {
                contentView.layer.position = CGPoint(x: contentView.layer.position.x, y: -(model.originalFrame.size.height / 2))
            }
        case .center:
            break
        case .full:
            break
        }
    }
    
    // MARK: Helper
    // 将需要移除的弹窗转移到另外一个队列
    private func divertToWaitRemoveQueue(with model: PopuperModel) {
        let allArr = getAllPopView(from: model.config.containerView)
        allArr.forEach { [weak self] obj in
            guard let self = self else { return }
            if obj.popupObj == model.popupObj {
                self.waitRemovePool.add(model)
                self.windowQueue.removeAll { item in
                    item == model
                }
            }
        }
        
    }
    
    private func drawBackgroundViewColor(with color: UIColor, alpha: CGFloat, withModel model: PopuperModel) -> UIColor {
        if model.popuperBgView.isHiddenBg {
            return UIColor.clear
        }
        if model.config.backgroundColor == UIColor.clear {
            return UIColor.clear
        }
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var resAlpha: CGFloat = 0.0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &resAlpha)
        let resColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return resColor
    }
    
    private func getPopupsFromAllPopups(with groupId: String?) -> [PopuperModel] {
        return getSameGroupPopups(with: groupId, popupList: windowQueue)
    }
    
    private func getSameGroupPopups(with groupId: String?, popupList: [PopuperModel]) -> [PopuperModel] {
        var resultArr = [PopuperModel]()
        if popupList.count < 1 {
            return resultArr
        }
        for itemModel in popupList {
            if itemModel.config.groupID == nil && groupId == nil {
                // 没有设置分组，即为同一默认组
                resultArr.append(itemModel)
                continue
            }
            if itemModel.config.groupID == groupId {
                resultArr.append(itemModel)
                continue
            }
        }
        return resultArr
    }
    
    // 取出同一容器内的相同Group的弹窗
    private func getAllPopView(with model: PopuperModel) -> [PopuperModel] {
        let allPops = getAllPopView(from: model.config.containerView)
        return getSameGroupPopups(with: model.config.groupID, popupList: allPops)
    }
    
    // 进入队列的元素都要进行优先级排序，优先级最高的放到数组的末尾
    private func enterPopWindsQueue(with model: PopuperModel) {
        for item in windowQueue {
            if item == model {
                return
            }
        }
        windowQueue.append(model)
        if windowQueue.count < 2 {
            return
        }
        // 插入排序进行优先级调整
        guard let lastModel = windowQueue.last else {
            return
        }
        
        let i = windowQueue.count - 1
        var j = i - 1
        while j >= 0 && windowQueue[j].config.priority > lastModel.config.priority {
            windowQueue[j+1] = windowQueue[j]
            j -= 1
        }
        windowQueue[j + 1] = lastModel
    }
    
    // MARK: Init
    private override init() { }
}
