package com.chat.socket.Controller;

import com.chat.socket.Service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @RequestMapping(value = "/test")
    public String TestPage() {
        return chatService.TestPage();
    }

    @RequestMapping(value = "/")
    public String ChatPage() {
        return chatService.ChatPage();
    }
}
