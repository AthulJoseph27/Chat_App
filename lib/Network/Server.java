import java.net.Socket;
import java.net.ServerSocket;
import java.io.*;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

class Server {
    private static ServerSocket serverSocket;
    private static final int PORT = 9086;
    private static List<ConnectionHandler> connections = new ArrayList<>();
    private static ExecutorService pool = Executors.newFixedThreadPool(50);
    private static final String AlphaNumericString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvxyz";
    private static HashMap<String, Boolean> ids = new HashMap<>();
    private static HashMap<String, Boolean> userNames = new HashMap<>();
    private static HashMap<String, String> allPeoples = new HashMap<>();

    public static void main(String[] args) throws IOException {
        serverSocket = new ServerSocket(PORT);
        waitForConnections();
    }

    private static void waitForConnections() throws IOException {
        while (true) {
            System.out.println("[SERVER] Waiting for connection...");
            Socket client = serverSocket.accept();
            System.out.println("[SERVER] Connected to client");
            ConnectionHandler connectionHandler = new ConnectionHandler(client);
            connections.add(connectionHandler);
            pool.execute(connectionHandler);
        }
    }

    public static void removeUser(String userName){
        for(int i=0;i<connections.size();i++){
            if(connections.get(i).userName.equals(userName)){
                connections.get(i).exit = true;
                connections.remove(i);
                break;
            }
        }
    }

    public static void NotifyNewConnection(){
        List<String> onlineUsers = Server.getOnlineUsers();

        for(ConnectionHandler cHandler: connections){
            cHandler.NotifyAboutNewConnection(onlineUsers);
        }

    }

    public static List<String> getOnlineUsers() {
        List<String> list = new ArrayList<>();

        for (ConnectionHandler cl : connections) {
            list.add(cl.userName);
        }

        return list;
    }

    private static boolean isIdAvailable(String id) {
        return !ids.containsKey(id);
    }

    public static String getUserName(String id) {
        return allPeoples.get(id);
    }

    public static String getRandomId() {
        int n = 10;

        StringBuilder sb;
        do {
            sb = new StringBuilder(n);;
            for (int i = 0; i < n; i++) {
                int index = (int)(Math.random() * (double)AlphaNumericString.length());
                sb.append(AlphaNumericString.charAt(index));
            }
        } while (!isIdAvailable(sb.toString()));

        ids.put(sb.toString(), true);

        return sb.toString();
    }

    public static boolean isUserNameAvailable(String userName) {
        System.out.println("Checking Availablity for "+userName);
        return !userNames.containsKey(userName);
    }

    public static boolean sentMessage(String toUserName, String fromUserName, String message) {

        try {
            if (toUserName.equals("^___GROUP_MESSAGE___")) {
                for (ConnectionHandler cHandler : connections) {
                    cHandler.sendMessage(fromUserName, message,true);
                }
            } else {
                for (ConnectionHandler cHandler : connections) {
                    if (cHandler.userName.equals(toUserName)) {
                        cHandler.sendMessage(fromUserName, message,false);
                        return true;
                    }
                }

                return false;
            }

        } catch (Exception e) {
            return false;
        }

        return true;
    }
}