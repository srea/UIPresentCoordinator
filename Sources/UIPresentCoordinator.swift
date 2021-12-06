//
//  UIPresentCoordinator.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/01.
//

import UIKit
import Combine
import SwiftUI

public protocol UIPresentable {
    // SwiftUI
    func enqueue(_ task: SwiftUIPresentTask)
    func dequeue() -> Alert
    func dequeue() -> AnyView

    // UIKit
    func enqueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    
    func flush()
}

public final class UIPresentCoordinator: ObservableObject, UIPresentable {
    
    public static let shared = UIPresentCoordinator.init()

    public static var suspendInterruptDefaultAlert: Bool = true
    
    public var waitingItems: Int {
        queue.count()
    }
    
    private var isPresenting: Bool = false
    private var queue = Queue<PresentingType>()

    public init() {
        UIViewController.present_coordinator_swizzle()
    }
    
    public func flush() {
        queue.clearAll()
    }

    public func dismissed(_ viewController: UIViewController) {
        guard isPresenting else {
            handleNextQueue()
            return
        }

        isPresenting = false

        // for SwiftUI State Hidden
        if case .swiftUI(let task) = queue.dequeue() {
            task.hide()
        }

        handleNextQueue()
    }
    
    private func handleNextQueue() {
        guard !isPresenting else {
            return
        }

        guard let item = queue.peek() else {
            return
        }

        guard let topViewController = UIWindow.key?.topViewController() else {
            return
        }

        if Self.suspendInterruptDefaultAlert && topViewController is UIAlertController {
            return
        }

        isPresenting = true

        item.show()
    }

}

/// Enqueue
extension UIPresentCoordinator {
    public func enqueue(_ task: SwiftUIPresentTask) {
        // FIXME: 同一TASKが入るとだめ
        queue.enqueue(.swiftUI(task))
        handleNextQueue()
    }

    public func enqueue(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        queue.enqueue(.uiKit(.init(controller: viewController, animated: animated, completion: completion)))
        handleNextQueue()
    }
}

/// Dequeue
extension UIPresentCoordinator {
    public func dequeue() -> AnyView {
        guard case .swiftUI(let alert) = queue.peek() else {
            fatalError()
        }
        guard case .view(let task) = alert else {
            fatalError()
        }
        guard let ui = task.content else {
            fatalError()
        }
        return ui
    }

    public func dequeue() -> Alert {
        guard case .swiftUI(let alert) = queue.peek() else {
            fatalError()
        }
        guard case .alert(let task) = alert else {
            fatalError()
        }
        guard let ui = task.content else {
            fatalError()
        }
        return ui
    }
}
