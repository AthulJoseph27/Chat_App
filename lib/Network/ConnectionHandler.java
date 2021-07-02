import java.net.Socket;
import java.io.*;
import java.util.*;

class ConnectionHandler implements Runnable {
    private Socket clientSocket;
    private BufferedReader in;
    private PrintWriter out;
    private String id = "-1";
    public String userName;
    public boolean exit = false;
    private static final String _MESSAGE = "1";
    private static final String _MY_ID = "2";
    private static final String _STOP = "3";
    private static final String _CHECK_USER_NAME = "4";
    private static final String _SEPARATOR = "##CHAT_SERVICE##";
    private static final String _USER_ID = "CHAT_ROOM_KEY=USER_ID";
    private static final String _AVAILABLE = "__A_V_A_I_L_A_B_L_E__";
    private static final String _NOT_AVAILABLE = "__N_O_T___A_V_A_I_L_A_B_L_E__";
    private static final String _GET_USERS = "__GET_ONLINE_USERS__";
    private static final String _GROUP_MESSAGE = "___GROUP_MESSAGE___";

    ConnectionHandler(Socket clientSocket) throws IOException {
        this.clientSocket = clientSocket;
        this.in = new BufferedReader(new InputStreamReader(this.clientSocket.getInputStream(),"UTF-8"));
        this.out = new PrintWriter(this.clientSocket.getOutputStream(), true);
    }

    public void NotifyAboutNewConnection(List<String> onlineUsers){
        String dt = _GET_USERS + _SEPARATOR;
        for (String users : onlineUsers)
            dt += (users + ";<SPLIT>;");

        out.println(dt);
    }

    @Override
    public void run() {
        try {

            String message = in.readLine();

            String[] data = message.split(_SEPARATOR);

            if (!data[0].equals(_MY_ID)) {
                // STOP CONNECTION
            }

            if (data[1].equals("-1")) {
                id = Server.getRandomId();
                out.println((_MY_ID + _SEPARATOR + id+_SEPARATOR));
            } else {
                id = data[1];
                userName = Server.getUserName(id);
                out.println(message);
            }

            while (!exit) {
                message = in.readLine();
                data = message.split(_SEPARATOR);

                if (data[0].equals(_CHECK_USER_NAME)) {
                    if (Server.isUserNameAvailable(data[1])) {
                        out.println((_CHECK_USER_NAME + _SEPARATOR + _AVAILABLE+_SEPARATOR));
                        userName = data[1];
                        Server.NotifyNewConnection();

                    } else {
                        out.println((_CHECK_USER_NAME + _SEPARATOR + _NOT_AVAILABLE+_SEPARATOR));
                    }
                } else if (data[0].equals(_MESSAGE)) {
                    // [to,from,message]
                    Server.sentMessage(data[1], data[2], data[3]);
                } else if (data[0].equals(_GET_USERS)) {
                    List<String> onlineUsers = Server.getOnlineUsers();
                    String dt = _GET_USERS + _SEPARATOR;
                    for (String users : onlineUsers)
                        dt += (users + ";<SPLIT>;");

                    out.println(dt);
                }else if(data[0].equals(_STOP)){
                    Server.removeUser(userName);
                }

            }
        } catch (IOException e) {
            System.err.println("IOException in ConnectionHandler");
            e.printStackTrace();
        } finally {
            out.close();
            try {
                in.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean sendMessage(String fromUser, String message, boolean groupMessage) {

        try {
            if (groupMessage) {
                message = _GROUP_MESSAGE + _SEPARATOR + fromUser + _SEPARATOR + _GROUP_MESSAGE + _SEPARATOR + message+_SEPARATOR;
            } else {
                message = _MESSAGE + _SEPARATOR + fromUser + _SEPARATOR + userName + _SEPARATOR + message+_SEPARATOR;
            }
            out.println(message);
        } catch (Exception e) {
            return false;
        }

        return true;
    }
}