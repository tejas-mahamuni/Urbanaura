package com.urbanaura.urbanaura.service;

import com.urbanaura.urbanaura.dto.ChatMessageDto;
import com.urbanaura.urbanaura.model.Message;
import com.urbanaura.urbanaura.model.Property;
import com.urbanaura.urbanaura.model.User;
import com.urbanaura.urbanaura.repository.MessageRepository;
import com.urbanaura.urbanaura.repository.PropertyRepository;
import com.urbanaura.urbanaura.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final PropertyRepository propertyRepository;

    public MessageService(MessageRepository messageRepository, UserRepository userRepository, PropertyRepository propertyRepository) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
        this.propertyRepository = propertyRepository;
    }

    @Transactional
    public ChatMessageDto saveMessage(ChatMessageDto dto) {
        User sender = userRepository.findById(dto.getSenderId())
                .orElseThrow(() -> new IllegalArgumentException("Invalid sender"));
        User receiver = userRepository.findById(dto.getReceiverId())
                .orElseThrow(() -> new IllegalArgumentException("Invalid receiver"));
        Property property = propertyRepository.findById(dto.getPropertyId())
                .orElseThrow(() -> new IllegalArgumentException("Invalid property"));

        Message message = new Message(sender, receiver, property, dto.getContent(), LocalDateTime.now(), false);
        Message savedMessage = messageRepository.save(message);

        return convertToDto(savedMessage);
    }

    @Transactional(readOnly = true)
    public List<ChatMessageDto> getConversation(Long user1Id, Long user2Id, Long propertyId) {
        User user1 = userRepository.findById(user1Id).orElseThrow();
        User user2 = userRepository.findById(user2Id).orElseThrow();
        Property property = propertyRepository.findById(propertyId).orElseThrow();

        return messageRepository.findConversation(user1, user2, property)
                .stream().map(this::convertToDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ChatMessageDto> getRecentConversations(User user) {
        return messageRepository.findAllUserConversations(user)
                .stream().map(this::convertToDto).collect(Collectors.toList());
    }

    @Transactional
    public void markAsRead(Long senderId, Long receiverId, Long propertyId) {
        User sender = userRepository.findById(senderId).orElseThrow();
        User receiver = userRepository.findById(receiverId).orElseThrow();
        Property property = propertyRepository.findById(propertyId).orElseThrow();
        messageRepository.markMessagesAsRead(sender, receiver, property);
    }

    private ChatMessageDto convertToDto(Message message) {
        ChatMessageDto dto = new ChatMessageDto();
        dto.setId(message.getId());
        dto.setSenderId(message.getSender().getId());
        dto.setReceiverId(message.getReceiver().getId());
        dto.setPropertyId(message.getProperty().getId());
        dto.setContent(message.getContent());
        dto.setTimestamp(message.getTimestamp());
        dto.setRead(message.isRead());
        dto.setSenderName(message.getSender().getUsername());
        dto.setPropertyTitle(message.getProperty().getTitle());
        return dto;
    }
}
