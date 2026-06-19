class WebSocketManager {
    constructor() {
        if (WebSocketManager.instance) {
            return WebSocketManager.instance;
        }
        WebSocketManager.instance = this;

        this.stompClient = null;
        this.isConnected = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
        this.messageCallbacks = [];
        this.currentUserId = null;
    }

    connect(userId, onConnectCallback) {
        this.currentUserId = userId;
        const socket = new SockJS('/ws-aura');
        this.stompClient = Stomp.over(socket);
        this.stompClient.debug = null; // Disable debug logging for production

        const headers = {}; // Add any necessary auth headers here

        this.stompClient.connect(headers, (frame) => {
            console.log('Connected: ' + frame);
            this.isConnected = true;
            this.reconnectAttempts = 0;
            
            // Subscribe to private messages queue (Spring handles user mapping automatically)
            this.stompClient.subscribe('/user/queue/messages', (message) => {
                const parsedMessage = JSON.parse(message.body);
                this.notifyMessageReceived(parsedMessage);
            });

            if (onConnectCallback) onConnectCallback();

        }, (error) => {
            console.error('WebSocket Error: ', error);
            this.isConnected = false;
            this.handleReconnect();
        });
    }

    handleReconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            const timeout = Math.pow(2, this.reconnectAttempts) * 1000;
            console.log(`Reconnecting in ${timeout / 1000} seconds...`);
            setTimeout(() => {
                this.reconnectAttempts++;
                this.connect(this.currentUserId);
            }, timeout);
        } else {
            console.error('Max reconnect attempts reached.');
        }
    }

    sendMessage(receiverId, propertyId, content) {
        if (this.isConnected && this.stompClient) {
            const chatMessage = {
                receiverId: receiverId,
                propertyId: propertyId,
                content: content
            };
            this.stompClient.send("/app/chat.private", {}, JSON.stringify(chatMessage));
            return true;
        } else {
            console.warn('Cannot send message: WebSocket is not connected.');
            return false;
        }
    }

    onMessageReceived(callback) {
        this.messageCallbacks.push(callback);
    }

    notifyMessageReceived(message) {
        this.messageCallbacks.forEach(callback => callback(message));
    }

    disconnect() {
        if (this.stompClient !== null) {
            this.stompClient.disconnect();
            this.isConnected = false;
        }
        console.log("Disconnected");
    }
}

const wsManager = new WebSocketManager();
export default wsManager;
