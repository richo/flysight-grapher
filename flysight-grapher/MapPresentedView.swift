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
let region = regionCenteredOn(center: skydiveCalifornia)

func regionCenteredOn(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
    return MKCoordinateRegion(center: center, latitudinalMeters: 5000, longitudinalMeters: 5000)
}

let START_TITLE = "Start!"
let END_TITLE = "End!"

var indexToPointMap: [CLLocationCoordinate2D]?;

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
    
    func removeOverlays() {
        self.view.removeOverlays(self.view.overlays)
    }
    
    func removeAnnotations() {
        self.view.removeAnnotations(self.view.annotations)
    }
    
    mutating func presentData(points: Array<CLLocationCoordinate2D>) {
        var locations = points.map { $0 }

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
    

}

struct MapView: View, DataPresentable {
    var map: MapRepresentedView = MapRepresentedView()
    // TODO(richo) it does kinda feel like maybe the map view should still own this part
    var highlight: DataAnnotation?


    var body: some View {
        self.map
    }
    
    init() {
        print("Making a new mapview?")
    }
    
    mutating func loadData(_ data: DataSet) {
        // TODO(richo) Deal with this error better
        let points = mapData(data)!
        self.map.presentData(points: points)

        indexToPointMap = points.map { $0 }
    }
    
    func clearData() {
        print("Clearing data from the map")
        // Remove the old lines
        self.map.removeOverlays()
        // Remove the old points
        self.map.removeAnnotations()
    }
    
    mutating func highlightPoint(index: Int) {
        let point = indexToPointMap![index]
        let highlight = DataAnnotation()
        highlight.coordinate = point
        map.view.addAnnotation(highlight)
        
        if let annotation = self.highlight {
            self.map.view.removeAnnotation(annotation)
        }
        
        self.highlight = highlight
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: DataAnnotation.self) {
            //Handle ImageAnnotations..
            var view: DataAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "dataAnnotation") as? DataAnnotationView
            if view == nil {
                view = DataAnnotationView(annotation: annotation, reuseIdentifier: "dataAnnotation")
            }

            let annotation = annotation as! DataAnnotation
            view?.annotation = annotation

            return view
        }

        return nil
    }
}

#if DEBUG
struct MapRepresentedView_Previews : PreviewProvider {
    static var previews: some View {
        MapRepresentedView()
    }
}
#endif

class DataAnnotation : NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
}

class DataAnnotationView: MKAnnotationView {
    private var imageView: UIImageView!
    private let circle = UIImage(named: "circle")

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        self.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        self.imageView.image = self.circle
        self.addSubview(self.imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
