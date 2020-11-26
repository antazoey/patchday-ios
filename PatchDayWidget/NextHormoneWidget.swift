//
//  PatchDayWidget.swift
//  PatchDayWidget
//
//  Created by Juliya Smith on 11/23/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
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

    private static func getDeliveryMethod() -> String? {
        let key = PDSetting.DeliveryMethod.rawValue
        return defaults.string(forKey: key)
    }

    private static func getNextHormoneSiteName() -> String? {
        let siteKey = SharedDataKey.NextHormoneSiteName.rawValue
        return defaults.string(forKey: siteKey)
    }

    private static func getNextHormoneExpirationDate() -> Date? {
        let dateKey = SharedDataKey.NextHormoneDate.rawValue
        return defaults.object(forKey: dateKey) as? Date
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
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

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

    var body: some View {
        let hormoneNameText = entry.hormone.name ?? NSLocalizedString(
            "...", comment: "Widget"
        )
        var expDateText: String
        if let storedDate = entry.hormone.date {
            expDateText = "At: \(Self.format(date: storedDate))"
        } else {
            expDateText = "..."
        }
        return VStack(alignment: .leading, spacing: 4) {
            Text("HRT")
                .font(.system(.title3))
                .foregroundColor(.black)
            Text(hormoneNameText)
                .font(.system(.callout))
                .foregroundColor(.black)
                .bold()
            Text(expDateText)
                .font(.system(.caption2))
                .foregroundColor(.black)
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .leading
        )
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.orange, .yellow]),
                    startPoint: .top,
                    endPoint: .bottom)
            )
    }

    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        return formatter.string(from: date)
    }
}
