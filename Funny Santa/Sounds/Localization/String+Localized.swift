//
//  String+Localized.swift
//  InternetShopKeeper
//
//  Created by Oleksandr Solokha on 13.04.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import Foundation


// extension to String Type for localize language
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
