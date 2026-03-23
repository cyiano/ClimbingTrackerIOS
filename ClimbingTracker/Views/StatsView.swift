//
//  StatsView.swift
//  ClimbingTracker
//
//  统计视图：显示年度统计、月度趋势、指定月份统计
//

import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var dataManager: DataManager

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingLarge) {
                // 年度统计（按岩馆）
                YearStatsCard(dataManager: dataManager)

                // 近12个月趋势
                MonthTrendCard(dataManager: dataManager)

                // 指定月份统计（按岩馆）
                SelectedMonthStatsCard(dataManager: dataManager)
            }
            .padding(Theme.spacingLarge)
        }
        .gradientBackground()
    }
}

// MARK: - 年度统计卡片

struct YearStatsCard: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private var yearStats: [GymStat] {
        dataManager.getYearStats(year: selectedYear)
    }

    private var yearStatsPages: [[GymStat]] {
        let pageSize = 8
        guard !yearStats.isEmpty else { return [] }
        return stride(from: 0, to: yearStats.count, by: pageSize).map { start in
            let end = min(start + pageSize, yearStats.count)
            return Array(yearStats[start..<end])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMedium) {
            // 标题和年份选择器
            HStack {
                Text("年度统计（按岩馆）")
                    .font(.headline)

                Spacer()

                HStack(spacing: Theme.spacingSmall) {
                    Button(action: { selectedYear -= 1 }) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                            .padding(Theme.spacingSmall)
                            .background(Color(.systemGray5))
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }

                    Picker("年份", selection: $selectedYear) {
                        ForEach(1970...2099, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .fixedSize()

                    Button(action: { selectedYear += 1 }) {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .padding(Theme.spacingSmall)
                            .background(Color(.systemGray5))
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }
                }
            }

            if yearStats.isEmpty {
                Text("暂无记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // 柱状图（水平滑动窗口，最多展示8个条目宽度）
                GeometryReader { proxy in
                    let availableWidth = proxy.size.width
                    ScrollView(.horizontal, showsIndicators: false) {
                        Chart(yearStats) { item in
                            BarMark(
                                x: .value("岩馆", item.gym),
                                y: .value("次数", item.count)
                            )
                            .foregroundStyle(Theme.primary)
                            .cornerRadius(Theme.cornerRadiusSmall)
                        }
                        .frame(width: chartWidth(availableWidth: availableWidth, itemCount: yearStats.count))
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 8))
                        }
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .padding(.top, 12)
                    }
                }
                .frame(height: LayoutHelper.chartHeight)

                // 表格（分页，左右滑动）
                TabView {
                    ForEach(yearStatsPages.indices, id: \.self) { index in
                        yearStatsTable(pageItems: yearStatsPages[index])
                            .padding(.horizontal, 2)
                    }
                }
                .frame(height: tableHeight(for: yearStatsPages.first?.count ?? 0))
                .tabViewStyle(.page(indexDisplayMode: yearStatsPages.count > 1 ? .automatic : .never))
            }
        }
        .cardStyle()
    }

    private func yearStatsTable(pageItems: [GymStat]) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("岩馆")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("次数")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.vertical, Theme.spacingMedium)
            .background(Color(.systemGray6))

            ForEach(pageItems) { item in
                HStack {
                    Text(item.gym)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(item.count)")
                        .frame(width: 60, alignment: .trailing)
                }
                .padding(.vertical, Theme.spacingMedium)
                Divider()
            }
        }
        .font(.subheadline)
    }

    private func tableHeight(for itemCount: Int) -> CGFloat {
        let headerHeight: CGFloat = 44
        let rowHeight: CGFloat = 44
        let rowCount = max(1, itemCount)
        return headerHeight + (CGFloat(rowCount) * rowHeight)
    }

    private func chartWidth(availableWidth: CGFloat, itemCount: Int) -> CGFloat {
        let barSlotWidth: CGFloat = 44
        let contentWidth = CGFloat(itemCount) * barSlotWidth
        return max(availableWidth, contentWidth)
    }
}

// MARK: - 近12个月趋势卡片

struct MonthTrendCard: View {
    @ObservedObject var dataManager: DataManager

    private var trendData: [MonthTrendStat] {
        dataManager.getMonthTrendStats()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMedium) {
            Text("月度统计（近12个月）")
                .font(.headline)

            if trendData.isEmpty || trendData.allSatisfy({ $0.count == 0 }) {
                Text("暂无记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(trendData) { item in
                    LineMark(
                        x: .value("月份", item.label),
                        y: .value("次数", item.count)
                    )
                    .foregroundStyle(Theme.primary)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("月份", item.label),
                        y: .value("次数", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.primary.opacity(0.3),
                                Theme.primary.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("月份", item.label),
                        y: .value("次数", item.count)
                    )
                    .foregroundStyle(Theme.primary)
                }
                .frame(height: LayoutHelper.chartHeight)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 2))
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - 指定月份统计卡片

struct SelectedMonthStatsCard: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())

    private var monthStats: (total: Int, gyms: [GymStat]) {
        dataManager.getMonthStats(year: selectedYear, month: selectedMonth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMedium) {
            // 标题和月份选择器
            HStack {
                Text("指定月份统计（按岩馆）")
                    .font(.headline)

                Spacer()

                HStack(spacing: Theme.spacingSmall) {
                    Picker("年份", selection: $selectedYear) {
                        ForEach(1970...2099, id: \.self) { year in
                            Text("\(year)年").tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .fixedSize()

                    Picker("月份", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)月").tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .fixedSize()
                }
            }

            Text("\(selectedYear)年\(selectedMonth)月共攀岩 \(monthStats.total) 次")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if monthStats.gyms.isEmpty {
                Text("暂无记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // 柱状图
                Chart(monthStats.gyms) { item in
                    BarMark(
                        x: .value("岩馆", item.gym),
                        y: .value("次数", item.count)
                    )
                    .foregroundStyle(Color(.systemGray))
                    .cornerRadius(Theme.cornerRadiusSmall)
                }
                .frame(height: LayoutHelper.chartHeight)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }

                // 表格
                VStack(spacing: 0) {
                    HStack {
                        Text("岩馆")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("次数")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, Theme.spacingMedium)
                    .background(Color(.systemGray6))

                    ForEach(monthStats.gyms) { item in
                        HStack {
                            Text(item.gym)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(item.count)")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, Theme.spacingMedium)
                        Divider()
                    }
                }
                .font(.subheadline)
            }
        }
        .cardStyle()
    }
}

#Preview {
    StatsView(dataManager: DataManager.shared)
}
