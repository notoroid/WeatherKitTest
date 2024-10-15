//
//  LocationManager.swift
//  WeatherKitTest
//
//  Created by 能登 要 on 2022/06/20.
//

import Foundation
import CoreLocation
import Observation

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    enum LocationManagerError: Error, LocalizedError {
        case deniedLocation; case restrictedLocation; case unknown
        var errorDescription: String? {
            switch self {
            case .deniedLocation: return "Location information is not allowed. Please allow Settings - Privacy to retrieve the location of your app."
            case .restrictedLocation: return "Location information is not allowed by the constraints specified on the device."
            case .unknown: return "An unknown error has occurred."
            }
        }
    }
    
    typealias AuthorizationStatusContinuation = CheckedContinuation<CLAuthorizationStatus, Never>
    fileprivate class DelegateAdaptorForAuthorization: NSObject, CLLocationManagerDelegate {
        var continuation: AuthorizationStatusContinuation?
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
             continuation?.resume(returning: manager.authorizationStatus)
        }
    }
    fileprivate let locationManager: CLLocationManager = .init()

    var currentLocation: CurrentLocationStatus = .init(active: false, location: .init())
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        currentLocation = .init(active: true, location: newLocation)
    }
    
    struct CurrentLocationStatus: Equatable {
        var active: Bool; var location: CLLocation
    }

    func startCurrentLocation() async throws {
        let authorizationStatus: CLAuthorizationStatus
        if locationManager.authorizationStatus == .notDetermined {
            let delegateAdaptor = DelegateAdaptorForAuthorization()
            locationManager.delegate = delegateAdaptor
            authorizationStatus = await withCheckedContinuation { (continuation: AuthorizationStatusContinuation) in
                delegateAdaptor.continuation = continuation
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            authorizationStatus = locationManager.authorizationStatus
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        switch authorizationStatus {
            case .notDetermined: break
            case .denied: throw LocationManagerError.deniedLocation
            case .authorizedAlways, .authorizedWhenInUse: break
            case .restricted: throw LocationManagerError.restrictedLocation
            default: throw LocationManagerError.unknown
        }
    }
}
