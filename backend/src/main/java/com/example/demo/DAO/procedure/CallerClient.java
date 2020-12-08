package com.example.demo.DAO.procedure;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import com.example.demo.DAO.GetConnectionMySql;
import com.example.demo.entity.Client;
import com.example.demo.entity.Login;

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

  public void blockIP(String ip) throws SQLException {
    CallableStatement cstmt = (CallableStatement) connection.prepareCall("{call blockIP(?)}");

    cstmt.setString(1, ip);
    cstmt.execute();
  }
}
