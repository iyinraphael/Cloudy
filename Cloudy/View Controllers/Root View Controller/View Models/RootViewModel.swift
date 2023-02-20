//
//  RootViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 21/09/2020.
//  Copyright © 2020 Cocoacasts. All rights reserved.
//

import UIKit
import Combine
import CoreLocation

final class RootViewModel: NSObject {

    // MARK: - Type Aliases
    
    typealias WeatherDataResult = (Result<WeatherData, WeatherDataError>) -> ()
    
    // MARK: - Properties

    var currentLocationDidChange: (() -> Void)?
    
    // MARK: -

    private(set) var currentLocation: CLLocation? {
        didSet {
            currentLocationDidChange?()
        }
    }

    // MARK: -
    
    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()

        // Configure Location Manager
        locationManager.distanceFilter = 1000.0
        locationManager.desiredAccuracy = 1000.0

        return locationManager
    }()

    // MARK: -
    
    private var weatherDataTask: URLSessionDataTask?
    private var subscription: AnyCancellable?
    
    // MARK: - Initialization

    override init() {
        super.init()
        
        // Setup Notification Handling
        setupNotificationHandling()
    }
    
    // MARK: - Public API

    func fetchWeatherData(_ completion: @escaping WeatherDataResult) {
        // Cancel In Progress Data Task
        weatherDataTask?.cancel()
        
        guard let location = currentLocation else {
            switch CLLocationManager.authorizationStatus() {
            case .denied,
                 .restricted:
                completion(.failure(.notAuthorizedToRequestLocation))
            default:
                completion(.failure(.failedToRequestLocation))
            }
            return
        }
        
        // Helpers
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Create URL
        let url = WeatherServiceRequest(latitude: latitude, longitude: longitude).url
        
        // Create Data Task
        weatherDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                self.didFetchWeatherData(data: data, response: response, error: error, completion: completion)
            }
        }
        
        // Start Data Task
        weatherDataTask?.resume()
    }

    // MARK: - Helper Methods
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.requestLocation()
            print("did receive notification > NOT Reactive")
        }

        subscription = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { notification in
                print("did receive notification > Reactive")
            }
    }
    
    // MARK: -

    private func requestLocation() {
        // Configure Location Manager
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            // Request Authorization
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: -
    
    private func didFetchWeatherData(data: Data?, response: URLResponse?, error: Error?, completion: WeatherDataResult) {
        if let error = error {
            completion(.failure(.failedRequest))
            print("Unable to Fetch Weather Data, \(error)")

        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    
                    // Configure JSON Decoder
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
                    // Decode JSON
                    let weatherData = try decoder.decode(WeatherData.self, from: data)

                    // Invoke Completion Handler
                    completion(.success(weatherData))

                } catch {
                    completion(.failure(.invalidResponse))
                    print("Unable to Decode Response, \(error)")
                }

            } else {
                completion(.failure(.failedRequest))
            }

        } else {
            fatalError("Invalid Response")
        }
    }

}

extension RootViewModel: CLLocationManagerDelegate {

    // MARK: - Authorization

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            manager.requestLocation()
        default:
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

    // MARK: - Location Updates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Update Current Location
            currentLocation = location

            // Reset Delegate
            manager.delegate = nil

            // Stop Location Manager
            manager.stopUpdatingLocation()

        } else {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if currentLocation == nil {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

}

extension RootViewModel: LocationsViewControllerDelegate {

    func controller(_ controller: LocationsViewController, didSelectLocation location: CLLocation) {
        currentLocation = location
    }

}
