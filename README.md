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

Provides a crosshair outside of the aircraft that will either:
- indicate a fixed offset angle ("angle" mode), indended for approach angle training.
- indicate the flight path angle ("flight path" mode), intended for flight path prediction for obstacle avoidance (and landing).

Switchover between modes can be manual or automatic at a given velocity. The crosshair can also automatically turn off at a given velocity.

The crosshair uses a movable reference point as origin. This can be the aircraft origin or pilot head.

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
# Parameter identifier, crosshair mode override (0=auto,1=angle,2=flight path)
MODE_OVERRIDE,0
# Parameter identifier, airspeed in knots indicated below which the crosshair turns on
AUTO_ENABLE,999
# Parameter identifier, airspeed in knots indicated below which angle mode is active
ANGLE_MODE,50
# All rotations in degrees, all offsets in meters
# Parameter identifier, visibility, offset x (sim/aircraft/view/acf_peX), offset y (sim/aircraft/view/acf_peZ), offset z (sim/aircraft/view/acf_peY)
#REFERENCE,0,0.38,-1.88,0.338
REFERENCE,0,0,0,0
# Parameter identifier, visibility, rotation x, rotation y, rotation z, offset x, offset y, offset z
CROSSHAIR,1,-10,0,0,0,10,0
```

&nbsp;

[Back to table of contents](#toc)

<a name="6.0"></a>
## 6 - Menu

A menu named "Cockpit Crosshair" will be added to the aircraft mdenu in X-Plane's main menu bar.

Menu options are the follwing:

Item|Description
-|-
Toggle Crosshair|Main switch to toggle the crosshair on and off.
Toggle Reference Object|Toggles the visibility of the reference object so that it can be positioned
Force Mode _[Active Mode]_|Each click will force the crosshair into a given mode in the following order: "Auto" --> "Angle" --> "Flight Path"
Reload Settings|Will reload _settings.cfg_

&nbsp;

[Back to table of contents](#toc)

<a name="7.0"></a>
## 7 - Datarefs and Commands

"Cockpit Crosshair" offers the following datarefs:

Dataref|Type|Writable|Description
-|-|-|-
cockpit_crosshair/reference_point|array[4]|Yes|Visibility and location information for the reference object (Visibility,X,Y,Z)
cockpit_crosshair/crosshair|array[7]|No|Output information for the crosshair object: (Visibility,Rot_X,Rot_Y,Rot_Z,Pos_X,Pos_Y,Pos_Z)
cockpit_crosshair/crosshair_offsets|array[7]|Yes|Offset information for the crosshair object: (Visibility,Rot_X,Rot_Y,Rot_Z,Pos_X,Pos_Y,Pos_Z)
cockpit_crosshair/auto_enable_ias|number|Yes|Indicated airspeed in knots at which the crosshair will turn on
cockpit_crosshair/angle_mode_ias|number|Yes|Indicated airspeed in knots at which the crosshair switch from flight path to angle mode

&nbsp;

"Cockpit Crosshair" offers the following commands that can be bound to any input device

Command|Description
-|-
cockpit_crosshair/toggle_crosshair|Toggle the crosshair on/off
cockpit_crosshair/toggle_reference|Toggles the reference object's visibility on/off
cockpit_crosshair/reload_settings|Reloads _settings.cfg_
cockpit_crosshair/cycle_mode|Each activation will force the crosshair into a given mode in the following order: "Auto" --> "Angle" --> "Flight Path"

&nbsp;

[Back to table of contents](#toc)

<a name="8.0"></a>
## 8 - Known Issues

- Because the crosshair and reference object is spawned with XPLMCreateInstance, it will always be treated as an external object
- The crosshair can not be scaled, so up close it will be very large and far away potentially hard to see.
- The crosshair can not be drawn over 3D objects, so if it vanishes behind the panel use side slip in herlicopters to put it into a side window or move the eyepoint upward to see it over the nose in fixed wing aircraft.
- The crosshair animation applies rotation first and translation second, so any X,Y,Z offsets will be applied at an angle. I may fix this in the future.

&nbsp;

[Back to table of contents](#toc)

<a name="9.0"></a>
## 9 - License

"Cockpit Crosshair" is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.
