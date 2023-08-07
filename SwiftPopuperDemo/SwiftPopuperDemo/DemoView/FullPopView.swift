//
//  FullPopView.swift
//  SwiftPopuperDemo
//
//  Created by BY H on 2023/8/7.
//

import UIKit
import SwiftPopuper

class FullPopView: UIView, SwiftPopuperProtocol {
    var popViewDismissBlock: (() -> Void)?
    
    private let imageView = UIImageView(image: UIImage(named: "FullAdver"))
    private let timeCountLabl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        timeCountLabl.backgroundColor = UIColor.black
        timeCountLabl.textColor = UIColor.white
        timeCountLabl.font = UIFont.systemFont(ofSize: 30)
        timeCountLabl.text = "测试剩余：3s"
        self.addSubview(timeCountLabl)
        timeCountLabl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func supplyCustomPopupView() -> UIView {
        return self
    }
    
    func layout(with superView: UIView) {
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func countTime(with count: TimeInterval) {
        timeCountLabl.text = "\(count)"
    }
    
    func popupViewDidDisappear() {
        print("闪屏广告消失了")
        popViewDismissBlock?()
    }
}
