import QtQuick 2.4
import Ubuntu.Components 1.3
import "conversion.js" as Converter

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "unit-converter.liu-xiao-guo"

    width: units.gu(60)
    height: units.gu(85)

    property real margins: units.gu(2)
    property real labelWidth: units.gu(12)

    // Length conversion model; the unit is Mile
    property var lengthModel: [
        {"unit": "Inch", "rate": 63360.0},
        {"unit": "Meter", "rate": 1609.344},
        {"unit": "Miles", "rate": 1.0},
        {"unit": "Feets", "rate": 5280.0},
        {"unit": "Yards", "rate": 1760.0},
        {"unit": "Kilometers", "rate": 1.609344},
    ]

    // Weight conversion model; the base unit is Pound
    property var weightModel: [
        {"unit": "Pounds", "rate": 1.0},
        {"unit": "Kilograms", "rate": 0.45359237},
        {"unit": "Ounces", "rate": 16},
        {"unit": "Stones", "rate": 0.0714285714},
        {"unit": "US Tons", "rate": 0.0005},
        {"unit": "UK Tons", "rate": 0.000446428571},
    ]

    // converter page template
    Component {
        id: pageContent
        Page {
            // expose Repeater's model for reusability, so we can set it from
            // outside, when we build the tabs
            property alias model: converter.model

            // remove the input panel when pressed outside of any text input
            MouseArea {
                anchors.fill: parent
                onPressed: Qt.inputMethod.hide();
            }

            Flickable {
                id: flickable
                clip: true
                anchors {
                    fill: parent
                    margins: root.margins
                }
                flickableDirection: Flickable.VerticalFlick
                contentWidth: pageLayout.width
                contentHeight: pageLayout.height

                Column {
                    id: pageLayout
                    width: flickable.width
                    height: childrenRect.height

                    spacing: units.gu(1.2)
                    // show as many lines as many units we have in the model
                    // it is assumed that the model has "unit" and "rate" roles
                    Repeater {
                        id: converter
                        Row {
                            spacing: units.gu(1)
                            Label {
                                text: i18n.tr(modelData.unit)
                                textSize: Label.Large
                                width: root.labelWidth
                                height: input.height
                                verticalAlignment: Text.AlignVCenter
                            }
                            // input field performing conversion
                            TextField {
                                id: input
                                //errorHighlight: false
                                validator: DoubleValidator {notation: DoubleValidator.StandardNotation}
                                width: pageLayout.width - root.labelWidth - spacing
                                text: "0.0"
                                font.pixelSize: FontUtils.sizeToPixels("large")
                                height: units.gu(4)
                                // on-the-fly conversion
                                onTextChanged: if (activeFocus) Converter.convert(input, converter, index)
                                onAccepted: Qt.inputMethod.hide()
                            }
                        }
                    }
                }
            }

            head.actions: Action {
                objectName: "action"
                iconName: "clear"
                text: i18n.tr("Clear")
                onTriggered: Converter.clear(converter)
            }
        }
    }

    Tabs {
        id: tabs

        // First tab begins here
        Tab {
            objectName: "Tab1"

            title: i18n.tr("Lengths")

            // Tab content begins here
            page: Loader {
                sourceComponent: pageContent
                onStatusChanged: {
                    if (status === Loader.Ready && item) {
                        item.parent = parent;
                        item.model = lengthModel;
                    }
                }
            }
        }

        // Second tab begins here
        Tab {
            objectName: "Tab2"

            title: i18n.tr("Weights")
            page: Loader {
                sourceComponent: pageContent
                onStatusChanged: {
                    if (status === Loader.Ready && item) {
                        item.parent = parent;
                        item.model = weightModel;
                    }
                }
            }
        }
    }
}

