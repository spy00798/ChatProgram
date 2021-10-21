package com.chat.socket.Service;

import com.chat.socket.database.dto.ChatDTO;
import com.chat.socket.database.dto.LoginDTO;
import com.chat.socket.database.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMapper chatMapper;

    public String ChatPage(HttpServletRequest request, LoginDTO loginDTO) {
            HttpSession session = request.getSession();
        if (session.getAttribute("loginInfo") == null) {
            return "redirect:/";
        } else {
            return "chat";
        }
    }

    public String loginForm() {
        return "loginForm";
    }

    public String loginAction(HttpServletRequest request, LoginDTO loginDTO) {
        HttpSession session = request.getSession();
        System.out.println(loginDTO.getUserId());
        System.out.println(loginDTO.getUserPwd());
        chatMapper.findUser(loginDTO);
        LoginDTO login = chatMapper.findUser(loginDTO);



        if (chatMapper.findUser(loginDTO).getUserId() != null) {
                session.setAttribute("loginInfo", login);
                System.out.println("-------login Success-------");

                return "success";
        } else {
            session.setAttribute("loginInfo", null);
            System.out.println("---Login Failed---");

            return "redirect:/";
        }
    }

    public List<LoginDTO> userStatus() {
        List<LoginDTO> data = chatMapper.findStatus();

        return data;
    }

    public void createLog(ChatDTO chatDTO) {
        chatMapper.createLog(chatDTO);

    }

}
