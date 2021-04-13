
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var status: CLAuthorizationStatus?
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    @Published var address: String = ""
    
    private func geocode() {
        guard let location = self.location else { return }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
            if error == nil {
                self.placemark = places?.first
                guard let placemark = places?.first else { return }
                guard let streetName = placemark.thoroughfare else { return }
                guard let streetNumber = placemark.subThoroughfare else { return }
                guard let zipCode = placemark.postalCode else { return }
                guard let city = placemark.locality else { return }

                DispatchQueue.main.async {
                    self.address = "\(streetName) \(streetNumber) \n \(zipCode) \(city)"
                    print("\(self.address)")
                }
            } else {
                self.placemark = nil
                print("geocode placemark = nil")
            }
        })
    }

    func startMySignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The device does not support this service.
            return
        }
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMySignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The device does not support this service.
            return
        }
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }

    override init() {
        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.requestWhenInUseAuthorization()
//      self.locationManager.startUpdatingLocation()
        startMySignificantLocationChanges()
//        stopMySignificantLocationChanges()
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
        
        print("locationManager didUpdateLocations")
        if placemark != nil {
            print("\(placemark!)")
        }
        let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons(context: PersistenceController.shared.viewContext)
        for beacon in beacons {
            if let beaconLocation = beacon.location {
                let distance = location.distance(from: beaconLocation.clLocation)
                print("distance \(beacon.wrappedName) = \(distance)")
                beacon.localDistanceFromPosition = distance
            }
        }
    }
}

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
}
