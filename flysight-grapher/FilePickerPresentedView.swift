//
//  FilePickerPresentedView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftUI
import MobileCoreServices

struct FilePickerController: UIViewControllerRepresentable {
     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
        // Update the controller
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .open)
        let delegate = PickerDelegate()
        controller.delegate = delegate
        
        return controller
    }
}

struct PickerView: View {
    var body: some View {
        FilePickerController()
    }
}

#if DEBUG
struct PickerView_Preview: PreviewProvider {
    static var previews: some View {
        PickerView()
            .aspectRatio(3/2, contentMode: .fit)
    }
}
#endif


class PickerDelegate: NSObject, UIDocumentPickerDelegate {
    func documentPicker(didPickDocumentsAt: [URL]) {
        print("Document picker did a picking")
    }
    
    func documentPickerWasCancelled() {
        print("Document picker was thrown away :(")
    }
}
