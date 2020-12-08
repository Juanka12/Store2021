package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.net.InetAddress;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.example.demo.entity.Login;
import com.example.demo.error.CRUD;
import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONObject;


@WebServlet("/loginClient")
public class LoginClient extends HttpServlet {

    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // InetAddress addr = InetAddress.getLocalHost();
        // String ipAddress = addr.getHostAddress();

        StringBuilder sb = new StringBuilder();
        BufferedReader br = request.getReader();
        String str = null;
        while ((str = br.readLine()) != null) {
        sb.append(str);
        }
        JSONObject json = new JSONObject(sb.toString());
        System.out.println(json);
        
        String ip = json.getString("ip");
        json.remove("ip");
        Gson g = new Gson();
        Login login = g.fromJson(json.toString(), Login.class);

        CRUD crud = new CRUD();
        JSONArray arrayJson = new JSONArray();
        arrayJson = crud.loginClient(login,ip);

        response.getWriter().write((arrayJson).toString());
      }
    
      protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
      }
}
