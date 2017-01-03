//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Garret Koontz on 1/3/17.
//  Copyright © 2017 GK. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
