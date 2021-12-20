package com.chat.socket.Service;

import com.chat.socket.Listener.SessionListener;
import com.chat.socket.database.dto.ChatDTO;
import com.chat.socket.database.dto.LoginDTO;
import com.chat.socket.database.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

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
    private final SessionListener sessionListener;

    public String ChatPage(HttpServletRequest request, LoginDTO loginDTO) {
        HttpSession session = request.getSession();
        if (session.getAttribute("loginInfo") == null) {
            return "redirect:/";
        } else {
            return "chat";
        }
    }

    public String loginForm(HttpServletRequest request) {
        HttpSession session = request.getSession();
        if (session.getAttribute("loginInfo") != null) {
            return "redirect:/chat";
        }
        return "loginForm";
    }

    public String loginAction(HttpServletRequest request, LoginDTO loginDTO) {
        HttpSession session = request.getSession();
        System.out.println("-----Login Check-----");
        System.out.println(loginDTO.getUserId());
        System.out.println(loginDTO.getUserPwd());
        System.out.println("---------------------");
        chatMapper.findUser(loginDTO);
        LoginDTO login = chatMapper.findUser(loginDTO);


        if (chatMapper.findUser(loginDTO).getUserId() == null) {
            System.out.println("---Login Failed---");
            return "redirect:/";
        } else {
            boolean duplicateChk = sessionListener.DuplicateCheck(login.getUserId());
            System.out.println("DuplicateResult : " + duplicateChk);
            if (duplicateChk == true) {
                return "duplicated.";
            } else if (chatMapper.findUser(loginDTO).getUserAccess() == 0) {
                System.out.println("This user was banned. : " + loginDTO.getUserId());
                    return "Banned.";
            }
            else {
                session.setAttribute("loginInfo", login);
                System.out.println("-------login Success-------");
                System.out.println(session.getId());
                return "success";
            }

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


    public void banUser(LoginDTO loginDTO) {
        chatMapper.userBan(loginDTO);
    }

    public void pardonUser(LoginDTO loginDTO) {
        chatMapper.userPardon(loginDTO);
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
            return "";
    }

    public void backupLog(MultipartFile filePath, ChatDTO chatDTO) {

            try {

            File file = new File(filePath.getOriginalFilename());
            file.createNewFile();

            OutputStream bout = new FileOutputStream(file);
            bout.write(filePath.getBytes());
            String line;
            BufferedReader br = new BufferedReader(new InputStreamReader(filePath.getInputStream(), "UTF-8"));
            while((line = br.readLine()) != null) {
                System.out.println(line);
                int nameidx = line.indexOf(" : ");
                System.out.println(nameidx);
                chatDTO.setRegTime(line.substring(1, 20));
                chatDTO.setChatContent(line.substring(nameidx + 3, line.length()));
                chatMapper.createLog(chatDTO);
            }

            bout.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

    }

}
