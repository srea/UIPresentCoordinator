//
//  ViewController.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/01.
//

import UIKit
import SwiftUI
import UIPresentCoordinator
import StoreKit
import UserNotifications
import AppTrackingTransparency
import CoreLocation

class DemoViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var queueItemLabel: UILabel!
    
    private var swiftUIDebugView: DebugView?
    
    @IBOutlet weak var swiftUIView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watchQueue()
        
        let debugView = DebugView.init {  }

        let vc = UIHostingController.init(rootView: debugView)
        addChild(vc)
        swiftUIView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.pinEdges(to: swiftUIView)
        
        vc.didMove(toParent: self)
        
        swiftUIDebugView = debugView
        UIPresentCoordinator.shared.suspendInterruptDefaultAlert = true
        
    }
    
    @IBAction func suspendSwitchDidChange(_ sender: UISwitch) {
        if sender.isOn {
            UIPresentCoordinator.shared.suspend()
        } else {
            UIPresentCoordinator.shared.resume()
        }
    }
    
    private func watchQueue() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.queueItemLabel.text = "Waiting items: \(UIPresentCoordinator.shared.waitingItems) "
            self?.watchQueue()
        }
    }
    
    // Interrupt
    
    @IBAction func showUIKitAlert(_ sender: Any) {
        showUIKit(style: .alert, useQueue: false)
    }
    
    @IBAction func showUIKitSheet(_ sender: Any) {
        showUIKitPresent(useQueue: false)
    }
    
    // Queue
    
    @IBAction func showUIKitAlertQueue(_ sender: Any) {
        showUIKit(style: .alert, useQueue: true)
    }
    
    @IBAction func showUIKitSheetQueue(_ sender: Any) {
        showUIKitPresent(useQueue: true)
    }

    @IBAction func requestReviewDidTap(_ sender: Any) {
        requestReview()
    }

    @IBAction func requestRemoteNotificationDidTap(_ sender: Any) {
        requestAPNS()
    }
    
    @IBAction func requestIDFADidTap(_ sender: Any) {
        requestIDFA()
    }

    @IBAction func requestLocation(_ sender: Any) {
        requestGPS()
    }

    // Common
    
    private func showUIKit(style: UIAlertController.Style, useQueue: Bool) {
        let alert = UIAlertController.init(
            title: "UIKit",
            message: "\(useQueue ? "Queue" : "Interrupt")",
            preferredStyle: style)
        alert.addAction(.init(title: "close", style: .default, handler: nil))
        
        if useQueue {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func requestReview() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func requestAPNS() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(granted, error) in
            if granted {
                DispatchQueue.main.async() {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
    }
    
    private func requestIDFA() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          print(status)
        })
    }

    private func requestGPS() {
        locationManager.requestAlwaysAuthorization()
    }
    
    private func showUIKitPresent(useQueue: Bool) {
        
        guard let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "CustomDialog") as? CustomDialogViewController else {
            return
        }
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .crossDissolve

        let label = UILabel.init(frame: .init(x: 0, y: 0, width: 200, height: 200))
        label.text = "UIKit + Sheet\n\(useQueue ? "Queue" : "Interrupt")"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]

        label.center = viewController.view.center
        viewController.view.addSubview(label)

        if useQueue {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
                self?.showUIKit(style: .alert, useQueue: false)
                self?.presentQueue(viewController, animated: true, completion: nil)
            }
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            confirmFlushQueue()
        }
    }
    
    private func confirmFlushQueue() {
        let alert = UIAlertController.init(title: "Confirm", message: "Flush queue?", preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "ok", style: .destructive, handler: { _ in
            UIPresentCoordinator.shared.flush()
        }))
        
        alert.addAction(.init(title: "cancel", style: .default, handler: { _ in
        }))

        presentQueue(alert, animated: true)
    }
    
}


struct DebugView: View {
    
    private let presentCoordinator: UIPresentCoordinatable = UIPresentCoordinator.shared

    // Interrupt
    @State private var isPresentedAlert = false
    @State private var isPresentedSheet = false
    
    // Queue
    @ObservedObject private var alertTask = Task<Alert>()
    @ObservedObject private var sheetTask = Task<AnyView>()
    @ObservedObject private var listAlertTask = Task<Alert>()

    private let showAlert: (()->Void)?
    
    mutating func showSwiftUIAlert() {
        self.isPresentedAlert = true
//        self.presentCoordinator.enqueue(.alert(alertTask))
    }

    init(showAlert: (()->Void)?) {
        self.showAlert = showAlert
        _ = alertTask.content {
            Alert(title: Text("SwiftUI + Alert"), message: Text("Queue"))
        }
        _ = sheetTask.content {
            AnyView(
                VStack {
                    Text("SwiftUI + Sheet")
                    Text("Interrupt")
                }
            )
        }
    }
    
    var body: some View {

        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8) {
            // Interrupt
            Text("Interrupt")
            
            // Alert
            Button("Show SwiftUI + Alert", action: {
                self.isPresentedAlert = true
            })
            .alert(isPresented: self.$isPresentedAlert) {
                Alert(title: Text("SwiftUI + Alert"), message: Text("Interrupt"))
            }
            
            // Sheet
            Button("Show SwiftUI + Sheet", action: {
                self.isPresentedSheet = true
            })
            .sheet(isPresented: $isPresentedSheet) {
            } content: {
                Text("SwiftUI + Sheet")
                Text("Interrupt")
            }

            Text("Queue")
            
            Button("Show SwiftUI + Alert", action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    presentCoordinator.enqueue(.alert(alertTask))
                }
            })
            .alert(isPresented: $alertTask.isPresented) {
                presentCoordinator.dequeue()
            }
            
            Button("Show SwiftUI + Sheet", action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    presentCoordinator.enqueue(.view(sheetTask))
                }
            })
            .sheet(isPresented: $sheetTask.isPresented) {
            } content: {
                presentCoordinator.dequeue()
            }
        }
    }
}

extension UIView {
    func pinEdges(to other: UIView) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
    }
}
