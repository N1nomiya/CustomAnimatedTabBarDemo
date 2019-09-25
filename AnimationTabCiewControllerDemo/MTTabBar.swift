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
        let cornerRadius = viewHeight * 0.3
        
        let r1: CGFloat = 12
        let r2: CGFloat = 32
        let sinA: CGFloat = sin(r1 / (r1 + r2))
        let A: CGFloat = asin(sinA)
        let B: CGFloat = CGFloat.pi / 2 - A
        let cosA: CGFloat = cos(A)
        let horiW: CGFloat = r2 * cosA

        let magicN1 = magicN(CGFloat.pi * 2 / B)
        let magicN2 = magicN(CGFloat.pi * 2 / B)

        let cur1P = CGPoint(x: viewWidth/2 - (r1+r2)*cosA,
                            y: 0)
        let cur1C1 = CGPoint(x: viewWidth/2 - (r1+r2)*cosA + r1*magicN1,
                             y: 0)
        let cur1C2 = CGPoint(x: viewWidth/2 - horiW - r1*magicN1*sinA,
                             y: r2*sinA - r1*magicN1*cosA)
        let cur1Des = CGPoint(x: viewWidth/2 - horiW,
                              y: r2*sinA)

        let cur2C1 = CGPoint(x: viewWidth/2 - horiW + r2*magicN2*sinA,
                             y: r2*sinA + r2*magicN2*cosA)
        let cur2C2 = CGPoint(x: viewWidth/2 - r2*magicN2,
                             y: r2)
        let cur2Des = CGPoint(x: viewWidth/2,
                              y: r2)

        let cur3C1 = CGPoint(x: viewWidth/2 + r2*magicN2,
                             y: r2)
        let cur3C2 =  CGPoint(x: viewWidth/2 + horiW - r2*magicN2*sinA,
                              y: r2*sinA  + r2*magicN2*cosA)
        let cur3Des = CGPoint(x: viewWidth/2 + horiW,
                              y: r2*sinA)


        let cur4C1 = CGPoint(x: viewWidth/2 + horiW + r1*magicN1*sinA,
                             y: r2*sinA - r1*magicN1*cosA)
        let cur4C2 = CGPoint(x: viewWidth/2 + (r1+r2)*cosA - r1*magicN1,
                             y: 0)
        let cur4Des = CGPoint(x: viewWidth/2 + (r1+r2)*cosA,
                              y: 0)

        let path: UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)

        path.move(to: cur1P)
        path.addCurve(to: cur1Des, controlPoint1: cur1C1, controlPoint2: cur1C2)
        path.addCurve(to: cur2Des, controlPoint1: cur2C1, controlPoint2: cur2C2)
        path.addCurve(to: cur3Des, controlPoint1: cur3C1, controlPoint2: cur3C2)
        path.addCurve(to: cur4Des, controlPoint1: cur4C1, controlPoint2: cur4C2)
        
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
    
    private func magicN(_ n: CGFloat) -> CGFloat {
        // 一个圆划分为 n 个贝赛尔曲线最佳控制点长度公式
        return (4/3)*tan(CGFloat.pi/(2*n))
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


