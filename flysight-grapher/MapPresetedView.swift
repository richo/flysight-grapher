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

struct MapRepresentedView: UIViewRepresentable {
    var view = MKMapView()
    var _delegate = RedLineDelegate()
    
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
    
    func presentData(points: Array<CLLocationCoordinate2D>) {
        var locations = points.map { $0 }

        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        self.view.addOverlay(polyline)
        
        // Then center the map on the end of the track
        view.setCenter(points.last!, animated: true)
        print("Created overlay with \(points.count) points")
        print("Finish: \(points.last!)")
        // view.setCameraZoomRange(MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 500000), animated: false)
        
        // Put a pin at start and end for debugging
        let start = MKPointAnnotation()
        start.coordinate = points.first!
        start.title = "Start!"
        view.addAnnotation(start)
        
        // Put a pin at start and end for debugging
        let end = MKPointAnnotation()
        end.coordinate = points.last!
        end.title = "End!"
        view.addAnnotation(end)
    }
}

struct MapView: View {
    var map: MapRepresentedView = MapRepresentedView()
    
    var body: some View {
        self.map
    }
    
    func loadDataFromCSV(_ csv: CSV) {
        // TODO(richo) Deal with this error better
        self.map.presentData(points: parseMapDataFromCSV(csv)!)
    }
}

func parseMapDataFromCSV(_ csv: CSV) -> Array<CLLocationCoordinate2D>? {
    do {
        var points: Array<CLLocationCoordinate2D> = []

        var header = false
        try csv.enumerateAsDict { dict in
            if !header {
                header = true
                return
            }
            
            let lat = Double(dict["lat"]!)!
            let lon = Double(dict["lon"]!)!
  
            points.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
       }
        return points
    } catch {
        // log("Done a whoopsie")
        return nil
    }
}


class RedLineDelegate: NSObject, MKMapViewDelegate {
     func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            print("Giving back a renderer!")
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
            
        }
        
        return MKOverlayRenderer()
    }
}
