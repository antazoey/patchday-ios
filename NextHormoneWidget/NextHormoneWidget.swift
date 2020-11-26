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
    let name: String?
    let date: Date?
}

struct NextHormoneEntry: TimelineEntry {
    let date: Date
    let hormone: NextHormone
}

struct NextHormoneLoader {

    private static var defaults = UserDefaults(suiteName: PDSharedDataGroupName)!

    static func fetch(completion: @escaping (NextHormone) -> Void) {
        let siteName = self.getNextHormoneSiteName()
        let nextDate = self.getNextHormoneExpirationDate()
        let next = NextHormone(name: siteName, date: nextDate)
        completion(next)
    }

    private static func getNextHormoneSiteName() -> String? {
        let key = SharedDataKey.NextHormoneSiteName.rawValue
        return defaults.string(forKey: key)
    }

    private static func getNextHormoneExpirationDate() -> Date? {
        let key = SharedDataKey.NextHormoneDate.rawValue
        return defaults.object(forKey: key) as? Date
    }
}

struct NextHormoneTimeline: TimelineProvider {
    typealias Entry = NextHormoneEntry

    func placeholder(in context: Context) -> NextHormoneEntry {
        let fakeHormone = NextHormone(name: SiteStrings.RightAbdomen, date: Date())
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
            entry in
            NextHormoneWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Hormone")
        .description("Shows your next hormone to change.")
    }
}

struct PlaceholderView : View {
    var body: some View {
        Text("Loading...")
    }
}

struct NextHormoneWidgetView : View {
    let entry: NextHormoneEntry

    var gradient: Gradient {
        Gradient(colors: [.pink, .white])
    }

    var body: some View {
        var dateText: String?
        if let d = entry.hormone.date {
            dateText = PDDateFormatter.formatDate(d)
        }

        var nameTextView: Text?
        if let n = entry.hormone.name {
            nameTextView = Text(n).font(.system(.callout)).foregroundColor(.black).bold()
        }

        var dateTextView: Text?
        if let d = dateText {
            dateTextView = Text(d).font(.system(.caption2)).foregroundColor(.black)
        }

        return VStack(alignment: .leading, spacing: 4) {
            nameTextView
            dateTextView
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding()
        .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
    }
}
