//
//  PresentingInfo.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

import UIKit

public struct UIKitPresentTask {
    let controller: UIViewController
    let animated: Bool
    let completion: (() -> Void)?
    
    func show() {
        guard let topViewController = UIWindow.key?.topViewController() else {
            return
        }
        topViewController.present(controller, animated: animated, completion: completion)
    }
}
