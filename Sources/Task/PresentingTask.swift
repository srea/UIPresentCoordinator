//
//  PresentingTask.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

public enum PresentingTask {
    case swiftUI(SwiftUIPresentTask)
    case uiKit(UIKitPresentTask)

    func show() {
        switch self {
        case .swiftUI(let task):
            task.show()
        case .uiKit(let task):
            task.show()
        }
    }
}
