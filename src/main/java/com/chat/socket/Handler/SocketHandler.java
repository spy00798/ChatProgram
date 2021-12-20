package com.chat.socket.Handler;

import com.chat.socket.Service.ChatService;
import com.chat.socket.database.dto.LoginDTO;
import com.chat.socket.database.mapper.ChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class SocketHandler extends TextWebSocketHandler {

    Map<WebSocketSession, String> userSessions = new HashMap<>();
    Map<WebSocketSession, String> SenderName = new HashMap<>();

    private final ChatMapper chatMapper;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {

        super.afterConnectionEstablished(session);
        Map<String, Object> loginSession = session.getAttributes();
        LoginDTO loginDTO = (LoginDTO) loginSession.get("loginInfo");

        userSessions.put(session, loginDTO.getUserId());
        SenderName.put(session, loginDTO.getUserName());
        loginDTO.setUserId(userSessions.get(session));
        System.out.println("=======OPEN=======");
        System.out.println(loginDTO.getUserId());
        chatMapper.updateConnect(loginDTO);




    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        for (WebSocketSession sess : userSessions.keySet()) {
                String messageContent = message.getPayload().substring(message.getPayload().indexOf(": ") + 1, message.getPayload().length()).trim();
                String ChatSender = message.getPayload().substring(0, message.getPayload().indexOf(" : ") + 1);
            if (messageContent.startsWith("/say to")) {
                int receiverStart = messageContent.indexOf(" \"", 0) + 2;
                int receiverEnd = messageContent.indexOf("\" ", 0);
                String sendContent = messageContent.substring(receiverEnd + 2, messageContent.length());
                String receiverId = messageContent.substring(receiverStart, receiverEnd);
                String senderId = userSessions.get(session);
                if (receiverId.equals(userSessions.get(sess))) {
                    sess.sendMessage(new TextMessage("FROM \"" + senderId + "\" : " + sendContent));
                }
                else if (ChatSender.trim().equals(SenderName.get(sess).trim())) {
                    sess.sendMessage(new TextMessage("TO \"" + receiverId + "\" : " + sendContent));
                }
            }else if (messageContent.startsWith("/kick")) {
                int receiverStart = messageContent.indexOf(" \"", 0) + 2;
                String receiverId = messageContent.substring(receiverStart, messageContent.length()-1);
                System.out.println(receiverId);
                if (receiverId.equals(userSessions.get(sess))) {
                    sess.sendMessage(new TextMessage("<script>location.replace('/logout.do')</script>"));
                }
            } else {
                sess.sendMessage(new TextMessage(message.getPayload()));
            }
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {

        LoginDTO loginDTO = new LoginDTO();
        loginDTO.setUserId(userSessions.get(session));
        System.out.println("=======CLOSE=======");
        System.out.println(loginDTO.getUserId());
        chatMapper.updateDisconnect(loginDTO);
        userSessions.remove(session);
        SenderName.remove(session);


    }
}