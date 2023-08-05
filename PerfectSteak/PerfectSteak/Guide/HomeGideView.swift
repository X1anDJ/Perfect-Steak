//
//  HomeGideView.swift
//
//  Created by Dajun Xian on 7/24/23.
//

import UIKit
import SnapKit

final class HomeGideView: UIView {
    
    enum Style {
        case taptoEnter
        case calculate
        
        var imageFile: String {
            switch self {
            case .taptoEnter:
                return "TaptoEnter"
            case .calculate:
                return "Calculate"
            }
        }
        
        var imageViewSize: CGSize {
            switch self {
            case .taptoEnter:
                return CGSize(width: 210, height: 144)
            case .calculate:
                return CGSize(width: 210, height: 60)
            }
        }
    }
    
    private var style: Style
        
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    init(_ style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.image = UIImage(named: style.imageFile)
        addSubview(imageView)
        
        switch style {
        case .taptoEnter:
            imageView.snp.makeConstraints { make in
                make.size.equalTo(style.imageViewSize)
                make.right.equalToSuperview().offset(-10)
            }
        case .calculate:
            imageView.snp.makeConstraints { make in
                make.size.equalTo(style.imageViewSize)
                make.right.equalToSuperview().offset(-20)
            }
        }
    }
}
