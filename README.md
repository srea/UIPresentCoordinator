# UIPresentCoordinator
Controls interrupt handling, such as alert views, and is compatible with UIKit and Swift UI.

This library manages items that are about to be presented in a queue and displays them on a first-in, first-out basis.

I have also tried to control the dialogs that the system displays, such as Push Notifications, App Tracking Transparency, and Location, but it has proven difficult.

## Motivation

The purpose of creating this library was to make it easier to solve the following problems.

```
[Presentation] Attempt to present <UIAlertController> on <ViewController>  which is already presenting <UIViewController>.
```

In addition, I felt it was necessary to have a mechanism that takes into account SwiftUI as well as UIKit.

## Requirements

- iOS 13+
- Swift 5

## Demo

|Before|After|
|-|-|
|![Before](https://github.com/srea/UIPresentCoordinator/raw/main/Docs/before.gif)|![After](https://github.com/srea/UIPresentCoordinator/raw/main/Docs/after.gif)|

![Demo](https://github.com/srea/UIPresentCoordinator/raw/main/Docs/demo.gif)

## Installation

### SwiftPM

- File > Swift Packages > Add Package Dependency...
- Add `https://github.com/srea/UIPresentCoordinator`

### CocoaPods

```
pod 'UIPresentCoordinator'
```

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

## Contributions

Your ideas, bug fixes, improvements, etc. are all welcome.

## License

UIPresentCoordinator is licensed under the MIT license. See [LICENSE](https://github.com/srea/UIPresentCoordinator/blob/main/LICENSE) for more info.
