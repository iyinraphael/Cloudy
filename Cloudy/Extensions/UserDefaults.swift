//
//  UserDefaults.swift
//  Cloudy
//
//  Created by Bart Jacobs on 03/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import Foundation

extension UserDefaults {

    // MARK: - Types
    
    private enum Keys {
        static let locations = "locations"
        static let currentLocation = "currentLocation"
        
        static let timeNotation = "timeNotation"
        static let unitsNotation = "unitsNotation"
        static let temperatureNotation = "temperatureNotation"
    }
    
    // MARK: - Time Notation

    class var timeNotation: TimeNotation {
        get {
            let storedValue = UserDefaults.standard.integer(forKey: Keys.timeNotation)
            return TimeNotation(rawValue: storedValue) ?? TimeNotation.twelveHour
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.timeNotation)
        }
    }

    // MARK: - Units Notation
    
    class var unitsNotation: UnitsNotation {
        get {
            let storedValue = UserDefaults.standard.integer(forKey: Keys.unitsNotation)
            return UnitsNotation(rawValue: storedValue) ?? UnitsNotation.imperial
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.unitsNotation)
        }
    }

    // MARK: - Temperature Notation
    
    class var temperatureNotation: TemperatureNotation {
        get {
            let storedValue = UserDefaults.standard.integer(forKey: Keys.temperatureNotation)
            return TemperatureNotation(rawValue: storedValue) ?? TemperatureNotation.fahrenheit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.temperatureNotation)
        }
    }

}

extension UserDefaults {

    // MARK: - Locations

    class var locations: [Location] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.locations) else {
                return []
            }
            
            return (try? JSONDecoder().decode([Location].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            
            UserDefaults.standard.set(data, forKey: Keys.locations)
        }
    }

    class func addLocation(_ location: Location) {
        // Load Locations
        var locations = self.locations

        // Add Location
        locations.append(location)
        
        // Save Locations
        self.locations = locations
    }

    class func removeLocation(_ location: Location) {
        // Load Locations
        var locations = self.locations

        // Fetch Location Index
        guard let index = locations.firstIndex(of: location) else {
            return
        }

        // Remove Location
        locations.remove(at: index)

        // Save Locations
        self.locations = locations
    }
    
    class var currentLocation: Location? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.currentLocation) else {
                return nil
            }
            
            return try? JSONDecoder().decode(Location.self, from: data)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            
            UserDefaults.standard.set(data, forKey: Keys.currentLocation)
        }
    }
    
}
