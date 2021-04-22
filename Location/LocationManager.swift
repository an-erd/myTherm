
import Foundation
import CoreLocation

public enum LocationMode: Int32 {
    case none = 0           // none activated
    case precise = 1        // precise location
    case significant = 2    // only significant changes
}

public enum LocationStatus: Int32 {
    case none = 0           // no location
    case approx = 1         // only rough location
    case precise = 2        // precise location
}

public enum LocationGeocodeStatus: Int32 {
    case none = 0           // no address available for current location
    case approx = 1         // address based on approximate location
    case precise = 2        // address based on precise location
}



class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var status: CLAuthorizationStatus?

    @Published var locationAuthorizationStatus: CLAuthorizationStatus?
    @Published var locationAuthorizationAccuracy: CLAccuracyAuthorization?
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    @Published var address: String = ""
    
    @Published var locationMode: LocationMode = .none
    @Published var locationStatus: LocationStatus = .none
    @Published var addressStatus: LocationGeocodeStatus = .none
    
    static var shared = LocationManager()

    var locationTimer: Timer?
    let minPrecision: Double = 65               // precision to consider as good
    let maxPrecision: Double = 15               // precision to consider as excellent
    let maxTimeLocationServices: Double = 30    // max time provided to get location

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.requestWhenInUseAuthorization()
    }

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

                self.address = "\(streetName) \(streetNumber) \n \(zipCode) \(city)"
                self.addressStatus = LocationGeocodeStatus(rawValue: self.locationStatus.rawValue)!
                print("geocode addressStatus \(self.addressStatus) \(self.address)")
            } else {
                self.placemark = nil
                self.address = ""
                self.addressStatus = .none
                
                print("geocode error \(String(describing: error)) addressStatus \(self.addressStatus)")
            }
        })
    }

    @objc
    private func locationTimerFire() {
        print("locationTimerFire reached precision \(self.locationStatus)")
        stopPreciseLocationUpdate()
        startMySignificantLocationChanges()
    }
    
    func startMySignificantLocationChanges() {
        DispatchQueue.main.async { [self] in
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // The device does not support this service.
                print("startMySignificantLocationChanges not supported")
                return
            }
            print("startMySignificantLocationChanges")
            self.locationManager.startMonitoringSignificantLocationChanges()
            locationMode = .significant
        }
    }
    
    func stopMySignificantLocationChanges() {
        DispatchQueue.main.async {
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                // The device does not support this service.
                print("stopMySignificantLocationChanges not supported")
                return
            }
            print("stopMySignificantLocationChanges")
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.locationMode = .none
        }
    }

    func startPreciseLocationUpdate () {
        DispatchQueue.main.async { [self] in
            print("startPreciseLocationUpdate")
            locationTimer = Timer.scheduledTimer(timeInterval: maxTimeLocationServices,
                                                 target: self,
                                                 selector: #selector(self.locationTimerFire),
                                                 userInfo: nil, repeats: false)
            self.locationMode = .precise
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopPreciseLocationUpdate() {
        DispatchQueue.main.async { [self] in
            print("stopPreciseLocationUpdate")
            if let timer = locationTimer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationMode = .none
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationAuthorizationStatus = status
        self.locationAuthorizationAccuracy = locationManager.accuracyAuthorization
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startPreciseLocationUpdate()
        }
        print("didChangeAuthorization \(String(describing: locationAuthorizationStatus?.rawValue)) \(String(describing: locationAuthorizationAccuracy?.rawValue))")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if locationMode == .precise {
            self.location = location
            self.geocode()
            if location.horizontalAccuracy <= maxPrecision {
                self.locationStatus = .precise
                stopPreciseLocationUpdate()
                startMySignificantLocationChanges()
            } else if location.horizontalAccuracy <= minPrecision {
                self.locationStatus = .approx
            }
        } else if locationMode == .significant {
            stopMySignificantLocationChanges()
            startPreciseLocationUpdate()
        }
    
        print("locationManager didUpdateLocations mode \(locationMode.rawValue) accuracy \(location.horizontalAccuracy)")
//        if placemark != nil {
//            print("\(placemark!)")
//        }
        let beacons: [Beacon] = MyCentralManagerDelegate.shared.fetchAllBeacons(context: PersistenceController.shared.viewContext)
        for beacon in beacons {
            if let beaconLocation = beacon.location {
                let distance = location.distance(from: beaconLocation.clLocation)
//                print("distance \(beacon.wrappedName) = \(distance)")
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
