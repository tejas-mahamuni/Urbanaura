package com.urbanaura.urbanaura.service;

import com.urbanaura.urbanaura.document.AiAssistantHistory;
import com.urbanaura.urbanaura.document.AqiLog;
import com.urbanaura.urbanaura.model.Locality;
import com.urbanaura.urbanaura.model.Property;
import com.urbanaura.urbanaura.repository.AqiLogRepository;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.SystemPromptTemplate;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class AiConsultantService {

    @Autowired
    private ChatModel chatModel;

    @Autowired
    private PropertySearchService propertySearchService;
    
    @Autowired
    private AqiLogRepository aqiLogRepository;

    @Autowired
    private MongoTemplate mongoTemplate; // For tracking history

    public String generateConsultation(String query, boolean isAdmin) {
        
        // --- STEP 1 & 2: RETRIEVAL ---
        List<Property> allProperties = propertySearchService.findAllProperties();
        List<Property> relevantProperties = selectRelevantProperties(query, allProperties);
        
        // Assemble a clean text representation of the database state to feed into the prompt
        String dbContext = relevantProperties.stream().map(p -> {
            Locality loc = p.getLocality();
            String locName = loc != null ? loc.getName() : "Unknown";
            Double latestAqi = null;
            if (locName != null) {
                List<AqiLog> logs = aqiLogRepository.findByLocalityOrderByTimestampDesc(locName);
                if (!logs.isEmpty()) latestAqi = logs.get(0).getAqiValue();
            }
            
            Integer safety = p.getSmartMetric() != null ? p.getSmartMetric().getSafetyRating() : 0;
            Integer parkDist = p.getSmartMetric() != null ? p.getSmartMetric().getDistToParkM() : 0;
            Integer metroDist = p.getSmartMetric() != null ? p.getSmartMetric().getDistToMetroM() : 0;
            
            return String.format("Title: %s | Price: %.2f | Locality: %s | Latest AQI: %s | Safety Rating (1-10): %d | Park Distance: %dm | Metro Distance: %dm",
                    p.getTitle(), p.getPrice(), locName, latestAqi, safety, parkDist, metroDist);
        }).collect(Collectors.joining("\n"));

        String systemText = "You are the UrbanAura Consultant. Answer the user's query using ONLY the provided DATABASE CONTEXT.\n" +
                "IMPORTANT FORMATTING RULES:\n" +
                "1. Make it cleanly spaced and highly scannable.\n" +
                "2. Use clear section breaks with empty lines.\n" +
                "3. Use emojis to guide the eye at the start of sections, do NOT clutter with symbols.\n" +
                "4. One main idea per line.\n" +
                "5. VERY IMPORTANT: Bold the key metrics (like property **Names**, **Prices**, and **Safety Ratings**) using markdown **asterisks**.\n" +
                "6. NEVER guess properties not in the context.\n" +
                "7. STRICT CONFINEMENT: If the user's query cannot be answered using ONLY the provided DATABASE CONTEXT, you MUST refuse to answer and politely state: 'I can only provide insights based on the UrbanAura property database. I do not have information to answer that.' Do not use outside general knowledge.\n\n" +
                "EXACT DESIRED ANSWER FORMAT:\n" +
                "🏠 Best Options in **[Locality]**\n\n" +
                "💰 Price Comparison\n" +
                "• **[Property 1]**: Rs. **[Price]** Cr\n" +
                "• **[Property 2]**: Rs. **[Price]** Cr\n\n" +
                "🔒 Safety Ratings\n" +
                "• **[Property 1]**: **[Rating]**/10\n" +
                "• **[Property 2]**: **[Rating]**/10\n\n" +
                "⭐ Top Recommendation\n" +
                "[Brief insight why one property is best based on context]\n\n" +
                "🚀 Next Step\n" +
                "Visit the property or compare it in the studio.\n\n" +
                "DATABASE CONTEXT:\n{context}\n\n" +
                "ADMIN INSTRUCTION:\n{adminInstruction}";

        String adminInstruction = isAdmin 
                ? "You may include operational context such as audit readiness, reporting, and observability when the user asks for system details."
                : "Do not reveal administrative or audit-only context.";

        SystemPromptTemplate systemTemplate = new SystemPromptTemplate(systemText);
        Message systemMessage = systemTemplate.createMessage(Map.of(
            "context", dbContext,
            "adminInstruction", adminInstruction
        ));

        // --- STEP 4: GENERATION ---
        UserMessage userMessage = new UserMessage(query);
        Prompt prompt = new Prompt(List.of(systemMessage, userMessage));

        try {
            String response = chatModel.call(prompt).getResult().getOutput().getText();
            
            // Persist Assistant History to MongoDB
            AiAssistantHistory history = new AiAssistantHistory(isAdmin ? 999L : 1L, query, response);
            mongoTemplate.save(history, "ai_assistant_history");
            
            return response;
        } catch (Exception e) {
            e.printStackTrace();
            return "UrbanAura AI Connection Error: " + e.getMessage() + "\n\n(Remember that your GROQ_API_KEY must be exported in your current active terminal session before running Maven!)";
        }
    }

    private List<Property> selectRelevantProperties(String query, List<Property> allProperties) {
        String normalizedQuery = query == null ? "" : query.toLowerCase(Locale.ROOT)
            .replace("hinjewadi", "hinjawadi")
            .replace("bener", "baner")
            .replace("vimanagar", "viman nagar")
            .replace("kalyaninagar", "kalyani nagar")
            .replace("koregaon", "koregaon park");
            
        Set<String> queryTokens = Arrays.stream(normalizedQuery.split("[^a-z0-9]+"))
                .filter(token -> !token.isBlank())
                .collect(Collectors.toCollection(LinkedHashSet::new));

        return allProperties.stream()
                .sorted(Comparator
                        .comparingInt((Property property) -> scorePropertyMatch(property, normalizedQuery, queryTokens))
                        .reversed()
                        .thenComparing(property -> property.getSmartMetric() != null && property.getSmartMetric().getSmartScore() != null
                                ? property.getSmartMetric().getSmartScore() : 0.0, Comparator.reverseOrder()))
                .limit(8)
                .collect(Collectors.toList());
    }

    private int scorePropertyMatch(Property property, String normalizedQuery, Set<String> queryTokens) {
        int score = 0;
        String title = property.getTitle() != null ? property.getTitle().toLowerCase(Locale.ROOT) : "";
        String address = property.getAddress() != null ? property.getAddress().toLowerCase(Locale.ROOT) : "";
        String localityName = property.getLocality() != null && property.getLocality().getName() != null
                ? property.getLocality().getName().toLowerCase(Locale.ROOT) : "";

        if (!normalizedQuery.isBlank()) {
            if (!title.isBlank() && normalizedQuery.contains(title)) {
                score += 6;
            }
            if (!localityName.isBlank() && normalizedQuery.contains(localityName)) {
                score += 5;
            }
        }

        for (String token : queryTokens) {
            if (title.contains(token)) {
                score += 3;
            }
            if (localityName.contains(token)) {
                score += 2;
            }
            if (address.contains(token)) {
                score += 1;
            }
        }

        return score;
    }
}
