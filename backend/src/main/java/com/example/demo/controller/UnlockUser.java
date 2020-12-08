package com.example.demo.controller;

import java.io.IOException;
import java.net.InetAddress;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.example.demo.DAO.procedure.CallerClient;

@WebServlet("/unlockUser")
public class UnlockUser extends HttpServlet{
    private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        String uuid = request.getParameter("uuid");
        String user = request.getParameter("u");

        InetAddress addr = InetAddress.getLocalHost();

        String ipAddress = addr.getHostAddress();
        System.out.println(ipAddress);
        try {
            CallerClient caller = new CallerClient();
            caller.unlockUser(uuid,user);
            caller.emptyUUID(uuid);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("/index");
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        doPost(request, response);
    }
}
