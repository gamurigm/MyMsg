import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:http/http.dart' as http;

class ChatRemoteDataSource {
  String wsUrl;
  String restUrl;
  WebSocketChannel? _channel;
  String? _currentUserId;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  bool _isReconnecting = false; // Guard against concurrent reconnects
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  StreamSubscription? _wsSubscription; // Track the listener to cancel it cleanly
  static const int _maxReconnectDelay = 30; // seconds

  // StreamController persistente que sobrevive a reconexiones
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();

  ChatRemoteDataSource({required this.wsUrl, required this.restUrl});

  void updateUrls(String ip) {
    wsUrl = 'ws://$ip:8081';
    restUrl = 'http://$ip:8081';
  }

  void connect(String userId) {
    _currentUserId = userId;
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _doConnect();
  }

  void _doConnect() {
    if (!_shouldReconnect || _currentUserId == null) return;

    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();
    _isReconnecting = false;

    // Cancel the previous listener BEFORE closing the channel
    // This prevents the old onDone from firing and triggering another reconnect
    _wsSubscription?.cancel();
    _wsSubscription = null;

    // Close old channel silently
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;

    try {
      print('[WS] Conectando a $wsUrl/ws?userId=$_currentUserId ...');
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws?userId=$_currentUserId'),
      );

      _wsSubscription = _channel!.stream.listen(
        (event) {
          // If we receive data, the connection is truly alive
          if (!_isConnected) {
            _isConnected = true;
            _reconnectAttempts = 0;
            print('[WS] ✅ Conexión establecida.');
          }
          try {
            final data = jsonDecode(event);
            print('[WS] Mensaje recibido: senderId=${data['senderId']}, chatId=${data['chatId']}');
            final message = Message(
              id: data['id'] ?? '',
              chatId: data['chatId'] ?? 'global',
              senderId: data['senderId'] ?? 'unknown',
              content: data['content'] ?? '',
              timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
              isFile: data['isFile'] ?? false,
              fileUrl: data['fileUrl'],
            );
            _messageController.add(message);
          } catch (e) {
            print('[WS] Error parseando mensaje: $e');
          }
        },
        onError: (error) {
          print('[WS] ❌ Error en WebSocket: $error');
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print('[WS] 🔌 WebSocket cerrado.');
          _isConnected = false;
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('[WS] ❌ Excepción al conectar: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    // Prevent multiple concurrent reconnect timers
    if (_isReconnecting) return;
    _isReconnecting = true;

    _reconnectAttempts++;
    // Exponential backoff: 2s, 4s, 8s, 16s... max 30s
    final delaySecs = (2 * _reconnectAttempts).clamp(2, _maxReconnectDelay);
    print('[WS] 🔄 Reconectando en ${delaySecs}s (intento #$_reconnectAttempts)...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySecs), () {
      _isReconnecting = false;
      _doConnect();
    });
  }

  Stream<Message> get messageStream => _messageController.stream;

  void sendMessage(Message message) {
    if (!_isConnected || _channel == null) return;
    final payload = jsonEncode({
      'id': message.id,
      'chatId': message.chatId,
      'senderId': message.senderId,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'isFile': message.isFile,
      'fileUrl': message.fileUrl,
    });
    _channel!.sink.add(payload);
  }

  Future<String> uploadFile(Uint8List bytes, String fileName) async {
    final request = http.MultipartRequest('POST', Uri.parse('$restUrl/upload'));
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['url'];
    } else {
      throw Exception('Error al subir el archivo (status: ${response.statusCode})');
    }
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _wsSubscription?.cancel();
    _messageController.close();
    _channel?.sink.close();
  }
}
