package com.example.demo.util;

import java.util.Properties;
import java.util.UUID;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.example.demo.DAO.procedure.CallerClient;
import com.example.demo.entity.Login;

public class SendEmail implements Runnable{
  Thread thread;
  Message message;

  public void sendUserPass(String email) {

    // Cambiar esto https://www.google.com/settings/security/lesssecureapps

    Login login = null;

    try {
      CallerClient callerClient = new CallerClient();
      login = callerClient.getClient(email);
    } catch (Exception e1) {
      e1.printStackTrace();
    }
  
    final String username = "juankaInformacionPagina@gmail.com";
    final String password = "1996empresa";

    Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.port", "587");

    Session session = Session.getInstance(props,
      new javax.mail.Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(username, password);
        }
      });

    try {

        this.message = new MimeMessage(session);
        this.message.setFrom(new InternetAddress(username));
        this.message.setRecipients(Message.RecipientType.TO,
            InternetAddress.parse(email));
        this.message.setSubject("Nuevo Registro");
        this.message.setText("Usuario y contraseña,"
            + "\n\n Usuario : "+login.getUser()
            + "\n\n Contraseña : "+login.getPassword());

        this.thread = new Thread(this,"mailThread");
        this.thread.start();
    } 

    catch (MessagingException e) 
    {
        e.printStackTrace();
    }
}

  public void sendUserBlocked(Login client) {

  // Cambiar esto https://www.google.com/settings/security/lesssecureapps

  String email = null;
  String user = null;
  String uuid = UUID.randomUUID().toString();
  try {
    CallerClient callerClient = new CallerClient();
    email = callerClient.getMail(client.getUser());
    user = callerClient.getClient(email).getUser();
    callerClient.setUUID(user, uuid);
  } catch (Exception e1) {
    e1.printStackTrace();
  }

  final String username = "juankaInformacionPagina@gmail.com";
  final String password = "1996empresa";
  final String enlaceRecuperacion = "http://localhost:8085/unlockUser?";

  Properties props = new Properties();
  props.put("mail.smtp.host", "smtp.gmail.com");
  props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
  props.put("mail.smtp.starttls.enable", "true");
  props.put("mail.smtp.auth", "true");
  props.put("mail.smtp.port", "587");

  Session session = Session.getInstance(props,
    new javax.mail.Authenticator() {
      protected PasswordAuthentication getPasswordAuthentication() {
          return new PasswordAuthentication(username, password);
      }
    });

  try {

      this.message = new MimeMessage(session);
      this.message.setFrom(new InternetAddress(username));
      this.message.setRecipients(Message.RecipientType.TO,
          InternetAddress.parse(email));
      this.message.setSubject("Bloqueo de cuenta");
      this.message.setText("Esta cuenta ha sido bloqueada por actividad sospechosa"
          + "\n\n Use este enlace para desbloquearla : " + enlaceRecuperacion+"u="+user+"&uuid="+uuid);


      this.thread = new Thread(this,"mailThread");
      this.thread.start();
  } 

  catch (MessagingException e) 
  {
      e.printStackTrace();
  }
}

@Override
public void run() {
  try {
    Transport.send(this.message);
  } catch (MessagingException e) {
    e.printStackTrace();
  }
}
}