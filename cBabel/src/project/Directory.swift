//
//  Directory.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 23.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Foundation

class Directory {

	private var path : String

	init(path: String) {
		self.path = path
	}

	func getFile(filename : String) -> File? {
		let fullPath = path + "/" + filename
		let file = File(path: fullPath)
		let manager = FileManager.default
		if !file.exists() || !manager.isReadableFile(atPath: fullPath) {
			return nil
		}
		return file
	}

	func getName() -> String {
		return path.components(separatedBy: "/").last!
	}

	func getDir(dirname : String) -> Directory? {
		let fullPath = path + "/" + dirname
		let manager = FileManager.default
		var isDir : ObjCBool = false
		let exists = manager.fileExists(atPath: fullPath, isDirectory: &isDir)
		if !exists || !isDir.boolValue {
			return nil
		}
		return Directory(path: fullPath)
	}

	func exists() -> Bool {
		let manager = FileManager.default
		var isDir : ObjCBool = false
		let exists = manager.fileExists(atPath: path, isDirectory: &isDir)
		return exists && isDir.boolValue
	}

	func getContentList() -> [String] {
		do {
			let manager = FileManager.default
			return try manager.contentsOfDirectory(atPath: path)
		} catch {
			NSLog("Error while getting dir content \(error)")
			return []
		}
	}

	func getSubdirs() -> [Directory] {
		let content = getContentList()
		var result : [Directory] = []
		for s in content {
			if let d = getDir(dirname: s) {
				result.append(d)
			}
		}
		return result
	}

}
