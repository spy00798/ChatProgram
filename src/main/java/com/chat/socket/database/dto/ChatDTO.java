package com.chat.socket.database.dto;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ChatDTO {

    private int idx;
    private String userId;
    private String userName;
    private String userIp;
    private String chatContent;
    private String regTime;
    private String whisperId;
}
