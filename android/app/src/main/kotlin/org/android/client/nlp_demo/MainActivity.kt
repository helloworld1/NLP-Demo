package org.android.client.nlp_demo

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.liberty.android.nlplib.bertqa.ml.QaClient

class MainActivity: FlutterActivity(), CoroutineScope by MainScope() {
    
    private val CHANNEL = "org.android.client.nlp_demo.channel"
    
    private var qaClient: QaClient? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        launch {
            qaClient = initQaClient()
        }
    }


    override fun onDestroy() {
        super.onDestroy()
        cancel()

        //qaClient?.unload()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getAnswer" -> {
                            val context = call.argument<String>("context") ?: ""
                            val question = call.argument<String>("question") ?: ""
                            launch {
                                result.success(getAnswer(context, question))
                            }
                        }
                        else -> result.notImplemented()
                    }
                }

    }

    suspend fun initQaClient(): QaClient {
        return withContext(Dispatchers.Default) {
            val client = QaClient(this@MainActivity)
            client.loadModel()
            client.loadDictionary()

            client
        }
    }

    suspend fun getAnswer(context: String, question: String): Map<String,  String> {
        return withContext(Dispatchers.Default) {
            val predicts = qaClient?.predict(question, context)

            val predict = predicts?.get(0)
            mapOf(
                    "answerText" to "${predict?.text}",
                    "startPosition" to "${predict?.pos?.start ?: 0}",
                    "endPosition" to "${predict?.pos?.end ?: 0}"
            )
        }
    }
}
