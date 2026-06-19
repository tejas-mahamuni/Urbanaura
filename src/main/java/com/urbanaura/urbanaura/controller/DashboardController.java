package com.urbanaura.urbanaura.controller;

import com.urbanaura.urbanaura.document.AqiLog;
import com.urbanaura.urbanaura.dto.TopSmartPropertyDto;
import com.urbanaura.urbanaura.model.Property;
import com.urbanaura.urbanaura.repository.AqiLogRepository;
import com.urbanaura.urbanaura.repository.LocalityRepository;
import com.urbanaura.urbanaura.service.PropertySearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.urbanaura.urbanaura.service.DataLoaderService;
import com.urbanaura.urbanaura.service.DataBackfillService;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class DashboardController {

    private static final double GREEN_AQI_WEIGHT = 0.6;
    private static final double GREEN_PARK_WEIGHT = 0.4;
    private static final double MAX_PARK_DISTANCE_M = 5000.0;

    @Autowired
    private PropertySearchService propertySearchService;
    
    @Autowired
    private AqiLogRepository aqiLogRepository;
    
    @Autowired
    private DataLoaderService dataLoaderService;

    @Autowired
    private DataBackfillService dataBackfillService;

    @Autowired
    private LocalityRepository localityRepository;
    
    @Autowired
    private com.urbanaura.urbanaura.repository.UserRepository userRepository;

    @GetMapping("/admin/load-data")
    @ResponseBody
    public String loadData() {
        dataLoaderService.loadAllData();
        return "Data loading sequence initiated and completed successfully! You can navigate back to http://localhost:8081 to see the Dashboard.";
    }

    @GetMapping("/admin/backfill-data")
    @ResponseBody
    public String backfillData() {
        DataBackfillService.BackfillSummary summary = dataBackfillService.backfillMissingData();
        return "Backfill completed. "
                + "Properties scanned: " + summary.propertiesScanned()
                + ", SmartMetrics created: " + summary.smartMetricsCreated()
                + ", SmartMetrics updated: " + summary.smartMetricsUpdated()
                + ", QuickCommerce created: " + summary.quickCommerceCreated()
                + ", QuickCommerce updated: " + summary.quickCommerceUpdated()
                + ", AQI locality seeds added: " + summary.aqiSeeded()
                + ". Return to http://localhost:8081.";
    }

    @GetMapping("/")
    public String loadDashboard(
            @RequestParam(required = false) Long filterLocalityId,
            Authentication authentication,
            Model model) {
        boolean isAuthenticated = authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getName());

        List<Property> rawProperties;
        if (filterLocalityId != null) {
            rawProperties = propertySearchService.findPropertiesByLocality(filterLocalityId);
        } else {
            rawProperties = propertySearchService.findAllProperties();
        }
        
        // Convert to DTO and calculate Aura Score
        List<TopSmartPropertyDto> propertyDtos = new ArrayList<>();
        
        for (Property p : rawProperties) {
            TopSmartPropertyDto dto = new TopSmartPropertyDto();
            dto.setId(p.getId());
            dto.setTitle(p.getTitle());
            dto.setPrice(p.getPrice());
            
            if (p.getLocality() != null) {
                dto.setLocalityName(p.getLocality().getName());
                // In a real application, properties should have lat/lng themselves or inherit from locality or amenity
                // We'll use locality coords as a proxy for the map if property doesn't have exact ones
                dto.setLatitude(p.getLocality().getLatitude());
                dto.setLongitude(p.getLocality().getLongitude());
            }

            if (p.getQuickCommerce() != null) {
                dto.setBlinkitDist(p.getQuickCommerce().getBlinkitDistanceM());
                dto.setAmazonDist(p.getQuickCommerce().getAmazonDistanceM());
                dto.setFlipkartDist(p.getQuickCommerce().getFlipkartDistanceM());
                dto.setNearestBlinkit(p.getQuickCommerce().getNearestBlinkit());
            }

            double baseScore = 0.0;
            if (p.getSmartMetric() != null) {
                dto.setSafetyRating(p.getSmartMetric().getSafetyRating());
                dto.setParkDist(p.getSmartMetric().getDistToParkM());
                dto.setMetroDist(p.getSmartMetric().getDistToMetroM());
                dto.setHospitalDist(p.getSmartMetric().getDistToHospitalM());
                dto.setNoiseLevelDb(p.getSmartMetric().getNoiseLevelDb());
                dto.setAqiBaseline(p.getSmartMetric().getAqiBaseline());
                dto.setMaintenanceMonthly(p.getSmartMetric().getMaintenanceMonthly());
                dto.setSmartScore(p.getSmartMetric().getSmartScore());
                baseScore = p.getSmartMetric().getSmartScore() != null ? p.getSmartMetric().getSmartScore() : 50.0;
            }

            // Calculate Aura Score incorporating recent AQI Context
            double auraScore = baseScore;
            Double latestAqi = null;
            Double latestPm25 = null;
            if (dto.getLocalityName() != null) {
                List<AqiLog> logs = aqiLogRepository.findByLocalityOrderByTimestampDesc(dto.getLocalityName());
                if (!logs.isEmpty()) {
                    latestAqi = logs.get(0).getAqiValue();
                    latestPm25 = logs.get(0).getPm25();
                    // Example adjustment: High AQI (bad air) lowers the score. (Assume 50 is perfect)
                    if (latestAqi != null && latestAqi > 100) {
                        auraScore = auraScore - ((latestAqi - 100) * 0.1); 
                    }
                }
            }
            
            dto.setLatestAqi(latestAqi);
            dto.setLatestPm25(latestPm25);
            dto.setAuraScore(Math.round(Math.max(0, Math.min(100, auraScore)) * 100.0) / 100.0);
            dto.setGreenIndex(calculateGreenIndex(dto));
            propertyDtos.add(dto);
        }

        // Prefer listings that can support the drawer well, but never leave the explorer empty.
        List<TopSmartPropertyDto> preferredProperties = propertyDtos.stream()
                .filter(this::hasCompleteDrawerData)
                .sorted((a, b) -> Double.compare(b.getAuraScore() != null ? b.getAuraScore() : 0, a.getAuraScore() != null ? a.getAuraScore() : 0))
                .limit(10)
                .collect(Collectors.toList());

        List<TopSmartPropertyDto> top10 = preferredProperties.isEmpty()
                ? propertyDtos.stream()
                        .filter(this::hasMinimumCardData)
                        .sorted((a, b) -> Double.compare(b.getAuraScore() != null ? b.getAuraScore() : 0, a.getAuraScore() != null ? a.getAuraScore() : 0))
                        .limit(10)
                        .collect(Collectors.toList())
                : preferredProperties;

        model.addAttribute("properties", top10);
        model.addAttribute("mapProperties", propertyDtos);
        model.addAttribute("isAuthenticated", isAuthenticated);
        model.addAttribute("username", isAuthenticated ? authentication.getName() : null);
        if (isAuthenticated) {
            userRepository.findByUsername(authentication.getName()).ifPresent(user -> {
                model.addAttribute("currentUserId", user.getId());
            });
        }
        model.addAttribute("isAdmin", isAuthenticated && authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch("ROLE_ADMIN"::equals));
        model.addAttribute("localities", localityRepository.findAll().stream()
                .map(locality -> new LocalityOption(locality.getId(), locality.getName()))
                .collect(Collectors.toList()));

        return "index";
    }
    
    // Internal Helper Class for Dropdown loop
    public static class LocalityOption {
        private Long id; private String name;
        public LocalityOption(Long id, String name) { this.id = id; this.name = name; }
        public Long getId() { return id; }
        public String getName() { return name; }
    }

    private double calculateGreenIndex(TopSmartPropertyDto dto) {
        double effectiveAqi = dto.getLatestAqi() != null
                ? dto.getLatestAqi()
                : dto.getAqiBaseline() != null ? dto.getAqiBaseline() : 100.0;
        double boundedAqi = Math.max(0.0, Math.min(100.0, 100.0 - effectiveAqi));

        double parkDistance = dto.getParkDist() != null ? dto.getParkDist() : MAX_PARK_DISTANCE_M;
        double boundedParkDistance = Math.max(0.0, Math.min(MAX_PARK_DISTANCE_M, parkDistance));
        double parkProximity = ((MAX_PARK_DISTANCE_M - boundedParkDistance) / MAX_PARK_DISTANCE_M) * 100.0;

        double weightedScore = (boundedAqi * GREEN_AQI_WEIGHT) + (parkProximity * GREEN_PARK_WEIGHT);
        return Math.round(weightedScore * 100.0) / 100.0;
    }

    private boolean hasCompleteDrawerData(TopSmartPropertyDto dto) {
        return dto.getLocalityName() != null
                && dto.getAuraScore() != null
                && dto.getSmartScore() != null
                && dto.getGreenIndex() != null
                && dto.getSafetyRating() != null
                && dto.getNoiseLevelDb() != null
                && dto.getParkDist() != null
                && hasConnectivityData(dto);
    }

    private boolean hasConnectivityData(TopSmartPropertyDto dto) {
        return dto.getBlinkitDist() != null
                || dto.getAmazonDist() != null
                || dto.getFlipkartDist() != null
                || dto.getMetroDist() != null
                || dto.getHospitalDist() != null;
    }

    private boolean hasMinimumCardData(TopSmartPropertyDto dto) {
        return dto.getLocalityName() != null
                && dto.getTitle() != null
                && dto.getPrice() != null
                && dto.getAuraScore() != null;
    }
}
