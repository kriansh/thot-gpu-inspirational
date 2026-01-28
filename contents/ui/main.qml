import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Qt5Compat.GraphicalEffects
import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    property var valueUsage: 0
    property var temperature: 0
    property var vramUsed: 0
    property var vramTotal: 0

    FontLoader {
        id: acheB
        source: "../fonts/AcherusGrotesque-Bold.ttf"
    }
    FontLoader {
        id: acheEB
        source: "../fonts/couture-bld.otf"
    }

    Layout.minimumHeight: 80
    Layout.minimumWidth: 80
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    Sensors.SensorDataModel {
        id: usageModel
        sensors: ["gpu/" + plasmoid.configuration.gpuSelection + "/usage"]
        enabled: true

        onDataChanged: topLeft => {
            const value = parseFloat(data(topLeft, Sensors.SensorDataModel.Value));
            if (!isNaN(value)) {
                valueUsage = value / 100;
            }
        }
    }

    Sensors.SensorDataModel {
        id: tempModel
        sensors: ["gpu/" + plasmoid.configuration.gpuSelection + "/temperature"]
        enabled: plasmoid.configuration.showTemperature

        onDataChanged: topLeft => {
            const value = parseFloat(data(topLeft, Sensors.SensorDataModel.Value));
            if (!isNaN(value)) {
                temperature = Math.round(value);
            }
        }
    }

    Sensors.SensorDataModel {
        id: vramModel
        sensors: [
            "gpu/" + plasmoid.configuration.gpuSelection + "/usedVram",
            "gpu/" + plasmoid.configuration.gpuSelection + "/totalVram"
        ]
        enabled: plasmoid.configuration.showVram

        onDataChanged: topLeft => {
            const used = parseFloat(data(index(0, 0), Sensors.SensorDataModel.Value));
            const total = parseFloat(data(index(1, 0), Sensors.SensorDataModel.Value));
            if (!isNaN(used)) vramUsed = used;
            if (!isNaN(total)) vramTotal = total;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            usageModel.enabled = false;
            usageModel.enabled = true;
            if (plasmoid.configuration.showTemperature) {
                tempModel.enabled = false;
                tempModel.enabled = true;
            }
            if (plasmoid.configuration.showVram) {
                vramModel.enabled = false;
                vramModel.enabled = true;
            }
        }
    }

    onValueUsageChanged: {
        if (valueUsage >= 0) {
            progressCanvas.requestPaint();
        }
    }

    Item {
        width: parent.height < parent.width ? parent.height : parent.width
        height: parent.height < parent.width ? parent.height : parent.width
        anchors.centerIn: parent

        Rectangle{
            id: mask
            color: "transparent"
            width: parent.height
            height: width
            radius: width/2
            visible: false
            Rectangle {
                id: intofCicle
                anchors.centerIn: parent
                width: parent.width*.65
                height: parent.height*.65
                color: "black"
                radius: width/2
            }
            Rectangle {
                id: rectangleOsMask
                width: parent.width/2
                height: parent.height/3
                color: "black"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
        Rectangle{
            id: mask2
            color: "transparent"
            width: parent.height
            height: width
            radius: width/2
            visible: false
            Rectangle {
                id: intofCicle2
                anchors.centerIn: parent
                width: parent.width*.65
                height: parent.height*.65
                color: "black"
                radius: width/2
            }
        }
        Rectangle {
            id: cicleBse
            anchors.centerIn: parent
            width: parent.height
            height: width
            color: "white"
            opacity: 0.6
            radius: width/2
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: mask
                invert: true
            }
        }
        Canvas {
            id: progressCanvas
            anchors.centerIn: parent
            width: parent.height
            height: width
            rotation: 180
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, progressCanvas.width, progressCanvas.height);

                ctx.fillStyle = cicleBse.color;
                ctx.beginPath();
                ctx.moveTo(progressCanvas.width / 2, progressCanvas.height / 2);
                ctx.arc(progressCanvas.width / 2, progressCanvas.height / 2, progressCanvas.width / 2, -Math.PI / 2, (-Math.PI / 2) + (2 * Math.PI * valueUsage));
                ctx.fill();
            }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: mask2
                invert: true
            }
        }
        Column {
            width: parent.width/2
            height: parent.height/3.6
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: - one.font.pixelSize*.4
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                id: one
                color: cicleBse.color
                text: i18n("GPU")
                font.family: acheEB.name
                font.pixelSize: cicleBse.height*.16
                verticalAlignment: Text.AlignBottom
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                id: two
                color: cicleBse.color
                text: Math.round(valueUsage*100) + "%"
                font.family: acheB.name
                font.pixelSize: one.font.pixelSize*.8
                verticalAlignment: Text.AlignTop
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                id: three
                color: cicleBse.color
                visible: plasmoid.configuration.showTemperature
                text: temperature + "°C"
                font.family: acheB.name
                font.pixelSize: one.font.pixelSize*.5
                verticalAlignment: Text.AlignTop
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                id: four
                color: cicleBse.color
                visible: plasmoid.configuration.showVram
                text: (vramUsed / 1073741824).toFixed(1) + "/" + (vramTotal / 1073741824).toFixed(1) + "GB"
                font.family: acheB.name
                font.pixelSize: one.font.pixelSize*.45
                verticalAlignment: Text.AlignTop
            }
        }
    }
}
