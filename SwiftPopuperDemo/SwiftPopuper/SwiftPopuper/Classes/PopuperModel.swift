//
//  PopuperModel.swift
//  SwiftPopuper
//
//  Created by BY H on 2023/8/4.
//

import UIKit

class PopuperModel: NSObject, UIGestureRecognizerDelegate {
    let popupObj: SwiftPopuperProtocol
    let popuperBgView: PopuperViewBgView
    var originalFrame: CGRect = .zero
    var timer: Timer?
    var dismissTime: TimeInterval = 0
    var config: PopuperConfig
    
    init(popuperBgView: PopuperViewBgView,
         config: PopuperConfig,
         popupObj: SwiftPopuperProtocol) {
        self.popuperBgView = popuperBgView
        self.config = config
        self.popupObj = popupObj
        super.init()
        if config.dismissDuration > 0 {
            dismissTime = config.dismissDuration
        }
    }
    
    /// 校验模型是否有效
    func isValidModel() -> Bool {
        if self.popuperBgView.bounds.size == .zero {
            return false
        }
        return true
    }
    
    func contentView() -> UIView {
        return popupObj.supplyCustomPopupView()
    }
    
    func setupCustomViewCorners() {
        popuperBgView.layoutIfNeeded()
        var isSetCorner = false
        if ((self.config.rectCorners.rawValue & UIRectCorner.topLeft.rawValue) != 0) {
            isSetCorner = true
        }
        if ((self.config.rectCorners.rawValue & UIRectCorner.topRight.rawValue) != 0) {
            isSetCorner = true
        }
        if ((self.config.rectCorners.rawValue & UIRectCorner.bottomLeft.rawValue) != 0) {
            isSetCorner = true
        }
        if ((self.config.rectCorners.rawValue & UIRectCorner.bottomRight.rawValue) != 0) {
            isSetCorner = true
        }
        if ((self.config.rectCorners.rawValue & UIRectCorner.allCorners.rawValue) != 0) {
            isSetCorner = true
        }
        if isSetCorner && self.config.rectCorners.rawValue > 0 {
            var cornerRadiusView = contentView()
            if let view = popupObj.needSetCornerRadiusView?() {
                if view.bounds.size != .zero {
                    cornerRadiusView = view
                }
            }
            let path = UIBezierPath(roundedRect: cornerRadiusView.bounds,
                                    byRoundingCorners: config.rectCorners,
                                    cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius))
            let layer = CAShapeLayer()
            layer.frame = cornerRadiusView.bounds
            layer.path = path.cgPath
            cornerRadiusView.layer.mask = layer
        }
    }
    
    /// 开始倒计时
    func startCountTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerLoopExecute), userInfo: nil, repeats: true)
        if let timer = timer {
            // 加入runloop循环池
            RunLoop.main.add(timer, forMode: .common)
            timer.fire()
        }
    }
    
    func closeTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        // 定时器计数复原
        dismissTime = config.dismissDuration
    }
    
    @objc private func timerLoopExecute() {
        if dismissTime < 1 {
            closeTimer()
            // 关闭弹窗
            SwiftPopuper.dismissWithPopup(self.popupObj)
            return
        }
        dismissTime -= 1
        popupObj.countTime?(with: self.dismissTime)
    }
    
    // MARK: 手势处理
    /// 添加相关手势
    func addGestureRecognizer() {
        // 弹窗背景添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(popupBgViewTap(_:)))
        tap.delegate = self
        popuperBgView.addGestureRecognizer(tap)
        
        // 添加上滑手势
        if config.needNoticeBarPanGesture {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(popupBgViewPan(_:)))
            pan.delegate = self
            popuperBgView.addGestureRecognizer(pan)
        }
    }
    
    @objc private func popupBgViewTap(_ tap: UIGestureRecognizer) {
        if config.clickOutsideDismiss {
            popuperBgView.endEditing(true)
            SwiftPopuper.dismissWithPopup(popupObj)
        }
    }
    
    @objc private func popupBgViewPan(_ pan: UIPanGestureRecognizer) {
        // 获取手指的偏移量
        let transP = pan.translation(in: contentView())
        let originFrame = originalFrame
        if transP.y < 0 {
            let offY = (originFrame.origin.y + (originFrame.size.height / 2)) - abs(transP.y)
            contentView().layer.position = CGPoint(x: contentView().layer.position.x, y: offY)
        } else {
            contentView().frame = originalFrame
        }
        if pan.state == .ended {
            if abs(transP.y) >= (originalFrame.size.height / 2) {
                // 向上滑动了至少内容的一半高度，触发关闭弹窗
                SwiftPopuper.dismissWithPopup(popupObj)
            } else {
                contentView().frame = originalFrame
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: contentView()) == true && config.sceneStyle != .topNoticeView {
            return false
        }
        return true
    }
    
    // MARK: Keyboard
    func addKeyboardMonitor() {
        let observer = self
        // 键盘将要显示
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // 键盘显示完毕
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        // 键盘frame将要改变
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        // 键盘frame改变完毕
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardDidChangeFrame(_:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
        // 键盘将要收起
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        // 键盘收起完毕
        NotificationCenter.default.addObserver(observer,
                                               selector: #selector(keyboardDidChangeFrame(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        config.keyboardWillShowCallback?()
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let keyboardEedFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardMaxY = keyboardEedFrame?.origin.y ?? 0
        let popViewPoint = contentView().layer.position
        let currMaxY = popViewPoint.y + (contentView().frame.size.height / 2)
        let offY = currMaxY - keyboardMaxY
        if keyboardMaxY < currMaxY { // 键盘被遮挡
            // 执行动画
            let originPoint = contentView().layer.position
            UIView.animate(withDuration: duration) { [weak self] in
                guard let self = self else { return }
                self.contentView().layer.position = CGPoint(x: originPoint.x, y: originPoint.y - offY)
            }
        }
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        config.keyboardDidShowCallback?()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let keyboardBeginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        config.keyboardFrameWillChange?(keyboardBeginFrame, keyboardEndFrame, duration)
    }
    
    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        let keyboardBeginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        config.keyboardFrameDidChange?(keyboardBeginFrame, keyboardEndFrame, duration)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        config.keyboardWillHideCallback?()
        guard let userInfo = notification.userInfo else {
            return
        }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        UIView.animate(withDuration: duration) { [weak self] in
            guard let self = self else { return }
            self.contentView().frame = self.originalFrame
        }
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        config.keyboardDidHideCallback?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
