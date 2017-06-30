//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Ankita Satpathy on 26/06/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain( updates: @escaping() -> Void) { //to perform UI updates
    DispatchQueue.main.async {
        updates()
    }
}
