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

struct AboutView : View {
    @EnvironmentObject var views: ViewContainer

    private let mailComposeDelegate = MailDelegate()
    let canSendMail = MFMailComposeViewController.canSendMail()
    
    var body: some View {
        
        return List {
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
        
        composeVC.setToRecipients(["richo@psych0tik.net"])
        composeVC.setSubject("Stoke Level feedback")

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
