import { FactoryTag } from "./factoryTag.js";

export function FactoryImg() {
  const factoryTag = new FactoryTag();
   const API = {};
  let params = {};
  
  API.loader = function(type){
      params = {};
    params.id = "loader";   
    params.class = "loaderjm";   
    params.alt = "Cargando ...";
    params.src = "../../../assets/img/SVG_loader/" + type + ".svg"; 
    return factoryTag.img(params);
  };

  return API;
}
