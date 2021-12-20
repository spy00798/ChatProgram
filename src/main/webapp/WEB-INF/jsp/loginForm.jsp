<%--
  Created by IntelliJ IDEA.
  User: spy00
  Date: 2021-10-20
  Time: 오전 10:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
</head>
<body>
<div id="wrap"
     style="margin: 0; padding: 0; width: 100vw; height: 100vh; display: flex; align-items: center; ">
    <form style="border: 1px solid black; width: 800px; height: 600px; margin:auto;">
        <h1 style="font-size: 48px; text-align: left; margin-left: 100px;">LOGIN</h1>
        <table style="width: 400px; height: 300px; margin: auto;">
            <tr style="margin: auto">
                <td style="font-size: 32px; font-weight: bold;">ID :</td>
                <td><input type="text" name="userId" id="userId" placeholder="아이디입력"
                           style="width: 300px; height: 50px; font-size: 18px; float: right;"></td>
            </tr>
            <tr>
                <td style="font-size: 32px; font-weight: bold;">PW :</td>
                <td><input type="password" name="userPwd" id="userPwd" placeholder="패스워드입력"
                           style="width: 300px; height: 50px; font-size: 18px; float: right;"></td>
            </tr>
            <tr>
                <td colspan="2"><a href="/register" style="float: right;width: 100px; height: 50px; text-align: center; line-height: 50px;">회원가입</a><input type="button" onclick="loginCheck()" value="로그인" style="float: right; width: 100px; height: 50px;"></td>
            </tr>
        </table>
    </form>
</div>
<script>
    function loginCheck() {

        let data = {
            userId : $("#userId").val(),
            userPwd : $("#userPwd").val()
        };

        console.log(data);
        $.ajax({
            url : "/login.do",
            type : "POST",
            data : data,
            success : function (data) {
                console.log(data);
                if (data == "success"){
                    location.replace("/chatting");
                } else if (data == "duplicated."){
                    alert("해당 아이디로 로그인한 세션이 이미 있습니다.");
                } else if (data == "Banned.") {
                    alert("차단된 아이디입니다.");
                } else {
                    alert("로그인 실패");
                }
            },
            error : function (){
                alert("통신실패");
            }
        })
    }
</script>
</body>
</html>
