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

        function wsOpen(){
            ws = new WebSocket("ws://"+ location.host +"/chat");
            wsEvt();
        }
        wsOpen();
        console.log(ws)

        function wsEvt() {
            ws.onopen = function (data) {

            }
            ws.onmessage = function (data) {
                var message = data.data;
                if (message != null || message.trim() != '') {
                    $(".textContent").append("<pre>" + message + "</pre>");
                }
            }

            document.addEventListener('keypress', function(e) {
                if(e.keyCode == 13) {
                    send();
                }
            })
        }

        function send() {
            var userName = `${sessionScope.loginInfo.userName}`
            var message = userName + " : " + "\n" + $(".textType").val();
            message = message.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace('\n', "<br>");
            if($('.textType').val() == "") {
                message = '';
            }
            let logData = {
                userId : `${sessionScope.loginInfo.userId}`,
                userName : `${sessionScope.loginInfo.userName}`,
                userIp : $("#userIp").val(),
                chatContent : $(".textType").val(),
                regTime : $("#chatTime").val()
            };
            ws.send(message);
            $.ajax({
                url : "logAjax",
                type : "POST",
                data : logData,
                success : function (data) {

                },
                error : function () {

                }
            });
            $(".textType").val("");


        };

        $(document).ready(function () {
            function showUser() {
                $.ajax({
                    url : "/listAjax",
                    type : "GET",
                    data : null,
                    success : function (data) {

                            console.log(data);
                            for (var i = 0; i < data.length; i++) {
                            if (data[i].userStatus == 1) {
                                $("#userList-online").append("<li>" + data[i].userName + "<li>");
                            } else {
                                $("#userList-offline").append("<li>" + data[i].userName + "<li>");
                            }
                        }
                    },
                    error : function () {
                        alert("통신실패");
                    }
                });
            };
            setTimeout(showUser, 100);
        });
    </script>
</head>
<body>
<%
    String ipAddress=request.getRemoteAddr();
    if(ipAddress.equalsIgnoreCase("0:0:0:0:0:0:0:1")){
        InetAddress inetAddress=InetAddress.getLocalHost();
        ipAddress=inetAddress.getHostAddress();
    }
%>
    <div id="wrap" style="display: flex; align-items: center; justify-content: center; height: 100vh;">
        <c:set var="now" value="<%=new java.util.Date()%>" />
        <input type="hidden" id="chatTime" value="<fmt:formatDate value="${now}" pattern="yyyy-MM-dd kk:mm:ss" />">
        <input type="hidden" id="userIp" value="<%= ipAddress %>">
        <div style="width: 1200px; height: 800px; border: 2px solid black; display: flex; flex-wrap: wrap; padding: 0;">
            <div class="textContent" style="width: 1050px; height: 700px; border-bottom: 1px solid black; overflow: auto; border-right: 1px solid black; box-sizing: border-box;"></div>
            <div style="width: 150px;height: 700px; border-bottom: 1px solid black; box-sizing: border-box;">
                <ul id="userList-online" style="list-style: none;">

                </ul>
                <ul id="userList-offline" style="list-style: none;">

                </ul>
            </div>
            <div style="width: 1050px;height: 100px; box-sizing: border-box;"><input class="textType" type="text" style="width:1050px;height:100px;font-size:16px; border: none;" placeholder="메시지 입력..."></div>
            <div class="submitBtn" style="width: 150px;height: 100px; box-sizing: border-box; border-left: 1px solid black;"><input type="button" value="전송" onclick="send()" style="width: 150px; height: 100px; border: none; outline: none; cursor: pointer; background: none"></div>
        </div>
    </div>
</body>
</html>
