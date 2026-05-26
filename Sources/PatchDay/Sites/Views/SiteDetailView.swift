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
    let siteIndex: Index

    @State private var name: String = ""
    @State private var selectedImageIndex: Int = 0
    @State private var didPrime = false

    private var site: Bodily? {
        container.sdk?.sites[siteIndex]
    }

    private var deliveryMethod: DeliveryMethod {
        container.sdk?.settings.deliveryMethod.value ?? .Patches
    }

    private var imageChoices: [UIImage] {
        SiteImages.All[deliveryMethod]
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
                TextField(NSLocalizedString("Site name", comment: ""), text: $name)
                    .autocapitalization(.words)
                    .accessibilityIdentifier("siteNameTextField")
                Picker(NSLocalizedString("Preset", comment: ""), selection: $name) {
                    ForEach(SiteStrings.all, id: \.self) { Text($0).tag($0) }
                }
                .accessibilityIdentifier("siteNamePresetPicker")
            }
            .accessibilityIdentifier("siteNameSection")

            Section(NSLocalizedString("Image:", comment: "")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(imageChoices.indices, id: \.self) { index in
                            Button {
                                selectedImageIndex = index
                            } label: {
                                Image(uiImage: imageChoices[index])
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
                            .accessibilityIdentifier("siteImageButton_\(index)")
                        }
                    }
                    .padding(.vertical, 4)
                }
                .accessibilityIdentifier("siteImagePickerScroll")
            }
            .accessibilityIdentifier("siteImageSection")
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(ActionStrings.Save) { save() }
                    .accessibilityIdentifier("siteSaveButton")
            }
        }
        .onAppear(perform: prime)
    }

    private func prime() {
        guard !didPrime, let site = site else { return }
        didPrime = true
        name = site.name
        let params = SiteImageDeterminationParameters(
            imageId: site.imageId, deliveryMethod: deliveryMethod
        )
        let currentImage = SiteImages[params]
        selectedImageIndex = imageChoices.firstIndex(of: currentImage) ?? 0
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
