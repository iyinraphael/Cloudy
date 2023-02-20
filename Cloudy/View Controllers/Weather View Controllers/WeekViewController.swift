//
//  WeekViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit

protocol WeekViewControllerDelegate: AnyObject {
    func controllerDidRefresh(controller: WeekViewController)
}

final class WeekViewController: WeatherViewController {

    // MARK: - Properties

    @IBOutlet private var tableView: UITableView! {
        didSet {
            // Configure Table View
            tableView.separatorInset = UIEdgeInsets.zero
        }
    }

    // MARK: -

    weak var delegate: WeekViewControllerDelegate?
    
    // MARK: -

    var viewModel: WeekViewModel? {
        didSet {
            updateView()
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup View
        setupView()
    }

    // MARK: - Public Interface

    override func reloadData() {
        updateView()
    }
    
    // MARK: - View Methods

    private func setupView() {
        setupRefreshControl()
    }

    private func updateView() {
        activityIndicatorView.stopAnimating()
        tableView.refreshControl?.endRefreshing()

        if viewModel != nil {
            updateWeatherDataContainerView()

        } else {
            messageLabel.isHidden = false
            messageLabel.text = "Cloudy was unable to fetch weather data."
        }
    }

    // MARK: -

    private func setupRefreshControl() {
        // Initialize Refresh Control
        let refreshControl = UIRefreshControl()

        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(WeekViewController.didRefresh(_:)), for: .valueChanged)

        // Update Table View)
        tableView.refreshControl = refreshControl
    }

    // MARK: -

    private func updateWeatherDataContainerView() {
        // Show Weather Data Container View
        weatherDataContainerView.isHidden = false

        // Update Table View
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc func didRefresh(_ sender: UIRefreshControl) {
        delegate?.controllerDidRefresh(controller: self)
    }
    
}

extension WeekViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfDays ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherDayTableViewCell.reuseIdentifier, for: indexPath) as? WeatherDayTableViewCell else {
            fatalError("Unable to Dequeue Weather Day Table View Cell")
        }

        guard let viewModel = viewModel?.viewModel(for: indexPath.row) else {
            fatalError("No View Model Available")
        }

        // Configure Cell
        cell.configure(with: viewModel)

        return cell
    }

}
