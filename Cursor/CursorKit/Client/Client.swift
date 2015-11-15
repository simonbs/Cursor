//
//  Client.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

public class Client {
    private let baseUrl = NSURL(string: "http://abc.ngrok.com:5000/")!

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
    
    internal func request<T>(method: Method, url: NSURL, params: [String: String]? = nil, mapFunc: (JSON -> T?), completion: (FailableOf<T> -> Void)? = nil) -> Request {
        return Manager.sharedInstance.request(method, url, parameters: params, encoding: .URL).responseSwiftyJSON { request, response, json, error in
            print(request.URL?.absoluteString)
            
            if let error = error {
                completion?(FailableOf(error))
                return
            }
            
            guard json != JSON.null else {
                let error = NSError(code: .NoJSONReceived, description: "No JSON response received.")
                completion?(FailableOf(error))
                return
            }
                    
            if let lastFMErrorCode = json["error"].int {
                let errorCode = ErrorCode(rawValue: lastFMErrorCode) ?? .UnknownError
                let error = NSError(code: errorCode, description: json["message"].string)
                completion?(FailableOf(error))
                return
            }
            
            if let errorDict = json["error"].dictionary {
                var errorCode: ErrorCode = .UnknownError
                if let lastFMErrorCode = errorDict["code"]?.int {
                    errorCode = ErrorCode(rawValue: lastFMErrorCode) ?? .UnknownError
                }
                
                let error = NSError(code: errorCode, description: errorDict["message"]?.string)
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
    
    private func createURL(resource: Resource) -> NSURL? {
        guard let url = NSURL(string: resource.resource, relativeToURL: baseUrl) else {
            return nil
        }
        
        return url
    }
}