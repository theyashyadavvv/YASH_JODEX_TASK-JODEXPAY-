package com.example.host_flutter_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import kotlin.random.Random

class FakeUpiActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_fake_upi)

        val amount = intent.getIntExtra("amount", 0)
        val upiId = intent.getStringExtra("upiId") ?: ""
        val receiverName = intent.getStringExtra("receiverName") ?: ""

        findViewById<TextView>(R.id.textAmount).text = "Amount: ₹$amount"
        findViewById<TextView>(R.id.textUpiId).text = "UPI ID: $upiId"
        findViewById<TextView>(R.id.textReceiver).text = "To: $receiverName"

        val passwordField = findViewById<EditText>(R.id.editPassword)
        val payButton = findViewById<Button>(R.id.buttonPay)

        payButton.setOnClickListener {
            // You can check password here if you want
            val isSuccess = Random.nextBoolean() // 50% chance
            val resultIntent = Intent()
            val status = if (isSuccess) "success" else "failure"
            val txnId = if (isSuccess) "TXN${System.currentTimeMillis()}" else ""
            resultIntent.putExtra("result", status)
            resultIntent.putExtra("transactionId", txnId)
            setResult(Activity.RESULT_OK, resultIntent)
            finish()
        }
    }
} 