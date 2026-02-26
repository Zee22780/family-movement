import SwiftUI

struct StatsView: View {
    @AppStorage("dailySteps") private var dailyStepsData: String = "{}"
    @AppStorage("todaySteps") private var legacyTodaySteps: Int = 0
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var todayKey: String {
        Self.dateFormatter.string(from: Date())
    }

    private var dailySteps: [String: Int] {
        decodeDailySteps()
    }

    private var weekKeys: [String] {
        keys(in: .weekOfYear)
    }

    private var monthKeys: [String] {
        keys(in: .month)
    }

    private var yearKeys: [String] {
        keys(in: .year)
    }

    private var weekTotal: Int {
        sum(for: weekKeys)
    }

    private var monthTotal: Int {
        sum(for: monthKeys)
    }

    private var yearTotal: Int {
        sum(for: yearKeys)
    }

    private var daysLoggedThisWeek: Int {
        weekKeys.filter { (dailySteps[$0] ?? 0) > 0 }.count
    }

    private var coachLine: String {
        if weekTotal == 0 {
            return "Log today to start the streak."
        }
        if daysLoggedThisWeek < 3 {
            return "Good start—let’s get 3 days."
        }
        if daysLoggedThisWeek < 5 {
            return "Momentum’s building—keep going."
        }
        return "Strong week—keep it rolling."
    }

    private var last7Days: [(date: Date, key: String, steps: Int)] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            let key = Self.dateFormatter.string(from: date)
            return (date, key, dailySteps[key] ?? 0)
        }
    }

    private var maxLast7: Int {
        max(1, last7Days.map { $0.steps }.max() ?? 1)
    }

    private var bestDayThisMonth: (date: Date, steps: Int)? {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else {
            return nil
        }
        var best: (Date, Int)? = nil
        for date in dates(in: interval) {
            let key = Self.dateFormatter.string(from: date)
            let value = dailySteps[key] ?? 0
            if value <= 0 {
                continue
            }
            if let current = best {
                if value > current.1 {
                    best = (date, value)
                }
            } else {
                best = (date, value)
            }
        }
        return best
    }

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBlue)
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stats")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Keep stacking days.")
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("This week")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            Text("\(weekTotal) steps")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryBlue)

                            Text("Days logged: \(daysLoggedThisWeek) / 7")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last 7 days")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(Array(last7Days.enumerated()), id: \.offset) { _, item in
                                    VStack(spacing: 6) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(item.steps > 0 ? Color.primaryBlue : Color.gray.opacity(0.3))
                                            .frame(height: CGFloat(item.steps) / CGFloat(maxLast7) * 80)

                                        Text(dayAbbrev(for: item.date))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("This month")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(monthTotal)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primaryBlue)
                            }

                            HStack {
                                Text("This year")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(yearTotal)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primaryBlue)
                            }

                            if let best = bestDayThisMonth {
                                HStack {
                                    Text("Best day")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(best.steps) • \(shortDate(best.date))")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primaryBlue)
                                }
                            } else {
                                HStack {
                                    Text("Best day")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("Log one to set it")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)

                        Text(coachLine)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.teal)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear {
            if legacyTodaySteps > 0 {
                let current = decodeDailySteps()
                if current[todayKey] == nil {
                    var updated = current
                    updated[todayKey] = legacyTodaySteps
                    dailyStepsData = encodeDailySteps(updated)
                }
            }
        }
    }

    private func sum(for keys: [String]) -> Int {
        keys.reduce(0) { $0 + (dailySteps[$1] ?? 0) }
    }

    private func keys(in component: Calendar.Component) -> [String] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: component, for: Date()) else {
            return []
        }
        return dates(in: interval).map { Self.dateFormatter.string(from: $0) }
    }

    private func dates(in interval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var current = interval.start
        let calendar = Calendar.current
        while current < interval.end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }
        return dates
    }

    private func dayAbbrev(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func decodeDailySteps() -> [String: Int] {
        guard let data = dailyStepsData.data(using: .utf8) else {
            return [:]
        }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }

    private func encodeDailySteps(_ steps: [String: Int]) -> String {
        guard let data = try? JSONEncoder().encode(steps),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

#Preview {
    StatsView()
}
