//
//  CalendarView.swift
//  ClimbingTracker
//
//  日历视图：显示月度日历，支持点击日期记录攀岩
//

import SwiftUI

// MARK: - Date Identifiable Extension

extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}

struct CalendarView: View {
    @ObservedObject var dataManager: DataManager
    @State private var currentDate = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingMedium) {
                // 月份标题 + 工具栏
                calendarHeader

                // 星期标题行
                weekdayRow

                Divider()

                // 日历网格
                calendarGrid
            }
            .padding(.vertical, Theme.spacingLarge)
            .padding(.horizontal, Theme.spacingMedium)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .fill(Color(.systemBackground).opacity(0.95))
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            .padding(.horizontal, LayoutHelper.calendarHorizontalPadding)
            .padding(.vertical, Theme.spacingLarge)
        }
        .scrollDisabled(true)
        .gradientBackground()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    handleMonthSwipe(translation: value.translation)
                }
        )
        .sheet(item: $selectedDate) { date in
            RecordFormView(
                dataManager: dataManager,
                dateKey: date.toDateKey(),
                isPresented: Binding(
                    get: { selectedDate != nil },
                    set: { if !$0 { selectedDate = nil } }
                )
            )
        }
    }

    // MARK: - 日历工具栏

    private var calendarHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(calendar.component(.year, from: currentDate))年")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(calendar.component(.month, from: currentDate))月")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }

            Spacer()

            HStack(spacing: Theme.spacingSmall) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                        .padding(Theme.spacingSmall)
                }

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                        .padding(Theme.spacingSmall)
                }
            }
        }
    }

    // MARK: - 星期标题行

    private var weekdayRow: some View {
        HStack(spacing: 6) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - 日历网格

    private var calendarGrid: some View {
        let days = generateCalendarDays()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
            ForEach(days, id: \.date) { day in
                DayCell(
                    day: day,
                    record: dataManager.getRecord(for: day.date.toDateKey()),
                    isCurrentMonth: day.isCurrentMonth
                )
                .onTapGesture {
                    selectedDate = day.date
                }
            }
        }
    }

    // MARK: - 辅助方法

    private func changeMonth(by offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: currentDate) {
            currentDate = newDate
        }
    }

    private func handleMonthSwipe(translation: CGSize) {
        let horizontal = translation.width
        let vertical = translation.height
        guard abs(horizontal) > abs(vertical) else { return }
        if horizontal > 40 {
            changeMonth(by: -1) // 左往右：上个月
        } else if horizontal < -40 {
            changeMonth(by: 1) // 右往左：下个月
        }
    }

    private func generateCalendarDays() -> [CalendarDay] {
        var days: [CalendarDay] = []

        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)

        // 当月第一天
        guard let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return days
        }

        // 当月第一天是星期几（0=周日，1=周一，...）
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1

        // 当月天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 30

        // 上个月的补位日期
        if firstWeekday > 0 {
            guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth) else {
                return days
            }
            let daysInPrevMonth = calendar.range(of: .day, in: .month, for: prevMonth)?.count ?? 30

            for i in (0..<firstWeekday).reversed() {
                let day = daysInPrevMonth - i
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: prevMonth),
                                                                  month: calendar.component(.month, from: prevMonth),
                                                                  day: day)) {
                    days.append(CalendarDay(date: date, isCurrentMonth: false))
                }
            }
        }

        // 当月日期
        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(CalendarDay(date: date, isCurrentMonth: true))
            }
        }

        // 下个月的补位日期（填充到42个格子，6行x7列）
        let remainingDays = 42 - days.count
        if remainingDays > 0 {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) else {
                return days
            }

            for day in 1...remainingDays {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: nextMonth),
                                                                  month: calendar.component(.month, from: nextMonth),
                                                                  day: day)) {
                    days.append(CalendarDay(date: date, isCurrentMonth: false))
                }
            }
        }

        return days
    }
}

// MARK: - 日历日期数据结构

struct CalendarDay {
    let date: Date
    let isCurrentMonth: Bool
}

// MARK: - 日期单元格

struct DayCell: View {
    let day: CalendarDay
    let record: ClimbRecord?
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: day.date))")
                .font(.system(size: Theme.fontSizeLarge, weight: .bold))
                .foregroundColor(isCurrentMonth ? .primary : .secondary)

            if let record = record {
                Text(record.gym)
                    .font(.system(size: Theme.fontSizeSmall))
                    .foregroundColor(Theme.primary)
                    .opacity(isCurrentMonth ? 1.0 : 0.5)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()
        }
        .frame(height: LayoutHelper.calendarCellHeight)
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(backgroundColor)
        .cornerRadius(Theme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var backgroundColor: Color {
        if record != nil {
            return Theme.primarySoft.opacity(isCurrentMonth ? 1.0 : 0.5)
        } else if !isCurrentMonth {
            return Color(.systemGray6)
        } else {
            return Color(.systemBackground)
        }
    }

    private var borderColor: Color {
        if record != nil {
            return Theme.primary.opacity(isCurrentMonth ? 0.5 : 0.25)
        } else {
            return Color(.systemGray4)
        }
    }
}

#Preview {
    CalendarView(dataManager: DataManager.shared)
        .padding()
}
