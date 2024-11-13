//
//  MainViewController.swift
//  tlator
//
//  Created by Bartosz Przybylski on 21.07.2015.
//  Copyright (c) 2015 Bartosz Przybylski. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers

extension URL {
  var isDirectory: Bool {
    return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory
      == true
  }
}

class ClosureMenuItem: NSObject {
  let action: () -> Void

  init(action: @escaping () -> Void) {
    self.action = action
  }

  @objc func performAction() {
    action()
  }
}

extension NSMenuItem {
  convenience init(
    title: String, keyEquivalent: String = "",
    actionClosure: @escaping () -> Void
  ) {
    let closureTarget = ClosureMenuItem(action: actionClosure)

    self.init(
      title: title, action: #selector(closureTarget.performAction),
      keyEquivalent: keyEquivalent)
    self.target = closureTarget

    objc_setAssociatedObject(
      self, "closureTarget", closureTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}

class MainViewController: NSViewController, NSTableViewDataSource {

  @IBOutlet weak var chooseOriginalFileBtn: NSButton!
  @IBOutlet weak var saveOriginalFileBtn: NSButton!
  @IBOutlet weak var saveTranslationFileBtn: NSButton!
  @IBOutlet weak var contentTable: NSTableView!
  @IBOutlet weak var localePicker: NSComboButton!

  var originalTextPath: URL?
  var translatedTextPath: URL?
  var originalText = NSMutableDictionary()
  var translatedText = NSMutableDictionary()
  var newEntryCounter = 1

  func parseLocale(path: String) -> NSMutableDictionary? {
    do {
      let localeURL = URL(string: path)
      let messageUrl = localeURL?.appendingPathComponent("messages.json")
      if let messagePath = messageUrl?.path {
        let data = NSData(contentsOfFile: messagePath)
        if let data = data as? Data {
          let jsonOpt =
            try JSONSerialization.jsonObject(
              with: data,
              options: JSONSerialization.ReadingOptions.mutableContainers
            ) as? NSMutableDictionary
          return jsonOpt
        }
      }

    } catch {
      self.showAlertDialog(msg: "Failed to decode file to json")
      return [:]
    }
    return [:]
  }

  func readOtheLocales(localeDir: String, mainLocale: String) {
    var availableLanguages: [String: URL?] = [:]
    do {
      let localeURL = URL(fileURLWithPath: localeDir)
      let fileManager = FileManager.default
      let dirContent = try fileManager.contentsOfDirectory(atPath: localeDir)
      for (_, langCode) in dirContent.enumerated() {
        if mainLocale.elementsEqual(langCode) == true {
          continue
        }
        if !langCode.matches(of: /^([a-z]{2}|[a-z]{2}-[A-Z]{2})$/).isEmpty {
          let langDir = localeURL.appendingPathComponent(langCode)
          availableLanguages[langCode] = langDir
        }
      }
    } catch {

    }
    self.localePicker.menu.removeAllItems()

    for (key, value) in availableLanguages {
      let action = {
        self.localePicker.stringValue = key
        NSLog("Selecting \(key)")
        if let path = value?.path, let parsed = self.parseLocale(path: path) {
          self.translatedText = parsed
          self.translatedTextPath = value?.appendingPathComponent(
            "messages.json")

          self.contentTable.reloadData()
        }
      }

      let menuItem = NSMenuItem(title: key, actionClosure: { action() })

      self.localePicker.menu.addItem(menuItem)
    }

  }

  @IBAction func openChooserDialog(sender: NSObject) {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.allowedContentTypes = [UTType.json]
    panel.beginSheetModal(
      for: self.view.window!,
      completionHandler: { (result) -> Void in
        if result == NSApplication.ModalResponse.OK {
          let fileUrl = panel.url
          let dirUrl = fileUrl?.deletingLastPathComponent()
          let languageCode = dirUrl?.lastPathComponent
          let localeDir = dirUrl?.deletingLastPathComponent()

          if let localeDirPath = localeDir?.path,
            let languageCode = languageCode
          {
            self.readOtheLocales(
              localeDir: localeDirPath, mainLocale: languageCode)
          }

          if let mainLocale = dirUrl?.path,
            let content = self.parseLocale(path: mainLocale)
          {
            self.originalText = content
            self.originalTextPath = fileUrl
          } else {
            self.showAlertDialog(msg: "Failed to read file")
          }
          self.contentTable.reloadData()
          panel.close()
        }
      })
  }

  @IBAction func addNewEntry(sender: NSObject) {
    self.originalText[self.getNewEntryName()] = NSMutableDictionary()
    self.contentTable.reloadData()
  }

  @IBAction func saveDocument(sender: NSObject) {
    if sender == self.saveOriginalFileBtn {
      if self.originalTextPath == nil {
        let saver = NSSavePanel()
        saver.beginSheetModal(
          for: self.view.window!,
          completionHandler: { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
              self.originalTextPath = saver.url
              self.saveDataOnPath(
                data: self.originalText, path: self.originalTextPath!)
            }
          })
      } else {
        self.saveDataOnPath(
          data: self.originalText, path: self.originalTextPath!)
      }

    } else if sender == self.saveTranslationFileBtn {
      if self.translatedTextPath == nil {
        let saver = NSSavePanel()
        saver.beginSheetModal(
          for: self.view.window!,
          completionHandler: { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
              self.translatedTextPath = saver.url
              self.saveDataOnPath(
                data: self.translatedText, path: self.translatedTextPath!)
            }
          })
      } else {
        self.saveDataOnPath(
          data: self.translatedText, path: self.translatedTextPath!)
      }
    }
  }

