import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    // Occupancy must come from actual windows (toplevels), not from
    // Hyprland.workspaces.values -- Hyprland keeps "ghost" workspace objects
    // around after their last window closes, so existence alone is not a
    // reliable occupied signal. Show 1..N, where N is the highest occupied
    // workspace (or the focused one, so the current empty workspace stays
    // visible) -- no trailing pills past that.
    var top = 0
    var tops = Hyprland.toplevels ? Hyprland.toplevels.values : []
    for (var i = 0; i < tops.length; i++) {
      var t = tops[i]
      var ws = t ? t.workspace : null
      var id = ws ? Number(ws.id) : NaN
      if (id > 0 && id > top) top = id
    }

    var focused = Hyprland.focusedWorkspace
    if (focused && focused.id > top) top = focused.id
    if (top < 1) top = 1

    var ids = []
    for (var n = 1; n <= top; n++) ids.push(n)
    return ids
  }

  // `Hyprland.workspaces.values` can change without causing a Repeater model
  // created by a function call to be rebuilt. Keep an explicit model in sync so
  // workspaces 6–10 extend this widget as soon as they exist; the bar then
  // naturally moves every widget to its right by one slot.
  property var displayedWorkspaceIds: [1, 2, 3, 4, 5]
  property string displayedWorkspaceKey: "1,2,3,4,5"

  function syncWorkspaceIds() {
    var ids = workspaceIds()
    var key = ids.join(",")
    if (key === displayedWorkspaceKey) return
    displayedWorkspaceKey = key
    displayedWorkspaceIds = ids
  }

  Component.onCompleted: syncWorkspaceIds()

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: root.syncWorkspaceIds()
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.displayedWorkspaceIds.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.displayedWorkspaceIds

      Item {
        id: cell
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        implicitWidth: btn.implicitWidth
        implicitHeight: btn.implicitHeight

        WidgetButton {
          id: btn
          anchors.fill: parent

          bar: root.bar
          text: modelData === 10 ? "0" : String(modelData)
          opacity: cell.occupied || cell.focused ? 1 : 0.5
          horizontalMargin: 6
          verticalPadding: 6
          fixedWidth: root.vertical ? root.barSize : Style.space(20)
          fixedHeight: root.barSize
          onPressed: function() { root.focusWorkspace(modelData) }
        }

        Rectangle {
          visible: cell.focused
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: Math.round(Style.font.body / 2) + Style.space(2)
          width: Style.space(10)
          height: Style.space(1)
          radius: height / 2
          color: Color.accent
        }
      }
    }
  }
}
