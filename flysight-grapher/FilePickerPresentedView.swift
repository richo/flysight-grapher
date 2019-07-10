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
    var callback: (URL) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .import)
        
        controller.delegate = context.coordinator
        
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController
        
        init(_ pickerController: FilePickerController) {
            self.parent = pickerController
        }
       
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let document = urls.first else {
                return
            }
            print("Selected a document: \(document)")
            parent.callback(document)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("view was cancelled")
        }
        
        deinit {
            print("Coordinator going away")
        }
    }
}

struct PickerView: View {
    var callback: (URL) -> ()
    var body: some View {
        FilePickerController(callback: callback)
    }
}

#if DEBUG
struct PickerView_Preview: PreviewProvider {
    static var previews: some View {
        func filePicked(_ url: URL) {
            print("Filename: \(url)")
        }
        return PickerView(callback: filePicked)
            .aspectRatio(3/2, contentMode: .fit)
    }
}
#endif
