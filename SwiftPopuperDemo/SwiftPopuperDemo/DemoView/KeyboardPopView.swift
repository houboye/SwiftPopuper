//
//  KeyboardPopView.swift
//  SwiftPopuperDemo
//
//  Created by BY H on 2023/8/7.
//

import UIKit
import SwiftPopuper

class KeyboardPopView: UIView, SwiftPopuperProtocol {
    private let imageView = UIImageView(image: UIImage(named: "bottom"))
    private let textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textField.placeholder = "测试输出框"
        textField.textAlignment = .center
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    func supplyCustomPopupView() -> UIView {
        self
    }
    
    func layout(with superView: UIView) {
        snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(320)
        }
    }
}
