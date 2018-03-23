//
//  File.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 22.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation

class File {

	let filePath : String

	init(path: String) {
		filePath = path
	}

	func exists() -> Bool {
		let manager = FileManager.default
		return manager.fileExists(atPath: filePath)
	}

	func readData() -> Data? {
		if !exists() {
			return nil
		}

		do {
			return try Data(contentsOf: URL(fileURLWithPath: filePath))
		} catch {
			NSLog("Error while reading file content \(error)")
			return nil
		}
	}
}
