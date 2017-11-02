//
//  MSALGraphRequest.swift
//  TM
//
//  Created by Amin Amjadi on 8/5/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import Foundation

/*protocol MSALGraphRequesting
{
    func getJSON(path: String, completion: @escaping (_ json: [String:Any]?, Error?) -> Void)
    func getData(path: String, completion: @escaping (_ data: Data?, Error?) -> Void)
}*/

class MSALGraphRequest {
    
    let kGraphErrorDomain: NSErrorDomain = "MSALGraphErrorDomain"
    
    var token: String
    
    class func graphURL(with path:String) -> URL? {
        return URL(string: "https://graph.microsoft.com/beta/\(path)")
    }
    
    init(withToken token: String) {
        self.token = token
    }
    
    func getJSON(path: String, completion: @escaping (_ json: [String:Any]?, Error?) -> Void) {
        
        getData(path: path) {
            (data, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            do {
                let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                completion(resultJson, nil)
                return
            }
            catch let error {
                completion(nil, error)
                return
            }
        }
    }
    
    func getData(path: String, completion: @escaping (_ data: Data?, Error?) -> Void) {
        let urlRequest = NSMutableURLRequest()
        urlRequest.url = MSALGraphRequest.graphURL(with: path)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [ "Authorization" : "Bearer \(token)" ]
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let response = response as? HTTPURLResponse, 200 == response.statusCode {
                completion(data, nil)
                return
            }
            else {
                do {
                    let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    completion(nil, NSError(domain: self.kGraphErrorDomain as String,
                                            code: (response as? HTTPURLResponse)!.statusCode,
                                            userInfo: resultJson["error"] as! [String : Any]))
                    return
                }
                catch let error {
                    completion(nil, error)
                    return
                }
            }
        }
        task.resume()
    }
}

