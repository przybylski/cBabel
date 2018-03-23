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



}
