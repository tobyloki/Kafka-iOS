//
//  GET.swift
//  DialIos
//
//  Created by user194038 on 5/8/21.
//

import SwiftUI
import SwiftyJSON

class HTTP {
	private static let TAG = String(describing: HTTP.self)
	
	private static let endpoint = "https://secure-serval-7009-us1-kafka.upstash.io"
	
	public static func GET(_ path: String, _ completionHandler: ((JSON?, Error?) -> Void)?) {
		DispatchQueue.global().async {
			// URL
			let url:URL? = URL(string: endpoint + path)
			
			guard url != nil else {
				Log.i(TAG, "Error creating url object")
				completionHandler?(nil, "Error creating url object")
				return
			}
			
			// URL Request
			var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
			
			// Specify the header
			let credentials = "c2VjdXJlLXNlcnZhbC03MDA5JNC8h_-vI9Koo8np5i1hMWzWRBX5dRuPN_krkSc:c0198c8c37c54d3bbb1b676597ac6a0d"
			let encodedCredentials = Data(credentials.utf8).base64EncodedString()
			
			let headers = [
				"Content-Type": "application/json",
				"Authorization": "Basic \(encodedCredentials)"
			]
			
			request.allHTTPHeaderFields = headers
			
			// Set the request type
			request.httpMethod = "GET"
			
			// Get the URLSession
			let sesion = URLSession.shared
			
			// Create the data task
			let dataTask = sesion.dataTask(with: request) { (data, response, error) in
				// Check for error in network request
				if let error = error {
					Log.i(TAG, error.localizedDescription)
					completionHandler?(nil, error)
				} else {
					// get the status code
					var statusCode: Int = -1
					if let response = response as? HTTPURLResponse {
						statusCode = response.statusCode
						Log.i(TAG, "\(request.httpMethod!) - Status Code: \(statusCode)")
					}
					
					// get the raw string data
//					Log.i(TAG, "\(request.httpMethod!) - Response: \(data != nil ? String(decoding: data!, as: UTF8.self) : "<No Data>")")
					
					if !(200...299).contains(statusCode) {   // good status code
						Log.i(TAG, "\(request.httpMethod!) - Error status code: \(statusCode)")
						completionHandler?(nil, String(decoding: data!, as: UTF8.self))
					} else if data != nil && data!.count > 0 {
						// Try to parse out the data
						do {
							let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]]
							let json = JSON(dictionary as Any)
							if json.error == nil {
								completionHandler?(json, nil)
							} else {
								Log.i(TAG, "\(request.httpMethod!) - Error parsing json: \(json.error!)")
								completionHandler?(nil, json.error)
							}
						} catch let error {
							Log.i(TAG, "\(request.httpMethod!) - Error parsing response data: \(error)")
							completionHandler?(nil, error)
						}
					} else {
						// no error, but no data either
						completionHandler?(nil, nil)
					}
				}
			}
			
			// Fire off the data task
			dataTask.resume()
		}
	}
	
	public static func POST(_ path: String, _ data: JSON, _ completionHandler: ((JSON?, Error?) -> Void)?) {
		// URL
		let url:URL? = URL(string: endpoint + path)
		
		guard url != nil else {
			Log.i(TAG, "Error creating url object")
			completionHandler?(nil, "Error creating url object")
			return
		}
		
		// URL Request
		var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
		
		// Specify the header
		let credentials = "c2VjdXJlLXNlcnZhbC03MDA5JNC8h_-vI9Koo8np5i1hMWzWRBX5dRuPN_krkSc:c0198c8c37c54d3bbb1b676597ac6a0d"
		let encodedCredentials = Data(credentials.utf8).base64EncodedString()
		
		let headers = [
			"Content-Type": "application/json",
			"Authorization": "Basic \(encodedCredentials)"
		]
		
		request.allHTTPHeaderFields = headers
		
		// Specify the body
		do {
			let requestBody = try data.rawData()
			request.httpBody = requestBody
		} catch {
			Log.i(TAG, "Error creating the data object from json: \(error)")
			completionHandler?(nil, error)
		}
		
		// Set the request type
		request.httpMethod = "POST"
		
		// Get the URLSession
		let sesion = URLSession.shared
		
		// Create the data task
		let dataTask = sesion.dataTask(with: request) { (data, response, error) in
			// Check for error in network request
			if let error = error {
				Log.i(TAG, error.localizedDescription)
				completionHandler?(nil, error)
			} else {
				// get the status code
				var statusCode: Int = -1
				if let response = response as? HTTPURLResponse {
					statusCode = response.statusCode
					Log.i(TAG, "\(request.httpMethod!) - Status Code: \(statusCode)")
				}
				
				// get the raw string data
//				Log.i(TAG, "\(request.httpMethod!) - Response: \(data != nil ? String(decoding: data!, as: UTF8.self) : "<No Data>")")
				
				if !(200...299).contains(statusCode) {   // good status code
					Log.i(TAG, "\(request.httpMethod!) - Error status code: \(statusCode)")
					completionHandler?(nil, String(decoding: data!, as: UTF8.self))
				} else if data != nil && data!.count > 0 {
					// Try to parse out the data
					do {
						let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]]
						let json = JSON(dictionary as Any)
						if json.error == nil {
							completionHandler?(json, nil)
						} else {
							Log.i(TAG, "\(request.httpMethod!) - Error parsing json: \(json.error!)")
							completionHandler?(nil, json.error)
						}
					} catch let error {
						Log.i(TAG, "\(request.httpMethod!) - Error parsing response data: \(error)")
						completionHandler?(nil, error)
					}
				} else {
					// no error, but no data either
					completionHandler?(nil, nil)
				}
			}
		}
		
		// Fire off the data task
		dataTask.resume()
		//        }
	}
}
