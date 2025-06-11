//
//  TaskRow.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct TaskRow: View {
    var task: String
    var quantity: Int
    var completed: Bool

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: completed ? "checkmark.circle" : "circle")

            VStack(alignment: .leading) {
                Text(task)
                    .font(.body)
                if quantity > 1 {
                    Text("Qty: \(quantity)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: "Do laundry", quantity: 1, completed: true)
    }
}
