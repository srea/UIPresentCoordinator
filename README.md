# UIPresentCoordinator
Controls interrupt handling, such as alert views, and is compatible with UIKit and Swift UI.

## Installation


## Usage

### UIKit

#### Before

```swift
// Display without interruption
let alert = UIAlertController(...)
...
present(alert, animated: true, completion: nil)
```

#### After

```swift
// Display without interruption
let alert = UIAlertController(...)
...
presentQueue(alert, animated: true, completion: nil)
```

### SwiftUI

#### Before

```swift
struct DebugView: View {
    private let presentCoordinator: UIPresentable = UIPresentCoordinator.shared

    @State private var isPresented = false
    
    var body: some View {
        Button("Show Alert", action: {
            isPresented = true
        })
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Alert"))
        }
    }
}
```

#### After

```swift
struct DebugView: View {
    private let presentCoordinator: UIPresentable = UIPresentCoordinator.shared

    @ObservedObject private var alertTask = Task<Alert>()
    
    var body: some View {
        Button("Show Alert", action: {
            presentCoordinator.enqueue(.alert(alertTask.content({
                Alert(title: Text("Alert"))
            })))
        })
        .alert(isPresented: $alertTask.isPresented) {
            presentCoordinator.dequeue()
        }
    }
}
```
