//
//  AppDelegate.swift
//  GeofenceTest
//
//  Created by Thomas Smallwood on 3/10/20.
//  Copyright © 2020 Thomas Smallwood. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
          .requestAuthorization(options: options) { success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      application.applicationIconBadgeNumber = 0
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func handleGeoFenceBreak(for region: CLRegion!) {
      // Show an alert if application is active
      if let message = UserDefaults.standard.string(forKey: "GeofenceMessage"),
        UIApplication.shared.applicationState == .active {
        window?.rootViewController?.showAlert(withTitle: nil, message: message)
      } else {
        // Otherwise present a local notification
        guard let message = UserDefaults.standard.string(forKey: "GeofenceMessage") else { return }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = message
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "geofenceBreak",
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            print("Error: \(error)")
          }
        }
      }
    }
}

extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleGeoFenceBreak(for: region)
    }
  }
}

