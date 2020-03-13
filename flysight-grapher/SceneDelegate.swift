//
//  SceneDelegate.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import UIKit
import SwiftUI

class ViewContainer: ObservableObject {
    @State var graph = GraphView()
    @State var map = MapView()
    @State var performance = PerformanceView()
    @State var about = AboutView()

    
    var split: SplitGraphMapView {
        get {
            SplitGraphMapView(
                graph: self.graph,
                map: self.map
            )
        }
    }
    
    var splitDelegate: SplitViewDelegate?
    
    init() {
        self.splitDelegate = split.delegate()
        self.graph.setDelegate(self.splitDelegate!)
    }
    
    func loadData(_ url: URL) -> DataSet? {
        let loader = DataLoader()
        return loader.loadFromURL(url)
    }

    func fileUrlCallback(_ url: URL, _ cb: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {

            guard let data = self.loadData(url) else {
                print("No data loaded :(")
                cb(false)
                return
            }
        
            print("Loading data into graph")
            self.graph.clearData()
            self.graph.loadData(data)
            
            print("Loading data into map")
            self.map.clearData()
            self.map.loadData(data)
            
            print("Loading data into performance view")
            self.performance.clearData()
            self.performance.loadData(data)
            
            cb(true)
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    @ObservedObject var views = ViewContainer()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView()
                .environmentObject(views)
                )
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

