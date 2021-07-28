# Changelog

# 3.6.2 (unreleased)

Fixed

- Bug where a Pill's X-Days "Off" position would NOT increment, causing a perpetually increasing due date.
- Bug where the widget would not update immediately after taking a hormone or changing a pill.
- Bug where you were still able to add new pills when Pills were globally disabled.

# 3.6.1

Changed

- A Pill's Last Taken Date is now shown again when taken on a previous day.

# 3.6.0

Fixed

- A bug where a portion of the notification minutes slider in the Settings View was not honoring dark mode.
- A display fallacy where the "Notifications Minutes Before" label would say "30" even though notifications were 
    off.

Added

- New setting "Constant Expiration Times" that maintains the same expiration time. This makes it easier to
    maintain a consistent schedule.

Changed

- Some verbiage around hormone dates and sites on the Hormone Details View.

## 3.5.0

Added

- New custom hormone expiration intervals, such as "Every 1½ Days" up to "Every 25½ Days".
- The ability to undo taking a pill.
- Pill Cells now display the times taken today out of the total times per day.

Fixed

- Issue where you would still get an Expired-Notification after changing a hormone prior to its expiration.
- Bug where the expiration date text would not update when selecting a date using the Date Picker in the 
    Hormone Detail View.
- Bug where the expiration date text would not update when pressing the Autofill button.
- Clipping issue with time number labels in the Pill Details view.
- Issue where the save button in the Pill Details View was the wrong color for Dark mode.

Changed

- Hormone Cells now display more verbose expiration dates for dates that are farther away from now.
- Hormone Cell expiration dates now are prefixed with either "Exp:" or "Next:" rather than what they before
    ("Expired:", "Expires", etc.) to save screen room for potentially longer dates.
- Pill Cells now don't display a Last Taken date when the pill was not yet taken that day.
- You can now save typed Pill name changes without having to close the text field.
- You can now save typed Site name changes without having to close the text field.
- You can now save custom site name changes for hormones without having to close the text field.
- X days-based pill expiration intervals now have quotes around the "X" so that it does not seem like the 
    Roman-numeral 10.

## 3.4.0

Added

- The ability to disable Pills entirely using a switch at the top of the Pills View.

Changed

- You can no longer create Sites or Pills that have names longer than 30 characters.
- The Hormone Widget will no longer mention anything about pills if you are not using them.

## 3.3.2

Fixed

- Bug where if you had the Accessibility setting "Increase Contrast" enabled, Alert Buttons would have no text.
- Bug when setting the Delivery Method for the first time in an empty schedule would not adjust the Quantity
correctly.
- Bug where you would receive a warning about the loss of data when changing the Delivery Method to the 
    same setting that is already set.
- Bug where if you had the Accessibility setting "Bold Text" enabled, the Tab title texts would be cut-off.
- Issue where changing a Patch would hide its Site Image unnecessarily.
    This bug occurred when changing the delivery method away from Patches and then back to Patches and then 
    setting a Patch for the first time.

## 3.3.1

Fixed

- Bug where the penultimate day in a Pill Schedule with an "X Days On, X Days Off" expiration interval would 
    incorrectly set the next date after taking.

## 3.3.0

Changed

- Pill Expiration Intervals "First 10 Days", "First 20 Days", "Last 10 Days", and "Last 20 Days" were replaced 
    with the new Pill Expiration Intervals "First X Days of the Month" and "Last X Days of the Month" and a 
    corresponding "days" property.  The days option is configurable and can be any number 1 - 25.

Added

- New Pill Expiration Interval "X Days On, X Days Off" for creating a schedule where you take a pill for a certain 
    number of days and then stop taking the pill for a certain number of days.  You can set the "Days on" and 
    "Days off" properties accordingly to any numbers 1 - 25.

Fixed

- Issue where you could not take a newly added pill.
- Issue that caused the app to crash in situations when creating a new pill or site, then backgrounding the app, 
    then foregrounding again.
- Bug preventing reordering sites.
- Issue where an arrow component in the Site Schedule View would not hide during editing mode.
- Bug where if you create a site in an empty Sites schedule, it would not load some of the components in the 
    cell.
- Display issue with Pill Cells causing longer dates to get truncated.

## 3.2.3

Fixed

- Issue that caused the app to crash when editing the timesaday values for a new pill.
- Bug in the Hormones Details View preventing the user from setting the date if the site was set first.
- Bug where the Pill Expiration Interval picker would open at the wrong index for some of the options.

## 3.2.2

Fixed

- Issue where pill notifications would re-schedule incorrectly.
- Issue where the pill tab badge value would not update.

## 3.2.1

Fixed

