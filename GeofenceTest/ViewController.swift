//
//  ViewController.swift
//  GeofenceTest
//
//  Created by Thomas Smallwood on 3/10/20.
//  Copyright © 2020 Thomas Smallwood. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }


    @IBAction func addButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Message when breaking geofence:", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            guard let message = ac.textFields?.first?.text,
                let currentLocation = self.currentLocation else {
                print("No message or current location")
                return
            }
            UserDefaults.standard.set(message, forKey: "GeofenceMessage")

            let region = CLCircularRegion(center: currentLocation.coordinate, radius: 150, identifier: "FencedCurrentLocation")
            self.locationManager.startMonitoring(for: region)

        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
}

// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
        }
    }
}

