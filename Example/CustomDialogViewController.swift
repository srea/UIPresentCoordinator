//
//  CustomDialogViewController.swift
//  UI Queue
//
//  Created by srea on 2021/12/07.
//

import Foundation
import UIKit

class CustomDialogViewController: UIViewController {
    
    @IBOutlet weak var dialogView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialogView.layer.cornerRadius = 10.0
        self.dialogView.backgroundColor = .random()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
