//
//  DataService.swift
//  Sunshine
//
//  Created by Koushal, KumarAjitesh on 2019/03/06.
//  Copyright © 2019 Unifa. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

struct DataService {
    
    func fetchVenues(coordinate: CLLocationCoordinate2D, radius: Int, completionHandler: @escaping ([Venue]?, Error?) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        var venuesArray = [Venue]()

        dispatchQueue.async {
            self.fetchVenueList(coordinate, radius) { (venues, error) in
                guard error == nil, let venues = venues else {
                    completionHandler(nil, error)
                    return
                }
                venuesArray = venues
                semaphore.signal()
            }

            semaphore.wait()
            
            let dispatchGroup = DispatchGroup()
            var detailsError: Error?

            for venue in venuesArray {
                dispatchGroup.enter()
                self.fetchDetails(of: venue) { (error) in
                    if let error = error {
                        detailsError = error
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completionHandler(venuesArray, detailsError)
            }
        }
    }

    //Fetching Venue List
    private func fetchVenueList(_ coordinate: CLLocationCoordinate2D, _ radius: Int, completionHandler: @escaping ([Venue]?, Error?) -> Void) {
        let venueRequest = ServiceRequest.explore(coordinate, radius)
        Alamofire.request(venueRequest).validate().responseJSON { (response) in
            if let error = response.error {
                completionHandler(nil, error)
                return
            }
            
            if let jsonDict = response.result.value as? [String: Any] {
                guard let response = jsonDict["response"] as? [String: Any], let groups = response["groups"] as? [[String: Any]], let recommendedPlaces = groups.first, let venues = recommendedPlaces["items"] as? [[String: Any]]  else { return }
                var venueArr = [Venue]()
                venues.forEach { (item) in
                    guard let dict = item["venue"] as? [String: Any] else { return}
                    venueArr.append(Venue(fromDict: dict))
                }
                completionHandler(venueArr, nil)
                return
            }
        }
    }
    
    //Fetching Details of Venue
    private func fetchDetails(of venue: Venue, completionHandler: @escaping ((Error?) -> Void)) {
        guard let id = venue.id else { return}
        let venueDetailRequest = ServiceRequest.details(id: id)

        Alamofire.request(venueDetailRequest).validate().responseJSON { response in
            guard response.result.isSuccess, let jsonDict = response.result.value as? [String: Any] else {
                completionHandler(response.error)
                return
            }
            guard let responseDict = jsonDict["response"] as? [String: Any],
                let venueDict = responseDict["venue"] as? [String: Any]
                else { return }
            venue.getDetails(fromDict: venueDict)
            completionHandler(nil)
        }
    }
}
