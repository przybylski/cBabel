//
//  ConfigurationReader.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 22.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation

class ConfigurationReader {

	let configurationFile : File

	init(file : File) {
		configurationFile = file;
	}

	func read() {
		if !configurationFile.exists() {
			return
		}
		if let fileData = configurationFile.readData() {
			readFrom(fileData: fileData)
		}
	}

	private func readFrom(fileData : Data) {
		do {
			let jsonRaw = try JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers)
			if let json = jsonRaw as? NSMutableDictionary {
				var defaultLocale = json["default_locale"]
				if defaultLocale == nil {
					defaultLocale = "en"
				}
				NSLog("Default locale is \(String(describing: defaultLocale))")
			}

		} catch {
			NSLog("Error while serializing file content: \(error)")
		}
	}

}
