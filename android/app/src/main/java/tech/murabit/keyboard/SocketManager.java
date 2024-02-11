package tech.murabit.keyboard;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.logging.Logger;

public class SocketManager {
    private static final Logger LOGGER = Logger.getLogger("KEYBOARD");
    Socket mSocket;
    PrintWriter mPrintWriter;

    private static final int PORT = 7800;

    public void sendMessage(String address, String message){
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    mSocket = new Socket(address, PORT);
                    mPrintWriter = new PrintWriter(mSocket.getOutputStream());
                    mPrintWriter.write(message);
                    mPrintWriter.flush();
                    mPrintWriter.close();
                    mSocket.close();
                } catch (IOException e) {
                    LOGGER.info(e.getMessage());
                }
            }
        });
        thread.start();
    }

}
