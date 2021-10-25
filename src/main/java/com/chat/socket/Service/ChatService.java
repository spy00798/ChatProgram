package com.chat.socket.Service;

import com.chat.socket.database.dto.ChatDTO;
import com.chat.socket.database.dto.LoginDTO;
import com.chat.socket.database.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;
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


        if (chatMapper.findUser(loginDTO).getUserId() == null) {
            session.setAttribute("loginInfo", null);
            System.out.println("---Login Failed---");

            return "redirect:/";
        } else {
            session.setAttribute("loginInfo", login);
            System.out.println("-------login Success-------");

            return "success";
        }
    }

    public String logoutAction(HttpServletRequest request) {
        HttpSession session = request.getSession();
        if (session.getAttribute("loginInfo") == null) {
            return "redirect:/";
        }
        session.invalidate();
        System.out.println("------logout complete------");
        return "redirect:/";
    }

    public List<LoginDTO> userStatus() {
        List<LoginDTO> data = chatMapper.findStatus();

        return data;
    }

    public void createLog(ChatDTO chatDTO) {
        chatMapper.createLog(chatDTO);

    }

    public List<ChatDTO> showLog(ChatDTO chatDTO) {
        List<ChatDTO> data = chatMapper.findLog(chatDTO);

        return data;
    }

    public String downloadLog(HttpServletResponse response, ChatDTO chatDTO) {

        System.out.println(chatDTO.getUserId());

            SimpleDateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");

            Date now = new Date();
//            System.out.println(System.getProperty("user.home"));

            String today = format.format(now);

            String fileName = chatDTO.getUserId() + "_" + today + ".txt";

        try {


            System.out.println(fileName);

            File file = new File(fileName);
            FileWriter fileWriter = new FileWriter(file, true);


            for (ChatDTO log : chatMapper.findLog(chatDTO)) {
                String logText = "[" + log.getRegTime() + "]" + log.getUserName() + " : " + log.getChatContent() + "\n";
                logText = logText.replaceAll("<", "&lt;").replaceAll(">", "&gt;");
                fileWriter.write(logText);
            }

            fileWriter.close();
            OutputStream bout = response.getOutputStream();

            FileInputStream fis = new FileInputStream(file);

            int length;
            byte[] buffer = new byte[1024];
            while((length = fis.read(buffer)) != -1){
                bout.write(buffer,0,length);
                bout.flush();
            }



        } catch (Exception e) {
            e.printStackTrace();
        }
            return fileName;
    }

}
