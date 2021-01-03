package com.example.demo.DAO.procedure;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import com.example.demo.DAO.GetConnectionMySql;
import com.example.demo.entity.Client;
import com.example.demo.entity.Login;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

public class CallerClient extends GetConnectionMySql {

  public CallerClient() throws SQLException, ClassNotFoundException {
    super();
  }

  public Boolean existEmail(String email) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	EmailExist_client(?, ?)}");
    cstmt.setString(1, email);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public Boolean existNif(String nif) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	NifExist_client(?, ?)}");
    cstmt.setString(1, nif);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public Boolean existCP(String cp) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	CPExist_postalcode(?, ?)}");
    cstmt.setString(1, cp);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public Boolean existMobile(String cp) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	MobileExist_client(?, ?)}");
    cstmt.setString(1, cp);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public Boolean existUser(String user) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	UserExist_client(?, ?)}");
    cstmt.setString(1, user);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public Boolean isUserBlocked(String user) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	isUserBlocked(?, ?)}");
    cstmt.setString(1, user);
    cstmt.registerOutParameter(2, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(2);
  }

  public String getMail(String user) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	GetMail(?, ?)}");
    cstmt.setString(1, user);
    cstmt.registerOutParameter(2, Types.VARCHAR);
    cstmt.execute();
    return cstmt.getString(2);
  }

  public Boolean existPassword(String user, String password) throws SQLException{
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call 	PasswordExist_client(?, ?, ?)}");
    cstmt.setString(1, user);
    cstmt.setString(2, password);
    cstmt.registerOutParameter(3, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(3);
  }

  public Boolean addClient(Client client) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call AddClient(?,?,?,?,?,?,?,?,?)}");
    cstmt.setString(1, client.getName());
    cstmt.setString(2, client.getSurname());
    cstmt.setString(3, client.getNif());
    cstmt.setString(4, client.getMobile());
    cstmt.setString(5, client.getEmail());
    cstmt.setString(6, client.getBirthdate());
    cstmt.setString(7, client.getPostalCode());
    cstmt.setString(8, client.getAddress());
    cstmt.registerOutParameter(9, Types.BOOLEAN);
    cstmt.execute();
    return cstmt.getBoolean(9);
  }

  public Login getClient(String email) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call GetClient(?, ?, ?)}");

    cstmt.setString(1, email);
    cstmt.registerOutParameter(2, Types.VARCHAR);
    cstmt.registerOutParameter(3, Types.VARCHAR);
    cstmt.execute();

    Login login = new Login(cstmt.getString(2), cstmt.getString(3));
    return login;
  }
  public JSONArray getAllDataClient(int id) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call GetDataClient(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

    cstmt.setInt(1, id);
    cstmt.registerOutParameter(2, Types.VARCHAR);
    cstmt.registerOutParameter(3, Types.VARCHAR);
    cstmt.registerOutParameter(4, Types.CHAR);
    cstmt.registerOutParameter(5, Types.CHAR);
    cstmt.registerOutParameter(6, Types.VARCHAR);
    cstmt.registerOutParameter(7, Types.DATE);
    cstmt.registerOutParameter(8, Types.VARCHAR);
    cstmt.registerOutParameter(9, Types.VARCHAR);
    cstmt.registerOutParameter(10, Types.VARCHAR);
    cstmt.registerOutParameter(11, Types.VARCHAR);
    cstmt.execute();

    JSONArray json = new JSONArray();
    JSONObject oneJson = new JSONObject();
    oneJson.put("name", cstmt.getString(2));
    oneJson.put("surname", cstmt.getString(3));
    oneJson.put("nif", cstmt.getString(4));
    oneJson.put("phone_0", cstmt.getString(5));
    oneJson.put("email", cstmt.getString(6));
    oneJson.put("birthdate", cstmt.getString(7));
    oneJson.put("cp0", cstmt.getString(8));
    oneJson.put("address", cstmt.getString(9));
    oneJson.put("user", cstmt.getString(10));
    oneJson.put("password", cstmt.getString(11));
    json.put(oneJson);
    return json;
  }

  public void updateClient(Client client) throws SQLException {
    int idClient = (int) RequestContextHolder.currentRequestAttributes().getAttribute("idClient",
        RequestAttributes.SCOPE_SESSION);
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call UpdateClient(?, ?, ?, ?, ?, ?, ?, ?, ?)}");

    cstmt.setString(1, client.getName());
    cstmt.setString(2, client.getSurname());
    cstmt.setString(3, client.getNif());
    cstmt.setString(4, client.getMobile());
    cstmt.setString(5, client.getEmail());
    cstmt.setString(6, client.getBirthdate());
    cstmt.setString(7, client.getPostalCode());
    cstmt.setString(8, client.getAddress());
    cstmt.setInt(9, idClient);
    cstmt.execute();
  }
  public void updateClient(Login login) throws SQLException {
    int idClient = (int) RequestContextHolder.currentRequestAttributes().getAttribute("idClient",
        RequestAttributes.SCOPE_SESSION);
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call UpdateClientLogin(?, ?)}");

    cstmt.setString(1, login.getUser());
    cstmt.setInt(2, idClient);
    cstmt.execute();
  }

  public void unlockUser(String uuid,String user) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call UnlockUser(?,?)}");
    cstmt.setString(1, uuid);
    cstmt.setString(2, user);
    cstmt.execute();
  }

  public void blockUser(Login client) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call BlockUser(?)}");

    cstmt.setString(1, client.getUser());
    cstmt.execute();
  }

  public void setUUID(String user,String UUID) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call setUUID(?,?)}");

    cstmt.setString(1, user);
    cstmt.setString(2, UUID);
    cstmt.execute();
  }

  public void emptyUUID(String UUID) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call emptyUUID(?)}");

    cstmt.setString(1, UUID);
    cstmt.execute();
  }

  public int getClientID(String user) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call GetClientID(?,?)}");

    cstmt.setString(1, user);
    cstmt.registerOutParameter(2, Types.TINYINT);
    cstmt.execute();

    return cstmt.getInt(2);
  }
  public void blockIP(String ip) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call blockIP(?)}");

    cstmt.setString(1, ip);
    cstmt.execute();
  }
  public void registerIP(JSONObject json) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call RegisterIP(?,?,?,?)}");

    cstmt.setString(1, json.getString("ip"));
    cstmt.setString(2, json.getString("city"));
    cstmt.setString(3, json.getString("country"));
    cstmt.setInt(4, json.getInt("idClient"));
    cstmt.execute();
  }
}
