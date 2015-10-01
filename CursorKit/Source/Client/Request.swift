//
//  Request.swift
//  Tracks
//
//  Created by Simon Støvring on 20/08/2015.
//  Copyright © 2015 SimonBS. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension Request {    
    func responseSwiftyJSON(queue: dispatch_queue_t? = nil, completion: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, ErrorType?) -> Void) -> Self {
        let options: NSJSONReadingOptions = [  .AllowFragments ]
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options)) { request, response, result in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var responseJSON: JSON
                if result.isFailure {
                    responseJSON = JSON.null
                } else {
                    responseJSON = SwiftyJSON.JSON(result.value!)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completion(self.request!, self.response, responseJSON, result.error)
                })
            })
        }
    }
}
