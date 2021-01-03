import {FactoryView} from "../factory/factoryView.js"

export function ViewClient() {

  
  const API = {};
  
  API.register = function () {
    const factoryView = FactoryView();
    return factoryView.clientRegister();
  };

  API.login = function () {
    const factoryView = FactoryView();
    return factoryView.clientLogin();
  }

  API.avatar = function() {
    const factoryView = FactoryView();
    return factoryView.updateAvatar();
  }
  return API;
}
