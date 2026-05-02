import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    title: i18n("Mocha Settings")
    width: 800
    height: 600

    pageStack.initialPage: Kirigami.Page {
        title: i18n("Preferences")
        Kirigami.FormLayout {
            anchors.fill: parent
            Controls.Label {
                Kirigami.FormData.label: i18n("Welcome to Mocha Dock")
                text: i18n("This is the new modern Settings UI.")
            }
        }
    }
}
