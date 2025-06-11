//
//  ContentView.swift
//  Shopping List
//
//  Created by Marcus Grant on 3/25/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var realmManager = RealmManager()
    @StateObject var suggestionManager = SuggestionManager()
    @State private var showAddTaskView = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(hue: 0.086, saturation: 0.141, brightness: 0.972)
            TasksView()
                .environmentObject(realmManager)
            
            SmallAddButton()
                .padding()
                .onTapGesture {
                    showAddTaskView.toggle()
                }
        }
        .sheet(isPresented: $showAddTaskView) {
            AddTaskView()
                .environmentObject(realmManager)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color(hue: 0.086, saturation: 0.141, brightness: 0.972))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SuggestionManager())

    }
}
