package com.urbanaura.urbanaura.repository;

import com.urbanaura.urbanaura.model.Message;
import com.urbanaura.urbanaura.model.Property;
import com.urbanaura.urbanaura.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("SELECT m FROM Message m WHERE (m.sender = :user1 AND m.receiver = :user2 AND m.property = :property) OR (m.sender = :user2 AND m.receiver = :user1 AND m.property = :property) ORDER BY m.timestamp ASC")
    List<Message> findConversation(@Param("user1") User user1, @Param("user2") User user2, @Param("property") Property property);

    @Query("SELECT m FROM Message m WHERE m.sender = :user OR m.receiver = :user ORDER BY m.timestamp DESC")
    List<Message> findAllUserConversations(@Param("user") User user);
    
    @Modifying
    @Query("UPDATE Message m SET m.isRead = true WHERE m.sender = :sender AND m.receiver = :receiver AND m.property = :property AND m.isRead = false")
    void markMessagesAsRead(@Param("sender") User sender, @Param("receiver") User receiver, @Param("property") Property property);
    
    @Query("SELECT COUNT(m) FROM Message m WHERE m.receiver = :user AND m.isRead = false")
    long countUnreadMessages(@Param("user") User user);
}
