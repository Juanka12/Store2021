package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.util.Base64;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.json.JSONObject;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

@WebServlet("/updateAvatar")
public class UpdateAvatar extends HttpServlet{
    
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        StringBuilder sb = new StringBuilder();
        BufferedReader br = request.getReader();
        String str = null;
        while ((str = br.readLine()) != null) {
        sb.append(str);
        }
        JSONObject json = new JSONObject(sb.toString());

        String base64 = json.getString("file").substring(json.getString("file").indexOf(",")+1);
        int idClient = (int) RequestContextHolder.currentRequestAttributes().getAttribute("idClient",
        RequestAttributes.SCOPE_SESSION);
        
        byte[] decodedBytes = Base64.getDecoder().decode(base64);
        FileUtils.writeByteArrayToFile(new File("src\\main\\resources\\static\\assets\\avatar\\Avatar" + idClient + ".png"), decodedBytes);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    } 
}
