//
//  ContentView.swift
//  KafkaGame
//
//  Created by Alex on 2/20/23.
//

import SwiftUI
import SwiftyJSON
import AlertToast

struct ContentView: View {
	private let TAG = String(describing: ContentView.self)
	
	@State var items: [String]
	@State private var showToast = false
	@State private var toastMsg = ""
	
    var body: some View {
		ZStack {
			ScrollView {
				VStack {
					Button {
						httpSend()
					} label: {
						Text("Send data")
							.foregroundColor(.white)
							.frame(width: 150, height: 60)
							.background(.blue)
							.cornerRadius(10)
					}
					.padding(.bottom, 10)
					
					//				List(items, id: \.self) { item in
					//					Text(item)
					//				}
					//				.listStyle(PlainListStyle())
					
					ForEach(items, id: \.self) { item in
						VStack {
							Text(item)
								.padding(5)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
        .padding()
		.onAppear {
			httpRequest()
		}
		.toast(isPresenting: $showToast) {
			AlertToast(displayMode: .hud, type: .regular, title: toastMsg)
		}
    }
	
	func getTimestamp(_ timestamp: Int) -> String {
		// Create a Date object from the Unix timestamp
		let date = Date(timeIntervalSince1970: Double(timestamp) / 1000)
		
		// Create a DateFormatter object to format the date and time string
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
		
		// Convert the Date object to a formatted date and time string
		let formattedDateString = dateFormatter.string(from: date)
		
		return formattedDateString
	}
	
	func httpRequest() {
		DispatchQueue.global().async {
			while(true) {
				HTTP.GET("/consume/mygroup1/myconsumer3/game-enriched") { [self] data, error in
					DispatchQueue.main.async { [self] in
						if let error = error {
							Log.i(TAG, error.localizedDescription)
						} else if let data = data {
							if !data.isEmpty {
								Log.i(TAG, "httpRequest response: \(data)")
								
								for item in data {
									let itemJson = item.1
//									let key = itemJson["key"].stringValue
									let kafkaValueJson = itemJson["value"].string
									
									var userId: String? = nil
									var color: String? = nil
									var colorValue: Int? = nil
									
									if let kafkaValueJson = kafkaValueJson {
										do {
											let jsonData = kafkaValueJson.data(using: .utf8)!
											let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
											let json = JSON(dictionary as Any)
											
											if let userIdJson = json["userId"].string {
												userId = userIdJson
											}
											
											if let colorJson = json["color"].string {
												color = colorJson
											}
											
											if let colorValueJson = json["colorValue"].int {
												colorValue = colorValueJson
											}
										} catch {
											print(error.localizedDescription)
										}
									}
									
									var timestampStr: String? = nil
									if let timestamp = itemJson["timestamp"].int {
										timestampStr = getTimestamp(timestamp)
									}
									
//									var msg = "key: \(key)"
									var msg = ""
									if let timestampStr = timestampStr, let userId = userId, let color = color, let colorValue = colorValue {
										msg.insert(contentsOf: "\(timestampStr) - ", at: msg.startIndex)
										msg.append("userId: \(userId), color: \(color), colorValue: \(colorValue)")
										
										Log.i(TAG, "Adding msg: \(msg)")
										items.insert(msg, at: 0)
									}
								}
							}
						}
					}
				}
				
				sleep(1)
			}
		}
	}

    // make an http request function called httpRequest()
	func httpSend() {
		Log.i(TAG, "Hello")
		
		let userId = "myuserid"
		
		let colors = ["red", "green", "blue", "yellow"]
		
		let randomIndex = Int.random(in: 0..<colors.count)
		let randomColor = colors[randomIndex]
		let value = Int.random(in: 0...100)
		
		let gameInfo = JSON([
			"userId": userId,
			"selection": randomColor,
			"value": value
		])
		
		let userInfo = JSON([
			"nickname": "jologop"
		])
		
		let data1 = JSON([
			"key": userId,
			"value": String(describing: gameInfo)
		])
		let data2 = JSON([
			"key": userId,
			"value": String(describing: userInfo)
		])
		let data = JSON([data1/*, data2*/])
		Log.i(TAG, "Sending data: \(data)")
		
		HTTP.POST("/produce/game", data) { [self] data, error in
			DispatchQueue.main.async { [self] in
				if let error = error {
					Log.i(TAG, error.localizedDescription)
				} else {
					Log.i(TAG, "httpSend response: \(String(describing: data))")
					
					toastMsg = "userId: \(userId), selection: \(gameInfo["selection"].stringValue), value: \(gameInfo["value"].intValue)"
					showToast = true
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(items: ["item 1", "item 2", "item 3"])
    }
}
