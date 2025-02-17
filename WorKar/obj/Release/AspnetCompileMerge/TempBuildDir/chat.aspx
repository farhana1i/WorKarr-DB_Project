﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="chat.aspx.cs" Inherits="WorKar.chat" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Chat | WorKarr</title>
    <link rel="icon" href="images/logo_square.png"
        type="image/x-icon" />

    <!--Font Awsome link-->

    <!-- Font awsome link -->
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous" />
    <script src="https://kit.fontawesome.com/571b8d9aa3.js" crossorigin="anonymous"></script>

    <!--My stylesheet-->
    <link href="style/main_background.css" rel="stylesheet" runat="server" />
    <link href="style/glass_background.css" rel="stylesheet" runat="server" />
    <link href="style/chat.css" rel="stylesheet" runat="server" />


    <script type="text/javascript">
        $(document).bind("contextmenu", function (e) {
            e.preventDefault();
        });
        $(document).keydown(function (e) {
            if (e.which === 123) {
                return false;
            }
        });
    </script>

    <!--AJAX API-->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
    <script type="text/javascript">
        function load_messages(input)
        {
            let contactUsername = input.split('_')[1];
            $.ajax({
                type: "POST",
                url: "chat.aspx/Load_Messages",
                data: '{"contactUserName":"' + contactUsername + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
 
                    if (response.d != "" && response.d.length > 0) {
                        var xmlDoc = $.parseXML(response.d);
                        var xml = $(xmlDoc);
                        var messages = xml.find("Table1");
                        let contactUserPhoto = $("#photo_" + contactUsername).attr('src');
                        load_chat_window_header(contactUsername, contactUserPhoto);
                        make_messages_list(messages);
                        $("#message-input-containerID").css("display", "flex");
                        $("#message_inputID").focus();
                    }
                },
                failure: function (response) {
                    alert("Failed");
                },
                complete: function () {
                    update_contacts_status();
                    //let myUpdateContactsStatus = setTimeout(function () {
                    //}, 15000);
                }
            });
            return false;
        };


        function wrapper_for_load_messages() {
            let profile_header = $(".contact-profile");
            if (profile_header.length > 0) {
                let contactUserName = profile_header.attr('id').split('_')[1];
                let contact_tag_id = "contact_" + contactUserName.trim();

                load_messages(contact_tag_id);
            }
        }


        // function to load chat window header
        function load_chat_window_header(userName, userPhoto) {
            $("#chat_windowID").prepend(get_chat_window_template(userName, userPhoto));
        }

        // remove all previous profile headers
        function remove_all_previous_profiel_header() {
            $(".contact-profile").remove();
        }

        function get_chat_window_template(userName, userPhoto) {
            this.remove_all_previous_profiel_header();
            return " \
                <div class=\"contact-profile\" id=\"profileHeader_" + userName + "\"> \
                    <img class=\"contact-profile-photo\" src = \"" + userPhoto + "\" width = \"60px\" /> \
                    <p>" + userName + "</p> \
                </div > \
            ";

        }

        // this function will return message template
        // messageType --> sent/replies
        function get_message_template(message) {
            var msg_code = " \
                <li class=\"" + message.MsgType + "\"> \
                    <div> \
                    <p>" + message.Msg + "</p> \
                    <p id=\"msg_timeID\">"+ formatAMPM(new Date(message.MsgTime)) + "</p> \
                    </div> \
                </li>\
            ";
            var parser = new DOMParser();
            msg_code = parser.parseFromString(msg_code, "text/html").body;
            return msg_code;
        }

        function AddMessage(message) {
            var messageTemplate = get_message_template(message);
            // append messages to the messageList div
            $("#messagesListID").append(messageTemplate);
        }

        // this function will attach messages in the message list container
        function make_messages_list(messagesList) {
            $("#messagesListID").empty();
            for (var i = 0; i < messagesList.length; i++) {
                var message =
                {
                    Msg: messagesList[i].getElementsByTagName("Message")[0].childNodes[0].nodeValue,
                    MsgTime: messagesList[i].getElementsByTagName("AddedOn")[0].childNodes[0].nodeValue,
                    MsgType: messagesList[i].getElementsByTagName("MessageType")[0].childNodes[0].nodeValue
                };

                AddMessage(message);            // append msg to messageListID
            }
            $("#messagesListID").css("display", "initial");
        }

        function formatAMPM(date) {
            var hours = date.getHours();
            var minutes = date.getMinutes();
            var ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours ? hours : 12; // the hour '0' should be '12'
            minutes = minutes < 10 ? '0' + minutes : minutes;
            var strTime = hours + ':' + minutes + ' ' + ampm;
            return strTime;
        }

        // to send private message 
        function send_msg_btn_click() {
            let message = $("#message_inputID").val();
            if (message.length > 0) {
                let toUsername = $(".contact-profile").attr('id').split('_')[1];
                send_private_message(toUsername, message);

                $("#message_inputID").val("");
                $("#message_inputID").focus();
            }
            return false;
        }


        // to save provate msg in database
        function send_private_message(toUsername, message) {

            var messageObject = {
                Msg: message,
                MsgType: "Send",
                MsgTime: new Date().toString()
            };
            AddMessage(messageObject);
            $("#messagesListID-container").animate({ scrollTop: 9999 }, 'slow');

            $.ajax({
                type: "POST",
                url: "chat.aspx/Send_Private_Message",
                data: '{"toUserName":"' + toUsername + '","message":"' + message + '"}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    //let returnValue = response.d.toString().split("-");

                    //var messageObject = {
                    //    Msg: returnValue[0],
                    //    MsgType: "Send",
                    //    MsgTime: returnValue[1]
                    //};
                    //AddMessage(messageObject);
                    //$("#messagesListID-container").animate({ scrollTop: 9999 }, 'slow');
                },
                failure: function (response) {
                    alert("Failed to send message. Retry!");
                }
            });
            return false;
        };

       // set interval to reload messages and update contacts statuses after every 5 seconds
        $(document).ready(function () {
            let myLoadMsgInterval = setInterval(function () {
                wrapper_for_load_messages();
            }, 20000);
        });

        // to get value of a parameter
        function GetUrlParameter(sParam) {
            var sPageURL = window.location.search.substring(1);

            var sURLVariables = sPageURL.split('&');

            for (var i = 0; i < sURLVariables.length; i++) {
                var sParameterName = sURLVariables[i].split('=');

                if (sParameterName[0] == sParam) {
                    return sParameterName[1];
                }
            }
        }

        // to open chat window for the top user 
        function open_top_contact_chat_window() {
            let toUsername = null;
            toUsername = GetUrlParameter("Username");

            if (typeof toUsername != "undefined" && toUsername.length > 0)
            {
                this.load_messages("contact_" + toUsername);                    
            }
        }

        window.onload = open_top_contact_chat_window();

        function update_contacts_status() {
            let contacts = document.getElementsByClassName("contact");
            let contactsUsernames = new Array();

            for (var i = 0; i < contacts.length; ++i) {
                contactsUsernames.push(contacts[i].id.split('_')[1]);
            }
            get_updated_contacts_status(contactsUsernames);
        }

        function get_updated_contacts_status(usernames) {

            if (usernames == "" || usernames.length <= 0) {
                return;
            }

            // Make the ajax call
            $.ajax({
                type: "POST",
                url: "chat.aspx/Get_Updated_Contacts_Status", // the method we are calling
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ contactsUsernames: usernames }),
                dataType: "json",
                success: function (response) {

                    var xmlDoc = $.parseXML(response.d);
                    var xml = $(xmlDoc);
                    var contactsStatus = xml.find("Table1");

                    // update status of users
                    for (var i = 0; i < contactsStatus.length; ++i)
                    {
                        var username = contactsStatus[i].getElementsByTagName("Username")[0].childNodes[0].nodeValue;
                        var status = contactsStatus[i].getElementsByTagName("UserStatus")[0].childNodes[0].nodeValue;
                        set_updated_contacts_status(username, status);
                    }
                },
                failure: function (response) {
                    alert('Update Contacts Status Failed');
                }
            });
        }


        // to update status of contacts after ajax reques
        function set_updated_contacts_status(username, status)
        {
            var tag_html = status + "<span class=\"contact-status " + status + "\"></span>";
            $("#Status_" + username).html(tag_html);
        }

    </script>
