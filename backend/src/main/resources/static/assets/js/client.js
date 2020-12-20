import { ManagerFunctions } from "./modul_js/function/manager_functions.js";
import { ViewClient } from "./modul_js/view/viewClient.js";
import {d,$,Q,Qa,sS} from "./modul_js/function/global.js";
import {STRATEGY} from "./modul_js/enum/enum_stratey.js";
import { GeneralPurposeFunctions } from "./modul_js/function/general_purpose_functions.js";
import { ViewIndex } from "./modul_js/view/viewIndex.js";

let url;
const managerFunctions = new ManagerFunctions();
const viewIndex = new ViewIndex();
const viewClient = new ViewClient();

d.addEventListener("DOMContentLoaded", (e) => {
  $("myFooter").appendChild(viewIndex.Footer());
  $("myHeader").appendChild(viewIndex.HeaderClient());
  $("myBody").appendChild(viewIndex.Home());
  managerFunctions.darkLight("dark-mode");
  managerFunctions.weather();
  managerFunctions.dado();
  managerFunctions.scrollTopButton(".scroll-top-btn");
  });

d.addEventListener("click", (e) => {

  if (e.target.id == "updatePersonal") {
    url = "/getClientData";
    const globalFunction = new GeneralPurposeFunctions();
    globalFunction.resetAutoIncrementPhoneCP();
    let myBody = $("myBody");
    myBody.innerHTML = "";
    myBody.appendChild(viewClient.register());    
    managerFunctions.validations();     
    managerFunctions.phone();   
    managerFunctions.saveDataControls();
    managerFunctions.showIniStrategy(STRATEGY.ALL);
    fetch(url)
    .then(res => res.json())
    .then(out => {
      managerFunctions.fillData(out[0])
    });
  }
  if (e.target.id == "updateAccount") {
    url = "/getClientData";
    let myBody = $("myBody");
    myBody.innerHTML = "";
    myBody.appendChild(viewClient.login());
    managerFunctions.validations();
    managerFunctions.saveDataControls();
    managerFunctions.showIniStrategy(STRATEGY.ALL);
    fetch(url)
    .then(res => res.json())
    .then(out => {
      managerFunctions.fillData(out[0])
    });
  }
  if (e.target.id == "updateAvatar") {
    console.log("updateAvatar");
  }
  if (e.target.id == "logout") {
    url = "/logout";
    fetch(url)
    .then(location.reload())
  }
  if (e.target.id == "submit") {
    url = "/updateClient";
    const dataControl = managerFunctions.getDataControls();
    managerFunctions.loader().on();
    managerFunctions.ajaxForm({
      url,dataControl
    });
  }

});