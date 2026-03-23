//
//  ContentView.swift
//  ClimbingTracker
//
//  主视图：Tab导航结构
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        TabView {
            // Tab 1: 日历
            NavigationView {
                CalendarView(dataManager: dataManager)
                    .navigationTitle("日历")
                    .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("日历", systemImage: "calendar")
            }

            // Tab 2: 统计
            NavigationView {
                StatsView(dataManager: dataManager)
                    .navigationTitle("统计")
                    .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("统计", systemImage: "chart.bar.fill")
            }

            // Tab 3: 管理
            NavigationView {
                DataManagementView(dataManager: dataManager)
                    .navigationTitle("数据管理")
                    .navigationBarTitleDisplayMode(.large)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("管理", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
