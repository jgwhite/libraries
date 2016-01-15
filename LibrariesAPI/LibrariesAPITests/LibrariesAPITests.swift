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

    var client: LibrariesAPIClient!

    override func setUp() {
        client = LibrariesAPIClient(apiKey: "test-api-key")
    }

    func testProjectSuccess() {
        let expectation = expectationWithDescription("testProjectSuccess")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt?api_key=test-api-key"),
            builder: json(["name":  "grunt"])
        )

        client.project("npm", "grunt") { project in
            XCTAssertEqual(project?["name"] as? String, "grunt")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testProjectNotFound() {
        let expectation = expectationWithDescription("testProjectNotFound")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt?api_key=test-api-key"),
            builder: json([], status: 404)
        )

        client.project("npm", "grunt") { project in
            XCTAssertNil(project)

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testProjectDependenciesSuccess() {
        let expectation = expectationWithDescription("testProjectDependenciesSuccess")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt/latest/dependencies?api_key=test-api-key"),
            builder: json(["name": "grunt"])
        )

        client.projectDependencies("npm", "grunt") { project in
            XCTAssertEqual(project?["name"] as? String, "grunt")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testProjectDependents() {
        let expectation = expectationWithDescription("testProjectDependents")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt/dependents?api_key=test-api-key"),
            builder: json([["name": "some-other-project"]])
        )

        client.projectDependents("npm", "grunt") { dependents in
            let project = dependents[0] as? [String: AnyObject]

            XCTAssertEqual(project?["name"] as? String, "some-other-project")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testProjectDependentsNotFound() {
        let expectation = expectationWithDescription("testProjectDependentsNotFound")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt/dependents?api_key=test-api-key"),
            builder: json([], status: 404)
        )

        client.projectDependents("npm", "grunt") { dependents in
            XCTAssertEqual(dependents.count, 0)

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testProjectDependentRepositories() {
        let expectation = expectationWithDescription("testProjectDependentRepositories")

        stub(
            http(.GET, "https://libraries.io/api/npm/grunt/dependent_repositories?api_key=test-api-key"),
            builder: json([["name": "some-other-project"]])
        )

        client.projectDependentRepositories("npm", "grunt") { dependents in
            let project = dependents[0] as? [String: AnyObject]

            XCTAssertEqual(project?["name"] as? String, "some-other-project")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testSearch() {
        let expectation = expectationWithDescription("testSearch")

        stub(
            http(.GET, "https://libraries.io/api/search?api_key=test-api-key&q=foo"),
            builder: json([["name": "foo"]])
        )

        client.search("foo") { dependents in
            let dependent = dependents[0] as? [String: AnyObject]

            XCTAssertEqual(dependent?["name"] as? String, "foo")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testGithub() {
        let expectation = expectationWithDescription("testGithub")

        stub(
            http(.GET, "https://libraries.io/api/github/gruntjs/grunt?api_key=test-api-key"),
            builder: json(["full_name": "gruntjs/grunt"])
        )

        client.github("gruntjs", "grunt") { project in
            XCTAssertEqual(project?["full_name"] as? String, "gruntjs/grunt")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testGithubDependencies() {
        let expectation = expectationWithDescription("testGithubDependencies")

        stub(
            http(.GET, "https://libraries.io/api/github/gruntjs/grunt/dependencies?api_key=test-api-key"),
            builder: json(["full_name": "gruntjs/grunt"])
        )

        client.githubDependencies("gruntjs", "grunt") { project in
            XCTAssertEqual(project?["full_name"] as? String, "gruntjs/grunt")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }

    func testGithubProjects() {
        let expectation = expectationWithDescription("testGithubProjects")

        stub(
            http(.GET, "https://libraries.io/api/github/gruntjs/grunt/projects?api_key=test-api-key"),
            builder: json([["full_name": "gruntjs/grunt"]])
        )

        client.githubProjects("gruntjs", "grunt") { projects in
            let project = projects[0] as? [String: AnyObject]

            XCTAssertEqual(project?["full_name"] as? String, "gruntjs/grunt")

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5) { print("Timeout error: \($0)") }
    }


    func http(method: HTTPMethod, _ urlString: String) -> NSURLRequest -> Bool {
        let url = NSURL(string: urlString)!

        return { (request: NSURLRequest) in
            XCTAssertEqual(request.HTTPMethod, method.description)
            XCTAssertEqual(request.URL?.scheme, url.scheme)
            XCTAssertEqual(request.URL?.host, url.host)
            XCTAssertEqual(request.URL?.path, url.path)
            XCTAssertEqual(request.URL?.query, url.query)
            return true
        }
    }

}
