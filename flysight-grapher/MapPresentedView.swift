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
import class SwiftCSV.CSV

let skydiveCalifornia = CLLocationCoordinate2D(latitude: 37.729787, longitude: -121.333130)
let region = regionCenteredOn(center: skydiveCalifornia)

func regionCenteredOn(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
    return MKCoordinateRegion(center: center, latitudinalMeters: 5000, longitudinalMeters: 5000)
}

let START_TITLE = "Start!"
let END_TITLE = "End!"

struct MapRepresentedView: UIViewRepresentable {
    var view = MKMapView()
    var _delegate = RedLineDelegate()
    var points: Array<CLLocationCoordinate2D>?
    var highlight: MKPointAnnotation?
    
    func makeUIView(context: UIViewRepresentableContext<MapRepresentedView>) -> MapRepresentedView.UIViewType {
        view.mapType = .satellite
        // Try to figure out if we already did the init thing.
        if view.delegate == nil {
            view.region = region
            view.delegate = self._delegate
        }

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MapRepresentedView>) {
        // Update the view.
    }
    
    func removeOverlays() {
        self.view.removeOverlays(self.view.overlays)
    }
    
    func removeAnnotations() {
        self.view.removeAnnotations(self.view.annotations)
    }
    
    mutating func presentData(points: Array<CLLocationCoordinate2D>) {
        var locations = points.map { $0 }
        self.points = locations

        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        self.view.addOverlay(polyline)
        
        print("Created overlay with \(points.count) points")
        print("Finish: \(points.last!)")
        
        // Put a pin at start and end for debugging
        let start = MKPointAnnotation()
        start.coordinate = points.first!
        start.title = START_TITLE
        view.addAnnotation(start)
        
        // Put a pin at start and end for debugging
        let end = MKPointAnnotation()
        end.coordinate = points.last!
        end.title = END_TITLE
        view.addAnnotation(end)
        
        // Then center the map on the end of the track
        view.setCenter(end.coordinate, animated: true)
    }
    
    mutating func highlightValue(index: Int) {
        if let annotation = self.highlight {
            self.view.removeAnnotation(annotation)
        }
        
        let point = self.points![index]
        let highlight = MKPointAnnotation()
        highlight.coordinate = point
        view.addAnnotation(highlight)
        
        self.highlight = highlight
    }
}

struct MapView: View, DataPresentable {
    var map: MapRepresentedView = MapRepresentedView()
    
    var body: some View {
        self.map
    }
    
    mutating func loadData(_ data: DataSet) {
        // TODO(richo) Deal with this error better
        self.map.presentData(points: mapData(data)!)
    }
    
    func clearData() {
        print("Clearing data from the map")
        // Remove the old lines
        self.map.removeOverlays()
        // Remove the old points
        self.map.removeAnnotations()
    }
    
    mutating func highlightValue(index: Int) {
        self.map.highlightValue(index: index)
    }

}

private func mapData(_ data: DataSet) -> Array<CLLocationCoordinate2D>? {
    data.data.map { point in
        point.position
    }
}


class RedLineDelegate: NSObject, MKMapViewDelegate {
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

#if DEBUG
struct MapRepresentedView_Previews : PreviewProvider {
    static var previews: some View {
        MapRepresentedView()
    }
}
#endif
