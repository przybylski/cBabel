//
//  RecentProjectsViewController.swift
//  cBabel
//
//  Created by Bartosz Przybylski on 23.03.2018.
//  Copyright © 2018 Bartosz Przybylski. All rights reserved.
//

import Cocoa

class RecentProjectsViewController : NSViewController {

	@IBOutlet var recentProjectsStack : NSStackView?
	@IBOutlet var openProjectLabel : NSButton?

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		fillRecentView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fillRecentView()
	}

	@IBAction func openProjectClicked(sender: Any) {
		let openFileModal = NSOpenPanel()
		openFileModal.canChooseDirectories = true
		openFileModal.canChooseFiles = false
		openFileModal.allowsMultipleSelection = false
        
		openFileModal.beginSheetModal(for: self.view.window!) { (modalResponse) in

		}
	}

	private func fillRecentView() {

	}

}
