//
//  Task.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import Foundation
import RealmSwift

class ShoppingTask: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var completed: Bool = false
    @Persisted var quantity: Int = 1
    @Persisted var order: Int = 0
}


