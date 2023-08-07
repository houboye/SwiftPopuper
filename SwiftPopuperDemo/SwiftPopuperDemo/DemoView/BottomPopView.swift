//
//  BottomPopView.swift
//  SwiftPopuperDemo
//
//  Created by BY H on 2023/8/7.
//

import UIKit
import SwiftPopuper

class BottomPopView: UIView, SwiftPopuperProtocol {
    private let imageView = UIImageView(image: UIImage(named: "bottomShare"))
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    func supplyCustomPopupView() -> UIView {
        return self
    }
    
    func layout(with superView: UIView) {
        snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(220)
        }
    }
}
