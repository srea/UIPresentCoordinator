//
//  FirebaseInAppMessagingInterruptSuppression.swift
//  UI Queue
//
//  Created by srea on 2021/12/12.
//

import Foundation

public struct FirebaseInAppMessagingInterruptSuppression: InterruptSuppression {

    private(set) public var classTypes: [AnyClass] = []
    private(set) public var classNames: [String] = []

    public init() {
        addClassIfAvailable(list: &classTypes, className: "FIRIAMImageOnlyViewController")
        addClassIfAvailable(list: &classTypes, className: "FIRIAMBannerViewController")
        addClassIfAvailable(list: &classTypes, className: "FIRIAMModalViewController")
        addClassIfAvailable(list: &classTypes, className: "FIRIAMCardViewController")
    }
}
