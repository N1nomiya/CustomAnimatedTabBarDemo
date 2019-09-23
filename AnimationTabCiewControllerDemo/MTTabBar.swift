//
//  MTTabBar.swift
//  AnimationTabCiewControllerDemo
//
//  Created by Zark on 2019/9/22.
//  Copyright © 2019 Zark. All rights reserved.
//

import UIKit

protocol MTTabBarDelegate: class {
    func leftButtonTapped()
    func rightButtonTapped()
}

class MTTabBar: UIView {
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "left"), for: .normal)
        self.addSubview(button)
        button.addTarget(self, action: #selector(leftButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var centerView: MTTabBarCenterView = {
        let centerView = MTTabBarCenterView(frame: CGRect(origin: .zero, size: CGSize(width: F.centerViewW, height: F.centerViewW)))
        centerView.delegate = self
        self.addSubview(centerView)
        return centerView
    }()
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "right"), for: .normal)
        self.addSubview(button)
        button.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    override var backgroundColor: UIColor? { willSet { computeShape() } }
    
    private var shapeColor: UIColor
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    weak var delegate: MTTabBarDelegate?
    
    init(shapeColor: UIColor) {
        self.shapeColor = shapeColor
        super.init(frame: .zero)
        setupUI()
    }
       
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
       
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != lastComputedLayerSize {
            computeShape()
        }
    }
    
    private func setupUI() {
        leftButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(0.35)
            make.height.width.equalTo(F.sideBtnW)
        }
        centerView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(F.centerViewW)
            make.bottom.equalTo(self.snp.top).offset(F.centerViewW/2)
        }
        rightButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.65)
            make.height.width.equalTo(F.sideBtnW)
        }
    }
    
    /* Store the size when computing the shape in order
    not to recompute on every call to `layoutSubview` if
    it's not necessary.
    */
    private var lastComputedLayerSize: CGSize = .zero
    private func computeShape() {
        if let sublayer = layer.sublayers?.first,
            sublayer == shapeLayer {
                sublayer.removeFromSuperlayer()
        }
        
        let viewWidth = frame.size.width
        let viewHeight = frame.size.height
//        let roundHolderRadius = viewHeight * 2 / 3
        /// 包围圆的半径
        let roundHolderRadius: CGFloat = 33
        /// 过渡曲线半径
        let transitionWidth: CGFloat = 10
        /// 整体圆角半径
        let cornerRadius = viewHeight * 0.3
        
        let initPoint1 = CGPoint(x: viewWidth/2 - roundHolderRadius - transitionWidth, y: 0)
        let curve1Des = CGPoint(x: viewWidth/2 - roundHolderRadius, y: transitionWidth)
        let curve1Control1 = CGPoint(x: viewWidth/2 - roundHolderRadius - transitionWidth*0.5, y: 0)
        let curve1Control2 = CGPoint(x: viewWidth/2 - roundHolderRadius, y: 0)
        
        let initPoint2 = CGPoint(x: viewWidth/2 - roundHolderRadius, y: 0)
        let circleCenter = CGPoint(x: viewWidth/2, y: 0)
        
        let initPoint3 = CGPoint(x: viewWidth/2 + roundHolderRadius, y: transitionWidth)
        let curve2Des = CGPoint(x: viewWidth/2 + roundHolderRadius + transitionWidth, y: 0)
        let curve2Control1 = CGPoint(x: viewWidth/2 + roundHolderRadius, y: 0)
        let curve2Control2 = CGPoint(x: viewWidth/2 + roundHolderRadius + transitionWidth*0.5, y: 0)
        
        /// 圆角
        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        /// 左过渡
        path.move(to: initPoint1)
        path.addCurve(to: curve1Des, controlPoint1: curve1Control1, controlPoint2: curve1Control2)
        /// 包围圆
        path.addLine(to: initPoint2)
        path.addArc(withCenter: circleCenter, radius: roundHolderRadius, startAngle: CGFloat(180.0).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: false)
        /// 右过渡
        path.addLine(to: initPoint3)
        path.addCurve(to: curve2Des, controlPoint1: curve2Control1, controlPoint2: curve2Control2)
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = shapeColor.cgColor
        
//        shapeLayer.shadowColor = UIColor(white: 0.0, alpha: 0.3).cgColor
//        shapeLayer.shadowOffset = CGSize(width: 0, height: 2)
//        shapeLayer.shadowOpacity = 1
//        shapeLayer.shadowRadius = cornerRadius
//        shapeLayer.shadowPath = path.cgPath
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.insertSublayer(shapeLayer, at: 0)
        lastComputedLayerSize = frame.size
    }
    
    /// 使 centerButton 越界部分可响应点击
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isHidden {
            let newPoint = self.convert(point, to: centerView)
            if centerView.point(inside: newPoint, with: event) {
                return centerView.hitTest(newPoint, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
    
    
    public func unExpendCenterView() {
        centerView.unExpend()
    }
}

// MARK: - Controls
extension MTTabBar {
    @objc func leftButtonTapped(_ sender: UIButton) {
        delegate?.leftButtonTapped()
    }

    @objc func rightButtonTapped(_ sender: UIButton) {
        delegate?.rightButtonTapped()
    }
}

// MARK: - MTTabBarCenterViewDelegate
extension MTTabBar: MTTabBarCenterViewDelegate {
    func topButtonTapped() {
        delegate?.leftButtonTapped()
    }
    
    func bottomButtonTapped() {
        delegate?.rightButtonTapped()
    }
}

// MARK: - Frame
extension MTTabBar {
    fileprivate struct F {
        static let centerViewW: CGFloat = 54
        static let sideBtnW: CGFloat = 30
    }
}


