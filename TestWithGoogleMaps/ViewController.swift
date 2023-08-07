//
//  ViewController.swift
//  TestWithGoogleMaps
//
//  Created by Никитин Артем on 4.08.23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    
    private var locationArray: [CLLocationCoordinate2D] = []

    private var latitude: Double!
    private var longitude: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if [.authorizedWhenInUse, .authorizedAlways].contains(locationManager.authorizationStatus) {
            locationManager.startUpdatingLocation()
            addAnnotationsToMap()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    private func updateLocationPermissions() {
        switch locationManager.accuracyAuthorization {
        case .reducedAccuracy:
            print("reduced accuracy")
        case .fullAccuracy:
            fallthrough
        @unknown default:
            print("full or unknown")
            break
        }

        switch locationManager.authorizationStatus {
        case .denied:
            print("Please, open settings and enable location use")
        case.restricted:
            print("Can't use location servicew on this iDevice")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            fallthrough
        case .authorizedAlways:
            fallthrough
        @unknown default:
            locationManager.startUpdatingLocation()
        }
    }

    private func addAnnotationsToMap() {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.networkManager.fetchData(latitudeUser: self.latitude, longitudeUser: self.longitude) { result in
                switch result {
                case .success(let addressInfos):
                    self.locationArray = addressInfos.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                    self.locationManager.stopUpdatingLocation()
                    let annotations = self.locationArray.map { location in
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        return annotation
                    }
                    self.mapView.addAnnotations(annotations)
                    
                    if let firstLocation = self.locationArray.first {
                        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        let region = MKCoordinateRegion(center: firstLocation, span: span)
                        DispatchQueue.main.async {
                            self.mapView.setRegion(region, animated: true)
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let lastLocation = locations.last else { return }

        self.latitude = lastLocation.coordinate.latitude
        self.longitude = lastLocation.coordinate.longitude
        
        addAnnotationsToMap()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationPermissions()
    }
}


