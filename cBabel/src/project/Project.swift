//
//  Project.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 22.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation


class Project {

	var confReader : ConfigurationReader

	init(path: String) {
		confReader = ConfigurationReader(projectDir: path)
		confReader.read()
	}

	func hasLocalesDirectory() -> Bool {
		return confReader.isCorrectConfiguration() && confReader.hasLocalesDir()
	}

	func createLocalesDirectory() -> Bool {
		if !confReader.isCorrectConfiguration() {
			return false
		}

		let manager = FileManager.default
		do {
			try manager.createDirectory(atPath: confReader.getLocalesPath(), withIntermediateDirectories: true, attributes: nil)
		} catch {
			return false
		}
		return true
	}

	func getAvailableLocales() -> [String] {
		return confReader.existingLocale
	}


}
