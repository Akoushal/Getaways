//
//  VenueViewModel.swift
//  AdyenLite
//
//  Created by Koushal, KumarAjitesh on 2019/09/06.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import Foundation
import CoreLocation

class VenueViewModel {
    
    private var venues: [Venue]? {
        didSet {
            guard let vns = venues else { return }
            self.setupVenues(with: vns)
            self.didFinishFetch?()
        }
    }
    var error: Error? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    private var dataService: DataService?
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var didFinishFetch: (() -> ())?
    var venueList: [Venue] = [Venue]()
    
    // MARK: - Constructor
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    // MARK: - Network call
    func fetchVenues(for coordinate: CLLocationCoordinate2D, radius: Int) {
        self.dataService?.fetchVenues(coordinate: coordinate, radius: radius, completionHandler: { (venues, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.venues = venues ?? []
        })
    }
    
    // MARK: - UI Logic
    private func setupVenues(with venues: [Venue]) {
        //Update ViewModel
        self.venueList = venues
    }
}
