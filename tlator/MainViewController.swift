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

	var originalTextPath : String?
	var translatedTextPath : String?
	var originalText = NSMutableDictionary()
	var translatedText = NSMutableDictionary()
	var newEntryCounter = 1

	@IBAction func openChooserDialog(sender : NSObject) {
		var panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.beginSheetModalForWindow(self.view.window!, completionHandler: {(result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				if let u = panel.URL,
					let path = u.path,
					let data = NSData(contentsOfFile: path) {

						if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSMutableDictionary {

							if sender == self.chooseOriginalFileBtn {
								self.originalText = json
								self.originalTextPath = path
							} else if sender == self.chooseExistingFileBtn {
								self.translatedText = json
								self.translatedTextPath = path
							}

							self.contentTable.reloadData()

						} else {
							panel.close()
							self.showAlertDialog("Failed to decode file to json")
						}
				} else {
					panel.close()
					self.showAlertDialog("Failed to read file")
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
				var saver = NSSavePanel()
				saver.beginSheetModalForWindow(self.view.window!, completionHandler: {(result) -> Void in
					if result == NSFileHandlingPanelOKButton {
						self.originalTextPath = saver.URL?.path
						self.saveDataOnPath(self.originalText, path: self.originalTextPath!)
					}
				})
			} else {
				self.saveDataOnPath(self.originalText, path: self.originalTextPath!)
			}

		} else if (sender == self.saveTranslationFileBtn) {

			if self.translatedTextPath == nil {
				var saver = NSSavePanel()
				saver.beginSheetModalForWindow(self.view.window!, completionHandler: {(result) -> Void in
					if result == NSFileHandlingPanelOKButton {
						self.translatedTextPath = saver.URL?.path
						self.saveDataOnPath(self.translatedText, path: self.translatedTextPath!)
					}
				})
			} else {
				self.saveDataOnPath(self.translatedText, path: self.translatedTextPath!)
			}
		}
	}

	func showAlertDialog(msg : String) {
		var alert = NSAlert()
		alert.informativeText = msg
		alert.messageText = "Opening failed"
		alert.alertStyle = NSAlertStyle.CriticalAlertStyle
		alert.runModal()
	}

	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return self.originalText.count;
	}

	func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		if var keys = self.originalText.allKeys as? [String],
			let id = tableColumn?.identifier {
				keys.sort( { $0 < $1 } )
				switch id {
					case "id":
						return keys[row]
					case "originalText":
						return (self.originalText[keys[row]] as? NSDictionary)?["message"]
					case "description":
						return (self.originalText[keys[row]] as? NSDictionary)?["description"]
					case "translatedText":
						return (self.translatedText[keys[row]] as? NSDictionary)?["message"]
					default:
						NSLog("Incorrect table column %@", id)
				}
		}
		return nil
	}

	func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
		if var keys = self.originalText.allKeys as? [String],
			let newValue = object as? String,
			let id = tableColumn?.identifier {
				keys.sort( { $0 < $1 } )
				switch id {
					case "id":
						let oldRow = keys[row]
						if oldRow == newValue { return } // no work needed

						self.originalText[newValue] = self.originalText[oldRow] as! NSMutableDictionary
						self.originalText.removeObjectForKey(oldRow)
						if let v = self.translatedText[oldRow] as? NSMutableDictionary {
							self.translatedText[newValue] = v
							self.translatedText.removeObjectForKey(oldRow)
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
						NSLog("Incorrect table column %@", id)
				}
		}
	}

	func getNewEntryName() -> String {
		return String(format: "New entry %d", arguments: [self.newEntryCounter++])
	}

	func saveDataOnPath(data : NSDictionary, path : String) {
		var err : NSError?
		if let jsonData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.PrettyPrinted, error: &err) {
			jsonData.writeToFile(path, atomically: true)
		} else {
			NSLog("Error while serializing object \(err)")
		}
	}
}

