package com.chat.socket.Controller;

import com.chat.socket.Service.ChatService;
import com.chat.socket.database.dto.ChatDTO;
import com.chat.socket.database.dto.LoginDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping(value = "")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @RequestMapping(value = "/chatting")
    public String ChatPage(HttpServletRequest request, LoginDTO loginDTO) {
        return chatService.ChatPage(request, loginDTO);
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

    @RequestMapping(value = "logout.do")
    public String logoutAction(HttpServletRequest request) {
        return chatService.logoutAction(request);
    }

    @ResponseBody
    @RequestMapping(value = "/listAjax")
    public List<LoginDTO> userStatus() {
        return chatService.userStatus();
    }

    @ResponseBody
    @RequestMapping(value = "/logAjax")
    public void createLog(ChatDTO chatDTO) {
        chatService.createLog(chatDTO);
    }

    @ResponseBody
    @RequestMapping(value = "/showAjax")
    public List<ChatDTO> showLog(ChatDTO chatDTO) {

        return chatService.showLog(chatDTO);
    }

    @ResponseBody
    @RequestMapping(value = "/download.do")
    public void downloadLog(HttpServletResponse response, ChatDTO chatDTO) {
        chatService.downloadLog(response, chatDTO);
    }
}
