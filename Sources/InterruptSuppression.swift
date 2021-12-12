//
//  InterruptSuppression.swift
//  UI Queue
//
//  Created by srea on 2021/12/12.
//

import Foundation


public protocol InterruptSuppression {
    var classNames: [AnyClass] { get }
}

extension InterruptSuppression {
    func addClassIfAvailable(list: inout [AnyClass], className: String) {
        guard let classType = NSClassFromString(className) else {
            return
        }
        list.append(classType)
    }
}

struct SystemAlertInterruptSuppression: InterruptSuppression {
    
    public var classNames: [AnyClass] = []
    
    public init() {
        addClassIfAvailable(list: &classNames, className: "UIAlertController")
        addClassIfAvailable(list: &classNames, className: "SwiftUI.PlatformAlertController")
        addClassIfAvailable(list: &classNames, className: "SKStoreReviewPresentationWindow")
    }
}

struct FirebaseInAppMessagingInterruptSuppression: InterruptSuppression {
    
    public var classNames: [AnyClass] = []
    
    public init() {
        addClassIfAvailable(list: &classNames, className: "FIRIAMImageOnlyViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMBannerViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMModalViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMCardViewController")
    }
}

struct UserDefineInterruptSuppression: InterruptSuppression {
    public var classNames: [AnyClass] = []
    
    public init(objects: [AnyClass]) {
        classNames.append(contentsOf: objects)
    }
}
