package com.example.demo.error;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import net.minidev.json.JSONObject;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import com.example.demo.DAO.procedure.CallerClient;
import com.example.demo.entity.Client;
import com.example.demo.entity.Login;
import com.example.demo.util.AddErrorArrayError;
import com.example.demo.util.GenerateString;
import com.example.demo.util.GetDataControlFromValue;
import com.example.demo.util.SendEmail;
import com.example.demo.validate.ValidatorLengthComposite;
import com.example.demo.validate.ValidatorValueComposite;
import com.example.demo.verify.VerifyClient;
import com.google.gson.Gson;

public class CRUD {
  final int limiteLogin = 3;
  HashMap<String, ArrayList<ErrorValidate>> errorsValidation = new HashMap<String, ArrayList<ErrorValidate>>();
  HashMap<String, ErrorVerify> errorsVerification = new HashMap<String, ErrorVerify>();
  JSONArray arrayJson = new JSONArray();
  CallerClient caller;

  public JSONArray addClient(Client client) {
    errorsValidation = getErrorsLength(client);
    Boolean error = false;
    if (errorsValidation.isEmpty()) {
      errorsValidation = getErrorsValue(client);
      if (errorsValidation.isEmpty()) {
        try {
          errorsVerification = getErrorsVerify(client);
        } catch (SQLException e) {
          e.printStackTrace();
        }
        if (errorsVerification.isEmpty()) {
          try {
            caller = new CallerClient();

            if (caller.addClient(client)) {
              int idClient = caller.getClientID(caller.getClient(client.getEmail()).getUser());
              RequestContextHolder.currentRequestAttributes().setAttribute("idClient", idClient,
                RequestAttributes.SCOPE_SESSION);
              successfullAction("addClient");
              
              SendEmail mail = new SendEmail();
              mail.sendUserPass(client.getEmail());
            } else {
              failedAction("addClient");
            }
          } catch (ClassNotFoundException | SQLException e) {

            e.printStackTrace();
          }

        } else {
          for (java.util.Map.Entry<String, ErrorVerify> entry : errorsVerification.entrySet()) {
            JSONObject oneJson = new JSONObject();
            oneJson.put("messageErrorControl", entry.getValue().getMsgEs());
            oneJson.put("messageValueControl", entry.getKey());
            oneJson.put("messageNameControl", GetDataControlFromValue.getDataControlClient(client, entry.getKey()));
            arrayJson.put(oneJson);
        }
        }

      } else {
        error = true;
      }
    } else {
      error = true;
    }
    if (error) {
      for (java.util.Map.Entry<String, ArrayList<ErrorValidate>> entry : errorsValidation.entrySet()) {
        ArrayList<ErrorValidate> myerror = entry.getValue();
        myerror.forEach((n) -> {
          JSONObject oneJson = new JSONObject();
          oneJson.put("messageErrorControl", n.getMsgEs());
          oneJson.put("messageValueControl", entry.getKey());
          oneJson.put("messageNameControl", GetDataControlFromValue.getDataControlClient(client, entry.getKey()));
          arrayJson.put(oneJson);
        });
      }
    }
    return arrayJson;
  }

  public JSONArray loginClient(Login client){
    CallerClient caller;
    errorsValidation = getErrorsLength(client);
    Boolean error = false;
    if (errorsValidation.isEmpty()) {
      errorsValidation = getErrorsValue(client);
      if (errorsValidation.isEmpty()) {
        try {
          errorsVerification = getErrorsVerify(client);
        } catch (SQLException e) {
          e.printStackTrace();
        }
        if (errorsVerification.isEmpty()) {
          successfullAction("loginClient");
          try {
           caller = new CallerClient();
           int idClient = caller.getClientID(client.getUser()); 
           RequestContextHolder.currentRequestAttributes().setAttribute("idClient", idClient,
           RequestAttributes.SCOPE_SESSION);
          } catch (Exception e) {
          }
        } else {
          int contador = Integer.parseInt(RequestContextHolder.currentRequestAttributes().getAttribute("intentos",
          RequestAttributes.SCOPE_SESSION).toString());
          contador++;
          RequestContextHolder.currentRequestAttributes().setAttribute("intentos", contador,
          RequestAttributes.SCOPE_SESSION);
          if (contador>=limiteLogin) {
            try {
              caller = new CallerClient();
              if (caller.existUser(client.getUser())) {
                caller.blockUser(client);
                SendEmail mail = new SendEmail();
                mail.sendUserBlocked(client);
                JSONObject oneJson = new JSONObject();
                oneJson.put("error", 2);
                oneJson.put("message", "Usuario bloqueado se envio un mail");
                oneJson.put("submitName", "submit");
                oneJson.put("errorboxSubmit", "boxerror_submit");
                arrayJson.put(oneJson);
              }else{
                // caller.blockIP(ip);
                JSONObject oneJson = new JSONObject();
                oneJson.put("error", 2);
                oneJson.put("message", "Sobrepasado el numero de intentos");
                oneJson.put("submitName", "submit");
                oneJson.put("errorboxSubmit", "boxerror_submit");
                arrayJson.put(oneJson);
              }
              RequestContextHolder.currentRequestAttributes().setAttribute("intentos", 0,
                RequestAttributes.SCOPE_SESSION);

            } catch (Exception e) {
              System.out.println(e);
            }
          }
          for (java.util.Map.Entry<String, ErrorVerify> entry : errorsVerification.entrySet()) {
              JSONObject oneJson = new JSONObject();
              oneJson.put("messageErrorControl", entry.getValue().getMsgEs());
              oneJson.put("messageValueControl", entry.getKey());
              oneJson.put("messageNameControl", GetDataControlFromValue.getDataControlClient(client, entry.getKey()));
              arrayJson.put(oneJson);
          }
        }

      } else {
        error = true;
      }
    } else {
      error = true;
    }
    if (error) {
      for (java.util.Map.Entry<String, ArrayList<ErrorValidate>> entry : errorsValidation.entrySet()) {
        ArrayList<ErrorValidate> myerror = entry.getValue();
        myerror.forEach((n) -> {
          JSONObject oneJson = new JSONObject();
          oneJson.put("messageErrorControl", n.getMsgEs());
          oneJson.put("messageValueControl", entry.getKey());
          oneJson.put("messageNameControl", GetDataControlFromValue.getDataControlClient(client, entry.getKey()));
          arrayJson.put(oneJson);
        });
      }
    }
    return arrayJson;
  }

