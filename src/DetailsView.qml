/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import "./"

BaseView {
    id: root

    property real itemSize: width / 3
    property string searchFor: ""
    property string poiName: ""

    loading: theDetails.isLoading

    DensityHelpers {
        id:localHelper
    }

    JsonModel {
        id: theDetails
        phrase: root.visible ? root.searchFor : ""
        searchString: "http://baugeschichte.at/app/v1/getData.php?action=getBuildingDetail&name="
        onNewobject: {
            poiName = magneto.title
            for (var key in magneto.payload) {
                var jsonObject = magneto.payload[key];
                if (jsonObject.title.trim() !== "Info") {
                    jsonObject.detailText = jsonObject.text
                    jsonObject.text = ""
                    model.append(jsonObject);
                }
            }
        }
        onErrorChanged: {
            if (error !== "") {
                console.log("Error: " + error);
                var jsonObject = {"detailText": error, "title": qsTr("Load error")};
                model.append(jsonObject);
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: initialTextbackground
        width: parent.width
        height:  parent.height / 2
        anchors.bottom: parent.bottom

        color: "#FFFCF2"
        border.color: "#8E8E8E"

        visible: mainListView.count === 0
    }

    ListView {
        id:                     mainListView
        anchors                 { fill: parent; /*margins: 10*/ }
        interactive:            false
        orientation:            ListView.Horizontal
        highlightMoveDuration:  250
        clip:                   false
        model:                  theDetails.model

        delegate:               Item {
            width:      mainListView.width
            height:     mainListView.height

            SplitView{
                anchors.fill: parent
                orientation: Qt.Vertical

                ImageCarousel {
                    id: imagePathView

                    width: parent.width
                    height: parent.height / 2
                    Layout.fillHeight: true
                    Layout.maximumHeight: parent.height * 0.75
                    Layout.minimumHeight: parent.height * 0.25

                    model: images
                }

                Rectangle {
                    id: textBase

                    width: parent.width
                    height: parent.height / 2
                    Layout.maximumHeight: parent.height * 0.75
                    Layout.minimumHeight: parent.height * 0.25

                    color: initialTextbackground.color
                    border.color: initialTextbackground.border.color

                    Text {
                        id: titleText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        text: (poiName !== "") ? (poiName + ": " + title) : title
                        smooth: true
                        font.pixelSize: localHelper.defaultFontSize
                        anchors.margins: localHelper.dp(5)
                        wrapMode: Text.Wrap
                    }

                    TextArea {
                        anchors { top: titleText.bottom;
                            bottom: parent.bottom; left: parent.left;
                            right: parent.right; margins: 5 }
                        readOnly:           true
                        verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                        wrapMode:           TextEdit.WordWrap
                        text:               (detailText.length > 0) ? detailText : qsTr("Kein Text")
                        font.pixelSize:     localHelper.smallFontSize
                    }

                    Keys.onLeftPressed: console.log("onLeft Details")
                    Keys.onRightPressed: console.log("onLeft Details")
                }
            }//SplitView
        }
    }

    Image {
        id:prevImage
        anchors { left: parent.left; bottom: parent.bottom; margins: 10 }
        width: localHelper.dp(50)
        height: localHelper.dp(50)

        source: "resources/Go-previous.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: theDetails.model.count > 1

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if ( mainListView.currentIndex != 0 ) {
                    mainListView.decrementCurrentIndex()
                } else {
                    mainListView.currentIndex = mainListView.count - 1
                }
            }
        }
    }
    Image {
        id:nextImage
        anchors { right: parent.right; bottom: parent.bottom; margins: 10 }
        width: localHelper.dp(50)
        height: localHelper.dp(50)

        source: "resources/Go-next.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: theDetails.model.count > 1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if ( mainListView.currentIndex != mainListView.count - 1 ) {
                    mainListView.incrementCurrentIndex()
                } else {
                    mainListView.currentIndex = 0
                }
            }
        }
    }
}
