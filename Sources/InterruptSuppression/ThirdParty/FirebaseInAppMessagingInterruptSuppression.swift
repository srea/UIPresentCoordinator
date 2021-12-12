//
//  FirebaseInAppMessagingInterruptSuppression.swift
//  UI Queue
//
//  Created by srea on 2021/12/12.
//

import Foundation

public struct FirebaseInAppMessagingInterruptSuppression: InterruptSuppression {
    
    public var classNames: [AnyClass] = []
    
    public init() {
        addClassIfAvailable(list: &classNames, className: "FIRIAMImageOnlyViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMBannerViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMModalViewController")
        addClassIfAvailable(list: &classNames, className: "FIRIAMCardViewController")
    }
}
