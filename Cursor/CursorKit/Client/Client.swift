//
//  Client.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

public class Client {
    private let baseUrl = NSURL(string: "http://34180550.ngrok.com")!

    public init() { }

    internal func request<T>(method: Method, _ resource: Resource, params: [String: String]? = nil, rootElementPath: JSONSubscriptType..., mapFunc: (JSON -> T?), completion: (FailableOf<[T]> -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, rootElementPath: rootElementPath, mapFunc: mapFunc, completion: completion)
    }
    
    internal func request<T>(method: Method, url: NSURL, params: [String: String]? = nil, rootElementPath: JSONSubscriptType..., mapFunc: (JSON -> T?), completion: (FailableOf<[T]> -> Void)? = nil) -> Request {
        return request(method, url: url, rootElementPath: rootElementPath, mapFunc: mapFunc, completion: completion)
    }
    
    private func request<T>(method: Method, url: NSURL, params: [String: String]? = nil, rootElementPath: [JSONSubscriptType], mapFunc: (JSON -> T?), completion: (FailableOf<[T]> -> Void)? = nil) -> Request {
        let includingMapFunc: JSON -> [T]? = {
            let rootElement = $0[rootElementPath]
            guard let arr = rootElement.array else {
                return []
            }
            
            var results: [T] = []
            for e in arr {
                if let obj = mapFunc(e) {
                    results.append(obj)
                }
            }
            
            return results
        }
        
        return request(method, url: url, params: params, mapFunc: includingMapFunc, completion: completion)
    }
    
    internal func request<T>(method: Method, _ resource: Resource, params: [String: String]? = nil, mapFunc: (JSON -> T?), completion: (FailableOf<T> -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, mapFunc: mapFunc, completion: completion)
    }
    
    internal func request<T>(method: Method, url: NSURL, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, mapFunc: (JSON -> T?), completion: (FailableOf<T> -> Void)? = nil) -> Request {
        let encoding: ParameterEncoding = method == .GET ? .URL : .JSON
        return Manager.sharedInstance.request(method, url, parameters: params, headers: headers, encoding: encoding).responseSwiftyJSON { [weak self] request, response, json, error in
            print(request.URL?.absoluteString)
            
            if let error = error {
                completion?(FailableOf(error))
                return
            }
            
            guard json != JSON.null else {
                completion?(FailableOf(NSError(code: .NoJSONReceived, description: "No JSON response received.")))
                return
            }
            
            if let error = self?.errorFromJSON(json) {
                completion?(FailableOf(error))
                return
            }
            
            if let mapped = mapFunc(json) {
                completion?(FailableOf(mapped))
            } else {
                let error = NSError(code: .UnableToParseResponse, description: "Could not parse the received response into an object.")
                completion?(FailableOf(error))
            }
        }
    }
    
    internal func request(method: Method, _ resource: Resource, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, completion: (Failable -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, headers: headers, completion: completion)
    }
    
    internal func request(method: Method, url: NSURL, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, completion: (Failable -> Void)? = nil) -> Request {
        let encoding: ParameterEncoding = method == .GET ? .URL : .JSON
        return Manager.sharedInstance.request(method, url, parameters: params, headers: headers, encoding: encoding).responseSwiftyJSON { [weak self] request, response, json, error in
            print(request.URL?.absoluteString)
            
            if let error = error {
                completion?(Failable.Failure(error))
                return
            }
            
            if let error = self?.errorFromJSON(json) {
                completion?(Failable.Failure(error))
                return
            }
            
            completion?(Failable.Success)
        }
    }
    
    // Subclasses may override this to provide an error from a JSON response.
    // If nil is returned, the JSON response is assumed to be valid (i.e. no error)
    func errorFromJSON(json: JSON) -> NSError? {
        return nil
    }
    
    private func createURL(resource: Resource) -> NSURL? {
        guard let url = NSURL(string: resource.resource, relativeToURL: baseUrl) else {
            return nil
        }
        
        return url
    }
}