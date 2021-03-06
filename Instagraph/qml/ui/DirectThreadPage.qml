import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: directthreadpage

    property bool list_loading: false

    property var threadId

    property var threadUsers: []

    header: PageHeader {
        title: i18n.tr("Direct")
    }

    function directThreadFinished(data) {
        directthreadpage.header.title = data.thread.thread_title != "" ? data.thread.thread_title : data.thread.inviter.username;

        directThreadModel.clear()
        for (var j = 0; j < data.thread.users.length; j++) {
            threadUsers[data.thread.users[j].pk] = data.thread.users[j];
        }
        for (var i = 0; i < data.thread.items.length; i++) {
            data.thread.items[i].ctext = data.thread.items[i].text;
            directThreadModel.append(data.thread.items[i]);
        }

        list_loading = false
    }

    function messagePostedFinished(data) {
        for (var j = 0; j < data.threads.length; j++) {
            var thread = data.threads[j];
            for (var i = 0; i < thread.items.length; i++) {
                thread.items[i].ctext = thread.items[i].text;
                directThreadModel.insert(0, thread.items[i]);
            }
        }

        addMessageField.text = '';
    }

    function likePostedFinished(data) {
        for (var j = 0; j < data.threads.length; j++) {
            var thread = data.threads[j];
            for (var i = 0; i < thread.items.length; i++) {
                thread.items[i].ctext = thread.items[i].text;
                directThreadModel.insert(0, thread.items[i]);
            }
        }
    }

    Component.onCompleted: {
        directThread();
    }

    function directThread()
    {
        list_loading = true
        instagram.directThread(threadId);
    }

    function sendMessage(text)
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+i+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directMessage(recip_string, text, threadId);
    }

    function sendLike()
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+i+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directLike(recip_string, threadId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: directthreadpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: directThreadModel
        dynamicRoles: true
    }

    ListView {
        id: directThreadList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: addMessageItem.top
            bottomMargin: units.gu(1)
            top: directthreadpage.header.bottom
        }
        onMovementEnded: {
        }
        verticalLayoutDirection: ListView.BottomToTop
        clip: true
        cacheBuffer: parent.height*2
        model: directThreadModel
        delegate: ListItem {
            id: directThreadDelegate
            divider.visible: false
            height: (user_id != my_usernameId && index == 0) || (user_id != my_usernameId && index != 0 && directThreadModel.get(index-1).user_id != user_id) ? entry_column.height + units.gu(2) : entry_column.height + units.gu(1)

            Component.onCompleted: {
                if (user_id == my_usernameId) {
                    // men
                } else {
                    // diger
                }
            }

            Column {
                id: entry_column
                spacing: units.gu(1)
                width: parent.width
                y: units.gu(1)

                Column {
                    visible: (user_id == my_usernameId && typeof hide_in_thread == 'undefined') || (user_id != my_usernameId && typeof hide_in_thread != 'undefined' && hide_in_thread == "1")
                    anchors.right: parent.right

                    Rectangle {
                        visible: item_type == "text"
                        width: item_type == "text" ? myText.width + units.gu(2.5) : 0
                        height: item_type == "text" ? myText.height + units.gu(2.5) : 0
                        color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                        Label {
                            id: myText
                            wrapMode: Text.WordWrap
                            width: contentWidth >= entry_column.width/2 - units.gu(2.5) ? entry_column.width/2 - units.gu(2.5) : contentWidth
                            anchors.centerIn: parent
                            text: item_type == "text" ? ctext : ''
                        }
                    }

                    Icon {
                        visible: item_type == "like"
                        width: units.gu(4)
                        height: units.gu(4)
                        name: "like"
                        color: UbuntuColors.red
                    }

                    Image {
                        visible: item_type == "media"
                        width: item_type == "media" ? entry_column.width/2 - units.gu(2.5) : 0
                        height: item_type == "media" ? width/media.image_versions2.candidates[0].width*media.image_versions2.candidates[0].height : 0
                        source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "media" ? media.image_versions2.candidates[0].url : '')
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        smooth: true
                        clip: true
                    }

                    Image {
                        visible: item_type == "media_share"
                        width: item_type == "media_share" ? entry_column.width/2 - units.gu(2.5) : 0
                        height: item_type == "media_share" ? width/media_share.image_versions2.candidates[0].width*media_share.image_versions2.candidates[0].height : 0
                        source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "media_share" ? media_share.image_versions2.candidates[0].url : '')
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        smooth: true
                        clip: true
                    }

                    Image {
                        visible: item_type == "reel_share"
                        width: item_type == "reel_share" ? entry_column.width/2 - units.gu(2.5) : 0
                        height: item_type == "reel_share" ? width/reel_share.media.image_versions2.candidates[0].width*reel_share.media.image_versions2.candidates[0].height : 0
                        source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "reel_share" ? reel_share.media.image_versions2.candidates[0].url : '')
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        smooth: true
                        clip: true
                    }

                    Rectangle {
                        visible: item_type == "reel_share" && reel_share.text
                        width: item_type == "reel_share" && reel_share.text ? myReelText.width + units.gu(2.5) : 0
                        height: item_type == "reel_share" && reel_share.text ? myReelText.height + units.gu(2.5) : 0
                        color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                        Label {
                            id: myReelText
                            wrapMode: Text.WordWrap
                            width: contentWidth >= entry_column.width/2 - units.gu(2.5) ? entry_column.width/2 - units.gu(2.5) : contentWidth
                            anchors.centerIn: parent
                            text: item_type == "reel_share" && reel_share.text ? reel_share.text : ''
                        }
                    }

                    Row {
                        width: units.gu(5)
                        visible: item_type == "action_log"
                        spacing: units.gu(1)
                        anchors.right: parent.right

                        Icon {
                            visible: item_type == "action_log"
                            width: units.gu(2)
                            height: units.gu(2)
                            name: "like"
                            color: UbuntuColors.red
                        }

                        UbuntuShape {
                            width: units.gu(2)
                            height: width
                            radius: "large"

                            source: Image {
                                width: parent.width
                                height: parent.height
                                source: status == Image.Error ? "../images/not_found_user.jpg" : (user_id != my_usernameId ? threadUsers[user_id].profile_pic_url : '')
                                fillMode: Image.PreserveAspectCrop
                                anchors.centerIn: parent
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }
                        }
                    }

                    Item {
                        visible: item_type == "action_log" && user_id != my_usernameId
                        width: item_type == "action_log" && user_id != my_usernameId ? parent.width : 0
                        height: item_type == "action_log" && user_id != my_usernameId ? units.gu(0.3) : 0
                    }

                    Label {
                        text: item_type == "action_log" && user_id != my_usernameId ? threadUsers[user_id].username : ''
                        fontSize: "small"
                        color: UbuntuColors.darkGrey
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                    }
                }

                Column {
                    width: parent.width
                    visible: (user_id != my_usernameId && typeof hide_in_thread == 'undefined') || (user_id == my_usernameId && typeof hide_in_thread != 'undefined' && hide_in_thread == "1")
                    anchors.left: parent.left

                    Row {
                        width: parent.width
                        spacing: units.gu(1)

                        Item {
                            visible: !otherUserPhoto.visible
                            width: units.gu(5)
                            height: width
                        }

                        Item {
                            id: otherUserPhoto
                            visible: (user_id != my_usernameId && index == 0) || (user_id != my_usernameId && index != 0 && directThreadModel.get(index-1).user_id != user_id)
                            width: units.gu(5)
                            height: width
                            anchors.bottom: parent.bottom

                            UbuntuShape {
                                width: parent.width
                                height: width
                                radius: "large"

                                source: Image {
                                    id: feed_user_profile_image
                                    width: parent.width
                                    height: width
                                    source: status == Image.Error ? "../images/not_found_user.jpg" : (user_id != my_usernameId ? threadUsers[user_id].profile_pic_url : '')
                                    fillMode: Image.PreserveAspectCrop
                                    anchors.centerIn: parent
                                    sourceSize: Qt.size(width,height)
                                    smooth: true
                                    clip: true
                                }
                            }

                            Item {
                                width: activity.width
                                height: width
                                anchors.centerIn: parent
                                opacity: feed_user_profile_image.status == Image.Loading

                                Behavior on opacity {
                                    UbuntuNumberAnimation {
                                        duration: UbuntuAnimation.SlowDuration
                                    }
                                }

                                ActivityIndicator {
                                    id: activity
                                    running: true
                                }
                            }
                        }

                        Column {
                            spacing: units.gu(0.2)
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                visible: (user_id != my_usernameId && index == directThreadModel.count-1) || (user_id != my_usernameId && index != directThreadModel.count-1 && directThreadModel.get(index+1).user_id != user_id)
                                text: visible ? threadUsers[user_id].username : ''
                                fontSize: "small"
                                color: UbuntuColors.darkGrey
                                font.weight: Font.Light
                                wrapMode: Text.WordWrap
                            }

                            Rectangle {
                                visible: item_type == "text"
                                width: item_type == "text" ? othersText.width + units.gu(2.5) : 0
                                height: item_type == "text" ? othersText.height + units.gu(2.5) : 0
                                color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                                Label {
                                    id: othersText
                                    wrapMode: Text.WordWrap
                                    width: contentWidth >= entry_column.width/2 - units.gu(2.5) ? entry_column.width/2 - units.gu(2.5) : contentWidth
                                    anchors.centerIn: parent
                                    text: item_type == "text" ? ctext : ''
                                }
                            }

                            Icon {
                                visible: item_type == "like"
                                width: units.gu(4)
                                height: units.gu(4)
                                name: "like"
                                color: UbuntuColors.red
                            }

                            Image {
                                visible: item_type == "media"
                                width: item_type == "media" ? entry_column.width/2 - units.gu(2.5) : 0
                                height: item_type == "media" ? width/media.image_versions2.candidates[0].width*media.image_versions2.candidates[0].height : 0
                                source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "media" ? media.image_versions2.candidates[0].url : '')
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }

                            Image {
                                visible: item_type == "media_share"
                                width: item_type == "media_share" ? entry_column.width/2 - units.gu(2.5) : 0
                                height: item_type == "media_share" ? width/media_share.image_versions2.candidates[0].width*media_share.image_versions2.candidates[0].height : 0
                                source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "media_share" ? media_share.image_versions2.candidates[0].url : '')
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }

                            Image {
                                visible: item_type == "reel_share"
                                width: item_type == "reel_share" ? entry_column.width/2 - units.gu(2.5) : 0
                                height: item_type == "reel_share" ? width/reel_share.media.image_versions2.candidates[0].width*reel_share.media.image_versions2.candidates[0].height : 0
                                source: status == Image.Error ? "../images/not_found_user.jpg" : (item_type == "reel_share" ? reel_share.media.image_versions2.candidates[0].url : '')
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }

                            Row {
                                width: units.gu(5)
                                visible: item_type == "action_log"
                                spacing: units.gu(1)

                                Icon {
                                    visible: item_type == "action_log"
                                    width: units.gu(2)
                                    height: units.gu(2)
                                    name: "like"
                                    color: UbuntuColors.red
                                }

                                UbuntuShape {
                                    width: units.gu(2)
                                    height: width
                                    radius: "large"

                                    source: Image {
                                        width: parent.width
                                        height: parent.height
                                        source: status == Image.Error ? "../images/not_found_user.jpg" : (user_id != my_usernameId ? threadUsers[user_id].profile_pic_url : '')
                                        fillMode: Image.PreserveAspectCrop
                                        anchors.centerIn: parent
                                        sourceSize: Qt.size(width,height)
                                        smooth: true
                                        clip: true
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }

    Item {
        id: addMessageItem
        height: units.gu(5)
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        Row {
            width: parent.width
            spacing: units.gu(1)

            TextField {
                id: addMessageField
                width: parent.width - addMessageButton.width - sendLikeButton.width - units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: i18n.tr("Write a message...")
                onAccepted: {
                    sendMessage(addMessageField.text)
                }
            }

            Icon {
                id: sendLikeButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.red
                height: units.gu(3)
                width: height
                name: "unlike"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sendLike()
                    }
                }
            }

            Button {
                id: addMessageButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.green
                text: i18n.tr("Send")
                onClicked: {
                    sendMessage(addMessageField.text)
                }
            }
        }
    }

    Connections{
        target: instagram
        onDirectThreadReady: {
            var data = JSON.parse(answer);
            directThreadFinished(data);
        }
        onDirectMessageReady: {
            var data = JSON.parse(answer);
            messagePostedFinished(data);
        }
        onDirectLikeReady: {
            var data = JSON.parse(answer);
            likePostedFinished(data);
        }
    }
}
