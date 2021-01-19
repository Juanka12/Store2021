import { ManagerFunctions } from "./modul_js/function/manager_functions.js";
import { ViewClient } from "./modul_js/view/viewClient.js";
import { ViewIndex } from "./modul_js/view/viewIndex.js";
import {d,$,Q,Qa,sS} from "./modul_js/function/global.js";
import {STRATEGY} from "./modul_js/enum/enum_stratey.js";
import { GeneralPurposeFunctions } from "./modul_js/function/general_purpose_functions.js";

let url;
const managerFunctions = new ManagerFunctions();
const viewClient = new ViewClient();
const viewIndex = new ViewIndex();

d.addEventListener("DOMContentLoaded", (e) => {
  $("myFooter").appendChild(viewIndex.Footer());
  $("myHeader").appendChild(viewIndex.Header());
  $("myBody").appendChild(viewIndex.Home());
  managerFunctions.darkLight("dark-mode");
  managerFunctions.weather();
  managerFunctions.CreateBBDDpostalCode();
  managerFunctions.dado();
  managerFunctions.scrollTopButton(".scroll-top-btn");
});

d.addEventListener("click", (e) => {
  let myBody = $("myBody");
  if (e.target.id == "linkRegister") {
     url = "/addClient";
     const globalFunction = new GeneralPurposeFunctions();
      globalFunction.resetAutoIncrementPhoneCP();
      myBody.innerHTML = "";
      myBody.appendChild(viewClient.register());    
      managerFunctions.validations();     
      managerFunctions.phone();   
     managerFunctions.saveDataControls();
     managerFunctions.showIniStrategy(STRATEGY.ONETOONE);
  }
  if (e.target.id == "linkLogin") {
    url = "/loginClient";
    myBody.innerHTML = "";
    myBody.appendChild(viewClient.login());
    managerFunctions.validations();
    managerFunctions.saveDataControls();
    managerFunctions.showIniStrategy(STRATEGY.ALL);
  }
  if (e.target.id == "forgotPassword") {
    url = "/forgotPassword";
    myBody.innerHTML = "";
    myBody.appendChild(viewClient.forgotPassword());
    managerFunctions.validations();
    managerFunctions.saveDataControls();
    managerFunctions.showIniStrategy(STRATEGY.ALL);
    $("informationPanel").innerHTML = "Le haremos llegar una nueva contraseña a su email";
  }
  if (e.target.id == "submit") {
    const dataControl = managerFunctions.getDataControls();
    managerFunctions.loader().on();
    managerFunctions.ajaxForm({
      url,dataControl
    });
   }
});
