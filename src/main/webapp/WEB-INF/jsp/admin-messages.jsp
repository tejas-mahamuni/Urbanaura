<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UrbanAura | Admin Messages Hub</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #1a73e8;
            --bg: #f8f9fa;
            --surface: #ffffff;
            --text-main: #202124;
            --text-muted: #5f6368;
            --border: #dadce0;
        }
        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            background-color: var(--bg);
            display: flex;
            height: 100vh;
            color: var(--text-main);
        }
        .sidebar {
            width: 320px;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
        }
        .sidebar-header {
            padding: 20px;
            border-bottom: 1px solid var(--border);
            font-weight: 600;
            font-size: 1.2rem;
        }
        .chat-list {
            flex-grow: 1;
            overflow-y: auto;
        }
        .chat-item {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
            cursor: pointer;
            transition: background 0.2s;
        }
        .chat-item:hover {
            background: #f1f3f4;
        }
        .chat-item-name {
            font-weight: 500;
            margin-bottom: 4px;
        }
        .chat-item-preview {
            font-size: 0.85rem;
            color: var(--text-muted);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .chat-area {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background: #e9ecef;
        }
        .chat-header {
            padding: 20px;
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
        }
        .property-info {
            margin-left: 15px;
        }
        .messages-container {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .message {
            max-width: 60%;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 0.95rem;
            line-height: 1.4;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }
        .message.received {
            background: var(--surface);
            align-self: flex-start;
            border-bottom-left-radius: 2px;
        }
        .message.sent {
            background: var(--primary);
            color: white;
            align-self: flex-end;
            border-bottom-right-radius: 2px;
        }
        .input-area {
            padding: 20px;
            background: var(--surface);
            display: flex;
            gap: 10px;
        }
        input[type="text"] {
            flex-grow: 1;
            padding: 12px 15px;
            border: 1px solid var(--border);
            border-radius: 24px;
            outline: none;
            font-family: inherit;
        }
        button {
            padding: 12px 24px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 24px;
            cursor: pointer;
            font-weight: 500;
            font-family: inherit;
            transition: background 0.2s;
        }
        button:hover {
            background: #1557b0;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="sidebar-header">Recent Inquiries</div>
    <div class="chat-list" id="chatList">
        <!-- Chat items injected via JS -->
    </div>
</div>

<div class="chat-area">
    <div class="chat-header">
        <h3 id="currentChatUser">Select a conversation</h3>
        <div class="property-info" id="currentChatProperty"></div>
    </div>
    <div class="messages-container" id="messagesContainer">
        <!-- Messages injected via JS -->
    </div>
    <div class="input-area">
        <input type="text" id="messageInput" placeholder="Type a message..." disabled>
        <button id="sendBtn" disabled>Send</button>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script type="module">
    import wsManager from '/js/websocket.js';

    // Mock Admin User ID - replace with actual session user ID in production
    const adminId = 1; 
    let currentReceiverId = null;
    let currentPropertyId = null;
    let conversations = {}; // map of key to messages

    function fetchRecent() {
        fetch('/api/messages/recent')
            .then(r => r.json())
            .then(data => {
                const chatList = document.getElementById('chatList');
                chatList.innerHTML = '';
                
                // Group by sender and property
                data.forEach(msg => {
                    const key = msg.senderId + '-' + msg.propertyId;
                    if (!conversations[key]) {
                        conversations[key] = msg;
                        const div = document.createElement('div');
                        div.className = 'chat-item';
                        div.innerHTML = `
                            <div class="chat-item-name">${msg.senderName}</div>
                            <div class="chat-item-preview">${msg.propertyTitle}</div>
                        `;
                        div.onclick = () => loadChat(msg.senderId, msg.propertyId, msg.senderName, msg.propertyTitle);
                        chatList.appendChild(div);
                    }
                });
            });
    }

    function loadChat(senderId, propertyId, senderName, propertyTitle) {
        currentReceiverId = senderId;
        currentPropertyId = propertyId;
        document.getElementById('currentChatUser').innerText = 'Chat with ' + senderName;
        document.getElementById('currentChatProperty').innerText = propertyTitle;
        
        document.getElementById('messageInput').disabled = false;
        document.getElementById('sendBtn').disabled = false;
        
        fetch(`/api/messages/history?userId=${senderId}&propertyId=${propertyId}`)
            .then(r => r.json())
            .then(data => {
                const container = document.getElementById('messagesContainer');
                container.innerHTML = '';
                data.forEach(msg => {
                    appendMessage(msg.content, msg.senderId == adminId ? 'sent' : 'received');
                });
            });
    }

    wsManager.connect(adminId, () => {
        console.log("Admin connected to socket");
        fetchRecent();
    });

    wsManager.onMessageReceived((msg) => {
        // If it's for current active chat, append it
        if ((msg.senderId == currentReceiverId && msg.propertyId == currentPropertyId) || (msg.senderId == adminId)) {
            appendMessage(msg.content, msg.senderId == adminId ? 'sent' : 'received');
        } else {
            // Otherwise just refresh recent list
            fetchRecent();
        }
    });

    function appendMessage(content, type) {
        const container = document.getElementById('messagesContainer');
        const msgDiv = document.createElement('div');
        msgDiv.className = `message ${type}`;
        msgDiv.textContent = content;
        container.appendChild(msgDiv);
        container.scrollTop = container.scrollHeight;
    }

    document.getElementById('sendBtn').addEventListener('click', () => {
        const input = document.getElementById('messageInput');
        const content = input.value.trim();
        if (content && currentReceiverId) {
            wsManager.sendMessage(currentReceiverId, currentPropertyId, content);
            input.value = '';
        }
    });

    document.getElementById('messageInput').addEventListener('keypress', (e) => {
        if(e.key === 'Enter') document.getElementById('sendBtn').click();
    });
</script>
</body>
</html>
