pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar"
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Variants {
    model: [Quickshell.screens[0]] // show only on main monitor
    // if you want to display on all monitors use this instead:
    // model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.launcher || visibilities.session ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: Region {
                x: BorderConfig.thickness
                y: BorderConfig.thickness
                width: win.width - BorderConfig.thickness * 2
                height: win.height - BorderConfig.thickness * 2
                intersection: Intersection.Xor

                regions: regions.instances
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: regions

                model: panels.children

                Region {
                    required property Item modelData

                    x: modelData.x + BorderConfig.thickness
                    y: modelData.y + BorderConfig.thickness
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

            HyprlandFocusGrab {
                active: visibilities.launcher || visibilities.session
                windows: [win]
                onCleared: {
                    visibilities.launcher = false;
                    visibilities.session = false;
                }
            }

            StyledRect {
                anchors.fill: parent
                opacity: visibilities.session ? 0.5 : 0
                color: Colours.palette.m3shadow

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.standard
                    }
                }
            }

            Item {
                id: background

                anchors.fill: parent
                visible: false

                Backgrounds {
                    panels: panels
                    bar: bar
                }
            }

            MultiEffect {
                anchors.fill: source
                source: background
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }

            PersistentProperties {
                id: visibilities

                property bool osd
                property bool session
                property bool launcher
                property bool dashboard

                Component.onCompleted: Visibilities.screens[scope.modelData] = this
            }

            Interactions {
                screen: scope.modelData
                visibilities: visibilities
                panels: panels
                bar: bar

                Panels {
                    id: panels

                    screen: scope.modelData
                    visibilities: visibilities
                    bar: bar
                }
            }
        }
    }
}
