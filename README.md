# X-Plane Cockpit Crosshair
A 3D object cockit crosshair for landing training for use in X-Plane helicopters (and maybe in fixed wing aircraft).

<a name="toc"></a>
## Table of Contents
1. [Features](#1.0)
2. [Requirements](#2.0)
3. [Installation](#3.0)
4. [Uninstallation](#4.0)    
5. [Configuration](#5.0)    
6. [Menu](#6.0)
7. [Datarefs and Commands](#7.0)
8. [Known Issues](#8.0)
9. [License](#9.0)

&nbsp;

<a name="1.0"></a>
## 1 - Features

Provides a crosshair outside of the aircraft that will indicate the horizontal and vertical flight path angle for flight path prediction, obstacle avoidance and landing. The crosshair compensates for head position to provide a similar sight picture from any cockpit seat. It supports offsets from a reference point or for the crosshair itself.

Below a certain air speed or with the landing lights switched on (see "Configuration" below), three vertical guidance bars representing three approach path angles are displayed next to the crosshair.

&nbsp;

[Back to table of contents](#toc)

<a name="2.0"></a>
## 2 - Requirements

- [X-Plane](https://www.x-plane.com/)  (12 or newer)
- [XLua](https://github.com/X-Plane/XLua) (1.3 or higher; only works locally on a single aircraft)

&nbsp;

[Back to table of contents](#toc)

<a name="3.0"></a>
## 3 - Installation

### 3.1 Aircraft without an XLua plugin

- Download the latest xlua plugin from its repository's [Releases page](https://github.com/X-Plane/XLua/releases).
- Unzip the archive and move the _"xlua"_ folder into the aircraft's _"plugins"_ folder.
- Download the latest code with the ["Code" --> "Download ZIP" button](https://github.com/JT8D-17/x-plane-cockpit-crosshair/archive/refs/heads/main.zip).
- Unzip the archive.
- Move the _"cockpit_crosshair"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"_.

### 3.2 Aircraft with an XLua plugin

- Download the latest code with the ["Code" --> "Download ZIP" button](https://github.com/JT8D-17/x-plane-cockpit-crosshair/archive/refs/heads/main.zip).
- Unzip the archive.
- Move the _"cockpit_crosshair"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"_.

&nbsp;

[Back to table of contents](#toc)

<a name="4.0"></a>
## 4 - Uninstallation

Delete the _"cockpit_crosshair"_ folder from _"[Aircraft's main folder]/plugins/xlua/scripts/"_.

&nbsp;

[Back to table of contents](#toc)

<a name="5.0"></a>
## 5 - Configuration

The crosshair is configured in _"plugins/xlua/scripts/cockpit_crosshair/settings.cfg"_. All settings are commented.   
Reloading the settings file can be done any time with the "Reload Settings" function from the "Cockpit Crosshair" menu.
The code for parsing and loading the settings file is hardened against malformed lines and values. Check X-Plane's developer console or _Log.txt_ if you find your file does not load properly.

```
# Settings for Cockpit Crosshair
#
# Parameter identifier, airspeed in knots indicated below which the crosshair turns on
AUTO_ENABLE,999
# Parameter identifier, airspeed in knots indicated below which the angle bars are visible
ANGLE_BARS_MAX_SPD,50
# Parameter identifier, set to 1 if the angle bars are to be exclusively tied to the landing lights switch
ANGLE_BARS_ON_LAND_LIGHT,1
#
# All rotations in degrees, all offsets in meters
# Parameter identifier, visibility, offset x (sim/aircraft/view/acf_peX), offset y (sim/aircraft/view/acf_peZ), offset z (sim/aircraft/view/acf_peY)
#REFERENCE,0,0.38,-1.88,0.338
REFERENCE,0,0,0,0
# Parameter identifier, visibility, rotation x, rotation y, rotation z, offset x, offset y, offset z
CROSSHAIR,1,0,0,0,0,10,0
# Parameter identifier, visibility, angle, angle, angle
ANGLE_BARS,1,-7,-10,-12
```

&nbsp;

[Back to table of contents](#toc)

<a name="6.0"></a>
## 6 - Menu

A menu named "Cockpit Crosshair" will be added to the aircraft menu on X-Plane's main menu bar.

Menu options are the follwing:

Item|Description
-|-
Toggle Crosshair|Main switch to toggle the crosshair on and off.
Toggle Reference Object|Toggles the visibility of the reference object so that it can be positioned
Angle Bars On Land. Lts.|When active ties the visibility of the angle bars to the landing lights instead of a velocity range
Reload Settings|Will reload _settings.cfg_

&nbsp;

[Back to table of contents](#toc)

<a name="7.0"></a>
## 7 - Datarefs and Commands

"Cockpit Crosshair" offers the following datarefs:

Dataref|Type|Writable|Description
-|-|-|-
cockpit_crosshair/reference_point|array[4]|Yes|Visibility and location information for the reference object (Visibility,X,Y,Z)
cockpit_crosshair/crosshair_in|array[7]|Yes|Input properties for the crosshair object: (Visibility,Rot_X,Rot_Y,Rot_Z,Pos_X,Pos_Y,Pos_Z)
cockpit_crosshair/crosshair_out|array[7]|No|Output properties for the crosshair object: (Visibility,Rot_X,Rot_Y,Rot_Z,Pos_X,Pos_Y,Pos_Z)
cockpit_crosshair/angle_bars_in|array[4]|Yes|Input properties for the angle bars: (Visibility,Rot_Bar_1,Rot_Bar_2,Rot_Bar_3)
cockpit_crosshair/angle_bars_out|array[4]|No|Output properties for the angle bars: (Visibility,Rot_Bar_1,Rot_Bar_2,Rot_Bar_3)
cockpit_crosshair/auto_enable_ias|number|Yes|Indicated airspeed in knots below which the crosshair will turn on
cockpit_crosshair/angle_bars_ias|number|Yes|Indicated airspeed in knots below which the angle bars are visible

&nbsp;

"Cockpit Crosshair" offers the following commands that can be bound to any input device:

Command|Description
-|-
cockpit_crosshair/toggle_crosshair|Toggle the crosshair on/off
cockpit_crosshair/toggle_reference|Toggles the reference object's visibility on/off
cockpit_crosshair/reload_settings|Reloads _settings.cfg_

&nbsp;

[Back to table of contents](#toc)

<a name="8.0"></a>
## 8 - Known Issues

- Because the crosshair and reference object is spawned with XPLMCreateInstance, it will always be treated as an external object
- The crosshair can not be scaled, so up close it will be very large and far away potentially hard to see.
- The crosshair can not be drawn over 3D objects, so if it vanishes behind the panel, use side slip in helicopters to put it into a side window or move the eyepoint upward to see it over the nose in fixed wing aircraft.
- The crosshair animation applies rotation first and translation second, so any X,Y,Z offsets will be applied at an angle. I might fix this in the future.
- The slight delay when toggling crosshair visbility features on and off is deliberate because the logic runs in a timer with a 1 second refresh interval to save CPU cycles.

&nbsp;

[Back to table of contents](#toc)

<a name="9.0"></a>
## 9 - License

"Cockpit Crosshair" is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.
