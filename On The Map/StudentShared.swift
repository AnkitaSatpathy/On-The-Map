//
//  StudentShared.swift
//  On The Map
//
//  Created by Ankita Satpathy on 26/06/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import Foundation

class StudentShared {
    var students : [ParseAPIClient.ParseModel] = []
    static let sharedInstance = StudentShared()
}
