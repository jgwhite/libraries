//
//  LibrariesAPITests.swift
//  LibrariesAPITests
//
//  Created by Jamie White on 13/01/2016.
//  Copyright © 2016 Jamie White. All rights reserved.
//

import XCTest
import Mockingjay
import LibrariesAPI

class LibrariesAPITests: XCTestCase {

    func testProject() {
        let expectation = expectationWithDescription("client.project")
        let client = LibrariesAPIClient(apiKey: "test-api-key")
        let body = [ "name": "grunt", "rank": 24 ]
        
        stub(http(.GET, uri: "/api/npm/grunt"), builder: json(body))
        
        client.project("npm", "grunt") { project in
            XCTAssert(project?["name"] as? String == "grunt")
            XCTAssert(project?["rank"] as? Int == 24)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { error in
            print("Timeout error: \(error)")
        }
    }

}
