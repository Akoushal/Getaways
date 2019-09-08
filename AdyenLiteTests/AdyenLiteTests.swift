//
//  AdyenLiteTests.swift
//  AdyenLiteTests
//
//  Created by Koushal, KumarAjitesh on 2019/09/06.
//  Copyright © 2019 Koushal, KumarAjitesh. All rights reserved.
//

import XCTest
import CoreLocation
@testable import AdyenLite

class AdyenLiteTests: XCTestCase {

    var srt: DataService?
    let venueMockedJSON: [String: Any] = ["id": "49b6e8d2f964a52016531fe3", "name": "Russ & Daughters",
      "location": ["address": "179 E Houston St", "distance": 130, "city": "New York", "state": "NY", "country": "United States"],
      "categories": ["id": "4bf58dd8d48988d1f5941735", "name": "Gourmet Shop", "pluralName": "Gourmet Shops", "shortName": "Gourmet", "icon": [ "prefix": "https://ss3.4sqi.net/img/categories_v2/shops/food_gourmet_", "suffix": ".png"],
          "primary": true]]
    
    override func setUp() {
        srt = DataService()
    }

    override func tearDown() {
        srt = nil
    }

    /*
     // Test: For checking Tableview Existence
     */
    func test_ControllerHasTableView() {
        let controller = ViewController()
        controller.loadViewIfNeeded()
        
        XCTAssertNotNil(controller.venueListTableView,
                        "Controller should have a tableview")
    }
    
    /*
     // Test: For checking Tableview conforms to TableViewDatasource
     */
    func test_tableViewConformsToTableViewDataSourceProtocol() {
        let controller = ViewController()
        XCTAssertTrue(controller.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(controller.responds(to: #selector(controller.tableView(_:cellForRowAt:))))
    }
    
    /*
     // Test: For FetchVenueList API
     */
    func test_fetchVenueList() {
        // Given Apiservice
        let srt = self.srt!

        // When fetch data
        let expect = XCTestExpectation(description: "callback")

        srt.fetchVenues(coordinate: CLLocationCoordinate2D(latitude: 52.376510, longitude: 4.905960), radius: 100) { (venues, error) in
            expect.fulfill()
            XCTAssertTrue(venues?.count ?? 0 > 0, "Venues Exist")
        }

        wait(for: [expect], timeout: 10.0)
    }

    /*
     // Test: For serializing mocked JSON object into Venue Model
     */
    func test_serializeVenueModel() {
        let venueModel = Venue.init(fromDict: venueMockedJSON)
        XCTAssert(venueModel.id == "49b6e8d2f964a52016531fe3")
        XCTAssert(venueModel.name == "Russ & Daughters")
    }
}
