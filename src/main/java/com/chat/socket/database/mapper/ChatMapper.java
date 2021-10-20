package com.chat.socket.database.mapper;

import com.chat.socket.database.dto.LoginDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChatMapper {

    LoginDTO findUser(LoginDTO loginDTO);
}
