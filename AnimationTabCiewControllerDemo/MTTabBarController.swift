//
//  MTTabBarController.swift
//  AnimationTabCiewControllerDemo
//
//  Created by Zark on 2019/9/22.
//  Copyright © 2019 Zark. All rights reserved.
//

import UIKit
import SnapKit

class MTTabBarController: UITabBarController {
    
    private let customTabBar = MTTabBar(shapeColor: .systemPurple)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSelf()
        configureTabBar()
        setupViews()
        addTapGesture()
    }
    
    private func configureSelf() {
        let firstVC = UIViewController()
        let secondVC = UIViewController()
        firstVC.view.backgroundColor = .systemBlue
        secondVC.view.backgroundColor = .systemPink
        self.viewControllers = [firstVC, secondVC]
        self.tabBar.isHidden = true
        self.view.backgroundColor = .white
    }

    private func configureTabBar() {
        customTabBar.delegate = self
        view.addSubview(customTabBar)
        
        customTabBar.layer.shadowColor = UIColor(white: 0.0, alpha: 0.3).cgColor
        customTabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        customTabBar.layer.shadowOpacity = 1
    }
    
    private func setupViews() {
        customTabBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-30)
//            make.center.equalToSuperview()
            make.height.equalTo(54)
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        self.customTabBar.unExpendCenterView()
    }
}

extension MTTabBarController: MTTabBarDelegate {
    func leftButtonTapped() {
        self.selectedIndex = 0
    }
    
    func centerButtonTapped() {
        
    }
    
    func rightButtonTapped() {
        self.selectedIndex = 1
    }
}

