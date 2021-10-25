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
                var message = data.data;
                if (message.trim() != null && message.trim() != '') {
                    $(".textContent").append("<pre>" + message + "</pre>");
                }
            }

            document.addEventListener('keypress', function (e) {
                if (e.keyCode == 13) {
                    send();
                }
            })
        }

        function send() {
            var userName = `${sessionScope.loginInfo.userName}`
            var message = userName + " : " + "\n" + $(".textType").val();
            message = message.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace('\n', "<br>");
            if ($('.textType').val().trim() == "") {
                message = '';
            }
            let logData = {
                userId: `${sessionScope.loginInfo.userId}`,
                userName: `${sessionScope.loginInfo.userName}`,
                userIp: $("#userIp").val(),
                chatContent: $(".textType").val(),
                regTime: $("#chatTime").val()
            };
            ws.send(message);
            $.ajax({
                url: "/logAjax",
                type: "POST",
                data: logData,
                success: function (data) {

                },
                error: function () {

                }
            });
            $(".textType").val("");


        };

        $(document).ready(function () {
            function showUser() {
                $.ajax({
                    url: "/listAjax",
                    type: "GET",
                    data: null,
                    success: function (data) {

                        console.log(data);
                        for (var i = 0; i < data.length; i++) {
                            // if (data[i].userStatus == 1) {
                            $("#userList-online").append("<li>" + data[i].userName + "<div onclick='showLog(`" + data[i].userId + "`,`" + data[i].userName + "`);'>log</div></li>");
                            // } else {
                            //     $("#userList-offline").append("<li>" + data[i].userName + "</li>");
                            // }
                        }
                    },
                    error: function () {
                        alert("통신실패");
                    }
                });
            };
            setTimeout(showUser, 100);
        });

        function showList() {
            $("#userList").stop().fadeToggle(500);
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
                    for (var i = 0; i < data.length; i++) {
                        $("#showLog > ul").append("<li>[" + data[i].regTime + "]" + data[i].userName + "(" + data[i].userId + ")" + " : " + data[i].chatContent.replaceAll(/</g, "&lt;").replaceAll(/>/g, "&gt;") + "</li>");
                    }
                    if (data.length == 0) {
                        $("#showLog > ul").append("<li style='font-size: 18px; text-align: center;'>------[채팅이력이 없습니다.]------</li>");
                    }
                    $("#showLog").append("<a href='/download.do?userId="+ userId +"' id='downloadLog' download='"+ userId +".txt' >다운로드</a>")
                },
                error: function () {
                    alert("통신실패");
                }
            });
        };

        function closeLog() {
            $("#showLog").remove();
        };


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

        #userList-online {
            margin: 0;
            padding: 0;
        }

        #userList-online > li {
            width: 100%;
            height: 70px;
            border-bottom: 1px solid #666;
        }

        #userList-online > li > div {
            width: 50px;
            height: 30px;
            background: orange;
            text-align: center;
            line-height: 30px;
            color: white;
            margin: 10px;
            cursor: pointer;
        }

        #userList-online > li > div:active {
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
            <a href="logout.do" style="">나가기</a>
        </div>
        <div class="textContent"
             style="width: 950px; height: 700px; border-bottom: 1px solid black; overflow: auto; border-right: 1px solid black; box-sizing: border-box;"></div>
        <div style="width: 50px;height: 700px; border-bottom: 1px solid black; box-sizing: border-box;">
            <input type="button" id="showBtn" value="&middot;&middot;&middot;" onclick="showList();">
        </div>
        <div style="width: 900px;height: 50px; box-sizing: border-box;"><input class="textType" type="text"
                                                                               style="width:900px;height:50px;font-size:16px; border: none;"
                                                                               placeholder="메시지 입력..."></div>
        <div class="submitBtn" style="width: 100px;height: 50px; box-sizing: border-box; border-left: 1px solid black;">
            <input type="button" value="전송" onclick="send()"
                   style="width: 100px; height: 50px; border: none; outline: none; cursor: pointer; background: none">
        </div>
    </div>
    <div id="userList">
        <div style="border-bottom: 1px solid black;">유저목록</div>
        <ul id="userList-online" style="list-style: none;"></ul>
        <%--                    <ul id="userList-offline">--%>

        <%--                    </ul>       --%>
    </div>
</div>
</body>
</html>
