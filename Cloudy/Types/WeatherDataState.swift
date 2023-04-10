//
//  WeatherDataState.swift
//  Cloudy
//
//  Created by Iyin Raphael on 3/29/23.
//  Copyright © 2023 Cocoacasts. All rights reserved.
//

import Foundation


enum WeatherDataState {

    // MARK: - Cases
    case loading
    case data(WeatherData)
    case error(WeatherDataError)

    // MARK: -

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .data, .error:
            return false
        }
    }

    var weatherData: WeatherData? {
        switch self {
        case .data(let weatherData):
            return weatherData
        case .loading, .error:
            return nil
        }
    }

    var weatherDataError: WeatherDataError? {
        switch self {
        case .error(let error):
            return error
        case .data, .loading:
            return nil
        }
    }
}
