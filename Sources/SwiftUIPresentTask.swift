//
//  SwiftUIPresentTask.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/03.
//

import SwiftUI

public enum SwiftUIPresentTask {
    case alert(Task<Alert>)
    case view(Task<AnyView>)

    func show() {
        presented(flag: true)
    }

    func hide() {
        presented(flag: false)
    }

    private func presented(flag: Bool) {
        switch self {
        case .alert(let task):
            task.isPresented = flag
        case .view(let task):
            task.isPresented = flag
        }
    }
}

public class Task<T>: ObservableObject {
    
    @Published public var isPresented = false
    var content: T?
    
    init() {}
    
    func content(_ content: () -> T) -> Task<T> {
        self.content = content()
        return self
    }
}
