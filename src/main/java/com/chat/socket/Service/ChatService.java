package com.chat.socket.Service;

import org.springframework.stereotype.Service;

@Service
public class ChatService {

    public String TestPage() {
        return "index";
    }

    public String ChatPage() {
        return "chat";
    }

}
