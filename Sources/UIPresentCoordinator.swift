//
//  UIPresentCoordinator.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/01.
//

import UIKit
import Combine
import SwiftUI

public protocol UIPresentCoordinatable {

    func enqueue(_ task: SwiftUIPresentTask)
    func enqueue(_ task: UIKitPresentTask)

    func dequeue() -> Alert

    func suspend()
    func resume()

    func flush()
}

public final class UIPresentCoordinator: ObservableObject, UIPresentCoordinatable {

    public static let shared = UIPresentCoordinator.init()

    public var interruptSuppressionTargets: [InterruptSuppression] = []

    public var waitingItems: Int {
        queue.count()
    }

    private var isSuspended: Bool = true
    private var isPresenting: Bool = false
    private var queue = Queue<PresentingTask>()

    private weak var presentingWindow: AnyObject?

    public init() {
        UIWindow.present_coordinator_swizzle()
        UIViewController.present_coordinator_swizzle()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidBecomeVisible(notification:)),
                                               name: UIWindow.didBecomeVisibleNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidBecomeHidden(notification:)),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func interruptSuppression(object: AnyObject) -> Bool {
        let type: AnyClass = type(of: object)
        return !interruptSuppressionTargets
            .filter {
                !$0.classTypes.filter { type === $0 }.isEmpty ||
                !$0.classNames.filter { NSStringFromClass(type).contains($0) }.isEmpty
            }
            .isEmpty
    }

    @objc func windowDidBecomeVisible(notification: Notification) {
        guard let window = notification.object as? UIWindow else {
            return
        }
        if interruptSuppression(object: window) {
            presentingWindow = notification.object as AnyObject
        }
    }

    @objc func windowDidBecomeHidden(notification: Notification) {
        dismissed()
    }

    public func flush() {
        queue.clearAll()
    }

    public func dismissed() {
        guard isPresenting else {
            handleNextQueue()
            return
        }

        isPresenting = false

        let item = queue.dequeue()

        if case .swiftUI(let task) = item {
            task.hide()
        }

        if case .uiKit(.window(let task)) = item {
            task.hide()
        }

        handleNextQueue()
    }

    private func handleNextQueue() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.presentingWindow == nil else {
                return
            }
            guard !self.isSuspended else {
                return
            }
            guard !self.isPresenting else {
                return
            }
            guard let item = self.queue.peek() else {
                return
            }

            self.isPresenting = true

            item.show()
        }
    }

    public func suspend() {
        isSuspended = true
    }

    public func resume() {
        isSuspended = false
        handleNextQueue()
    }

}

/// Enqueue
extension UIPresentCoordinator {

    func shouldEnqueue(object: AnyObject) -> Bool {
        
        guard interruptSuppression(object: object) else {
            return false
        }
        guard !isSuspended else {
            return true
        }
        guard !queue.isEmpty() else {
            return true
        }
        guard case .swiftUI = queue.peek() else {
            return true
        }
        return false
    }

    public func enqueue(_ task: SwiftUIPresentTask) {
        // FIXME: ??????TASK??????????????????
        enqueue(type: .swiftUI(task))
    }

    public func enqueue(_ task: UIKitPresentTask) {
        enqueue(type: .uiKit(task))
    }

    private func enqueue(type: PresentingTask) {
        queue.enqueue(type)
        handleNextQueue()
    }
}

/// Dequeue
extension UIPresentCoordinator {
    public func dequeue() -> some View {
        guard case .swiftUI(.view(let task)) = queue.peek(), let ui = task.content else {
            fatalError()
        }
        return ui
    }

    public func dequeue() -> Alert {
        guard case .swiftUI(.alert(let task)) = queue.peek(), let ui = task.content else {
            fatalError()
        }
        return ui
    }
}
