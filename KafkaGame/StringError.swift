//
//  StringError.swift
//  DialIos
//
//  Created by user194038 on 5/9/21.
//

import SwiftUI

extension String: LocalizedError {
	public var errorDescription: String? { return self }
}
