import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 32),
            const Text(
              'PAY & CHAT',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const DiguHostApp());
}

class DiguHostApp extends StatelessWidget {
  const DiguHostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digu Host App',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.orange,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          fillColor: Colors.white,
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(220, 56),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDE7),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                "Welcome To JodetxPay",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          elevation: 2,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.message_outlined, color: Colors.black),
                  label: const Text('Message Host App', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(260, 64),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    side: const BorderSide(color: Colors.orange, width: 2),
                    elevation: 4,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MessagePage()),
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  label: const Text('UPI Payment Demo', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(260, 64),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageEntry {
  final String text;
  final bool fromAar; // true: sent from AAR, false: reply from host
  MessageEntry(this.text, this.fromAar);
}

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  static const MethodChannel _channel = MethodChannel('com.example/aar_channel');
  final TextEditingController _controller = TextEditingController();
  final List<MessageEntry> _messages = [];
  bool _isSending = false;
  String _status = 'Idle';

  Future<void> _sendMessageToHost() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _isSending = true;
      _messages.add(MessageEntry(message, true));
      _status = 'Sending...';
      _controller.clear();
    });
    try {
      final response = await _channel.invokeMethod('sendToHost', {'message': message});
      setState(() {
        _messages.add(MessageEntry(response.toString(), false));
        _status = 'Message sent!';
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(MessageEntry('❌ Error: $e', false));
        _status = 'Error sending message.';
        _isSending = false;
      });
    }
  }

  Widget _buildMessageBubble(MessageEntry entry) {
    final isHostReply = !entry.fromAar;
    final isAarMessage = entry.fromAar;
    return Align(
      alignment: entry.fromAar ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: entry.fromAar ? Colors.orange : Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(entry.fromAar ? 18 : 4),
            bottomRight: Radius.circular(entry.fromAar ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAarMessage)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Message from AAR Module:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            if (isHostReply)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Response from Host App:',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            Text(
              entry.text,
              style: TextStyle(
                color: entry.fromAar ? Colors.black : Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDE7),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                "Message Host App",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          elevation: 2,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: BoxConstraints(
                  maxWidth: isWide ? 800 : double.infinity,
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: _messages.isEmpty
                              ? Center(child: Text('No messages yet.', style: TextStyle(fontSize: 18, color: Colors.grey[600])))
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, idx) => _buildMessageBubble(_messages[_messages.length - 1 - idx]),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        hintText: 'Type a message',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(32)),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      minLines: 1,
                                      maxLines: 4,
                                      onSubmitted: (_) => _sendMessageToHost(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                                    onPressed: () {}, // Optionally add emoji picker
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ))
                                  : const Icon(Icons.send, color: Colors.white),
                              onPressed: _isSending ? null : _sendMessageToHost,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Status: $_status',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  static const MethodChannel _hostToAar = MethodChannel('host_to_aar');
  static const MethodChannel _aarToHost = MethodChannel('aar_to_host');
  bool _isPaying = false;
  String _upiResult = '';
  String _status = 'Idle';

  @override
  void initState() {
    super.initState();
    _aarToHost.setMethodCallHandler((call) async {
      if (call.method == 'paymentResult') {
        setState(() {
          _upiResult = call.arguments['result'] ?? '';
          _status = 'Payment Result: ${call.arguments['result'] ?? ''}';
          _isPaying = false;
        });
      }
    });
  }

  Future<void> _startUpiPayment() async {
    setState(() {
      _isPaying = true;
      _upiResult = '';
      _status = 'Requesting UPI...';
    });
    try {
      final paymentData = {
        'amount': 100,
        'upiId': 'abc@upi',
        'receiverName': 'John',
      };
      await _hostToAar.invokeMethod('startUpiPayment', paymentData);
      // Result will be handled by _aarToHost handler
    } catch (e) {
      setState(() {
        _upiResult = 'Payment Error: $e';
        _status = 'Payment Error: $e';
        _isPaying = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDE7),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 12),
              const Text(
                "UPI Payment Demo",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          elevation: 2,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                constraints: BoxConstraints(
                  maxWidth: isWide ? 800 : double.infinity,
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showSnackBar('Scan & Pay tapped'),
                                      child: _upiActionIcon(Icons.qr_code_scanner, 'Scan & Pay'),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showSnackBar('To Mobile tapped'),
                                      child: _upiActionIcon(Icons.phone_android, 'To Mobile'),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showSnackBar('To Bank tapped'),
                                      child: _upiActionIcon(Icons.account_balance, 'To Bank'),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showSnackBar('To Self tapped'),
                                      child: _upiActionIcon(Icons.person, 'To Self'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: _walletCard('Balance', Icons.account_balance_wallet, Colors.orange)),
                                const SizedBox(width: 8),
                                Expanded(child: _walletCard('History', Icons.history, Colors.black)),
                                const SizedBox(width: 8),
                                Expanded(child: _walletCard('Bank', Icons.account_balance, Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Card(
                              color: Colors.orange,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _isPaying ? null : _startUpiPayment,
                                      icon: _isPaying
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ))
                                          : const Icon(Icons.currency_rupee, color: Colors.white),
                                      label: const Text('Pay ₹1 via UPI', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    if (_upiResult.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _upiResult.toLowerCase().contains('error') || _upiResult.toLowerCase().contains('fail') ? Colors.red[50] : _upiResult.toLowerCase().contains('success') ? Colors.green[50] : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _upiResult.toLowerCase().contains('success')
                                                ? Icons.check_circle
                                                : (_upiResult.toLowerCase().contains('error') || _upiResult.toLowerCase().contains('fail'))
                                                  ? Icons.cancel
                                                  : Icons.info_outline,
                                              color: _upiResult.toLowerCase().contains('success')
                                                ? Colors.green
                                                : (_upiResult.toLowerCase().contains('error') || _upiResult.toLowerCase().contains('fail'))
                                                  ? Colors.red
                                                  : Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _upiResult,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Status: $_status',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _upiActionIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(icon, color: Colors.white),
          radius: 24,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _walletCard(String label, IconData icon, Color color) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
