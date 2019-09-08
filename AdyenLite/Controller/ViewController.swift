//
//  ViewController.swift
//  AdyenLite
//
//  Created by Koushal, KumarAjitesh on 2019/09/06.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - Lazy Initializers & Variables
    internal lazy var venueListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .lightGray
        tableView.dataSource = self
        //tableView.delegate = self
        tableView.alpha = 0.0
        tableView.register(UINib(nibName: CellIdentifiers.venueCell, bundle: nil), forCellReuseIdentifier: CellIdentifiers.venueCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let actInd = UIActivityIndicatorView(frame: .zero)
        actInd.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            actInd.style = .large
        } else {
            actInd.style = .whiteLarge
        }
        
        actInd.startAnimating()
        actInd.hidesWhenStopped = true
        return actInd
    }()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private lazy var doneToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: .zero)
        toolbar.barStyle = .default
        toolbar.items = [UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSettings)),
                         UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(settingsChanged))]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    private lazy var textField: UITextField = {
        let txtField = UITextField(frame: .zero)
        txtField.inputView = pickerView
        txtField.inputAccessoryView = doneToolBar
        return txtField
    }()
    
    private lazy var emptyListLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.text = Configuration.NoVenuesAlert
        lbl.alpha = 0.0
        return lbl
    }()
    
    private let locationManager = CLLocationManager()
    private var radius: Int = 300
    
    private var currentLocationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if viewModel.venueList.isEmpty {
                attemptFetchVenues()
            }
        }
    }
    
    private var radiusRange: [Int] {
        return (100...2000).filter { $0 % 100 == 0 }
    }
    
    private var errorTag: Error?
    
    // MARK: - Injection
    let viewModel = VenueViewModel(dataService: DataService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItems()
        checkForLocationServices()
        setUpUISubviews()
    }
    
    // MARK: - UISetup
    
    private func setUpNavigationItems() {
        title = Configuration.title
        view.backgroundColor = .lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconSettings"), style: .plain, target: self, action: #selector(settingsButtonPressed))
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .lightGray
    }
    
    private func setUpUISubviews() {
        view.backgroundColor = .lightGray
        view.addSubview(venueListTableView)
        view.addSubview(activityIndicator)
        view.addSubview(textField)
        view.addSubview(emptyListLabel)
        
        venueListTableView.edgesAnchorEqualTo(destinationView: view).activate()
        activityIndicator.centerEdgesAnchorEqualTo(destinationView: view).activate()
        emptyListLabel.edgesAnchorEqualTo(destinationView: view, top: 20, left: 20, right: 20).activate()
    }
    
    // MARK: - BarButton Action
    
    @objc private func settingsButtonPressed() {
        textField.becomeFirstResponder()
    }
    
    // MARK: - Toolbar Action Methods
    
    @objc private func dismissSettings() {
        textField.resignFirstResponder()
    }
    
    @objc private func settingsChanged() {
        textField.resignFirstResponder()
        if venueListTableView.alpha == 1.0 {
            venueListTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
        }
        checkForLocationAuthorization()
    }
    
    // MARK: - Location Services & Authorization
    
    private func checkForLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            checkForLocationAuthorization()
        } else {
            presentAlert()
        }
    }
    
    private func checkForLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            emptyListLabel.alpha = 1.0
            activityIndicator.stopAnimating()
            presentAlert()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            activityIndicator.startAnimating()
            attemptFetchVenues()
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    // MARK: - ViewModel Injection & Callbacks
    
    private func attemptFetchVenues() {
        guard let coord = currentLocationCoordinate else { return}
        viewModel.fetchVenues(for: coord, radius: radius)
        
        viewModel.updateLoadingStatus = {
            let _ = self.viewModel.isLoading ? self.activityIndicatorStart() : self.activityIndicatorStop()
        }
        
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                self.errorTag = error
                self.presentAlert()
            }
        }
        
        viewModel.didFinishFetch = {
            //Update UI
            if self.viewModel.venueList.count == 0 {
                self.emptyListLabel.alpha = 1.0
                self.venueListTableView.alpha = 0.0
            } else {
                self.emptyListLabel.alpha = 0.0
                self.venueListTableView.alpha = 1.0
            }
            self.venueListTableView.reloadData()
        }
    }
    
    private func activityIndicatorStart() {
        // Code for show activity indicator view
        activityIndicator.startAnimating()
    }
    
    private func activityIndicatorStop() {
        // Code for stop activity indicator view
        activityIndicator.stopAnimating()
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLoc = locations.last, currentLoc.timestamp.timeIntervalSinceNow > -15.0  else { return }
        currentLocationCoordinate = currentLoc.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.venueList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.venueCell, for: indexPath) as? VenueCell else { return UITableViewCell()}
        cell.configure(listObj: viewModel.venueList[indexPath.row])
        return cell
    }
}

// MARK: - UIPickerViewDataSource

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return radiusRange.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let radius = radiusRange[row]
        return "\(radius) meters"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        radius = radiusRange[row]
    }
}

// MARK: - Alert Protocol

extension ViewController: AlertPresentable {
    
    var alertComponents: AlertComponents {
        guard let error = errorTag else {
            let settingsAction = AlertActionComponent(title: "Settings", style: .default) { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = AlertActionComponent(title: "Cancel", style: .cancel, handler: nil)
            
            let alertComponents = AlertComponents(title: AlertTitle.LocationServiceDisabledTitle, message: AlertTitle.LocationServiceDisabledMessage, actions: [settingsAction, cancelAction], completion: nil)
            return alertComponents
        }
        
        let okAction = AlertActionComponent(title: "OK", style: .cancel, handler: nil)
        let alertComponents = AlertComponents(title: AlertTitle.ErrorTitle, message: error.localizedDescription, actions: [okAction], completion: nil)
        return alertComponents
    }
}
