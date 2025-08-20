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
    @Environment(\.colorScheme) private var colorScheme

    private var pageBackground: Color {
        if colorScheme == .dark {
            return Color(.systemGroupedBackground)   // or Color.black.opacity(0.95) if you want darker
        } else {
            return Color(hue: 0.086, saturation: 0.141, brightness: 0.972) // your old light bg
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            pageBackground.ignoresSafeArea()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SuggestionManager())

    }
}
