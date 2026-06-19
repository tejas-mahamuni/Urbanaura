<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UrbanAura | Admin Operations</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        :root {
            --bg: #eef5f6; --text: #13252c; --muted: #6f8b95; --line: rgba(19,37,44,.15);
            --accent: #0f9d8a; --accent-deep: #0c8272; --surface: #ffffff;
        }
        body { background-color: var(--bg); font-family: 'Inter', sans-serif; color: var(--text); }
        .sidebar { background: var(--text); min-height: 100vh; color: #fff; padding-top: 2rem; box-shadow: 4px 0 24px rgba(0,0,0,0.1); z-index: 10;}
        .sidebar a { color: #8cadb8; text-decoration: none; padding: 14px 24px; display: block; font-weight: 500; border-radius: 12px; margin: 4px 12px; transition: all 0.2s;}
        .sidebar a:hover { color: #fff; background: rgba(255,255,255,0.1); transform: translateX(4px); }
        .card { border: none; border-radius: 20px; box-shadow: 0 12px 36px rgba(19,37,44,0.06); overflow: hidden; background: var(--surface); }
        .card-header { background: #f8fbfb; font-weight: 700; color: #163744; padding: 20px 24px; border-bottom: 1px solid var(--line); font-size: 18px; letter-spacing: -0.01em; }
        .table { margin-bottom: 0; }
        .table th { font-weight: 600; color: var(--muted); text-transform: uppercase; font-size: 12px; padding: 16px 24px; border-bottom: 1px solid var(--line); }
        .table td { padding: 16px 24px; vertical-align: middle; border-bottom: 1px solid rgba(19,37,44,0.05); }
        .table-hover tbody tr:hover { background-color: #f7fafa; }
        .btn-brand { background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; border: none; font-weight: 600; padding: 10px 20px; border-radius: 999px; box-shadow: 0 4px 12px rgba(15,157,138,0.25); transition: transform 0.2s, box-shadow 0.2s;}
        .btn-brand:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(15,157,138,0.35); color: #fff; }
        .btn-outline-danger { border-radius: 999px; padding: 6px 16px; font-weight: 600; font-size: 13px; }
        .badge { font-weight: 600; padding: 6px 10px; border-radius: 6px; }
        /* Chat UI */
        .chat-hub-btn { position: fixed; right: 40px; bottom: 40px; width: 64px; height: 64px; border-radius: 50%; background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; display: flex; justify-content: center; align-items: center; box-shadow: 0 10px 30px rgba(15,157,138,0.4); cursor: pointer; transition: transform 0.2s; z-index: 1000;}
        .chat-hub-btn:hover { transform: scale(1.1); }
        .chat-list-item { padding: 16px 20px; border-bottom: 1px solid var(--line); cursor: pointer; transition: all 0.2s; border-left: 4px solid transparent; }
        .chat-list-item:hover { background: #f8fbfb; }
        .chat-list-item.active { background: #f0f7f7; border-left-color: var(--accent); }
        .chat-list-item.unread { background: rgba(15,157,138,0.06); border-left-color: rgba(15,157,138,0.5); }
        .chat-list-item.unread .fw-bold { color: var(--accent) !important; }
        .chat-avatar { width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; flex-shrink: 0; }
        .chat-message { max-width: 85%; padding: 12px 16px; border-radius: 18px; margin-bottom: 12px; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); line-height: 1.5;}
        .chat-message.sent { background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; align-self: flex-end; border-bottom-right-radius: 4px; }
        .chat-message.received { background: #ffffff; border: 1px solid rgba(19,37,44,0.1); color: var(--text); align-self: flex-start; border-bottom-left-radius: 4px; }
    </style>
</head>
<body>
<div class="container-fluid p-0">
    <div class="row g-0">
        <!-- Sidebar -->
        <div class="col-md-2 sidebar">
            <div class="px-4 mb-5">
                <span style="display:inline-block; width:36px; height:36px; background:var(--accent); border-radius:10px; color:#fff; text-align:center; line-height:36px; font-weight:800; font-size:18px; margin-right:10px; vertical-align:middle;">UA</span>
                <span style="font-weight:800; font-size:20px; vertical-align:middle; letter-spacing:-0.03em;">Central</span>
            </div>
            <a href="/admin/dashboard" style="color:#fff; background:rgba(255,255,255,0.08);">Dashboard Registry</a>
            <a href="/admin/property/new">Add Property</a>
            <hr style="border-color:rgba(255,255,255,0.1); margin:24px;">
            <a href="/">Exit to Dashboard</a>
        </div>
        
        <!-- Main Content -->
        <div class="col-md-10" style="padding: 40px 60px; height: 100vh; overflow-y: auto;">
            <div class="d-flex justify-content-between align-items-center mb-5">
                <div>
                    <h2 style="font-weight:800; color:var(--text); letter-spacing:-0.03em; margin-bottom:4px;">Property Asset Management</h2>
                    <p style="color:var(--muted); font-size:15px; font-weight:500;">Oversee live database assets and territorial boundaries.</p>
                </div>
                <div class="d-flex gap-3">
                    <input type="text" id="adminSearch" class="form-control" placeholder="Search properties..." style="border-radius:999px; padding:10px 20px; border:1px solid var(--line); min-width:260px;" onkeyup="filterProperties()">
                    <a href="/admin/property/new" class="btn btn-brand" style="white-space:nowrap;">+ Add Property</a>
                </div>
            </div>

            <!-- Properties Table -->
            <div class="card mb-5">
                <div class="card-header">Active Listed Properties (${properties.size()})</div>
                <div class="card-body p-0">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Asset Title</th>
                                <th>Pricing</th>
                                <th>Neighborhood Zone</th>
                                <th class="text-end">Controls</th>
                            </tr>
                        </thead>
                        <tbody id="propertiesTable">
                            <c:forEach var="prop" items="${properties}">
                                <tr>
                                    <td class="text-muted fw-bold">#<c:out value="${prop.id}"/></td>
                                    <td><strong style="color:var(--text); font-size:15px;"><c:out value="${prop.title}"/></strong></td>
                                    <td><span style="color:var(--accent-deep); font-weight:800;">Rs. <c:out value="${prop.price}"/> Cr</span></td>
                                    <td><span class="badge" style="background:rgba(15,157,138,0.1); color:var(--accent-deep);"><c:out value="${prop.locality.name}"/></span></td>
                                    <td class="text-end">
                                        <form action="/admin/property/delete/${prop.id}" method="post" style="display:inline;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('WARNING: This will permanently delete this property asset. Proceed?');">Delete</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Localities Reference Table -->
            <h4 style="font-weight:800; color:var(--text); letter-spacing:-0.02em;" class="mb-4">Geographic Zones</h4>
            <div class="card">
                <div class="card-body p-0">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Locality Name</th>
                                <th>Governing City</th>
                                <th>Mapping Coords</th>
                                <th>Trust / Safety Base</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="loc" items="${localities}">
                                <tr>
                                    <td class="text-muted fw-bold">#<c:out value="${loc.id}"/></td>
                                    <td><strong style="color:var(--text);"><c:out value="${loc.name}"/></strong></td>
                                    <td><c:out value="${loc.city}"/></td>
                                    <td><code style="color:var(--muted); background:rgba(0,0,0,0.04); padding:4px 8px; border-radius:4px;"><c:out value="${loc.latitude}"/>, <c:out value="${loc.longitude}"/></code></td>
                                    <td><strong style="color:var(--accent);"><c:out value="${loc.safetyScore}"/> / 10</strong></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Floating Chat Button -->
<div class="chat-hub-btn" data-bs-toggle="offcanvas" data-bs-target="#adminChatDrawer">
    <i data-lucide="message-square" style="width: 28px; height: 28px; color: white;"></i>
</div>

<!-- Admin Chat Drawer (Split Layout) -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="adminChatDrawer" style="width: 800px; border-radius: 24px 0 0 24px; box-shadow: -10px 0 50px rgba(0,0,0,0.15);">
    <div class="offcanvas-header border-bottom py-3">
        <h5 class="offcanvas-title fw-bold">Admin Communications Hub</h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body p-0 d-flex h-100" style="overflow: hidden;">
        <!-- Left: Chat List -->
        <div style="width: 320px; border-right: 1px solid var(--line); overflow-y: auto;" id="adminChatList">
            <!-- Items injected by JS -->
            <div class="p-4 text-center text-muted small">Loading conversations...</div>
        </div>
        <!-- Right: Chat Area -->
        <div class="d-flex flex-column" style="flex: 1; background: #fcfdfe;">
            <div class="p-3 border-bottom bg-white d-flex align-items-center">
                <div>
                    <h6 class="mb-0 fw-bold" id="adminChatUserName">Select a conversation</h6>
                    <small class="text-muted" id="adminChatPropName">...</small>
                </div>
            </div>
            <div id="adminMessagesContainer" class="p-3 d-flex flex-column" style="flex: 1; overflow-y: auto;">
                <!-- Messages -->
            </div>
            <div class="p-3 bg-white border-top">
                <div class="input-group">
                    <input type="text" id="adminMsgInput" class="form-control rounded-pill me-2 px-3" placeholder="Type reply..." disabled>
                    <button class="btn btn-brand rounded-circle d-flex align-items-center justify-content-center" style="width: 42px; height: 42px; padding:0;" id="adminSendBtn" disabled>
                        <i data-lucide="send" style="width: 18px; color: white;"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script type="module">
    import wsManager from '/js/websocket.js';
    
    lucide.createIcons();

    const adminUsername = '<c:out value="${username}"/>'; 
    const currentAdminId = <c:out value="${currentUserId != null ? currentUserId : -1}"/>;
    let currentReceiverId = null;
    let currentPropertyId = null;
    let conversations = {}; 

    function fetchRecent() {
        conversations = {};
        fetch('/api/messages/recent')
            .then(r => r.json())
            .then(data => {
                const chatList = document.getElementById('adminChatList');
                chatList.innerHTML = '';
                
                data.forEach(msg => {
                    const otherUserId = msg.senderId === currentAdminId ? msg.receiverId : msg.senderId;
                    const otherUserName = msg.senderId === currentAdminId ? 'User #' + msg.receiverId : msg.senderName;
                    const key = otherUserId + '-' + msg.propertyId;
                    
                    if (!conversations[key]) {
                        conversations[key] = msg;
                        const div = document.createElement('div');
                        const isUnread = (!msg.read && msg.senderId !== currentAdminId);
                        div.className = 'chat-list-item' + (isUnread ? ' unread' : '');
                        div.id = 'chat-item-' + otherUserId + '-' + msg.propertyId;
                        div.innerHTML = 
                            '<div class="d-flex gap-3 align-items-center">' +
                                '<div class="chat-avatar">' + otherUserName.charAt(0).toUpperCase() + '</div>' +
                                '<div style="flex:1; min-width:0;">' +
                                    '<div class="d-flex justify-content-between align-items-center">' +
                                        '<div class="fw-bold" style="font-size:15px; color:var(--text);">' + otherUserName + (isUnread ? '<span style="display:inline-block; width:8px; height:8px; background:var(--accent); border-radius:50%; margin-left:8px;"></span>' : '') + '</div>' +
                                    '</div>' +
                                    '<div class="text-truncate mt-1" style="font-size:12px; color:var(--accent-deep); font-weight:600;"><i data-lucide="home" style="width:12px; height:12px; margin-top:-2px; margin-right:4px;"></i>' + msg.propertyTitle + '</div>' +
                                    '<div class="text-muted mt-1 text-truncate" style="font-size:13px;' + (isUnread ? 'font-weight:600; color:var(--text) !important;' : '') + '">' + (msg.senderId === currentAdminId ? 'You: ' : '') + msg.content + '</div>' +
                                '</div>' +
                            '</div>';
                        div.onclick = () => loadChat(otherUserId, msg.propertyId, otherUserName, msg.propertyTitle);
                        chatList.appendChild(div);
                        if (window.lucide) window.lucide.createIcons();
                    }
                });
            });
    }

    function loadChat(senderId, propertyId, senderName, propertyTitle) {
        currentReceiverId = senderId;
        currentPropertyId = propertyId;
        
        // Update active styling
        document.querySelectorAll('.chat-list-item').forEach(el => el.classList.remove('active'));
        const activeItem = document.getElementById('chat-item-' + senderId + '-' + propertyId);
        if (activeItem) activeItem.classList.add('active');

        document.getElementById('adminChatUserName').innerText = senderName;
        document.getElementById('adminChatPropName').innerText = propertyTitle;
        
        document.getElementById('adminMsgInput').disabled = false;
        document.getElementById('adminSendBtn').disabled = false;
        
        fetch('/api/messages/history?userId=' + senderId + '&propertyId=' + propertyId)
            .then(r => r.json())
            .then(data => {
                const container = document.getElementById('adminMessagesContainer');
                container.innerHTML = '';
                
                // Add secure encryption message
                const secureMsg = document.createElement('div');
                secureMsg.style.textAlign = 'center';
                secureMsg.style.fontSize = '12px';
                secureMsg.style.color = 'var(--muted)';
                secureMsg.style.marginBottom = '16px';
                secureMsg.innerHTML = '<i data-lucide="lock" style="width:12px; margin-right:4px; margin-top:-2px;"></i>End-to-end encrypted chat started';
                container.appendChild(secureMsg);

                data.forEach(msg => {
                    appendMessage(msg.content, msg.senderId === currentAdminId ? 'sent' : 'received');
                });
                if (window.lucide) window.lucide.createIcons();
            });
    }

    wsManager.connect(adminUsername, () => {
        console.log("Admin hub connected to socket");
        fetchRecent();
    });

    wsManager.onMessageReceived((msg) => {
        if ((msg.senderId == currentReceiverId && msg.propertyId == currentPropertyId) || (msg.senderId === currentAdminId)) {
            appendMessage(msg.content, msg.senderId === currentAdminId ? 'sent' : 'received');
        }
        // Always refresh recent to put latest on top/update previews
        fetchRecent();
    });

    function appendMessage(content, type) {
        const container = document.getElementById('adminMessagesContainer');
        const msgDiv = document.createElement('div');
        msgDiv.className = 'chat-message ' + type;
        msgDiv.textContent = content;
        container.appendChild(msgDiv);
        container.scrollTop = container.scrollHeight;
    }

    document.getElementById('adminSendBtn').addEventListener('click', () => {
        const input = document.getElementById('adminMsgInput');
        const content = input.value.trim();
        if (content && currentReceiverId) {
            wsManager.sendMessage(currentReceiverId, currentPropertyId, content);
            input.value = '';
        }
    });

    document.getElementById('adminMsgInput').addEventListener('keypress', (e) => {
        if(e.key === 'Enter') document.getElementById('adminSendBtn').click();
    });
</script>

<script>
    function filterProperties() {
        const query = document.getElementById('adminSearch').value.toLowerCase();
        const rows = document.querySelectorAll('#propertiesTable tbody tr');
        rows.forEach(row => {
            const text = row.innerText.toLowerCase();
            row.style.display = text.includes(query) ? '' : 'none';
        });
    }
</script>
</body>
</html>
