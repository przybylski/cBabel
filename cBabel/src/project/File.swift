//
//  File.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 22.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation

class File {

	let fileURL : URL

	init(url: URL) {
		fileURL = url
	}

	func exists() -> Bool {
		let manager = FileManager.default
		return manager.fileExists(atPath: fileURL.absoluteString)
	}

	func readData() -> Data? {
		if !exists() {
			return nil
		}

		do {
			return try Data(contentsOf: fileURL)
		} catch {
			NSLog("Error while reading file content \(error)")
			return nil
		}
	}
}
