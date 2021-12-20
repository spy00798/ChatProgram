<%@ page import="java.net.InetAddress" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Created by IntelliJ IDEA.
  User: spy00
  Date: 2021-10-18
  Time: 오후 12:59
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Chat</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script type="text/javascript">
        var ws;

        function wsOpen() {
            ws = new WebSocket("ws://" + location.host + "/chat");
            wsEvt();
        }

        wsOpen();
        console.log(ws)

        function wsEvt() {

            ws.onopen = function (data) {

            }
            ws.onmessage = function (data) {
                console.log(data);
                var message = data.data;
                console.log(message);
                console.log((message.substring((message.indexOf(": ") + 1), message.length).trim().startsWith("/say to", 0) && message.substring(0, message.indexOf(" :")) == `${sessionScope.loginInfo.userName}`));
                if (message.trim() != null && message.trim() != '') {
                    if (message.startsWith("FROM", 0)) {
                        $("#textContent").append("<pre style='color: green;'>" + message + "</pre>");
                    } else if (message.startsWith("TO", 0)) {
                        $("#textContent").append("<pre style='color: blue;'>" + message + "</pre>");
                    } else {
                        $("#textContent").append("<pre>" + message + "</pre>");
                    }
                    $("#textContent").scrollTop($("#textContent")[0].scrollHeight);
                }

            }


            document.addEventListener('keypress', function (e) {
                if (e.keyCode == 13) {
                    send();
                }
            })
        }

        function send() {
            let userName = `${sessionScope.loginInfo.userName}`
            let textMessage = $(".textType").val();
            textMessage = textMessage.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace('\n', "<br>");
            if (textMessage.trim() == "") {
                textMessage = '';
            }
            let message = userName + " : " + textMessage;
            let logData = {
                userId: `${sessionScope.loginInfo.userId}`,
                userName: userName,
                userIp: $("#userIp").val(),
                chatContent: message,
                regTime: $("#chatTime").val()
            };
            ws.send(message);

            if (message.trim() != null && message.trim() != '') {
                $.ajax({
                    url: "/logAjax",
                    type: "POST",
                    data: logData,
                    success: function (data) {

                    },
                    error: function () {

                    }
                });
                $(".textType").val(null);

            }
            ;
        };

        function showUser() {
            $.ajax({
                url: "/listAjax",
                type: "GET",
                data: null,
                success: function (data) {
                    console.log(data);
                    addUser(data)
                },
                error: function () {
                    alert("통신실패");
                }
            });
        };

        function showList() {
            $("#userList").stop().fadeToggle(500);
            showUser();
        };

        function showLog(userId, userName) {
            $("#wrap").append("<div id='showLog' style='position: fixed; width: 500px; height: 800px; background: white; border: 1px solid black;'><div id='closeBtn' onclick='closeLog();'>X</div><ul></ul></div");
            var logInfo = {
                userId: userId,
                userName: userName
            };
            console.log(logInfo)
            $.ajax({
                url: "/showAjax",
                type: "GET",
                data: logInfo,
                success: function (data) {
                    console.log(data);
                    $("#showLog").append("<h2>" + userName + "(" + userId + ") 님의 채팅" + "</h2>")
                    for (let i = 0; i < data.length; i++) {
                        $("#showLog > ul").append("<li>[" + data[i].regTime + "]" + data[i].userName + "(" + data[i].userId + ")" + " : " + data[i].chatContent.replaceAll(/</g, "&lt;").replaceAll(/>/g, "&gt;") + "</li>");
                    }
                    if (data.length == 0) {
                        $("#showLog > ul").append("<li style='font-size: 18px; text-align: center;'>------[채팅이력이 없습니다.]------</li>");
                    }
                    $("#showLog").append("<a href='/download.do?userId=" + userId + "' id='downloadLog' download='" + userId + ".txt' >다운로드</a>")
                    $("#showLog").append("<form id='fileForm' enctype='multipart/form-data'><input type='file' id='fileBack' accept='.txt' onchange='getRealPath(this)' /><input type='button' id='backup_btn' value='복원' onclick='BackupDo(`" + userName + "`,`" + userId + "`,`" + userIp + "`)'/></form>")
                },
                error: function () {
                    alert("통신실패");
                }
            });
        };

        function addUser(data) {
            $("#userList-online > li > ul").empty();
            $("#userList-offline > li > ul").empty();

            for (var i = 0; i < data.length; i++) {
                if (data[i].userStatus == "1") {
                    if (data[i].userName != `${sessionScope.loginInfo.userName}`) {
                        if (data[i].userAccess == "0") {
                            $("#userList-online > li > ul").append("<li>" + data[i].userName + "<div class='btn_area' style='display: flex'><div class='log_btn' onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div><div class='whisper' style='width: 70px; height: 30px; float: left; margin: 10px; border: 1px solid black; text-align: center; line-height: 30px; cursor:pointer;' onclick='tellmsg(`" + data[i].userId + "`)' >귓속말</div><div class='kick_btn' style='width: 50px; height: 30px; margin: 10px; background: black; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='kickUser(`" + data[i].userId + "`);' >Kick</div><div class='pardon_btn' style='width: 70px; height: 30px;margin: 10px; background: blue; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='pardonUser(`" + data[i].userId + "`)'>PARDON</div></div></li>");
                        } else {
                            $("#userList-online > li > ul").append("<li>" + data[i].userName + "<div class='btn_area' style='display: flex'><div class='log_btn' onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div><div class='whisper' style='width: 70px; height: 30px; float: left; margin: 10px; border: 1px solid black; text-align: center; line-height: 30px; cursor:pointer;' onclick='tellmsg(`" + data[i].userId + "`)' >귓속말</div><div class='kick_btn' style='width: 50px; height: 30px; margin: 10px; background: black; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='kickUser(`" + data[i].userId + "`);' >Kick</div><div class='ban_btn' style='width: 50px; height: 30px;margin: 10px; background: red; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='banUser(`" + data[i].userId + "`)'>BAN</div></div></li>");
                        }
                    } else {
                        $("#userList-online > li > ul").append("<li>" + data[i].userName + "<div class='btn_area' style='display: flex'><div class='log_btn' onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div></div></li>");
                    }
                } else {
                    if (data[i].userAccess == "0") {
                        $("#userList-offline > li > ul").append("<li>" + data[i].userName + "<div class='btn_area' style='display: flex'><div class='log_btn' onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div><div class='pardon_btn' style='width: 70px; height: 30px;margin: 10px; background: blue; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='pardonUser(`" + data[i].userId + "`)'>PARDON</div></div></li>");
                    } else {
                        $("#userList-offline > li > ul").append("<li>" + data[i].userName + "<div class='btn_area' style='display: flex'><div class='log_btn' onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div><div class='ban_btn' style='width: 50px; height: 30px;margin: 10px; background: red; color: white; text-align: center; line-height: 30px; cursor: pointer;' onclick='banUser(`" + data[i].userId + "`)'>BAN</div></div></li>");
                    }
                }
            }
        }

        function tellmsg(userId) {
            $("#userList").stop().fadeOut(0);
            $(".textType").val("/say to \"" + userId + "\" ")
        }

        function kickUser(userId) {

            ws.send("/kick \"" + userId + "\"");
            alert("추방 완료");


        }

        function banUser(userId) {
            let param = {
                userId: userId
            }
            $.ajax({
                url: "/ban.do",
                type: "POST",
                data: param,
                success: function () {
                    alert("차단 완료");
                    if ($('#userId').val() == userId) {
                        location.replace('/logout.do');
                    }
                },
                error: function () {
                    alert("통신 실패");
                }
            })
            ws.send("/kick \"" + userId + "\"");
        }

        function pardonUser(userId) {
            let param = {
                userId: userId
            }
            $.ajax({
                url: "/pardon.do",
                type: "POST",
                data: param,
                success: function () {
                    alert("차단 해제 완료");
                },
                error: function () {
                    alert("통신 실패");
                }
            })
        };

        function closeLog() {
            $("#showLog").remove();
        };

        function getRealPath(address) {
            $("#showLog > ul > li").remove()
            let fileReader = new FileReader();
            fileReader.readAsText(address.files[0], "utf-8");
            fileReader.onloadend = function (event) {
                for (let i = 0; i < event.target.result.split("\n").length; i++) {
                    $("#showLog > ul").append("<li>" + event.target.result.split("\n")[i] + "</li>")
                }
                console.log(event.target.result.split("\n"))
                // showLog(event.target.result.split("\n"))
            }
        }

        function BackupDo(userName, userId) {
            let data = new FormData();
            data.append("file", $("#fileBack")[0].files[0]);
            data.append("userId", userId);
            data.append("userName", userName);
            data.append("userIp", $("#userIp").val());

            $.ajax({
                url: "/backup.do",
                contentType: false,
                processData: false,
                type: "POST",
                data: data,
                success: function () {

                },
                error: function () {

                }

            })
        }


    </script>
    <style>
        #wrap {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            height: 100vh;
            position: relative;
        }

        #showBtn {
            width: 100%;
            height: 100%;
            border: none;
            outline: none;
            font-size: 48px;
            background: none;
            transition: 0.4s;
            cursor: pointer;
            padding: 0;
        }

        #showBtn:hover {
            background: black;
            color: white;
        }

        #userList {
            border: 1px solid black;
            width: 300px;
            height: 500px;
            overflow: auto;
            background: white;
            position: absolute;
            display: none;
        }

        #userList-online, #userList-offline {
            margin: 0;
            padding: 0;
        }

        #userList-online > li > ul > li, #userList-offline > li > ul > li {
            width: 100%;
            height: 70px;
            border-bottom: 1px solid #666;
            padding-top: 10px;
            text-decoration: none;
        }

        #userList-offline > li > ul {
            list-style: none;
            padding: 0;
        }

        #userList-online > li > ul {
            padding: 0;
            list-style: none;
        }

        #userList-online > li > ul > li::before {
            content: "";
            width: 10px;
            height: 10px;
            display: inline-block;
            background: lime;
            border-radius: 50%;
            margin: 0 10px;

        }

        #userList-offline > li > ul > li::before {
            content: "";
            width: 10px;
            height: 10px;
            display: inline-block;
            background: gray;
            border-radius: 50%;
            margin: 0 10px;

        }

        .log_btn {
            width: 50px;
            height: 30px;
            background: orange;
            text-align: center;
            line-height: 30px;
            color: white;
            margin: 10px;
            cursor: pointer;
        }

        .log_btn:active {
            background: orangered;
        }

        #closeBtn {
            width: 50px;
            height: 50px;
            background: red;
            color: white;
            font-size: 36px;
            font-weight: bold;
            position: absolute;
            right: 0;
            top: 0;
            text-align: center;
            line-height: 50px;
            cursor: pointer;
        }

        #closeBtn:active {
            background: darkred;
        }

        #showLog > ul {
            list-style: none;
            border: 1px solid black;
            width: 400px;
            height: 500px;
            overflow: auto;
            margin: 0 auto;
            padding: 0;
            position: absolute;
            bottom: 50px;
            left: 50%;
            transform: translate(-50%, 0);
        }

        #downloadLog {
            position: absolute;
            top: 200px;
            right: 50px;
            color: black;
            width: 80px;
            height: 30px;
            display: block;
            text-decoration: none;
            text-align: center;
            line-height: 30px;
            background: #ccc;
            border: 1px solid #666;
        }

        #downloadLog:active {
            background: #999;
        }

        .textHeader > a {
            background: red;
            color: white;
            width: 100px;
            height: 50px;
            display: block;
            text-align: center;
            line-height: 50px;
            text-decoration: none;
            float: right;
        }

    </style>
