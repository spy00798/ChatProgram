package com.chat.socket.database.mapper;

import com.chat.socket.database.dto.ChatDTO;
import com.chat.socket.database.dto.LoginDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ChatMapper {

    LoginDTO findUser(LoginDTO loginDTO);
    List<ChatDTO> findLog(ChatDTO chatDTO);
    List<LoginDTO> findStatus();
    void createLog(ChatDTO chatDTO);
    void updateConnect(LoginDTO loginDTO);
    void updateDisconnect(LoginDTO loginDTO);
    void userBan(LoginDTO loginDTO);
    void userPardon(LoginDTO loginDTO);
}
