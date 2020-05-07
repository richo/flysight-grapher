//
//  ContentView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @State var showFilePicker = false
    @State var showFileError = false
    @State var isLoading = false

    @EnvironmentObject var views: ViewContainer
    
    @State var defaultTab = 1
    var isiPhone = UIDevice.current.userInterfaceIdiom == .phone

    var body: some View {
        return LoadingView(isLoading: $isLoading) {
            VStack {
                TabView (selection: self.$defaultTab) {
                self.views.graph.tabItem({ Text("Graph") }).tag(0);
                self.views.map.tabItem({ Text("Map") }).tag(1);
                if !self.isiPhone {
                    self.views.split.tabItem({ Text("Split") }).tag(2);
                }
                    if !self.isiPhone && self.views.showAerobatics {
                    self.views.aerobatics.tabItem({ Text("Aeros") }).tag(3);
                }
                self.views.performance.tabItem({ Text("Performance") }).tag(4);
                self.views.about.tabItem({ Text("About") }).tag(5);
            };
            Button("Load Data") {
                self.showFilePicker = true
            }.padding();
        }
        }
        .alert(isPresented: $showFileError) {
            Alert(title: Text("Failed to load"), message: Text("Loaded data contained zero rows"), dismissButton: .default(Text("Ok :(")))
        }
        .sheet(isPresented: $showFilePicker, content: { PickerView(callback: self.fileUrlCallbackWrapper) })

    }
    
    func fileUrlCallbackWrapper(_ url: URL) {
        self.views.fileUrlCallback(url, { (ret: Bool) -> () in
            self.isLoading = false
            self.showFileError = !ret
        })
        self.isLoading = true
    }
    
    init() {
        if !isiPhone {
            self.defaultTab = 2
        }
    }
    

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
