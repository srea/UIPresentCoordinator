//
//  Queue.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/02.
//

import Foundation

struct Queue<T> {
    private var elements: [T] = []
    
    mutating func enqueue(_ element: T) {
        elements.append(element)
    }
    
    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }

    mutating func clearAll() {
        elements.removeAll()
    }

    func isEmpty() -> Bool {
        elements.isEmpty
    }
    
    func peek() -> T? {
        elements.first
    }
    
    func count() -> Int {
        elements.count
    }
}
