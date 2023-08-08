//
//  PopuperConfig.swift
//  SwiftPopuper
//
//  Created by BY H on 2023/8/3.
//

import UIKit

public enum PopupScene {
    case center
    case halfPage
    case topNoticeView
    case full
}

public enum PopAnimationStyle {
    case fade
    case fallTop // for PopupScene.center
    case riseBottom // for PopupScene.halfPage
    case scale
}

public enum DismissAnimationStyle {
    case fade
    case none
}

public typealias PopupStrategyPriority = CGFloat
public typealias PopuperCallback = () -> Void
public typealias PopuperKeyBoardChange = (_ beginFrame: CGRect, _ endFrame: CGRect, _ duration: CGFloat) -> Void

public struct PopuperConfig {
    /// 唯一标识
    public var identifier: String
    
    /// 场景
    public var sceneStyle: PopupScene = .center
    
    /// 先进先出 范围：0~1000
    public var priority: PopupStrategyPriority = 0
    
    /// 点击弹窗背景是否消失
    public var isClickOutsideDismiss = false
    
    /// 弹窗的容器视图，默认是当前APP的keywindow,可以设置成其他容器
    public var containerView: UIView?
    
    /// 持续时长 设置后会在设定时间结束后自动dismiss
    /// 默认为0，不自动消失
    public var dismissDuration: TimeInterval = 0
    
    /// 设置YES会让之前的所有同组弹窗全部清除掉（优先级属性失效)
    public var isAloneMode = false
    
    /// 和aloneMode模式类似，不过terminatorMode会清除掉之前所有分组的弹窗
    public var isTerminatorMode = false
    
    /// pop动画样式
    public var popAnimationStyle: PopAnimationStyle = .fade
    
    /// dismiss动画样式
    public var dismissAnimationStyle: DismissAnimationStyle = .fade
    
    /// 弹窗视图后面的背景色，通常是默认的半透明黑色，可自定义设置
    public var backgroundColor: UIColor = UIColor.black
    
    /// 背景透明度，默认值为：0.25
    public var backgroundAlpha: CGFloat = 0.25
    
    /// 分组ID，如果设置了分组ID，不同分组ID的弹窗不受影响,独立调度展示，
    /// HLLPopupSceneTopNoticeView 类型的默认自带分组（因为顶部通知条可覆盖普通弹窗）
    public var groupID: String?
    
    /// 弹窗内容圆角方向,默认UIRectCornerAllCorners,当cornerRadius>0时生效
    public var rectCorners: UIRectCorner = .allCorners
    
    /// 弹窗内容圆角大小
    public var cornerRadius: CGFloat = 0
    
    /// 顶部通知条支持上滑关闭 默认true
    public var isNeedNoticeBarPanGesture = true
    
    /// 是否隐藏背景，默认为：false
    public var isHiddenBackgroundView = false
    
    /// 键盘和弹窗之间的垂直间距,通常默认为10，底部弹窗默认0
    public var keyboardVSpace: CGFloat = 10
    
    /// 动画时长，不设置内部会默认根据动画类型设置 0~3s
    public private(set) var popAnimationTime: TimeInterval = 0.3
    public private(set) var dismissAnimationTime: TimeInterval = 0.3
    
    // MARK: 事件回调
    /// 点击背景回调
    public var clickBgCallback: PopuperCallback?
    // MARK: 弹窗显示生命周期
    public var popViewDidShowCallback: PopuperCallback?
    public var popViewDidDismissCallback: PopuperCallback?

    // MARK: 键盘处理
    public var keyboardWillShowCallback: PopuperCallback?
    public var keyboardDidShowCallback: PopuperCallback?
    public var keyboardFrameWillChange: PopuperKeyBoardChange?
    public var keyboardFrameDidChange: PopuperKeyBoardChange?
    public var keyboardWillHideCallback: PopuperCallback?
    public var keyboardDidHideCallback: PopuperCallback?
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    mutating func configureDefaultParams() {
        if cornerRadius > 0 && rectCorners.rawValue == 0 {
            rectCorners = .allCorners
        }
        // 通知条场景默认进行独立分组
        if sceneStyle == .topNoticeView && groupID == nil {
            groupID = "PopupSceneTopNoticeBar"
            isHiddenBackgroundView = true
        }
        // 通知条默认自带上滑关闭手势
        if sceneStyle == .topNoticeView {
            isNeedNoticeBarPanGesture = true
            isClickOutsideDismiss = false
        }
        if sceneStyle == .halfPage {
            keyboardVSpace = 0
        }
    }
    
    mutating func setPopAnimationTime(_ time: TimeInterval) {
        if time > 0 && time < 3 {
            self.popAnimationTime = time
        }
    }
    
    mutating func setDismissAnimationTime(_ time: TimeInterval) {
        if time > 0 && time < 3 {
            self.dismissAnimationTime = time
        }
    }
}
