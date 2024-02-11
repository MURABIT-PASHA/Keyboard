package tech.murabit.keyboard;

import androidx.annotation.NonNull;

import java.util.logging.Logger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "tech.murabit/method";
    private static final Logger LOGGER = Logger.getLogger("MURABIT LOG");
    SocketManager socketManager = new SocketManager();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("sendMessage")) {
                                String message = call.argument("message");
                                String address = call.argument("address");
                                LOGGER.info(message);
                                socketManager.sendMessage(address, message);
                                result.success("Success");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
