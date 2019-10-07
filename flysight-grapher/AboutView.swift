//
//  SettingsView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftUI
import MessageUI
import Combine

final class SettingsStore: ObservableObject {
    let didChange = PassthroughSubject<SettingsStore, Never>()

    private var _wingyperf = UserDefault(key: "showWingsuitPerf", defaultValue: false)

    var showWingsuitPerf: Bool {
        get { return _wingyperf.wrappedValue }
        set {
            _wingyperf.wrappedValue = newValue
            didChange.send(self)
        }
    }
    
    @UserDefault(key: "showSwoopPerf", defaultValue: false)
    var showSwoopPerf: Bool {
        didSet {
            didChange.send(self)
        }
    }
    
    @UserDefault(key: "displayWingsuitWindowOnGraph", defaultValue: false)
    var displayWingsuitWindowOnGraph: Bool {
        didSet {
            didChange.send(self)
        }
    }
    
    @Published
    private var _devmode = UserDefault(key: "developerMode", defaultValue: false)
    var developerMode: Bool {
        get { return _devmode.wrappedValue }
        set {
            _devmode.wrappedValue = newValue
            didChange.send(self)
        }
    }
}


struct AboutView : View {
    @EnvironmentObject var settings: SettingsStore
    private let mailComposeDelegate = MailDelegate()
    let canSendMail = MFMailComposeViewController.canSendMail()
    
    @State var localDevMode = false;
    
//    let loadFile: (URL) -> ()

    var body: some View {
//        let dummyAngle = Button(action: {
//            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-angle", ofType: "csv")!)
//
//            self.loadFile(url)
//        }) {
//            Text("Dummy Angle Jump")
//        }
//        let dummyWingsuit = Button(action: {
//            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-wingsuit", ofType: "csv")!)
//
//            self.loadFile(url)
//        }) {
//            Text("Dummy Wingsuit Flight")
//        }
//        let dummySwoop = Button(action: {
//            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-swoop", ofType: "csv")!)
//
//            self.loadFile(url)
//
//        }) {
//            Text("Dummy Swoop")
//        }
//
        
        return List {
            Section(header: Text("Wingsuit")) {
                Toggle(isOn: $settings.showWingsuitPerf) {
                    Text("Show wingsuit data in performance view")
                }.padding()
//                Toggle(isOn: $settings.displayWingsuitWindowOnGraph) {
//                    Text("Show wingsuit performance window on graph")
//                }.padding()
            }
//            Section(header: Text("Swoop")) {
//                Toggle(isOn: $settings.showSwoopPerf) {
//                    Text("Show swoop data in performance view")
//                }.padding()
//            }
            Section(header: Text("Support")) {
                if canSendMail {
                    Button(action: {
                        self.presentMailCompose()
                    }) {
                        Text("Email the developer")
                    }
                } else {
                    Text("For support, contact richo@psych0tik.net")
                }
            }
            Section(header: Text("Developer")) {
                Toggle(isOn: $settings.developerMode) {
                    Text("Show developer tools")
                }.padding()
                // This doesn't actually update


                if settings.developerMode {
                    Text("dummySwoop;");
                    Text("dummyAngle;");
                    Text("dummyWingsuit;");
                }
            }
        }.listStyle(GroupedListStyle())
    }
    
    private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }

    }
    
    private func presentMailCompose() {
        let vc = UIApplication.shared.keyWindow?.rootViewController

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate

        vc?.present(composeVC, animated: true)
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        func cb(_url: URL) {
            
        }
        return AboutView()
    }
}
#endif
