//
//  TutorialSheet.swift
//  PatchDay
//
//  A short, paged walkthrough opened from Settings → Tutorial. Explains the
//  two-step flow: set up a site rotation on the Sites tab, then apply it to a
//  hormone on the Hormones tab with the → button.
//

import SwiftUI
import PDKit

private struct TutorialStep {
    let icon: String
    /// Optional asset-catalog screenshot shown instead of the SF Symbol.
    let image: String?
    let title: String
    let body: String
}

struct TutorialSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private let steps: [TutorialStep] = [
        TutorialStep(
            icon: "hand.wave",
            image: nil,
            title: NSLocalizedString("Quick tutorial", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "Set up a site rotation and apply it to a hormone — two short steps.",
                comment: "Tutorial intro body"
            )
        ),
        TutorialStep(
            icon: "mappin.and.ellipse",
            image: "tutorial-sites",
            title: NSLocalizedString("1. Set up your sites", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "Open the Sites tab. Tap Edit → Presets for a ready-made rotation "
                    + "(like Abdomen L×3 → R×3), or tap a site to Duplicate it. Same-named "
                    + "spots collapse into one “×N” row.",
                comment: "Tutorial sites body"
            )
        ),
        TutorialStep(
            icon: "arrow.right.circle",
            image: "tutorial-change",
            title: NSLocalizedString("2. Apply it on Hormones", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "On the Hormones tab, tap a patch for a quick menu. The → option shows "
                    + "your next site and places the patch there with the current time.",
                comment: "Tutorial hormones body"
            )
        ),
        TutorialStep(
            icon: "pills",
            image: "tutorial-pills",
            title: NSLocalizedString("3. Pills work the same", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "On the Pills tab, tap a pill and choose Take to log it. Add pills with the "
                    + "row at the bottom.",
                comment: "Tutorial pills body"
            )
        ),
        TutorialStep(
            icon: "calendar",
            image: "tutorial-pill-schedule",
            title: NSLocalizedString("4. Set a pill's schedule", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "Edit a pill to choose how often it's due (every day, every other day, or a "
                    + "days-of-the-month range) and how many times a day, each with its own time.",
                comment: "Tutorial pill schedule body"
            )
        ),
        TutorialStep(
            icon: "checkmark.circle",
            image: nil,
            title: NSLocalizedString("You're set", comment: "Tutorial step title"),
            body: NSLocalizedString(
                "The → button always points to your next site, so changing a patch is one "
                    + "tap. Revisit this tutorial any time from Settings.",
                comment: "Tutorial closing body"
            )
        )
    ]

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $page) {
                    ForEach(steps.indices, id: \.self) { index in
                        stepView(steps[index]).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Button(isLastPage ? ActionStrings.Done
                    : NSLocalizedString("Next", comment: "Advance tutorial")) {
                    if isLastPage {
                        dismiss()
                    } else {
                        withAnimation { page += 1 }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .accessibilityIdentifier("tutorialNextButton")
            }
            .navigationTitle(NSLocalizedString("Tutorial", comment: "Tutorial sheet title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ActionStrings.Done) { dismiss() }
                        .accessibilityIdentifier("tutorialDoneButton")
                }
            }
        }
    }

    private var isLastPage: Bool { page >= steps.count - 1 }

    @ViewBuilder
    private func stepView(_ step: TutorialStep) -> some View {
        VStack(spacing: 20) {
            if let image = step.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: step.icon)
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
            }
            Text(step.title)
                .font(.title2)
                .bold()
            Text(step.body)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .padding(.top, 48)
    }
}
