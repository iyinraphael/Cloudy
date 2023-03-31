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

    // MARK: - Properties

    var currentLocationDidChange: (() -> Void)?
    
    // MARK: -

    var weatherDataStatePublisher: AnyPublisher<WeatherDataState, Never> {
        weatherDataStateSubject
            .eraseToAnyPublisher()
    }

    @Published private(set) var currentLocation: CLLocation?

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
    private var subscriptions: Set<AnyCancellable> = []
    private let weatherDataStateSubject = PassthroughSubject<WeatherDataState, Never>()
    
    // MARK: - Initialization

    override init() {
        super.init()
        // Setup Bindings
        setupBindings()

        // Setup Notification Handling
        setupNotificationHandling()
    }
    
    // MARK: - Public API

    func refreshData() {
        requestLocation()
    }

    private func fetchWeatherData(for location: CLLocation) {

        // Cancel In Progress Data Task
        weatherDataTask?.cancel()

        // Helpers
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Create URL
        let url = WeatherServiceRequest(latitude: latitude, longitude: longitude).url
        
        // Create Data Task
        weatherDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                self?.didFetchWeatherData(data: data, response: response, error: error)
            }
        }
        
        // Start Data Task
        weatherDataTask?.resume()
        weatherDataStateSubject.send(.loading)
    }

    // MARK: - Helper Methods

    private func setupBindings() {
        $currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.fetchWeatherData(for: location)
            }.store(in: &subscriptions)
    }
    
    private func setupNotificationHandling() {
        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = .medium

       NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .throttle(for: .seconds(30), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                self?.requestLocation()
                print("\(dateFormatter.string(from: Date())) did receive notification > throttled")
            }.store(in: &subscriptions)
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
    
    private func didFetchWeatherData(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            weatherDataStateSubject.send(.error(.failedRequest))
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
                        weatherDataStateSubject.send(.data(weatherData))

                } catch {
                    weatherDataStateSubject.send(.error(.invalidResponse))
                    print("Unable to Decode Response, \(error)")
                }

            } else {
                weatherDataStateSubject.send(.error(.failedRequest))
            }

        } else {
            weatherDataStateSubject.send(.error(.invalidResponse))
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
