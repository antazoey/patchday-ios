//
//  SiteDetailView.swift
//  PatchDay
//
//  Full SwiftUI replacement for SiteDetailViewController: name editing +
//  horizontal image picker scoped to the current delivery method.
//

import SwiftUI
import PDKit

struct SiteDetailView: View {

    @EnvironmentObject private var container: AppContainer
    @Environment(\.colorScheme) private var colorScheme
    let siteIndex: Index

    @State private var name: String = ""
    @State private var selectedImageIndex: Int = 0
    @State private var didPrime = false
    @State private var imageManuallyChosen = false

    private var site: Bodily? {
        container.sdk?.sites[siteIndex]
    }

    private var deliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    private var imageChoices: [UIImage] {
        SiteImages.All[deliveryMethod]
    }

    /// Site images ship with light + dark variants, but `UIImage(named:)`
    /// resolves to a single appearance when SiteImages builds them — which left
    /// the picker showing light-mode artwork in Dark Mode. Re-resolve each image
    /// for the current color scheme so the picker matches the rest of the UI.
    private func adaptiveImage(_ image: UIImage) -> UIImage {
        let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        return image.imageAsset?.image(with: UITraitCollection(userInterfaceStyle: style)) ?? image
    }

    private var navTitle: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == SiteStrings.NewSite {
            return SiteStrings.NewSite
        }
        return PDTitleStrings.EditSiteTitle
    }

    var body: some View {
        Form {
            Section(NSLocalizedString("Name", comment: "")) {
                // No preset picker by design — creating a site means typing a new
                // name. To reuse an existing location, use Sites → Add Existing.
                TextField(NSLocalizedString("Site name", comment: ""), text: $name)
                    .autocapitalization(.words)
                    .accessibilityIdentifier("siteNameTextField")
            }

            Section(NSLocalizedString("Image:", comment: "")) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(imageChoices.indices, id: \.self) { index in
                                Button {
                                    selectedImageIndex = index
                                    imageManuallyChosen = true
                                } label: {
                                    Image(uiImage: adaptiveImage(imageChoices[index]))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .padding(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    index == selectedImageIndex
                                                        ? Color.accentColor
                                                        : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                                .id(index)
                                .accessibilityIdentifier("siteImageButton_\(index)")
                                .accessibilityAddTraits(
                                    index == selectedImageIndex ? [.isSelected] : []
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("siteImagePickerScroll")
                    // Keep the selected image in view: when the name auto-picks
                    // an image (or it's primed from an existing site), the
                    // choice can be off-screen and invisible otherwise.
                    .onChange(of: selectedImageIndex) { _, index in
                        withAnimation { proxy.scrollTo(index, anchor: .center) }
                    }
                    .onAppear { proxy.scrollTo(selectedImageIndex, anchor: .center) }
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(ActionStrings.Save) { save() }
                    .accessibilityIdentifier("siteSaveButton")
            }
        }
        .onChange(of: name) { _, newName in
            syncImageToName(newName)
        }
        .onAppear(perform: prime)
    }

    private func prime() {
        guard !didPrime, let site = site else { return }
        didPrime = true
        // A brand-new site starts with the "New Site" placeholder name; show an
        // empty field so it prompts the user to type a name rather than pre-filling.
        name = site.name == SiteStrings.NewSite ? "" : site.name
        let params = SiteImageDeterminationParameters(
            imageId: site.imageId, deliveryMethod: deliveryMethod
        )
        let currentImage = SiteImages[params]
        selectedImageIndex = imageChoices.firstIndex(of: currentImage) ?? 0
        // Preserve a deliberately-chosen image (custom, or one that doesn't match
        // the site name) so a later rename doesn't clobber it. A brand-new site
        // or one whose image already matches its name stays auto-syncing.
        if site.imageId != site.name {
            imageManuallyChosen = true
        }
    }

    /// Auto-select the image matching the chosen site name so the user doesn't
    /// have to scroll the image picker for a standard site. Skipped once the user
    /// has hand-picked an image, and a no-match name (custom) leaves it untouched.
    private func syncImageToName(_ siteName: String) {
        guard !imageManuallyChosen else { return }
        let trimmed = siteName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = imageChoices.firstIndex(where: { SiteImages.getName(from: $0) == trimmed }) {
            selectedImageIndex = match
        }
    }

    private func save() {
        guard let sdk = container.sdk else {
            container.popSites()
            return
        }
        sdk.sites.rename(at: siteIndex, to: name)
        if let chosen = imageChoices.tryGet(at: selectedImageIndex) {
            let imageName = SiteImages.getName(from: chosen)
            sdk.sites.setImageId(at: siteIndex, to: imageName)
        }
        container.triggerRefresh()
        container.popSites()
    }
}