</head>
<body>
    <form id="form1" runat="server" style="width: 100%;">
        <main>
            <section class="glass">
                <div class="sidepanel">
                    <div class="wrap profile-head-wrap">
                        <asp:Repeater ID="rptrUser_DetailID" runat="server">
                            <ItemTemplate>
                                <img id="profile-img" src='<%# Eval("UserPhoto") %>' alt="" />
                                <div>
                                    <p id="currUserFirstName" runat="server"><%# Eval("UserFName") %></p>
                                    <span>@<span id="currUserName" runat="server"><%# Eval("Username") %></span></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="contacts-header-container">
                        <i class="fal fa-users"></i>
                        <h3>Contacts</h3>
                    </div>
                    <div class="contacts" id="contacts-container">
                        <ul id="contactsListID">
                            <!-- all contacts div -->
                            <asp:Repeater ID="rptrContacts_list" runat="server">
                                <ItemTemplate>
                                    <li id="contact_<%# Eval("contactUserName") %>" class="contact" ondblclick="return load_messages(this.id);">
                                        <div class="wrap">
                                            <div class="contact-name-photo">
                                                <img id="photo_<%# Eval("contactUserName") %>" src="<%# Eval("contactUserPhoto") %>" width="60px" />
                                                <div class="meta">
                                                    <p class="name"><%# Eval("contactUserName") %> </p>
                                                    <p class="status-text" id="Status_<%# Eval("contactUserName") %>">
                                                        <%# Eval("contactStatus") %>
                                                        <span class="contact-status <%# Eval("contactStatus") %>"></span>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    </li>
                                </ItemTemplate>
                            </asp:Repeater>
                        </ul>
                    </div>
                </div>
                <div class="content" id="chat_windowID">

                    <div class="messages" id="messagesListID-container">
                        <!-- messages container -->
                        <ul id="messagesListID">
                            <!--all messages-->
                        </ul>
                    </div>

                    <div class="message-input" id="message-input-containerID">
                        <div class="wrapper">
                            <input id="message_inputID" type="text" maxlength="500" placeholder="Write your message... " />
                        </div>
                        <button type="button" onclick="return send_msg_btn_click();"  class="submit" id="send_msgID"><i class="fa fa-paper-plane"></i></button>
                    </div>
                </div>
            </section>
        </main>
    </form>

    <script type="text/javascript">

        // send message if enter key is pressed
        $("#message_inputID").keypress(function (event)
        {
            if (event.keyCode == 13) {
                event.preventDefault();
                $("#send_msgID").click();
            }
        });

    </script>
</body>
</html>
