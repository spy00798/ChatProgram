package com.chat.socket.Controller;

import com.chat.socket.Service.ChatService;
import com.chat.socket.database.dto.LoginDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;

@Controller
@RequestMapping(value = "")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @RequestMapping(value = "/test")
    public String TestPage() {
        return chatService.TestPage();
    }

    @RequestMapping(value = "/chatting")
    public String ChatPage() {
        return chatService.ChatPage();
    }

    @RequestMapping(value = "/")
    public String loginForm() {
        return chatService.loginForm();
    }

    @ResponseBody
    @RequestMapping(value = "/login.do", method = RequestMethod.POST)
    public String loginAction(HttpServletRequest request, LoginDTO loginDTO) {
        return chatService.loginAction(request, loginDTO);
    }
}