  func showAlertDialog(msg: String) {
    let alert = NSAlert()
    alert.informativeText = msg
    alert.messageText = "Opening failed"
    alert.alertStyle = NSAlert.Style.critical
    alert.runModal()
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.originalText.count
  }

  func tableView(
    _ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?,
    row: Int
  ) -> Any? {
    if var keys = self.originalText.allKeys as? [String],
      let id = tableColumn?.identifier
    {
      keys = keys.sorted(by: { $0 < $1 })
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

  func tableView(
    _ tableView: NSTableView, setObjectValue object: Any?,
    for tableColumn: NSTableColumn?, row: Int
  ) {
    if var keys = self.originalText.allKeys as? [String],
      let newValue = object as? String,
      let id = tableColumn?.identifier
    {
      keys = keys.sorted(by: { $0 < $1 })
      switch id.rawValue {
      case "id":
        let oldRow = keys[row]
        if oldRow == newValue { return }  // no work needed

        self.originalText[newValue] =
          self.originalText[oldRow] as! NSMutableDictionary
        self.originalText.removeObject(forKey: oldRow)
        if let v = self.translatedText[oldRow] as? NSMutableDictionary {
          self.translatedText[newValue] = v
          self.translatedText.removeObject(forKey: oldRow)
        }
        tableView.reloadData()
      case "originalText":
        (self.originalText[keys[row]] as! NSMutableDictionary)["message"] =
          newValue
      case "translatedText":
        if self.translatedText[keys[row]] == nil {
          self.translatedText[keys[row]] = NSMutableDictionary()
        }
        if let t = self.translatedText[keys[row]] as? NSMutableDictionary {
          t["message"] = newValue
        }
      case "description":
        (self.originalText[keys[row]] as? NSMutableDictionary)?["description"] =
          newValue
      default:
        NSLog("Incorrect table column \(id)")
      }
    }
  }

  func getNewEntryName() -> String {
    self.newEntryCounter += 1
    return String(format: "New entry %d", arguments: [self.newEntryCounter])
  }

  func saveDataOnPath(data: NSDictionary, path: URL?) {
    do {
      if let url = path {
        let jsonData = try JSONSerialization.data(
          withJSONObject: data,
          options: [
            JSONSerialization.WritingOptions.prettyPrinted,
            JSONSerialization.WritingOptions.sortedKeys,
          ])
        try jsonData.write(to: url)
      }
    } catch {
      NSLog("Error while serializing object \(error)")

    }
  }
}
