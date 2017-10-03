//
//  clientAPI.swift
//  TypeSafeKituraClient
//
//  Created by Shihab Mehboob on 03/10/2017.
//  Copyright © 2017 IBM. All rights reserved.
//

import UIKit
import Foundation
import SwiftyRequest
import Kitura

public class Client {
    
    let serverURL: String
    
    /*
    init(url: String) {
        
    }
     
    client.get(path: "/users/1") { (result: Employee?, error: Error?) in
    
    }
     */
    
    func get<ReturnType: Codable>(path: String, id: String, onCompletion: (ReturnType?, Error?) -> Void) {
        // construct the GET request
        
        let url = "\(serverURL)\(path):\(id)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { response in
            
            if let value = try? JSONDecoder.decode(ReturnType.self, data: responseData) {
                onCompletion(value, nil)
            } else {
                onCompletion(nil, RequestError(message: ""))
            }
            
        }
    }
    
    func getAll<ReturnType: Codable>(path: String, onCompletion: (ReturnType?, Error?) -> Void) {
        // construct the GET request
        
        let url = "\(serverURL)\(path)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { response in
            
            if let value = try? JSONDecoder.decode(ReturnType.self, data: responseData) {
                onCompletion(value, nil)
            } else {
                onCompletion(nil, RequestError(message: ""))
            }
            
        }
    }
    
    func post<ReturnType: Codable>(path: String, data: Codable, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)\(path)"
        let param = try JSONDecoder().decode(data.self, from: data)
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey,
                                            message: param)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            if let value = try? JSONEncoder.encode(result) {
                response.send(data: value)
            } else {
                response.status(.internalServerError)
            }
            
        }
    }
    
    func put<ReturnType: Codable>(path: String, id: String, data: Codable, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)\(path):\(id)"
        let param = try JSONDecoder().decode(data.self, from: data)
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey,
                                            message: param)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            if let value = try? JSONEncoder.encode(result) {
                response.send(data: value)
            } else {
                response.status(.internalServerError)
            }
            
        }
    }
    
    func delete<ReturnType: Codable>(path: String, id: String, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)\(path):\(id)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            print(result)
            
        }
    }
    
    func deleteAll<ReturnType: Codable>(path: String, onCompletion: (ReturnType?, error?) -> Void) {
        // construct the POST request
        
        let url = "\(serverURL)\(path)"
        let requestParameters = RestRequest(method: .post,
                                            url: url,
                                            credentials: .apiKey)
        let request = RestRequest(requestParameters)
        request.responseData(responseToError: responseToError) { result in
            
            print(result)
            
        }
    }
    
}
