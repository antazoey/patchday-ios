# PatchData

PatchData is PatchDay's Core Data interface. The API is composed of what are called Schedules. Each entity has its own schedule. The following are a list of entites:

## Estrogens

The estrogen schedule is the main schedule of the application. 
You can use Patches or Injections mode.
If using patches, the patches are sorted from oldest to newest (top to bottom).
If using injections, there will only be one estrogen entity in the schedule.
Expiration dates are listed beneath each estrogen button.
The site images on the buttons reflect the bodily sites where the patches are placed, 
or in the case of injections, the last place injected. They could also be a blankish image instead.

Use `siteScheduleRef.suggest()` in the SiteSchedule to set 'date and time placed' to the current date and time
and the 'site' to the next available site.
If there are no sites available, 
the site will not change. Also, the user could edit the estrogen attributes individually.
This is useful if there was a mistake.

Here are some useful UserDefaults pertaining to estrogens and sites.

  `defaultsRef.deliveryMethod`: Either patches or injections. Refers to how estrogen enters your body.

  `defaultsRef.timeInterval`: How long until next dose.

  `defaultsRef.quantity`: How many estrogens are in the schedule. For injections, it's always 1.

  `defaultsRef.notifications`: Receive a notification to take next dose.

  `defaultsRef.siteIndex`: Determined next index for the next site to place an estrogen.
  
--------------

## Pills

When did you last take each pill?
When do you need to take the next pill?
Tap the pill cell to edit the pill attributes, such as the name and the times per day it is taken.
The 'take' function is how to stamp the pill as taken. If the pill is past due, the 'take' button will have a notification bubble.

--------------

## Sites

The site schedule is a user-customizable ordering of bodily sites for patches to be placed or injections injected. 
This helps keep PatchDay quick and easy to use. 
For example, say the user gets a patch-expired notification. 
This notification will mention where to place the next patch and a button to change it directly from the notification.
How does PatchDay know the site? 
It is all based on this site schedule and the fact the each row can only be occupied by one estrogen at a time. 
Want multiple estrogens on the same site or to be replaced at the same site after changing? 
Easy. Just make two of the same sites in the site schedule! The possibilities are endless.

The site schedule is also good for merely renaming sites. 
For example, rename the default "Right Abdomen" to "R-Tummy" or anything else. 
Also, change it's a picture if you like.
