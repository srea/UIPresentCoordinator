//
//  ViewController.swift
//  UI Present Coordinator
//
//  Created by srea on 2021/12/01.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aaa = AAA.init { [weak self] in
            self?.didTap(())
        }

        let vc = UIHostingController.init(rootView: aaa)
        vc.view.frame = .init(x: 0, y: 0, width: 200, height: 300)
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
    }
    
    private func showModalAfter3() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            let alert = UIAlertController.init(title: "UIKit Async 3 sec", message: "UIAlertController", preferredStyle: .alert)
            alert.addAction(.init(title: "close", style: .default, handler: { _ in
                // do stuff
            }))
            self.presentQueue(alert, animated: true) {
                print("completion 1")
            }
        }
    }

    @IBAction func didTap(_ sender: Any) {
        
        let alert = UIAlertController.init(title: "UIKit", message: "UIAlertController", preferredStyle: .alert)
        
        alert.addAction(.init(title: "close", style: .default, handler: { _ in
            // do stuff
        }))
        alert.addAction(.init(title: "show modal after 3", style: .destructive, handler: { [weak self] _ in
            self?.showModalAfter3()
        }))
        
        presentQueue(alert, animated: true) {
            print("completion 1")
        }
        
        let vc = UIViewController.init()
        vc.view.backgroundColor = .red

        presentQueue(vc, animated: true) {
            print("completion 2")
        }
        
        let vc2 = AViewController.init()
        vc2.view.backgroundColor = .blue

        presentQueue(vc2, animated: true) {
            print("completion 2")
        }

        
        let alert2 = UIAlertController.init(title: "UIKit", message: "UIAlertController", preferredStyle: .actionSheet)
        
        alert2.addAction(.init(title: "ok", style: .default, handler: { _ in
            // do stuff
        }))
        
        presentQueue(alert2, animated: true) {
            print("completion 3")
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Debug: Queueを削除
            UIPresentCoordinator.shared.flush()
        }
    }
    
}

struct AAA: View {
    
    private let presentCoordinator: UIPresentable = UIPresentCoordinator.shared

    // タスクを用意
    @ObservedObject private var alertTask = Task<Alert>()
    @ObservedObject private var sheetTask = Task<AnyView>()
    @ObservedObject private var listAlertTask = Task<Alert>()

    private let didTap: (()->Void)?
    
    init(didTap: (()->Void)?) {
        self.didTap = didTap
        alertTask.content {
            Alert(title: Text("ポケモン名"),
                  message: Text("ピカチュウ"),
                  dismissButton: .default(Text("閉じる")))
        }
        listAlertTask.content {
            Alert(title: Text("List Button"))
        }
    }
    
    var body: some View {

        VStack {
            // 画面遷移先
            Button(action: {
                presentCoordinator.enqueue(.view(sheetTask.content {
                    AnyView.init(
                        Button {
                            presentCoordinator.enqueue(.alert(listAlertTask))
                            sheetTask.isPresented.toggle()
                        } label: {
                            Text("Alert Enqueue")
                        }
                    )
                }))
            }) {
                Text("Show Sheet Enqueue")
            }
            .sheet(isPresented: $sheetTask.isPresented) {
            } content: {
                presentCoordinator.dequeue()
            }

            // ボタン
            Button(action: {
//                self.didTap?()
                self.presentCoordinator.enqueue(.alert(alertTask))
//                self.didTap?()
            }) {
                Text("Alert Enqueue")
            }
            .alert(isPresented: $alertTask.isPresented) {
                self.presentCoordinator.dequeue()
            }

            // リストボタン
            List(1..<2) { index in
                Button(action: {
//                    self.didTap?()
                    self.presentCoordinator.enqueue(.alert(listAlertTask))
//                    self.didTap?()
                }) {
                    Text("Item \(index)")
                }
            }.alert(isPresented: $listAlertTask.isPresented) {
                self.presentCoordinator.dequeue()
            }
        }
    }
}