</head>
<body>
<%
    String ipAddress = request.getRemoteAddr();
    if (ipAddress.equalsIgnoreCase("0:0:0:0:0:0:0:1")) {
        InetAddress inetAddress = InetAddress.getLocalHost();
        ipAddress = inetAddress.getHostAddress();
    }
%>
<div id="wrap">
    <c:set var="now" value="<%=new java.util.Date()%>"/>
    <input type="hidden" id="chatTime" value="<fmt:formatDate value="${now}" pattern="yyyy-MM-dd kk:mm:ss" />">
    <input type="hidden" id="userId" value="${sessionScope.loginInfo.userId}">
    <input type="hidden" id="userIp" value="<%= ipAddress %>">
    <div style="width: 1000px; height: 800px; border: 2px solid black; display: flex; flex-wrap: wrap; padding: 0;">
        <div class="textHeader" style="width: 1000px; height: 50px; border-bottom: 1px solid black;">
            <a href="/logout.do" style="">나가기</a>
        </div>
        <div id="textContent"
             style="width: 950px; height: 700px; border-bottom: 1px solid black; overflow: auto; border-right: 1px solid black; box-sizing: border-box;"></div>
        <div style="width: 50px;height: 700px; border-bottom: 1px solid black; box-sizing: border-box;">
            <input type="button" id="showBtn" value="&middot;&middot;&middot;" onclick="showList();">
        </div>
        <div style="width: 900px;height: 50px; box-sizing: border-box;"><input type="text"
                                                                               style="width:900px;height:50px;font-size:16px; border: none; resize: none"
                                                                               class="textType"
                                                                               placeholder="메시지 입력..."/></div>
        <div class="submitBtn" style="width: 100px;height: 50px; box-sizing: border-box; border-left: 1px solid black;">
            <input type="button" value="전송" onclick="send()"
                   style="width: 100px; height: 50px; border: none; outline: none; cursor: pointer; background: none">
        </div>
    </div>
    <div id="userList">
        <div style="border-bottom: 1px solid black; height: 30px; line-height: 30px; font-size: 18px;">유저목록</div>
        <div style="border-bottom: 1px solid black; height: 30px; line-height: 30px; font-size: 18px;">online</div>
        <ul id="userList-online" style="list-style: none;">
            <li>
                <ul>

                </ul>
            </li>
        </ul>
        <div style="border-bottom: 1px solid black; height: 30px; line-height: 30px; font-size: 18px;">offline</div>
        <ul id="userList-offline" style="list-style: none;">
            <li>
                <ul>

                </ul>
            </li>
        </ul>
    </div>
</div>
</body>
</html>

