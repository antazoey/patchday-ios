//
//  NextHormoneWidget.swift
//  NextHormoneWidget
//
//  Created by Juliya Smith on 11/23/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import WidgetKit
import SwiftUI
import PDKit

struct NextHormone {
    let hormone: String?
    let hormoneDate: Date?
    let pill: String?
    let pillDue: Date?
}

struct NextHormoneEntry: TimelineEntry {
    let date: Date
    let hormone: NextHormone
}

struct NextHormoneLoader {
    private static var defaults = UserDefaults(suiteName: PDSharedDataGroupName)

    static func fetch(completion: @escaping (NextHormone) -> Void) {
        let siteName = self.getNextHormoneSiteName()
        let nextDate = self.getNextHormoneExpirationDate()
        let pillName = self.getNextPillName()
        let pillDate = self.getNextPillDate()
        let next = NextHormone(
            hormone: siteName, hormoneDate: nextDate, pill: pillName, pillDue: pillDate
        )
        completion(next)
    }

    private static func getNextHormoneSiteName() -> String? {
        defaults?.string(forKey: SharedDataKey.NextHormoneSiteName.rawValue)
    }

    private static func getNextHormoneExpirationDate() -> Date? {
        defaults?.object(forKey: SharedDataKey.NextHormoneDate.rawValue) as? Date
    }

    private static func getNextPillName() -> String? {
        defaults?.string(forKey: SharedDataKey.NextPillToTake.rawValue)
    }

    private static func getNextPillDate() -> Date? {
        defaults?.object(forKey: SharedDataKey.NextPillTakeTime.rawValue) as? Date
    }
}

struct NextHormoneTimeline: TimelineProvider {
    typealias Entry = NextHormoneEntry

    func placeholder(in context: Context) -> NextHormoneEntry {
        let fakeHormone = NextHormone(
            hormone: SiteStrings.RightAbdomen,
            hormoneDate: Date(),
            pill: PillStrings.DefaultPills[0],
            pillDue: Date()
        )
        return NextHormoneEntry(date: Date(), hormone: fakeHormone)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextHormoneEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(
        in context: Context, completion: @escaping (Timeline<NextHormoneEntry>
    ) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
            ?? currentDate

        NextHormoneLoader.fetch {
            nextHormone in
            let entry = NextHormoneEntry(date: currentDate, hormone: nextHormone)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}


@main
struct NextHormoneWidget: Widget {
    let kind: String = "PatchDayNextHormoneWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextHormoneTimeline()){
            entry in NextHormoneWidgetView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("Next Hormone", comment: "OS Config screen"))
        .description("Shows your next hormone to change.")
    }
}

struct PlaceholderView : View {
    var body: some View {
        Text(DotDotDot)
    }
}

struct StringTextWidgetView : View {
    let str: String?

    var body: some View {
        var view: Text?
        if let s = str {
            view = Text(s).font(.system(.callout)).foregroundColor(.black).bold()
        }
        return view
    }
}

struct DateTextWidgetView : View {
    let date: Date?

    var dateText: String? {
        var dateText: String?
        if let d = date {
            dateText = PDDateFormatter.formatDate(d)
        }
        return dateText
    }

    var body: some View {
        var dateTextView: Text?
        if let d = dateText {
            dateTextView = Text(d).font(.system(.caption2)).foregroundColor(.black)
        }
        return dateTextView
    }
}

struct NextHormoneWidgetView : View {
    let entry: NextHormoneEntry
    private let max: CGFloat = .infinity

    var gradient: Gradient {
        Gradient(colors: [.pink, .white])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            StringTextWidgetView(str: entry.hormone.hormone)
            DateTextWidgetView(date: entry.hormone.hormoneDate)
            StringTextWidgetView(str: entry.hormone.pill)
            DateTextWidgetView(date: entry.hormone.pillDue)
        }
        .frame(minWidth: 0, maxWidth: max, minHeight: 0, maxHeight: max, alignment: .leading)
        .padding()
        .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
    }
}
