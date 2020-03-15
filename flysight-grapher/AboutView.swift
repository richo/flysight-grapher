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
    
    @State private var showLicences = false
    
    var body: some View {
        
        return List {
            Section(header: Text("Support")) {
                Button(action: {
                    self.openPowerSupportPage()
                }) {
                    Text("Help, I get an error about using too much power!")
                }
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
            Section(header: Text("Open Source")) {
                Button(action: {
                    self.showLicences = true
                }) {
                    Text("View open source licenses")
                }
                .sheet(isPresented: $showLicences, onDismiss: {
                    
                }) {
                    LicenseView(isPresented: self.$showLicences)
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
    
    let PowerSupportUrl = "https://app.stokepile.co/stokelevel/support/power"
    private func openPowerSupportPage() {
        UIApplication.shared.open(URL(string: PowerSupportUrl)!)
    }
}

struct LicenseView: View {
    @Binding var isPresented: Bool

    var body: some View {
        let license = licenseBody()!
        return VStack {
            ScrollView {
                Text(license)
            }
            Spacer()
            Button("Dismiss") {
                self.isPresented = false
            }
        }
    }
    
    func licenseBody() -> String? {
        if let filepath = Bundle.main.path(forResource: "LICENSE", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                print("Couldn't open license")
            }
        } else {
            print ("Couldn't find license")
        }
        return nil
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