- Issue where the Hormones tab badge value would not clear after taking the hormone.
- Clipping issue on the Hormone date text, seen on iPads.

Changed

- Increased font size of the expiration date text for Hormone cells.

## 3.2.0

Added

- The Next Hormone Widget for iOS 14 (replacing the Today app).

Fixed

- Bug where Pill Schedules "Last 10 Days" and "Last 20 Days" would use the wrong start date of the month.
- Bug where Pill Schedules "First 10 Days" and "First 20 Days" would not work correctly at the end of the month.
- Layout issue that caused the date text to shift up when the Moon Icon for overnight Hormones was present.
- Bug where pill data was not being shared with Widgets.

Removed

- The PatchDayToday today widget was removed, as it is now deprecated in iOS 14. Use the Next Hormone 
    Widget instead!

Changed

- iPad font size for Hormone Cell text was decreased.
- Using new UI Date Picker compact style from iOS 14 for both hormone details date and pill times.
- On the Pill details view:
    - Times are now enumerated as rows.
    - The view scrolls when necessary.
- The data for the new Next Hormone Widget (formerly, the Today app) has changed:
    - Now, only the expiration date and the delivery method (Patch, Gel, etc.) are shown for expired Hormones,
        e.g. "Next Patch: Tomorrow at 12:00". This is to make it less confusing about which date is shown and to 
        focus on information that is most relevant.
- Changed Next date text for pills to be "Take to start" in the Pill Schedule View, to fix a clipping issue.

## 3.1.1

Fixed

- Fix text in expired Gel notification's title and body - was previously the Injection title and body.
- Fix text in all expired hormone notifications where it would indicate the hormone is not expired yet.
- Fixed migration issue where you would get an extra pill time even if you were only using a single time.

Removed

- Removed next suggested site text from expired hormone notifications, as it was faulty.

## 3.1.0

Added

- Pills can now be taken up to 4 times per day.

Fixed

- A bug with the Hormone Detail screen where changing both the Date and the Site would change the site of the 
    wrong Hormone.
- An issue that prevented Pill expiration-interval changes from saving.
- A bug where the Pill expiration interval "First twenty days" mistakenly used "First ten days".
- Bugs preventing pill expiration intervals "Last Twenty Days" or "Last Ten Days" from working properly after it's
    initial use.
- A bug where "Last Twenty Days" and "Last Ten Days" did one more day than expected.
- Mistake in Pill Detail view title where it said "New Pill" for the initial pills created.
- An anomaly in the Pills list where a fresh a Pill schedule would say 10:00 for the initial next-due dates.
    It now says a more helpful message.

## 3.0.4

Fixed

- Issue where App would not detect unsaved changes for Site Image.

Removed

- Faulty Hormone notification action for changing the hormone from the notification.

## 3.0.3

Fixed

- Issue where if you disable and re-enable the Notifications setting on Dark mode, some text would disappear.
- Issue where if there was only one Site, the site schedule would not suggest it.
- Issue where custom Gel images would appear as placeholder Gel images.
- Bug where when adding a new Site, it's order label would not display in a Site Cell.
- Actually fix issue where new Pills did not default to Notify=true.

## 3.0.2

Fixed

- Issue where the Pill tab would not display badge alerts when notifications were disabled for the Pill.
- Issue where the App badge would not update when changing a due Pill right away.
- Issue where new Pills did not default to Notify=true like they did before.

## 3.0.1

Fixed

- Issue where the Unsaved Changes Alert did not block the navigation after editing a hormone and tapping Back.
- Issue where if you declined adding a new site name from a type-edit on a hormone, it would not set the site.

## 3.0.0

Added

- Dark mode.
- Estro-Gel hormonal delivery method support with site choices:
- Arms
Supports custom sites.
- The concept of "Pill Schedules" with choices:
    - Every Day (previously was only one supported)
    - Every Other Day
    - First 10 Days of the Month
    - First 20 Days of the Month
    - Last 10 Days of the Month
    - Last 20 Days of the Month
    Available by editing a pill in the Pill Schedule.
- Hormone Cell Actions, useful for quickly changing Hormones.
- Warning for when leaving views without saving changes.
- Leaving Hormone Details View.
- Leaving Pill Details View.
- Icon improvements.
- Increased sizes.
- Changed Site Schedule tab icon.
- A Moon icon now displays in the top right of a Hormone Cell for overnight Hormones.

Changed

- Taking Pills is handled through alert actions now. Simply select the PillCell to Take a pill.
- Editing Pills is handled through alert actions now. Simply select the PillCell to Edit pill details.
- The SiteSchedule no longer cares about occupied sites and just follows the site Index accordingly.

Fixed

- Bug with custom sites not being scheduled correctly.

