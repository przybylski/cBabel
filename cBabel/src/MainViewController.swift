//
//  MainViewController.swift
//  tlator
//
//  Created by Bartosz Przybylski on 21.07.2015.
//  Copyright (c) 2015 Bartosz Przybylski. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource {

	@IBOutlet weak var chooseOriginalFileBtn : NSButton!
	@IBOutlet weak var chooseExistingFileBtn : NSButton!
	@IBOutlet weak var saveOriginalFileBtn : NSButton!
	@IBOutlet weak var saveTranslationFileBtn : NSButton!
	@IBOutlet weak var contentTable : NSTableView!

	var originalTextPath : URL?
	var translatedTextPath : URL?
	var originalText = NSMutableDictionary()
	var translatedText = NSMutableDictionary()
	var newEntryCounter = 1

	@IBAction func openChooserDialog(sender : NSObject) {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.beginSheetModal(for: self.view.window!, completionHandler: {(result) -> Void in
			if result == NSApplication.ModalResponse.OK {
				if let u = panel.url,
					let data = NSData(contentsOfFile: u.path) {

					do {

						let jsonOpt = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
						if let json = jsonOpt {

							if sender == self.chooseOriginalFileBtn {
								self.originalText = json
								self.originalTextPath = u
							} else if sender == self.chooseExistingFileBtn {
								self.translatedText = json
								self.translatedTextPath = u
							}

							self.contentTable.reloadData()
						}

					} catch {
						panel.close()
						self.showAlertDialog(msg: "Failed to decode file to json")
					}
				} else {
					panel.close()
					self.showAlertDialog(msg: "Failed to read file")
				}
			}
		})
	}

	@IBAction func addNewEntry(sender : NSObject) {
		self.originalText[self.getNewEntryName()] = NSMutableDictionary()
		self.contentTable.reloadData()
	}

	@IBAction func saveDocument(sender : NSObject) {
		if (sender == self.saveOriginalFileBtn) {
			if self.originalTextPath == nil {
				let saver = NSSavePanel()
				saver.beginSheetModal(for: self.view.window!, completionHandler: {(result) -> Void in
					if result == NSApplication.ModalResponse.OK {
						self.originalTextPath = saver.url
						self.saveDataOnPath(data: self.originalText, path: self.originalTextPath!)
					}
				})
			} else {
				self.saveDataOnPath(data: self.originalText, path: self.originalTextPath!)
			}

		} else if (sender == self.saveTranslationFileBtn) {

			if self.translatedTextPath == nil {
				let saver = NSSavePanel()
				saver.beginSheetModal(for: self.view.window!, completionHandler: {(result) -> Void in
					if result == NSApplication.ModalResponse.OK {
						self.translatedTextPath = saver.url
						self.saveDataOnPath(data: self.translatedText, path: self.translatedTextPath!)
					}
				})
			} else {
				self.saveDataOnPath(data: self.translatedText, path: self.translatedTextPath!)
			}
		}
	}

	func showAlertDialog(msg : String) {
		let alert = NSAlert()
		alert.informativeText = msg
		alert.messageText = "Opening failed"
		alert.alertStyle = NSAlert.Style.critical
		alert.runModal()
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.originalText.count;
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if var keys = self.originalText.allKeys as? [String],
			let id = tableColumn?.identifier {
				keys = keys.sorted( by: { $0 < $1 } )
				switch id.rawValue {
					case "id":
						return keys[row]
					case "originalText":
						return (self.originalText[keys[row]] as? NSDictionary)?["message"]
					case "description":
						return (self.originalText[keys[row]] as? NSDictionary)?["description"]
					case "translatedText":
						return (self.translatedText[keys[row]] as? NSDictionary)?["message"]
					default:
						NSLog("Incorrect table column \(id)")
				}
		}
		return nil
	}

	func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		if var keys = self.originalText.allKeys as? [String],
			let newValue = object as? String,
			let id = tableColumn?.identifier {
				keys = keys.sorted( by: { $0 < $1 } )
				switch id.rawValue {
					case "id":
						let oldRow = keys[row]
						if oldRow == newValue { return } // no work needed

						self.originalText[newValue] = self.originalText[oldRow] as! NSMutableDictionary
						self.originalText.removeObject(forKey: oldRow)
						if let v = self.translatedText[oldRow] as? NSMutableDictionary {
							self.translatedText[newValue] = v
							self.translatedText.removeObject(forKey: oldRow)
						}
						tableView.reloadData()
					case "originalText":
						(self.originalText[keys[row]] as! NSMutableDictionary)["message"] = newValue
					case "translatedText":
						if self.translatedText[keys[row]] == nil { self.translatedText[keys[row]] = NSMutableDictionary() }
						if let t = self.translatedText[keys[row]] as? NSMutableDictionary {
							t["message"] = newValue
						}
					case "description":
						(self.originalText[keys[row]] as? NSMutableDictionary)?["description"] = newValue
					default:
						NSLog("Incorrect table column \(id)")
				}
		}
	}

	func getNewEntryName() -> String {
		self.newEntryCounter += 1
		return String(format: "New entry %d", arguments: [self.newEntryCounter])
	}

	func saveDataOnPath(data : NSDictionary, path : URL?) {
		do {
			if let url = path {
				let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
				try jsonData.write(to: url)
			}
		} catch {
			NSLog("Error while serializing object \(error)")

		}
	}
}

