//
//  AlertController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/24.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {
    
    private lazy var alertWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ClearViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindowLevelAlert
        return window
    }()
    
    func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        guard let rootVC = alertWindow.rootViewController else { return }
        alertWindow.makeKeyAndVisible()
        rootVC.present(self, animated: flag, completion: completion)
    }
}

private class ClearViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
}
