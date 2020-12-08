package com.example.demo.controller;

import java.sql.SQLException;

import com.example.demo.DAO.procedure.CallerPage;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

@RestController
public class IndexController {
  @GetMapping("/index")
  public String index() throws ClassNotFoundException, SQLException {
    String myActivePage = "";
    String myIdSession = "";
    int myRecharge = 0;
    String html = "";
    CallerPage callerpage = new CallerPage();

    if (RequestContextHolder.currentRequestAttributes().getAttribute("activePage",
        RequestAttributes.SCOPE_SESSION) == null) {
        
      RequestContextHolder.currentRequestAttributes().setAttribute("intentos", "0",
          RequestAttributes.SCOPE_SESSION);
      RequestContextHolder.currentRequestAttributes().setAttribute("activePage", "index",
          RequestAttributes.SCOPE_SESSION);
      RequestContextHolder.currentRequestAttributes().setAttribute("idSession",
          RequestContextHolder.currentRequestAttributes().getSessionId(), RequestAttributes.SCOPE_SESSION);
      RequestContextHolder.currentRequestAttributes().setAttribute("recharge", 0, RequestAttributes.SCOPE_SESSION);
      myActivePage = (String) RequestContextHolder.currentRequestAttributes().getAttribute("activePage",
          RequestAttributes.SCOPE_SESSION);
      callerpage.addVisit(myActivePage);
      myIdSession = (String) RequestContextHolder.currentRequestAttributes().getAttribute("idSession",
          RequestAttributes.SCOPE_SESSION);
      myRecharge = (int) RequestContextHolder.currentRequestAttributes().getAttribute("recharge",
          RequestAttributes.SCOPE_SESSION);
    }
    if (RequestContextHolder.currentRequestAttributes().getAttribute("idSession",
        RequestAttributes.SCOPE_SESSION) == RequestContextHolder.currentRequestAttributes().getSessionId()) {
      myActivePage = (String) RequestContextHolder.currentRequestAttributes().getAttribute("activePage",
          RequestAttributes.SCOPE_SESSION);
      myIdSession = (String) RequestContextHolder.currentRequestAttributes().getAttribute("idSession",
          RequestAttributes.SCOPE_SESSION);
      myRecharge = (int) RequestContextHolder.currentRequestAttributes().getAttribute("recharge",
          RequestAttributes.SCOPE_SESSION);
      myRecharge++;
      RequestContextHolder.currentRequestAttributes().setAttribute("recharge", myRecharge,
          RequestAttributes.SCOPE_SESSION);

      return callerpage.getPage(myActivePage);

    }

    return html;

  }
}
