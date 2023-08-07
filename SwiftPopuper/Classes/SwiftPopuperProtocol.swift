//
//  SwiftPopuperProtocol.swift
//  SwiftPopuper
//
//  Created by BY H on 2023/8/3.
//

import UIKit

@objc public protocol SwiftPopuperProtocol: NSObjectProtocol where Self: NSObject {
    /// 提供一个弹窗view对象
    /// - Returns: 自定义弹窗view
    func supplyCustomPopupView() -> UIView
    
    /// 对自定义view进行布局
    /// - Parameter superView: super view
    func layout(with superView: UIView)
    
    /// 执行自定义动画
    @objc optional func executeCustomAnimation()
    
    /// 提供一个需要设置圆角的view 默认是 supplyCustomPopupView 提供的view
    /// - Returns: taget view
    @objc optional func needSetCornerRadiusView() -> UIView?
    
    /// 倒计时剩余时间回调
    /// - Parameter count: count
    @objc optional func countTime(with count: TimeInterval)
    
    // MARK: 弹窗的生命周期
    @objc optional func popupViewDidAppear()
    @objc optional func popupViewDidDisappear()
}
