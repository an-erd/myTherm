//
//  MapView.swift
//  TestNew3
//
//  Created by Andreas Erdmann on 16.08.20.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var centerCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        uiView.setRegion(region, animated: true)
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}

/*
struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var currentLocation : CLLocationCoordinate2D
//    @Binding var selectedPlace: MKPointAnnotation?
//    @Binding var showingPlaceDetails: Bool

//    var annotations: [MKPointAnnotation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
//        if annotations.count != view.annotations.count {
//            view.removeAnnotations(view.annotations)
//            view.addAnnotations(annotations)
//        }
//
        view.setCenter(currentLocation, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate{
       var parent: MapView
       init(_ parent: MapView) {
           self.parent = parent
       }

       func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }

//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            let identifier = "PlaceMark"
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.canShowCallout = true
//                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//
//            } else {
//                annotationView?.annotation = annotation
//            }
//
//            return annotationView
//        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//            guard let placemark = view.annotation as? MKPointAnnotation else {return}
//            parent.selectedPlace = placemark
//            parent.showingPlaceDetails = true
        }
    }
}
*/
