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


struct AboutView : View {
    @State var showPerfWindow = true
    @State var developerMode = false
    
    private let mailComposeDelegate = MailDelegate()
    
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
        
        
        return List {
            Section(header: Text("Wingsuit")) {
                Toggle(isOn: $showPerfWindow) {
                    Text("Show performance window in Graph view")
                }.padding()
            }
            Section(header: Text("About")) {
                Button(action: {
                    self.presentMailCompose()
                }) {
                    Text("Email support")
                }
                
            }
        }.listStyle(.grouped)
    }
    
    private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true)
        }

    }
    
    private func presentMailCompose() {
//        guard MFMailComposeViewController.canSendMail() else {
//            print("Can't send email, I guess?")
//            return
//        }
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
