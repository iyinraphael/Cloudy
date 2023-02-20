//
//  WeatherViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet private(set) var messageLabel: UILabel!
    @IBOutlet private(set) var weatherDataContainerView: UIView!
    @IBOutlet private(set) var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Public Interface

    func reloadData() {}

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup View
        setupView()
    }

    // MARK: - View Methods

    private func setupView() {
        // Configure Message Label
        messageLabel.isHidden = true

        // Configure Weather Data Container View
        weatherDataContainerView.isHidden = true

        // Configure Activity Indicator View
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
    }
    
}
