import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root

    width: 640
    height: 480

    color: "#000000"

    property int sessionIndex: session.index

    property color foreground: "#eeeeee"
    property color secondary: "#888888"
    property color borderColor: "#aaaaaa"
    property color focusedBorder: "#eeeeee"

    TextConstants {
        id: textConstants
    }

    /*
     * ------------------------------------------------------------
     * clock
     * ------------------------------------------------------------
     */

    property string clockText: ""
    property string dateText: ""

    function updateClock() {
        var now = new Date()

        clockText = Qt.formatTime(now, "HH:mm")
        dateText = Qt.formatDate(now, "dd MMM yyyy")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.updateClock()
    }

    Component.onCompleted: {
        root.updateClock()
        name.forceActiveFocus()
    }

    /*
     * ------------------------------------------------------------
     * login
     * ------------------------------------------------------------
     */

    function doLogin() {
        errorMessage.visible = false
        sddm.login(name.text, password.text, sessionIndex)
    }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.text = textConstants.loginSucceeded
            errorMessage.visible = true
        }

        function onLoginFailed() {
            password.text = ""
            errorMessage.text = textConstants.loginFailed
            errorMessage.visible = true
            password.forceActiveFocus()
        }

        function onInformationMessage(message) {
            errorMessage.text = message
            errorMessage.visible = true
        }
    }

    /*
     * ------------------------------------------------------------
     * global keyboard handling
     * ------------------------------------------------------------
     */

    focus: true

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            password.text = ""
            errorMessage.visible = false
            event.accepted = true
        }

        if (event.key === Qt.Key_Return ||
            event.key === Qt.Key_Enter) {

            if (password.activeFocus) {
                doLogin()
                event.accepted = true
            }
        }
    }

    /*
     * ------------------------------------------------------------
     * top rule
     * ------------------------------------------------------------
     */

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.topMargin: 40

        height: 1

        color: root.borderColor
    }

    /*
     * ------------------------------------------------------------
     * header
     * ------------------------------------------------------------
     */

    Text {
        anchors.left: parent.left
        anchors.top: parent.top

        anchors.leftMargin: 48
        anchors.topMargin: 58

        text: "fedora"

        color: root.foreground

        font.family: "monospace"
        font.pixelSize: 18
        font.bold: true
    }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top

        anchors.leftMargin: 125
        anchors.topMargin: 60

        text: "/ sway"

        color: root.secondary

        font.family: "monospace"
        font.pixelSize: 14
    }

    /*
     * ------------------------------------------------------------
     * clock
     * ------------------------------------------------------------
     */

    Column {
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 48
        anchors.topMargin: 55

        spacing: 2

        Text {
            width: 150

            text: root.clockText

            color: root.foreground

            font.family: "monospace"
            font.pixelSize: 18

            horizontalAlignment: Text.AlignRight
        }

        Text {
            width: 150

            text: root.dateText

            color: root.secondary

            font.family: "monospace"
            font.pixelSize: 11

            horizontalAlignment: Text.AlignRight
        }
    }

    /*
     * ------------------------------------------------------------
     * login form
     * ------------------------------------------------------------
     */

    Column {
        id: form

        anchors.centerIn: parent

        width: 360

        spacing: 18

        /*
         * prompt
         */

        Text {
            text: "> login"

            color: root.foreground

            font.family: "monospace"
            font.pixelSize: 20
            font.bold: true
        }

        /*
         * username
         */

        Column {
            width: parent.width

            spacing: 6

            Text {
                text: "username"

                color: root.secondary

                font.family: "monospace"
                font.pixelSize: 11
            }

            Rectangle {
                id: usernameBox

                width: parent.width
                height: 42

                color: "#000000"

                border.width: 1
                border.color: name.activeFocus
                              ? root.focusedBorder
                              : root.borderColor

                TextInput {
                    id: name

                    anchors.fill: parent

                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    text: userModel.lastUser

                    color: root.foreground

                    font.family: "monospace"
                    font.pixelSize: 14

                    verticalAlignment: TextInput.AlignVCenter

                    clip: true

                    KeyNavigation.tab: password

                    Keys.onReturnPressed: {
                        password.forceActiveFocus()
                    }

                    Keys.onEnterPressed: {
                        password.forceActiveFocus()
                    }
                }
            }
        }

        /*
         * password
         */

        Column {
            width: parent.width

            spacing: 6

            Text {
                text: "password"

                color: root.secondary

                font.family: "monospace"
                font.pixelSize: 11
            }

            Rectangle {
                id: passwordBox

                width: parent.width
                height: 42

                color: "#000000"

                border.width: 1
                border.color: password.activeFocus
                              ? root.focusedBorder
                              : root.borderColor

                TextInput {
                    id: password

                    anchors.fill: parent

                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    color: root.foreground

                    font.family: "monospace"
                    font.pixelSize: 14

                    verticalAlignment: TextInput.AlignVCenter

                    echoMode: TextInput.Password

                    clip: true

                    KeyNavigation.backtab: name
                    KeyNavigation.tab: session

                    Keys.onReturnPressed: root.doLogin()
                    Keys.onEnterPressed: root.doLogin()
                }
            }
        }

        /*
         * session
         */

        Column {
            width: parent.width

            spacing: 6

            Text {
                text: "session"

                color: root.secondary

                font.family: "monospace"
                font.pixelSize: 11
            }

            ComboBox {
                id: session

                width: parent.width
                height: 42

                model: sessionModel
                index: sessionModel.lastIndex

                color: "#000000"
                borderColor: root.borderColor
                focusColor: root.focusedBorder
                hoverColor: root.focusedBorder
                textColor: root.foreground
                menuColor: "#000000"
                borderWidth: 1

                font.family: "monospace"
                font.pixelSize: 13

                arrowIcon: ""

                KeyNavigation.backtab: password
                KeyNavigation.tab: loginButton
            }
        }

        /*
         * login button
         */

        Rectangle {
            id: loginButton

            width: parent.width
            height: 42

            color: loginMouse.pressed
                   ? root.foreground
                   : "#000000"

            border.width: 1
            border.color: root.foreground

            Text {
                anchors.centerIn: parent

                text: loginMouse.containsMouse
                      ? "[ login ]"
                      : "[  login  ]"

                color: loginMouse.pressed
                       ? "#000000"
                       : root.foreground

                font.family: "monospace"
                font.pixelSize: 13
                font.bold: true
            }

            MouseArea {
                id: loginMouse

                anchors.fill: parent

                hoverEnabled: true

                onClicked: root.doLogin()
            }

            KeyNavigation.backtab: session

            Keys.onReturnPressed: root.doLogin()
            Keys.onEnterPressed: root.doLogin()
        }

        /*
         * error message
         */

        Text {
            id: errorMessage

            width: parent.width

            visible: false

            text: ""

            color: root.foreground

            font.family: "monospace"
            font.pixelSize: 11

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    /*
     * ------------------------------------------------------------
     * bottom rule
     * ------------------------------------------------------------
     */

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.leftMargin: 48
        anchors.rightMargin: 48
        anchors.bottomMargin: 45

        height: 1

        color: "#555555"
    }

    /*
     * ------------------------------------------------------------
     * bottom-left help
     * ------------------------------------------------------------
     */

    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: 48
        anchors.bottomMargin: 22

        text: "tab: next    enter: login    esc: clear"

        color: root.secondary

        font.family: "monospace"
        font.pixelSize: 10
    }

    /*
     * ------------------------------------------------------------
     * bottom-right power controls
     * ------------------------------------------------------------
     */

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 48
        anchors.bottomMargin: 16

        spacing: 10

        Rectangle {
            width: 90
            height: 28

            visible: sddm.canReboot

            color: "#000000"

            border.width: 1
            border.color: "#555555"

            Text {
                anchors.centerIn: parent

                text: "[ reboot ]"

                color: root.secondary

                font.family: "monospace"
                font.pixelSize: 10
            }

            MouseArea {
                anchors.fill: parent

                onClicked: sddm.reboot()
            }
        }

        Rectangle {
            width: 100
            height: 28

            visible: sddm.canPowerOff

            color: "#000000"

            border.width: 1
            border.color: "#555555"

            Text {
                anchors.centerIn: parent

                text: "[ shutdown ]"

                color: root.secondary

                font.family: "monospace"
                font.pixelSize: 10
            }

            MouseArea {
                anchors.fill: parent

                onClicked: sddm.powerOff()
            }
        }
    }
}
