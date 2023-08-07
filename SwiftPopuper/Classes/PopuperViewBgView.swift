//
//  PopuperViewBgView.swift
//  SwiftPopuper
//
//  Created by BY H on 2023/8/4.
//

import UIKit

class PopuperViewBgView: UIView {
    var isHiddenBg = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self && self.isHiddenBg {
            return nil
        }
        return hitView
    }
}
