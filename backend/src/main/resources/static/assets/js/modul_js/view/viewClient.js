import {FactoryView} from "../factory/factoryView.js"

export function ViewClient() {

  
  const API = {};
  const factoryView = FactoryView();
  
  API.register = function () {
    return factoryView.clientRegister();
  };

  API.login = function () {
    return factoryView.clientLogin();
  }

  API.avatar = function() {
    return factoryView.updateAvatar();
  }

  API.forgotPassword = function() {
    return factoryView.forgotPassword();
  }
  return API;
}
