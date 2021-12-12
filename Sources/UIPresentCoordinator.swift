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

    public var interruptions: [Interruption] = []

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
        return !interruptions
            .filter {
                !$0.classNames.filter { type === $0 }.isEmpty
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
        guard let window = notification.object as? UIWindow else {
            return
        }
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
    public func enqueue(_ task: SwiftUIPresentTask) {
        // FIXME: 同一TASKが入るとだめ
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


public protocol Interruption {
    var classNames: [AnyClass] { get }
}

extension Interruption {
    func addClassIfAvailable(list: inout [AnyClass], className: String) {
        guard let classType = NSClassFromString(className) else {
            return
        }
        list.append(classType)
    }
}


public extension UIPresentCoordinator {

    struct SystemAlertInterruption: Interruption {

        public var classNames: [AnyClass] = []
        
        public init() {
            addClassIfAvailable(list: &classNames, className: "UIAlertController")
            addClassIfAvailable(list: &classNames, className: "SwiftUI.PlatformAlertController")
            addClassIfAvailable(list: &classNames, className: "SKStoreReviewPresentationWindow")
        }
    }

    struct FirebaseInAppMessagingInterruption: Interruption {

        public var classNames: [AnyClass] = []

        public init() {
            addClassIfAvailable(list: &classNames, className: "FIRIAMImageOnlyViewController")
            addClassIfAvailable(list: &classNames, className: "FIRIAMBannerViewController")
            addClassIfAvailable(list: &classNames, className: "FIRIAMModalViewController")
            addClassIfAvailable(list: &classNames, className: "FIRIAMCardViewController")
        }
    }
    
    struct CustomClassInterruption: Interruption {
        public var classNames: [AnyClass] = []
        
        public init(objects: [AnyClass]) {
            classNames.append(contentsOf: objects)
        }
    }
}