  public void logoutClient(){
    RequestContextHolder.currentRequestAttributes().setAttribute("activePage", "index",
    RequestAttributes.SCOPE_SESSION);

    RequestContextHolder.currentRequestAttributes().setAttribute("idClient", null,
    RequestAttributes.SCOPE_SESSION);
  }

  public JSONArray clientData(){
    int idClient = (int) RequestContextHolder.currentRequestAttributes().getAttribute("idClient",
        RequestAttributes.SCOPE_SESSION);
    try {
      caller = new CallerClient();
      arrayJson = caller.getAllDataClient(idClient);
    } catch (Exception e) {
      e.printStackTrace();
    }
    return arrayJson;
  }

  public JSONArray updateClient(org.json.JSONObject json) {

    Gson gson = new Gson();
    if (json.has("user")) {
      Login login = gson.fromJson(json.toString(), Login.class);
      try {
        caller = new CallerClient();
        caller.updateClient(login);
        SendEmail mail = new SendEmail();
        mail.sendNewPass(login);
        successfullAction("update");
      } catch (Exception e) {
        e.printStackTrace();
      }
    }else{
      Client client = gson.fromJson(json.toString(), Client.class);
      try {
        caller = new CallerClient();
        caller.updateClient(client);
        successfullAction("update");
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return arrayJson;
  }

  public JSONArray newPassword(String dni){
    String newPassword = GenerateString.getPassword(10);
    try {
      CallerClient caller = new CallerClient();
      String email = caller.getMailByDni(dni);
      String user = caller.getClient(email).getUser();
      Login login = new Login(user,newPassword);
      caller.updateClient(login);
      SendEmail mail = new SendEmail();
      mail.sendNewPass(login);
      JSONObject oneJson = new JSONObject();
      oneJson.put("error", 0);
      oneJson.put("validation", "ok");
      oneJson.put("verification", "ok");
      oneJson.put("New Password", "ok");
      arrayJson.put(oneJson);
    } catch (Exception e) {
      e.printStackTrace();
    } 
    return arrayJson;
  }

  private HashMap<String, ArrayList<ErrorValidate>> getErrorsValue(Client client) {
    HashMap<String, ArrayList<ErrorValidate>> errorsAll = new HashMap<>();
    errorsAll = new AddErrorArrayError(new ValidatorValueComposite().validate(client), errorsAll).getErrorsAll();
    return errorsAll;
  }

  private HashMap<String, ArrayList<ErrorValidate>> getErrorsLength(Client client) {
    HashMap<String, ArrayList<ErrorValidate>> errorsAll = new HashMap<>();
    errorsAll = new AddErrorArrayError(new ValidatorLengthComposite().validate(client), errorsAll).getErrorsAll();
    return errorsAll;
  }

  private HashMap<String, ArrayList<ErrorValidate>> getErrorsValue(Login client) {
    HashMap<String, ArrayList<ErrorValidate>> errorsAll = new HashMap<>();
    errorsAll = new AddErrorArrayError(new ValidatorValueComposite().validate(client), errorsAll).getErrorsAll();
    return errorsAll;
  }

  private HashMap<String, ArrayList<ErrorValidate>> getErrorsLength(Login client) {
    HashMap<String, ArrayList<ErrorValidate>> errorsAll = new HashMap<>();
    errorsAll = new AddErrorArrayError(new ValidatorLengthComposite().validate(client), errorsAll).getErrorsAll();
    return errorsAll;
  }

  private HashMap<String, ErrorVerify> getErrorsVerify(Client client) throws SQLException {
    VerifyClient verifyClient = null;
    try {
      verifyClient = new VerifyClient();
    } catch (ClassNotFoundException e) {

      e.printStackTrace();
    } catch (SQLException e) {

      e.printStackTrace();
    }
    return verifyClient.verify(client);
  }

  private HashMap<String, ErrorVerify> getErrorsVerify(Login client) throws SQLException {
    VerifyClient verifyClient = null;
    try {
      verifyClient = new VerifyClient();
    } catch (ClassNotFoundException e) {

      e.printStackTrace();
    } catch (SQLException e) {

      e.printStackTrace();
    }
    return verifyClient.verify(client);
  }

  private void successfullAction(String action) {
    RequestContextHolder.currentRequestAttributes().setAttribute("activePage", "client",
    RequestAttributes.SCOPE_SESSION);
    
    JSONObject oneJson = new JSONObject();
    oneJson.put("error", 0);
    oneJson.put("validation", "ok");
    oneJson.put("verification", "ok");
    oneJson.put(action, "ok");
    arrayJson.put(oneJson);
  }

  private void failedAction(String action) {
    JSONObject oneJson = new JSONObject();
    oneJson.put("error", 1);
    oneJson.put("validation", "ok");
    oneJson.put("verification", "ok");
    oneJson.put(action, "error");
    arrayJson.put(oneJson);
  }

}