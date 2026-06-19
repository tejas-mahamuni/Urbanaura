package com.urbanaura.urbanaura.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdminChatController {

    @GetMapping("/admin/messages")
    @PreAuthorize("hasRole('ADMIN')")
    public String adminMessages(Model model) {
        // You could populate initial chat histories here, or load them via REST API
        return "admin-messages";
    }
}
