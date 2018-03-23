//
//  ConfigurationReader.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 22.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation

class ConfigurationReader {

	private static let MANIFEST_FILE = "manifest.json"
	private static let LOCALES_DIR = "_locales"

	private static let DEFAULT_LOCALE_FIELD = "default_locale"

	var defaultLocale : String = "en"
	var existingLocale : [String] = []

	private let projectDirectory : Directory

	init(projectDir : String) {
		projectDirectory = Directory(path: projectDir)
	}

	func read() {
		if !projectDirectory.exists() {
			return
		}
		readDefaultLocale()
		readExisitingLocale()
	}

	private func readExisitingLocale() {
		existingLocale.removeAll()
		if let localeDirs = projectDirectory.getDir(dirname: ConfigurationReader.LOCALES_DIR) {
			for d in localeDirs.getSubdirs() {
				existingLocale.append(d.getName())
			}
		}
	}

	private func readDefaultLocale() {
		if let manifest = projectDirectory.getFile(filename: ConfigurationReader.MANIFEST_FILE),
			let fileData = manifest.readData() {
			readDefaultLocaleFrom(fileData: fileData)
		} else {
			NSLog("Error while reading default locale")
		}
	}

	private func readDefaultLocaleFrom(fileData : Data) {
		do {
			let jsonRaw = try JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers)
			if let json = jsonRaw as? NSMutableDictionary {
				defaultLocale = json[ConfigurationReader.DEFAULT_LOCALE_FIELD] as! String? ?? "en"
			}

		} catch {
			NSLog("Error while serializing file content: \(error)")
		}
	}

}
