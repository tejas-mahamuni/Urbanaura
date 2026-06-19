package com.urbanaura.urbanaura.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker // This unlocks the SimpMessagingTemplate bean
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final StompSecurityChannelInterceptor stompSecurityChannelInterceptor;

    public WebSocketConfig(StompSecurityChannelInterceptor stompSecurityChannelInterceptor) {
        this.stompSecurityChannelInterceptor = stompSecurityChannelInterceptor;
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // This creates the "Topic" where AQI pulses will be broadcasted, and "queue" for private messaging
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // This is the endpoint for your Leaflet.js map to connect to
        // We'll use /ws-aura to keep the "UrbanAura" branding
        registry.addEndpoint("/ws-aura")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(stompSecurityChannelInterceptor);
    }
}
