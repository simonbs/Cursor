//
//  Request.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

extension Request {
    // Transform response data from a request from Alamofire into JSON using the SwiftyJSON framework.
    // If a proper transform is not possible, JSON.null is used.
    // Optionally provide a queue to return on, returns on the main queue by default.
    func responseSwiftyJSON(queue: dispatch_queue_t? = nil, completion: (NSURLRequest, NSHTTPURLResponse?, JSON, ErrorType?) -> Void) -> Self {
        let options: NSJSONReadingOptions = [  .AllowFragments ]
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { response -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let result = response.result
                var responseJSON: JSON
                if result.isFailure {
                    responseJSON = JSON.null
                } else {
                    responseJSON = JSON(result.value!)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completion(self.request!, self.response, responseJSON, result.error)
                })
            })
        })
    }
}
