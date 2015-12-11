//
//  Client.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

/// Handles communication with the server. The server handles communication with HomePort.
public class Client {
    private let baseUrl = NSURL(string: "http://34180550.ngrok.com")!

    public init() { }

    /**
     Perform a request using the specified HTTP method and resource.
     Map the received data into an array containing elements of type T.

     - Parameter method: The HTTP method to use.
     - Parameter resource: The resource to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter rootElementPath: Path to start mapping of objects at.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
    internal func request<T>(method: Method, _ resource: Resource, params: [String: String]? = nil, rootElementPath: JSONSubscriptType..., mapFunc: (JSON -> T?), completion: (FailableOf<[T]> -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, rootElementPath: rootElementPath, mapFunc: mapFunc, completion: completion)
    }
    
    /**
     Perform a request using the specified HTTP method and URL.
     Map the received data into an array containing elements of type T.
     
     - Parameter method: The HTTP method to use.
     - Parameter url: URL to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter rootElementPath: Path to start mapping of objects at.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
    internal func request<T>(method: Method, url: NSURL, params: [String: String]? = nil, rootElementPath: JSONSubscriptType..., mapFunc: (JSON -> T?), completion: (FailableOf<[T]> -> Void)? = nil) -> Request {
        return request(method, url: url, rootElementPath: rootElementPath, mapFunc: mapFunc, completion: completion)
    }

    /**
     Perform a request using the specified HTTP method and URL.
     Map the received data into an array containing elements of type T.
     
     - Parameter method: The HTTP method to use.
     - Parameter url: URL to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter rootElementPath: Path to start mapping of objects at.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
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
    
    /**
     Perform a request using the specified HTTP method and URL.
     Map the received data into object of type T.
     
     - Parameter method: The HTTP method to use.
     - Parameter resource: The resource to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter rootElementPath: Path to start mapping of objects at.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
    internal func request<T>(method: Method, _ resource: Resource, params: [String: String]? = nil, mapFunc: (JSON -> T?), completion: (FailableOf<T> -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, mapFunc: mapFunc, completion: completion)
    }
    
    /**
     Perform a request using the specified HTTP method and URL.
     Map the received data into object of type T.
     
     - Parameter method: The HTTP method to use.
          - Parameter url: URL to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter headers: Headers to supply to the request.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
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
    
    /**
     Perform a request using the specified HTTP method and URL.
     Map the received data into object of type T.
     
     - Parameter method: The HTTP method to use.
     - Parameter resource: The resource to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter mapFunc: Closure to map a single element in the received data.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
    internal func request(method: Method, _ resource: Resource, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, completion: (Failable -> Void)? = nil) -> Request? {
        guard let url = createURL(resource) else { return nil }
        return request(method, url: url, params: params, headers: headers, completion: completion)
    }
    
    /**
     Perform a request using the specified HTTP method and URL.
     
     - Parameter method: The HTTP method to use.
     - Parameter url: URL to send the request to.
     - Parameter params: Parameters to use. Whether query or body parameters are used and the encoding depends on the HTTP method.
     - Parameter headers: Headers to supply to the request.
     - Parameter completion: Closure receives the mapped response as an array containing elements of type T.
     
     - Returns: The request, if it could be started.
     */
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
    
    /**
     Map JSON into an error.
     
     - Parameter json: JSON to map into an array, if it contains an error.

     - Returns: The error, if any.
     */
    func errorFromJSON(json: JSON) -> NSError? {
        return nil
    }
    
    /**
     Create a URL from a resource.
     
     - Parameter resource: Resource to create URL from.

     - Returns: the URL, if it could be created.
     */
    private func createURL(resource: Resource) -> NSURL? {
        return NSURL(string: resource.resource, relativeToURL: baseUrl)
    }
}