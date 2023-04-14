//
//  Logging.swift
//  DialIos
//
//  Created by user194038 on 5/9/21.
//

import os

class Log {
	static var logger = Logger()
	
	static func i(_ tag:String, _ message:String){
		logger.info("\(tag) - \(message)")
	}
}
