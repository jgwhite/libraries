//
//  Client.swift
//  LibrariesAPI
//
//  Created by Jamie White on 13/01/2016.
//  Copyright © 2016 Jamie White. All rights reserved.
//

import Foundation

public typealias LibrariesAPICallback = NSDictionary? -> Void

public struct LibrariesAPIClient {
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func project(platform: String, _ name: String, then: NSDictionary? -> Void) {
        fetch("\(platform)/\(name)") { then($0 as? NSDictionary) }
    }
    
    public func project_dependencies(platform: String, _ name: String, _ version: String = "latest", then: NSDictionary? -> Void) {
        fetch("\(platform)/\(name)/\(version)/dependencies") { then($0 as? NSDictionary) }
    }
    
    public func project_dependents(platform: String, _ name: String, then: NSArray -> Void) {
        fetch("\(platform)/\(name)/dependents") { then($0 as! NSArray) }
    }
    
    public func project_dependent_repositories(platform: String, _ name: String, then: NSArray -> Void) {
        fetch("\(platform)/\(name)/dependent_repositories") { then($0 as! NSArray) }
    }
    
    public func search(q: String, then: NSArray -> Void) {
        fetch("search", ["q": q]) { then($0 as! NSArray) }
    }
    
    public func github(owner: String, _ name: String, then: NSDictionary? -> Void) {
        fetch("github/\(owner)/\(name)") { then($0 as? NSDictionary) }
    }
    
    public func github_dependencies(owner: String, _ name: String, then: NSDictionary? -> Void) {
        fetch("github/\(owner)/\(name)/dependencies") { then($0 as? NSDictionary) }
    }
    
    public func github_projects(owner: String, _ name: String, then: NSArray -> Void) {
        fetch("github/\(owner)/\(name)/projects") { then($0 as! NSArray) }
    }
    
    func fetch(resource: String, _ params: [String: String] = [String: String](), then: AnyObject? -> Void) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let query = params.map { "\($0)=\($1)" }.joinWithSeparator("&")
        let url = NSURL(string: "https://libraries.io/api/\(resource)?api_key=\(apiKey)&\(query)")!
        let task = session.dataTaskWithURL(url) { data, response, error in
            if let data = data, dict = self.parseJSON(data) {
                then(dict)
            } else {
                then(nil)
            }
        }
        task.resume()
    }
    
    func parseJSON(data: NSData) -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch {
            return nil
        }
    }
}