<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device.width, initial-scale=1.0">
    <title>Aura Dashboard | UrbanAura</title>
    
    <!-- CSS Dependencies -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="/css/main.css"> <!-- Custom Silicon Valley Tokens -->
    
    <!-- Scripts -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</head>
<body>

    <!-- Pillar 2: Glassmorphism Navigation -->
    <nav class="apple-nav">
        <div class="container d-flex justify-content-between align-items-center">
            <h4 class="m-0 fw-bolder">UrbanAura <span style="color: var(--apple-accent);">Pune</span></h4>
            
            <div class="d-flex gap-4 align-items-center">
                <a href="#" class="text-decoration-none text-dark fw-bold">Map</a>
                <a href="#" class="text-decoration-none text-secondary">Listings</a>
                <!-- Role-Based Authorization using JSTL stub -->
                <c:if test="${isAdmin}">
                    <a href="#" class="text-decoration-none text-danger fw-bold d-flex align-items-center gap-1">
                        <i data-lucide="shield-alert" style="width: 16px;"></i> Admin DB
                    </a>
                </c:if>
                <i data-lucide="search" class="text-secondary" style="width: 20px;"></i>
            </div>
        </div>
    </nav>

    <!-- Main Container Layout -->
    <div class="container mt-4 mb-5">
        
        <!-- Live Map & AQI Dashboard Header -->
        <div class="row mb-5">
            <div class="col-12 text-center mb-4">
                <h1>Smart City Intel</h1>
                <p class="text-secondary">Explore AI-curated localities with high Smart Scores and green ratios.</p>
            </div>
            
            <div class="col-lg-8">
                <div class="apple-card p-0 overflow-hidden" style="height: 400px; border-radius: 20px;">
                    <!-- Light Theme Positron Map Container -->
                    <div id="map" style="height: 100%; width: 100%;"></div>
                </div>
            </div>
            
            <div class="col-lg-4">
                <div class="apple-card h-100 d-flex flex-column justify-content-center text-center">
                    <i data-lucide="zap" style="color: var(--apple-accent); width: 32px; height: 32px;" class="mx-auto mb-3"></i>
                    <h3 class="mb-1">Live AQI Matrix</h3>
                    <p class="text-secondary mb-4" style="font-size: 14px;">Websocket Broadcasting (CO4)</p>
                    
                    <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                        <span class="fw-bold">Kothrud</span>
                        <h4 class="mb-0" id="aqi-Kothrud">--</h4>
                    </div>
                    <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                        <span class="fw-bold">Baner</span>
                        <h4 class="mb-0" id="aqi-Baner">--</h4>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="fw-bold">Hinjawadi</span>
                        <h4 class="mb-0" id="aqi-Hinjawadi">--</h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Property Grid -->
        <h3 class="mb-4">Top 10 Rated Smart-Properties</h3>
        <div class="row g-4">
            <!-- JSTL Iterator passing the CO3 projected View Array -->
            <c:forEach var="prop" items="${smartProperties}">
                <div class="col-md-6 col-lg-4">
                    <div class="apple-card d-flex flex-column h-100">
                        
                        <!-- Aura Badge - JSTL Complex Conditional Block -->
                        <div class="mb-3 d-flex justify-content-between align-items-start">
                            <c:choose>
                                <c:when test="${prop.smartScore >= 80}">
                                    <span style="background: rgba(16, 185, 129, 0.12); color: #10b981; padding: 4px 12px; border-radius: 99px; font-weight: 700; font-size: 12px;">
                                        <i data-lucide="leaf" style="width: 14px; margin-top: -3px;"></i> Ultra Smart
                                    </span>
                                </c:when>
                                <c:when test="${prop.smartScore >= 50}">
                                    <span style="background: rgba(0, 113, 227, 0.12); color: var(--apple-accent); padding: 4px 12px; border-radius: 99px; font-weight: 700; font-size: 12px;">
                                        <i data-lucide="zap" style="width: 14px; margin-top: -3px;"></i> Excellent Quality
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span style="background: rgba(134, 134, 139, 0.12); color: var(--apple-text-secondary); padding: 4px 12px; border-radius: 99px; font-weight: 700; font-size: 12px;">
                                        Standard Quality
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <span class="fw-bold text-secondary" style="font-size: 13px;">Score: ${prop.smartScore}/100</span>
                        </div>

                        <h5 class="fw-bold mb-1">${prop.title}</h5>
                        <p class="text-secondary small mb-3"><i data-lucide="map-pin" style="width:14px;"></i> ${prop.address}</p>
                        
                        <div class="mt-auto">
                            <hr style="opacity:0.1">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="d-block small text-secondary">Asking Price</span>
                                    <!-- JSTL Number Format Tag -->
                                    <span class="fs-5 fw-bolder">₹<fmt:formatNumber value="${prop.price}" type="number" groupingUsed="true" /></span>
                                </div>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-outline-primary px-3 rounded-pill fw-bold" style="font-size: 14px;" onclick="openChatDrawer('${prop.id}', '${prop.title}')">
                                        <i data-lucide="message-circle" style="width: 14px; margin-top:-2px;"></i> Chat
                                    </button>
                                    <button class="apple-btn px-4" data-bs-toggle="modal" data-bs-target="#inquiryModal" onclick="document.getElementById('propId').value = '${prop.id}';">Inquire</button>
                                </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Inquiry UX Modal (Validated Form) -->
    <div class="modal fade" id="inquiryModal" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 20px; border: none; box-shadow: 0 20px 40px rgba(0,0,0,0.1);">
          <div class="modal-header border-0 pb-0">
            <h5 class="modal-title fw-bold">Request Property Callback</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body pt-3 pb-4 px-4">
            <form onsubmit="return validateInquiryForm(event)">
                <input type="hidden" id="propId" name="property_id">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Legal Name</label>
                    <input type="text" id="custName" class="apple-input w-100" required minlength="3" placeholder="John Doe">
                </div>
                <div class="mb-4">
                    <label class="form-label small fw-bold">Contact Email</label>
                    <input type="email" id="custEmail" class="apple-input w-100" required placeholder="john@company.com">
                </div>
                <button type="submit" class="apple-btn w-100 py-3 d-flex justify-content-center align-items-center gap-2">
                    Submit Priority Request <i data-lucide="arrow-right" style="width:16px"></i>
                </button>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Chat Drawer (Offcanvas) -->
    <div class="offcanvas offcanvas-end" tabindex="-1" id="chatDrawer" aria-labelledby="chatDrawerLabel" style="width: 400px; border-radius: 20px 0 0 20px; box-shadow: -10px 0 40px rgba(0,0,0,0.1);">
      <div class="offcanvas-header border-bottom">
        <div>
          <h5 class="offcanvas-title fw-bold" id="chatDrawerLabel">Chat with Owner</h5>
          <small class="text-secondary" id="chatPropertyTitle">Loading property...</small>
        </div>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
      </div>
      <div class="offcanvas-body d-flex flex-column p-0 bg-light">
        <div class="flex-grow-1 p-3 overflow-auto d-flex flex-column gap-2" id="userMessagesContainer">
            <!-- Messages go here -->
            <div class="text-center text-muted small my-3">Start of conversation</div>
        </div>
        <div class="p-3 bg-white border-top">
            <div class="input-group">
                <input type="text" id="userMessageInput" class="form-control rounded-pill me-2 px-3" placeholder="Type a message...">
                <button class="btn btn-primary rounded-circle d-flex align-items-center justify-content-center" style="width: 42px; height: 42px;" id="userSendBtn">
                    <i data-lucide="send" style="width: 18px; color: white;"></i>
                </button>
            </div>
        </div>
      </div>
    </div>

    <!-- Support Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Init Vector Graphics Pipeline
        lucide.createIcons();

        // Init CartoDB Positron Light Map (Pune Bounds)
        const map = L.map('map').setView([18.5204, 73.8567], 12);
        L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '© OpenStreetMap © CARTO',
            maxZoom: 19
        }).addTo(map);

        // CO4 Websocket Connectivity mapped dynamically to URI format
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const socket = new WebSocket(wsProtocol + '//' + window.location.host + '/ws/aqi');

        socket.onmessage = function(event) {
            const data = JSON.parse(event.data);
            const domId = 'aqi-' + data.zone;
            const element = document.getElementById(domId);
            
            if (element) {
                element.innerText = data.aqi;
                // Add Glow effect, then remove after 1 second
                element.classList.remove('glow');
                void element.offsetWidth; // Force CSS reflow
                element.classList.add('glow');
            }
        };

        // Standard JS UX validation hooking into UI elements securely
        function validateInquiryForm(event) {
            event.preventDefault();
            const emailStr = document.getElementById('custEmail').value;
            if(!emailStr.includes('@')) {
                alert("Please enter a valid email context!");
                return false;
            }
            // Trigger close & success sequence
            const m = bootstrap.Modal.getInstance(document.getElementById('inquiryModal'));
            m.hide();
            alert("Property inquiry logged securely! An agent will call you within 20 mins.");
            return true;
        }
    </script>

    <!-- Websocket Scripts for Chat -->
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script type="module">
        import wsManager from '/js/websocket.js';
        
        // Expose openChatDrawer to global scope for onclick handler
        window.openChatDrawer = function(propertyId, propertyTitle) {
            window.activeChatPropertyId = propertyId;
            document.getElementById('chatPropertyTitle').innerText = propertyTitle;
            const chatOffcanvas = new bootstrap.Offcanvas(document.getElementById('chatDrawer'));
            chatOffcanvas.show();
        };

        // Mock User ID - replace with session principal id
        const currentUserId = 12; // Test user ID
        const adminId = 1; // Send to admin
        
        wsManager.connect(currentUserId, () => {
            console.log("User connected to socket for chat");
        });

        wsManager.onMessageReceived((msg) => {
            if (msg.propertyId == window.activeChatPropertyId) {
                appendUserMessage(msg.content, msg.senderId == currentUserId ? 'sent' : 'received');
            }
        });

        function appendUserMessage(content, type) {
            const container = document.getElementById('userMessagesContainer');
            const msgDiv = document.createElement('div');
            // WhatsApp style bubbles
            msgDiv.className = `p-2 px-3 rounded-4 ${type === 'sent' ? 'bg-primary text-white align-self-end ms-4' : 'bg-white align-self-start me-4 border'}`;
            msgDiv.style.maxWidth = '85%';
            msgDiv.style.fontSize = '0.9rem';
            msgDiv.textContent = content;
            container.appendChild(msgDiv);
            container.scrollTop = container.scrollHeight;
        }

        document.getElementById('userSendBtn').addEventListener('click', () => {
            const input = document.getElementById('userMessageInput');
            const content = input.value.trim();
            if (content && window.activeChatPropertyId) {
                wsManager.sendMessage(adminId, window.activeChatPropertyId, content);
                input.value = '';
            }
        });
        
        document.getElementById('userMessageInput').addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                document.getElementById('userSendBtn').click();
            }
        });
    </script>
</body>
</html>
