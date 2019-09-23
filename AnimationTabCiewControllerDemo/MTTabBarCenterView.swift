//
//  MTTabBarCenterView.swift
//  AnimationTabCiewControllerDemo
//
//  Created by Zark on 2019/9/23.
//  Copyright © 2019 Zark. All rights reserved.
//

import UIKit
import SnapKit

protocol MTTabBarCenterViewDelegate: class {
    func topButtonTapped()
    func bottomButtonTapped()
}

class MTTabBarCenterView: UIView {
    
    private lazy var expandButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "add"), for: .normal)
        btn.addTarget(self, action: #selector(expendButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()
    private lazy var expandingTopButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "left"), for: .normal)
        btn.addTarget(self, action: #selector(expandingTopButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()
    private lazy var expandingBottomButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "right"), for: .normal)
        btn.addTarget(self, action: #selector(expandingBottomButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    weak var delegate: MTTabBarCenterViewDelegate?
    
    // distance between button and border, need calculate in init
    private var btnVerticalSideMargin: CGFloat
    
    override init(frame: CGRect) {
        btnVerticalSideMargin = frame.size.width/2 - F.btnW/2
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let viewWidth = frame.size.width
        backgroundColor = .systemGreen
        self.layer.cornerRadius = viewWidth/2
        self.clipsToBounds = true
        
        addSubview(expandButton)
        addSubview(expandingTopButton)
        addSubview(expandingBottomButton)
        
        expandButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(F.btnW)
        }
        expandingTopButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(self.frame.height + btnVerticalSideMargin)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(F.btnW)
        }
        expandingBottomButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(self.frame.height + btnVerticalSideMargin + F.btnW + F.btnInterMargin)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(F.btnW)
        }
        expandingTopButton.isHidden = true
        expandingTopButton.alpha = 0
        expandingBottomButton.isHidden = true
        expandingBottomButton.alpha = 0
    }
}

extension MTTabBarCenterView {
    @objc func expendButtonTapped(_ sender: UIButton) {
        expend()
    }
    
    @objc func expandingTopButtonTapped(_ sender: UIButton) {
        delegate?.topButtonTapped()
    }
    
    @objc func expandingBottomButtonTapped(_ sender: UIButton) {
        delegate?.bottomButtonTapped()
    }
    
    private func expend() {
        expandingTopButton.isHidden = false
        expandingBottomButton.isHidden = false
        
        let expandedHeight: CGFloat = F.btnW * 2 + F.btnInterMargin + btnVerticalSideMargin * 2
        
        self.snp.updateConstraints { (make) in make.height.equalTo(expandedHeight) }
        expandButton.snp.updateConstraints { (make) in
            make.centerY.equalToSuperview().offset(-expandedHeight/2 - btnVerticalSideMargin)
        }
        expandingTopButton.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(btnVerticalSideMargin)
        }
        expandButton.layer.removeAllAnimations()
        expandingTopButton.layer.removeAllAnimations()
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: T.duration, delay: 0,
                       usingSpringWithDamping: T.damping, initialSpringVelocity: 0, options: .curveEaseOut,
                       animations: {
                        self.expandButton.alpha = 0
                        self.expandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-90).toRadians())
                        self.expandingTopButton.alpha = 1
                        self.superview?.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.expandButton.isHidden = true
            }
        }
        
        expandingBottomButton.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(btnVerticalSideMargin + F.btnW + F.btnInterMargin)
        }
        expandingBottomButton.layer.removeAllAnimations()
        UIView.animate(withDuration: T.duration, delay: 0.1,
                       usingSpringWithDamping: T.damping, initialSpringVelocity: 0, options: .curveEaseOut,
                       animations: {
                        self.expandingBottomButton.alpha = 1
                        self.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func unExpend() {
        self.snp.updateConstraints { (make) in make.height.equalTo(self.frame.width)}
        expandButton.snp.updateConstraints { (make) in
            make.centerY.equalToSuperview()
        }
        expandingTopButton.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(self.frame.height + btnVerticalSideMargin)
        }
        expandingBottomButton.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(self.frame.height + btnVerticalSideMargin + F.btnW + F.btnInterMargin)
        }
        
        expandButton.isHidden = false
        
        expandButton.layer.removeAllAnimations()
        expandingTopButton.layer.removeAllAnimations()
        expandingBottomButton.layer.removeAllAnimations()
        self.layer.removeAllAnimations()
        
        UIView.animate(withDuration: T.duration, delay: 0,
                       usingSpringWithDamping: T.damping, initialSpringVelocity: 0, options: .curveEaseOut,
                       animations: {
                        self.expandButton.alpha = 1
                        self.expandButton.transform = .identity
                        self.expandingTopButton.alpha = 0
                        self.expandingBottomButton.alpha = 0
                        self.superview?.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.expandingTopButton.isHidden = true
                self.expandingBottomButton.isHidden = true
            }
        }
    }
}

extension MTTabBarCenterView {
    fileprivate struct F {
        static let btnW: CGFloat = 24
        static let btnInterMargin: CGFloat = 12
    }
    fileprivate struct T {
        static let duration: Double = 0.5
        static let damping: CGFloat = 0.6
    }
}
