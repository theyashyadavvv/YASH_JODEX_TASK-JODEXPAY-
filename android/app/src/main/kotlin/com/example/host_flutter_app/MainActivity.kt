package com.example.host_flutter_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example/aar_channel"
    private val AAR_ORIGIN_PREFIX = "[yash]" // ✅ For validation only
    private var pendingResult: MethodChannel.Result? = null
    private var lastFlutterEngine: FlutterEngine? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        lastFlutterEngine = flutterEngine

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendToHost" -> {
                    val message = call.argument<String>("message") ?: ""
                    if (message.trim().lowercase() == "hi") {
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("hostReply", "Hello!")
                        result.success("Hello!")
                    } else {
                        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                            .invokeMethod("hostReply", message)
                        result.success(message)
                    }
                }
                "startUpiPayment" -> {
                    val amount = call.argument<Int>("amount") ?: 0
                    val upiId = call.argument<String>("upiId") ?: ""
                    val receiverName = call.argument<String>("receiverName") ?: ""
                    startUpiIntent(amount, upiId, receiverName, result)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "host_to_aar").setMethodCallHandler { call, result ->
            if (call.method == "startUpiPayment") {
                val amount = call.argument<Int>("amount") ?: 0
                val upiId = call.argument<String>("upiId") ?: ""
                val receiverName = call.argument<String>("receiverName") ?: ""
                launchFakeUpiActivity(amount, upiId, receiverName)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startUpiIntent(amount: Int, upiId: String, receiverName: String, result: MethodChannel.Result) {
        val uri = Uri.parse(
            "upi://pay?pa=$upiId&pn=$receiverName&am=$amount&cu=INR"
        )
        val intent = Intent(Intent.ACTION_VIEW, uri)
        if (intent.resolveActivity(packageManager) != null) {
            pendingResult = result
            startActivityForResult(intent, 2023)
        } else {
            result.error("NO_UPI_APP", "No UPI app found on device", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 2024 && resultCode == Activity.RESULT_OK && data != null) {
            val status = data.getStringExtra("result") ?: "failure"
            val txnId = data.getStringExtra("transactionId") ?: ""
            val resultData = HashMap<String, Any?>()
            resultData["result"] = status
            resultData["transactionId"] = txnId
            MethodChannel(lastFlutterEngine!!.dartExecutor.binaryMessenger, "aar_to_host")
                .invokeMethod("paymentResult", resultData)
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun parseUpiResponse(response: String, resultCode: Int): Map<String, Any?> {
        val resultMap = mutableMapOf<String, Any?>()
        var status = "failure"
        var txnId = ""
        var approvalRef = ""
        if (resultCode == Activity.RESULT_OK && response.isNotEmpty()) {
            val pairs = response.split("&")
            for (pair in pairs) {
                val parts = pair.split("=")
                if (parts.size == 2) {
                    when (parts[0].lowercase()) {
                        "status" -> status = parts[1].lowercase()
                        "txnref", "approvalrefno" -> approvalRef = parts[1]
                        "txnid" -> txnId = parts[1]
                    }
                }
            }
        }
        resultMap["result"] = status
        resultMap["transactionId"] = if (txnId.isNotEmpty()) txnId else approvalRef
        resultMap["rawResponse"] = response
        return resultMap
    }

    // Launch the fake UPI payment UI
    private fun launchFakeUpiActivity(amount: Int, upiId: String, receiverName: String) {
        val intent = Intent(this, FakeUpiActivity::class.java)
        intent.putExtra("amount", amount)
        intent.putExtra("upiId", upiId)
        intent.putExtra("receiverName", receiverName)
        startActivityForResult(intent, 2024)
    }
}
