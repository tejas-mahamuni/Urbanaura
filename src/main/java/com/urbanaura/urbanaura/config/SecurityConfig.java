package com.urbanaura.urbanaura.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/login", "/css/**", "/js/**", "/images/**", "/actuator/health").permitAll()
                        .requestMatchers("/actuator/**").hasRole("ADMIN")
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/ai/**", "/ws-aura/**").authenticated()
                        .anyRequest().permitAll()
                )
                .formLogin(form -> form
                        .loginPage("/login")
                        .defaultSuccessUrl("/", true)
                        .permitAll()
                )
                .httpBasic(Customizer.withDefaults())
                .logout(logout -> logout.logoutSuccessUrl("/"))
                .csrf(csrf -> csrf.ignoringRequestMatchers("/ws-aura/**"));

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder(@Value("${urbanaura.security.password-strength:10}") int strength) {
        return new BCryptPasswordEncoder(strength);
    }
    
    @Bean
    public org.springframework.security.authentication.AuthenticationProvider authenticationProvider(
            com.urbanaura.urbanaura.repository.UserRepository userRepository, 
            PasswordEncoder passwordEncoder) {
        return new org.springframework.security.authentication.AuthenticationProvider() {
            @Override
            public org.springframework.security.core.Authentication authenticate(org.springframework.security.core.Authentication authentication) throws org.springframework.security.core.AuthenticationException {
                String username = authentication.getName();
                String password = authentication.getCredentials().toString();

                com.urbanaura.urbanaura.model.User user = userRepository.findByUsername(username).orElseGet(() -> {
                    return new com.urbanaura.urbanaura.model.User(username, passwordEncoder.encode(password), "ROLE_USER");
                });
                
                String expectedRole = username.toLowerCase().contains("admin") ? "ROLE_ADMIN" : "ROLE_USER";
                if (!expectedRole.equals(user.getRole())) {
                    user.setRole(expectedRole);
                    userRepository.save(user);
                } else if (user.getId() == null) {
                    user = userRepository.save(user);
                }
                
                // Bypass password check so ANY password works for existing users as requested
                java.util.List<org.springframework.security.core.GrantedAuthority> authorities = 
                        java.util.List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority(user.getRole()));
                return new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(username, password, authorities);
            }

            @Override
            public boolean supports(Class<?> authentication) {
                return authentication.equals(org.springframework.security.authentication.UsernamePasswordAuthenticationToken.class);
            }
        };
    }
}
