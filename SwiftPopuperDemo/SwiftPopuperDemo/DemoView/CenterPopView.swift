//
//  CenterPopView.swift
//  SwiftPopuperDemo
//
//  Created by BY H on 2023/8/7.
//

import UIKit
import SwiftPopuper

class CenterPopView: UIView, SwiftPopuperProtocol {
    private let imageView = UIImageView(image: UIImage(named: "center"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.centerY.equalTo(superView)
            make.height.equalTo(400)
        }
    }
    
}
