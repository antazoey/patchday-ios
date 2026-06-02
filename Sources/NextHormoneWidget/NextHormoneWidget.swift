//
//  NextHormoneWidget.swift
//  NextHormoneWidget
//
//  Created by Juliya Smith on 11/23/20.

import WidgetKit
import SwiftUI
import PDKit

struct NextHormone {
    let hormoneExpirationDate: Date?
    let hormoneSite: String?
    let pillsEnabled: Bool
    let pill: String?
    let pillDue: Date?
    let deliveryMethod: DeliveryMethod?
}

struct NextHormoneEntry: TimelineEntry {
    let date: Date
    let hormone: NextHormone
}

struct NextHormoneLoader {
    private static var defaults = UserDefaults(suiteName: PDSharedDataGroupName)

    static func fetch(completion: @escaping (NextHormone) -> Void) {
        let next = NextHormone(
            hormoneExpirationDate: nextHormoneExpirationDate,
            hormoneSite: nextHormoneSite,
            pillsEnabled: pillsEnabled,
            pill: nextPillName,
            pillDue: nextPillDate,
            deliveryMethod: deliveryMethod
        )
        completion(next)
    }

    private static var nextHormoneSite: String? {
        let site = defaults?.string(forKey: SharedDataKey.NextHormoneSite.rawValue)
        guard let site = site, !site.isEmpty, site != SiteStrings.NewSite else { return nil }
        return site
    }

    private static var deliveryMethod: DeliveryMethod {
        let key = PDSetting.DeliveryMethod.rawValue
        guard let storedValue = defaults?.string(forKey: key) else {
            return DefaultSettings.DELIVERY_METHOD_VALUE
        }
        return DeliveryMethodUD(storedValue).value
    }

    private static var nextHormoneExpirationDate: Date? {
        defaults?.object(forKey: SharedDataKey.NextHormoneDate.rawValue) as? Date
    }

    private static var pillsEnabled: Bool {
        defaults?.bool(forKey: PDSetting.PillsEnabled.rawValue) ?? false
    }

    private static var nextPillName: String? {
        defaults?.string(forKey: SharedDataKey.NextPillToTake.rawValue)
    }

    private static var nextPillDate: Date? {
        defaults?.object(forKey: SharedDataKey.NextPillTakeTime.rawValue) as? Date
    }
}

struct NextHormoneTimeline: TimelineProvider {
    typealias Entry = NextHormoneEntry

    func placeholder(in context: Context) -> NextHormoneEntry {
        let fakeHormone = NextHormone(
            hormoneExpirationDate: Date(),
            hormoneSite: SiteStrings.RightAbdomen,
            pillsEnabled: true,
            pill: PillStrings.DefaultPills[0],
            pillDue: Date(),
            deliveryMethod: .Patches
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
        StaticConfiguration(kind: kind, provider: NextHormoneTimeline()) {
            entry in NextHormoneWidgetView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("Next Hormone", comment: "OS Config screen"))
        .description("Shows your next hormone to change.")
    }
}

struct PlaceholderView: View {
    var body: some View {
        Text(PlaceholderStrings.DotDotDot)
    }
}

struct StringTextWidgetView: View {
    let text: String?

    var body: some View {
        var view: Text?
        if let s = text {
            view = Text(s).font(.system(.caption)).foregroundColor(.black).bold()
        }
        return view
    }
}

struct DateTextWidgetView: View {
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

struct NextHormoneWidgetView: View {
    let entry: NextHormoneEntry
    private let max: CGFloat = .infinity

    var gradient: Gradient {
        Gradient(colors: [.pink, .white])
    }

    var headerView: StringTextWidgetView? {
        guard let method = entry.hormone.deliveryMethod else { return nil }
        let methodString = SiteStrings.getDeliveryMethodString(method)
        let text = NSLocalizedString("Next \(methodString)", comment: "Widget view")
        return StringTextWidgetView(text: text)
    }

    /// The site the next patch is on, e.g. "Right Abdomen".
    var siteView: Text? {
        guard let site = entry.hormone.hormoneSite else { return nil }
        return Text(site).font(.system(.subheadline)).bold().foregroundColor(.black)
    }

    /// Whether the next patch is already due (expired) as of this entry.
    var isDue: Bool {
        guard let date = entry.hormone.hormoneExpirationDate else { return false }
        return date <= entry.date
    }

    /// "Due now" when overdue, otherwise the expiration date.
    @ViewBuilder
    var hormoneDueView: some View {
        if entry.hormone.hormoneExpirationDate != nil {
            if isDue {
                Text(NSLocalizedString("Due now", comment: "Widget view"))
                    .font(.system(.caption)).bold()
                    .foregroundColor(Color(PDColors[.NewItem]))
            } else {
                DateTextWidgetView(date: entry.hormone.hormoneExpirationDate)
            }
        }
    }

    var nextPillView: StringTextWidgetView? {
        guard entry.hormone.pillsEnabled else { return nil }
        guard let pill = entry.hormone.pill else { return nil }
        guard entry.hormone.pillDue != nil else { return nil }
        let text = NSLocalizedString("Next \(pill)", comment: "Widget view")
        return StringTextWidgetView(text: text)
    }

    var nextPillDueView: DateTextWidgetView? {
        guard entry.hormone.pillsEnabled else { return nil }
        guard let date = entry.hormone.pillDue else { return nil }
        return DateTextWidgetView(date: date)
    }

    /// Only show the hormone section when there's a next patch with a real
    /// applied date — an empty/dateless schedule has no "next hormone".
    var hasNextHormone: Bool {
        entry.hormone.hormoneExpirationDate != nil
    }

    var hasNextPill: Bool {
        entry.hormone.pillsEnabled
            && entry.hormone.pill != nil
            && entry.hormone.pillDue != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if hasNextHormone {
                headerView
                siteView
                hormoneDueView
            }
            if hasNextPill {
                nextPillView
                nextPillDueView
            }
            if !hasNextHormone && !hasNextPill {
                Text(NSLocalizedString("Nothing due", comment: "Widget empty state"))
                    .font(.system(.caption)).foregroundColor(.black)
            }
        }
        .frame(minWidth: 0, maxWidth: max, minHeight: 0, maxHeight: max, alignment: .leading)
        // iOS 17 requires widgets to declare their background via
        // containerBackground (a plain .background renders blank on the Home
        // Screen and in StandBy).
        .containerBackground(for: .widget) {
            LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
        }
    }
}
