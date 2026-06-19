package com.urbanaura.urbanaura.controller;

import com.urbanaura.urbanaura.dto.ChatMessageDto;
import com.urbanaura.urbanaura.model.User;
import com.urbanaura.urbanaura.repository.UserRepository;
import com.urbanaura.urbanaura.service.MessageService;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.security.Principal;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class PrivateChatController {

    private final SimpMessagingTemplate messagingTemplate;
    private final MessageService messageService;
    private final UserRepository userRepository;

    public PrivateChatController(SimpMessagingTemplate messagingTemplate, MessageService messageService, UserRepository userRepository) {
        this.messagingTemplate = messagingTemplate;
        this.messageService = messageService;
        this.userRepository = userRepository;
    }

    @MessageMapping("/chat.private")
    public void processMessage(@Payload ChatMessageDto chatMessageDto, SimpMessageHeaderAccessor headerAccessor) {
        Principal principal = headerAccessor.getUser();
        if (principal == null) {
            throw new IllegalArgumentException("User must be authenticated to send messages");
        }

        // Identify sender from Principal
        User sender = userRepository.findByUsername(principal.getName())
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        chatMessageDto.setSenderId(sender.getId());

        // Dynamic Receiver Lookup: If sender is NOT admin, route to admin. If sender IS admin, use provided receiverId.
        User receiver;
        if (sender.getRole().equals("ROLE_ADMIN")) {
            receiver = userRepository.findById(chatMessageDto.getReceiverId())
                    .orElseThrow(() -> new IllegalArgumentException("Receiver user not found"));
        } else {
            receiver = userRepository.findByUsername("admin")
                    .orElseThrow(() -> new IllegalArgumentException("Admin user not found"));
            chatMessageDto.setReceiverId(receiver.getId());
        }

        // Save the message
        ChatMessageDto savedMsg = messageService.saveMessage(chatMessageDto);

        // Send to intended recipient via /user/{receiverId}/queue/messages
        messagingTemplate.convertAndSendToUser(
                receiver.getUsername(), // Spring Security uses Principal name (username) for @SendToUser!
                "/queue/messages", 
                savedMsg
        );
        
        // Also send back to sender for optimistic UI update confirmation
        messagingTemplate.convertAndSendToUser(
                sender.getUsername(), 
                "/queue/messages", 
                savedMsg
        );
    }

    @GetMapping("/api/messages/history")
    public ResponseEntity<List<ChatMessageDto>> getHistory(
            @RequestParam Long userId,
            @RequestParam Long propertyId,
            Principal principal) {
        if (principal == null) return ResponseEntity.ok(Collections.emptyList());
        User currentUser = userRepository.findByUsername(principal.getName())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // Mark any messages sent from 'userId' to 'currentUser' for this property as read
        messageService.markAsRead(userId, currentUser.getId(), propertyId);

        return ResponseEntity.ok(messageService.getConversation(currentUser.getId(), userId, propertyId));
    }

    @GetMapping("/api/messages/recent")
    public List<ChatMessageDto> getRecentConversations(Principal principal) {
        User currentUser = userRepository.findByUsername(principal.getName()).orElseThrow();
        // Return raw list and let frontend group by sender and property
        return messageService.getRecentConversations(currentUser);
    }
}
