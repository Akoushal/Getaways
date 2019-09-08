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
    let contactMockedJSON: [String: Any] = ["id":8892, "first_name":"Amitabh", "last_name":"Bachchan", "profile_pic":"/images/missing.png", "favorite":true, "url":"http://gojek-contacts-app.herokuapp.com/contacts/8892.json"]
    
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
    func test_serializeVenueModel() {}
//    {
//        guard let data = try? JSONSerialization.data(withJSONObject: contactMockedJSON, options: .prettyPrinted), let contactModel = try? JSONDecoder().decode(Venue.self, from: data) else {
//            XCTFail()
//            return
//        }
//
//        XCTAssert(contactModel.id == 8892)
//        XCTAssert(contactModel.firstName == "Amitabh")
//    }
}
