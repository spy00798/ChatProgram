package com.chat.socket.database.dto;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class LoginDTO {
        private String userId;
        private String userPwd;
        private String userName;
        private int userStatus;
        private int userAccess;

}
