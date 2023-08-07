//
//  ViewController.swift
//  SwiftPopuperDemo
//
//  Created by BY H on 2023/8/7.
//

import UIKit
import SnapKit
import SwiftPopuper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        button.setTitle("开始演示", for: .normal)
        button.addTarget(self, action: #selector(showClick), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
        
        let button1 = UIButton()
        button1.setTitle("优先级覆盖", for: .normal)
        button1.addTarget(self, action: #selector(showClick1), for: .touchUpInside)
        button1.backgroundColor = UIColor.blue
        view.addSubview(button1)
        button1.snp.makeConstraints { make in
            make.centerX.equalTo(button)
            make.top.equalTo(button.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
        
        let button2 = UIButton()
        button2.setTitle("通知条覆盖", for: .normal)
        button2.addTarget(self, action: #selector(showClick2), for: .touchUpInside)
        button2.backgroundColor = UIColor.blue
        view.addSubview(button2)
        button2.snp.makeConstraints { make in
            make.centerX.equalTo(button1)
            make.top.equalTo(button1.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
    }
    
    @objc func showClick() {
        showFullAdvert()
    }
    
    @objc func showClick1() {
        showBottomShare1()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showCenter1()
        }
    }
    
    @objc func showClick2() {
        showTopbar()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showTopbar1()
        }
    }
    
    func showMorePopView() {
        let time: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.showCenter()
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.showCenter()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    self.showBottomShare()
                    DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                        self.showTopbar()
                        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                            self.showCenter()
                            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                                self.showBottomKeyboard()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func showCenter() {
        var config = PopuperConfig(identifier: "showCenter")
        config.sceneStyle = .center
        config.clickOutsideDismiss = true
        config.cornerRadius = 8
        config.popAnimationStyle = .scale
        config.isAloneMode = true
        let centerPopView = CenterPopView()
        SwiftPopuper.addPopup(centerPopView, options: config)
    }
    
    func showCenter1() {
        var config = PopuperConfig(identifier: "showCenter1")
        config.sceneStyle = .center
        config.clickOutsideDismiss = true
        config.cornerRadius = 8
        config.popAnimationStyle = .scale
        config.priority = 200
        let centerPopView = CenterPopView()
        SwiftPopuper.addPopup(centerPopView, options: config)
    }
    
    func showBottomShare() {
        var config = PopuperConfig(identifier: "showBottomShare")
        config.sceneStyle = .halfPage
        config.clickOutsideDismiss = true
        config.cornerRadius = 8
        config.popAnimationStyle = .scale
        config.dismissAnimationStyle = .fade
        config.isAloneMode = true
        let bottomSharePopView = BottomPopView()
        SwiftPopuper.addPopup(bottomSharePopView, options: config)
    }
    
    func showBottomShare1() {
        var config = PopuperConfig(identifier: "showBottomShare1")
        config.sceneStyle = .halfPage
        config.clickOutsideDismiss = true
        config.cornerRadius = 8
        config.popAnimationStyle = .scale
        config.dismissAnimationStyle = .fade
        config.priority = 100
        let bottomSharePopView = BottomPopView()
        SwiftPopuper.addPopup(bottomSharePopView, options: config)
    }
    
    func showFullAdvert() {
        var config = PopuperConfig(identifier: "showFullAdvert")
        config.sceneStyle = .full
        config.isAloneMode = true
        config.dismissDuration = 3
        let popView = FullPopView()
        popView.popViewDismissBlock = {
            self.showMorePopView()
        }
        SwiftPopuper.addPopup(popView, options: config)
    }
    
    func showTopbar() {
        var config = PopuperConfig(identifier: "showTopbar")
        config.sceneStyle = .topNoticeView
        config.dismissDuration = 3
        config.cornerRadius = 8
        config.isAloneMode = true
        let topBar = TopBarPopView()
        SwiftPopuper.addPopup(topBar, options: config)
    }
    
    func showTopbar1() {
        var config = PopuperConfig(identifier: "showTopbar")
        config.sceneStyle = .topNoticeView
        config.dismissDuration = 3
        config.cornerRadius = 8
        config.priority = 100
        let topBar = TopBarPopView()
        SwiftPopuper.addPopup(topBar, options: config)
    }
    
    func showBottomKeyboard() {
        var config = PopuperConfig(identifier: "showTopbar")
        config.sceneStyle = .halfPage
        config.cornerRadius = 8
        config.isAloneMode = true
        config.clickOutsideDismiss = true
        let popView = KeyboardPopView()
        SwiftPopuper.addPopup(popView, options: config)
    }
}

