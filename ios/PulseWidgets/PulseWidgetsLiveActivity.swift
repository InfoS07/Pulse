//
//  PulseWidgetsLiveActivity.swift
//  PulseWidgets
//
//  Created by Rafiq Messai on 03/07/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PulseWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PulseWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PulseWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PulseWidgetsAttributes {
    fileprivate static var preview: PulseWidgetsAttributes {
        PulseWidgetsAttributes(name: "World")
    }
}

extension PulseWidgetsAttributes.ContentState {
    fileprivate static var smiley: PulseWidgetsAttributes.ContentState {
        PulseWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PulseWidgetsAttributes.ContentState {
         PulseWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PulseWidgetsAttributes.preview) {
   PulseWidgetsLiveActivity()
} contentStates: {
    PulseWidgetsAttributes.ContentState.smiley
    PulseWidgetsAttributes.ContentState.starEyes
}
