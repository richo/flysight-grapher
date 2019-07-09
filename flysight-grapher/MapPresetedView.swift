//
//  MapPresetedView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

let skydiveCalifornia = CLLocationCoordinate2D(latitude: 37.729787, longitude: -121.333130)
let region = MKCoordinateRegion(center: skydiveCalifornia, latitudinalMeters: 1000, longitudinalMeters: 1000)

struct MapRepresentedView: UIViewRepresentable {
    var view: MKMapView = MKMapView()
    
    func makeUIView(context: UIViewRepresentableContext<MapRepresentedView>) -> MapRepresentedView.UIViewType {
        view.mapType = .satellite
        view.region = region
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MapRepresentedView>) {
        // Update the view.
    }
    
    func presentData(data: String) {
    }
}

struct MapView: View {
    var map: MapRepresentedView = MapRepresentedView()
    
    var body: some View {
        self.map
    }    
}
