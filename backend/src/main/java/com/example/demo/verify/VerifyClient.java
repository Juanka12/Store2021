package com.example.demo.verify;

import java.sql.SQLException;
import java.util.HashMap;

import com.example.demo.DAO.procedure.CallerClient;
import com.example.demo.entity.Client;
import com.example.demo.entity.Login;
import com.example.demo.error.ErrorVerify;

public class VerifyClient {
  CallerClient callerClient = null;
  HashMap<String, ErrorVerify> errors;

  public VerifyClient() throws ClassNotFoundException, SQLException {
    callerClient = new CallerClient();
    errors = new HashMap<String, ErrorVerify>();
  }

  public HashMap<String, ErrorVerify> verify(Client client) throws SQLException {

    if (callerClient.existEmail(client.getEmail())) {
      errors.put(client.getEmail(), ErrorVerify.EMAILEXITS);
    }
    if (callerClient.existNif(client.getNif())) {
      errors.put(client.getNif(), ErrorVerify.NIFEXITS);
    }
    if (!callerClient.existCP(client.getPostalCode())) {
      errors.put(client.getPostalCode(), ErrorVerify.POSTALCODENOTEXIST);
    }
    if (callerClient.existMobile(client.getMobile())) {
      errors.put(client.getMobile(), ErrorVerify.MOBILEEXIST);
    }

    return errors;

  }

  public HashMap<String, ErrorVerify> verify(Login client) throws SQLException {

    if (!callerClient.existUser(client.getUser())) {
      errors.put(client.getUser(), ErrorVerify.USERNOTEXIST);
      return errors;
    }else if (callerClient.isUserBlocked(client.getUser())) {
      errors.put(client.getUser(), ErrorVerify.USERBLOCKED);
      return errors;
      }else if (!callerClient.existPassword(client.getUser(), client.getPassword())) {
        errors.put(client.getPassword(), ErrorVerify.PASSWORDWRONG);
        return errors;
      }
    return errors;
  }

}
