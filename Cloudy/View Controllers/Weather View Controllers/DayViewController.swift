//
//  DayViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import Combine

protocol DayViewControllerDelegate: AnyObject {
    func controllerDidTapSettingsButton(controller: DayViewController)
    func controllerDidTapLocationButton(controller: DayViewController)
}

final class DayViewController: WeatherViewController {

    // MARK: - Properties

    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var windSpeedLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!

    // MARK: -

    weak var delegate: DayViewControllerDelegate?
    private var subscription: Set<AnyCancellable> = []

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup Bindings
        setupBindings()

        //Update View
        updateView()
    }

    var viewModel: DayViewModel?

    // MARK: - Public Interface

    override func reloadData() {
        updateView()
    }

    // MARK: - View Methods

    private func updateView() {
        if let _ = viewModel {

        } else {
            messageLabel.isHidden = false
            messageLabel.text = "Cloudy was unable to fetch weather data."
        }
    }

    // MARK: -

    private func setupBindings() {
        viewModel?.datePublisher
            .assign(to: \.text, on: dateLabel)
            .store(in: &subscription)

        viewModel?.timePublisher
            .assign(to: \.text, on: timeLabel)
            .store(in: &subscription)

        viewModel?.summaryPublisher
            .assign(to: \.text, on: descriptionLabel)
            .store(in: &subscription)

        viewModel?.temperaturePublisher
            .assign(to: \.text, on: temperatureLabel)
            .store(in: &subscription)

        viewModel?.windSpeedPublisher
            .assign(to: \.text, on: windSpeedLabel)
            .store(in: &subscription)

        viewModel?.imagePublisher
            .assign(to: \.image, on: iconImageView)
            .store(in: &subscription)

        viewModel?.loadingPublisher
            .assign(to: \.isHidden, on: weatherDataContainerView)
            .store(in: &subscription)

        viewModel?.loadingPublisher
            .map{ !$0 }
            .assign(to: \.isHidden, on: activityIndicatorView)
            .store(in: &subscription)
    }

    // MARK: - Actions

    @IBAction private func didTapSettingsButton(_ sender: UIButton) {
        delegate?.controllerDidTapSettingsButton(controller: self)
    }

    @IBAction private func didTapLocationButton(_ sender: UIButton) {
        delegate?.controllerDidTapLocationButton(controller: self)
    }

}
