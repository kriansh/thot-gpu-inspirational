import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_fontSize: sizeFontSpinBox.value
    property alias cfg_gpuSelection: gpuComboBox.currentValue
    property alias cfg_showTemperature: showTempCheckBox.checked
    property alias cfg_showVram: showVramCheckBox.checked

    ColumnLayout {
        spacing: units.smallSpacing * 2

        RowLayout{
            Label {
                text: i18n("Font Size")
            }
            SpinBox {
                id: sizeFontSpinBox
                from: 0
                to: 300
            }
        }

        RowLayout{
            Label {
                text: i18n("GPU Selection")
            }
            ComboBox {
                id: gpuComboBox
                textRole: "text"
                valueRole: "value"
                model: [
                    { text: i18n("All GPUs"), value: "all" },
                    { text: i18n("GPU 1 (Intel iGPU)"), value: "gpu1" },
                    { text: i18n("GPU 2 (NVIDIA dGPU)"), value: "gpu2" }
                ]
                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === cfg_gpuSelection) {
                            currentIndex = i;
                            break;
                        }
                    }
                }
            }
        }

        CheckBox {
            id: showTempCheckBox
            text: i18n("Show Temperature")
        }

        CheckBox {
            id: showVramCheckBox
            text: i18n("Show VRAM Usage")
        }

   }
}
