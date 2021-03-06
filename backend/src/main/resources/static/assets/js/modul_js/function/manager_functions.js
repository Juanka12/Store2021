import { COLOR } from "../enum/enum_color.js";
import { STRATEGY } from "../enum/enum_stratey.js";
import { w, d, $, lS, sS, Q, Qa } from "./global.js";
import { ValidateUtil, Validations } from "../factory/factoryValidation.js";

export function ManagerFunctions() {
  const API = {};

  API.darkLight = function (classDark) {
    const $selectors = Qa("[data-dark]");
    const $btn = $("darkMode");

    const setThemeInitial = function () {
      if (lS.getItem("theme") === null) {
        lS.setItem("theme", "light");
      } else {
        if (lS.getItem("theme") === "light") {
          $btn.value = "light";
          $selectors.forEach((el) => el.classList.remove(classDark));
        } else {
          $btn.value = "dark";
          $selectors.forEach((el) => el.classList.add(classDark));
        }
      }
    };
    const changeMode = (e) => {
      let state = "";
      e.target.value === "light" ? (state = "dark") : (state = "light");
      $selectors.forEach((el) => el.classList.toggle(classDark));
      e.target.value = state;
      lS.setItem("theme", state);
    };
    d.addEventListener("click", (e) => {
      if (e.target.id === "darkMode") {
        changeMode(e);
      }
    });
    setThemeInitial();
  };

  API.weather = function () {
    const key = "00c14c9fa75c8b84d8f1492058ac4369";
    if (key == "") $("temp").innerHTML = "Remember to add your api key!";

    function weatherBallon(cityID) {
      //fetch('https://api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=00c14c9fa75c8b84d8f1492058ac4369')
      //fetch('https://api.openweathermap.org/data/2.5/weather?id=' + cityID+ '&appid=' + key)
      //fetch('https://api.openweathermap.org/data/2.5/weather?q=arroyo de san servan,spain&APPID=00c14c9fa75c8b84d8f1492058ac4369')
      fetch(
        "https://api.openweathermap.org/data/2.5/weather?q=almendralejo,spain&APPID=00c14c9fa75c8b84d8f1492058ac4369"
      )
        .then(function (resp) {
          return resp.json();
        }) // Convert data to json
        .then(function (data) {
          drawWeather(data);
        })
        .catch(function () {
          // catch any errors
        });
    }
    function drawWeather(data) {
      var celcius = Math.round(parseFloat(data.main.temp) - 273.15);
      var fahrenheit = Math.round(
        (parseFloat(data.main.temp) - 273.15) * 1.8 + 32
      );
      var description = data.weather[0].description;

      $("description").innerHTML = description;
      $("temp").innerHTML = celcius + "&deg;";
      $("location").innerHTML = data.name;

      if (description.indexOf("rain") > 0) {
        $("myHome").className = "cwbody rainy";
      } else if (description.indexOf("cloud") > 0) {
        $("myHome").className = "cwbody cloudy";
      } else if (description.indexOf("sunny") > 0) {
        $("myHome").className = "cwbody sunny";
      } else {
        $("myHome").className = "cwbody clear";
      }
    }

    weatherBallon(4167865);
    //weatherBallon(6167865);
  };

  API.scrollTop = function (btn) {
    const $scrollBtn = d.querySelector(btn);

    w.addEventListener("scroll", (e) => {
      let scrollTop = w.pageYOffset || d.documentElement.scrollTop;
      if (scrollTop > 600) {
        $scrollBtn.classList.remove("hidden");
      } else {
        $scrollBtn.classList.add("hidden");
      }
      // console.log(w.pageXOffset,d.documentElement.scrollTop);
    });
    d.addEventListener("click", (e) => {
      if (e.target.matches(btn)) {
        w.scrollTo({
          behavior: "smooth",
          top: 0,
        });
      }
    });
  };

  API.validations = function () {
    d.addEventListener("keyup", (e) => {
      if (e.target.matches("[data-validate]")) {
        e.code == "Enter" || e.code == "Tab"
          ? eval(sS.getItem("strategy"))
          : eval(e.target.dataset.validate + "(e)");
      }
    });
  };

  API.phone = function () {
    "use strict";

    const COUNTRYPATTERN = {
      REGEX_FRANCE_FIJO: "^[0-9]{9}$", ///^[1-9](\d{2}){4}$
      REGEX_FRANCE_MOVIL: "^[6|7][0-9]{8}$",
      REGEX_SPAIN_FIJO: "^[9][0-9]{8}$",
      REGEX_SPAIN_MOVIL: "^[6|7][0-9]{8}$",
      REGEX_US_FIJO: "^[0-9]{10}$",
      REGEX_US_MOVIL: "^[0-9]{10}$",
    };
    const Prefix = [
      {
        default: true,
        prefijo: "ES",
        value: "+34",
        maximo: 9,
        flag: "es.png",
        mobile: COUNTRYPATTERN.REGEX_SPAIN_MOVIL,
        landline: COUNTRYPATTERN.REGEX_SPAIN_FIJO,
      },
      {
        prefijo: "FR",
        value: "+33",
        maximo: 9,
        flag: "fr.png",
        mobile: COUNTRYPATTERN.REGEX_FRANCE_MOVIL,
        landline: COUNTRYPATTERN.REGEX_FRANCE_FIJO,
      },
      {
        prefijo: "US",
        value: "+1",
        maximo: 10,
        flag: "us.png",
        mobile: COUNTRYPATTERN.REGEX_US_MOVIL,
        landline: COUNTRYPATTERN.REGEX_US_FIJO,
      },
    ];
    function updateChanges(phoneNumber, idCountry, phoneType) {
      eval(
        "sS.setItem('pattern_'+" +
          phoneNumber +
          ", Prefix[" +
          idCountry +
          "]." +
          phoneType +
          ")"
      );
      sS.setItem("numberLength_" + phoneNumber, Prefix[idCountry].maximo);
      $("phone_" + phoneNumber).setAttribute(
        "maxlength",
        Prefix[idCountry].maximo
      );
      $("phone_" + phoneNumber).setAttribute(
        "minlength",
        Prefix[idCountry].maximo
      );
      changeFlag(Prefix[idCountry].flag, $("phone_" + phoneNumber).id);
    }

    const changeFlag = function (flag, myId) {
      $("litleImg_" + myId).src = "../assets/img/flags/" + flag;
    };
    const changePrefix = function (e) {
      let phoneType = e.target.dataset.phonetype;
      let names = e.target.id.split("_");
      let phoneInput = names[1] + "_" + names[2];
      $(phoneInput).value = "";
      $(phoneInput).placeholder = "enter new phone";
      $(phoneInput).style.borderColor = COLOR.ERROR;
      let selectedValue = e.target.options[e.target.selectedIndex].value;
      for (let index in Prefix) {
        if (Prefix[index].value === selectedValue) {
          updateChanges(names[2], index, phoneType);
        }
      }
    };
    const fillSelectPrefix = function (phone, index) {
      let selectPrefixInternational = $("select_" + phone.id);
      for (let i in Prefix) {
        selectPrefixInternational.options[
          selectPrefixInternational.options.length
        ] = new Option(
          Prefix[i].prefijo,
          Prefix[i].value,
          undefined,
          Prefix[i].default
        );
        if (Prefix[i].default) {
          updateChanges(index, i, selectPrefixInternational.dataset.phonetype);
        }
      }
      selectPrefixInternational.addEventListener("change", function (e) {
        changePrefix(e);
      });
    };
    const phones = Qa("input[data-phoneType]");
    //console.log(phones);
    phones.forEach(fillSelectPrefix);
  };
  API.dado = function () {
    const dados = ["dado informatica", "dado harnina", "dado juntaextremadura"];
    const imagenes = [
      "assets/img/escudo02.png",
      "assets/img/harni01.png",
      "assets/img/Escudo_de_Extremadura.png",
    ];
    const clases = [
      "cara frontal",
      "cara trasera",
      "cara derecha",
      "cara izquierda",
      "cara arriba",
      "cara abajo",
    ];

    const creaImagen = function (imag, a, b, i) {
      var imagen = document.createElement("img");
      imagen.setAttribute("src", imag);
      imagen.className = "Imagen";
      imagen.id = "cara" + a + "-" + b + "-" + i;
      return imagen;
    };
    const creaCara = function (dado, a, b, imagen) {
      for (let i = 0; i < clases.length; i++) {
        var cara = document.createElement("div");
        cara.className = clases[i];
        cara.appendChild(creaImagen(imagen, a, b, i));
        dado[b].appendChild(cara);
      }
    };

    for (let i = 0; i < dados.length; i++) {
      const pageDados = document.getElementsByClassName(dados[i]);
      for (let j = 0; j < pageDados.length; j++) {
        creaCara(pageDados, i, j, imagenes[i]);
      }
    }
  };
  // IndexedDB
  const browserCompatibility = function () {
    let myIndexdDB =
      window.indexedDB ||
      window.mozIndexedDB ||
      window.webkitIndexedDB ||
      window.msIndexedDB;

    window.IDBTransaction =
      window.IDBTransaction ||
      window.webkitIDBTransaction ||
      window.msIDBTransaction;
    window.IDBKeyRange =
      window.IDBKeyRange || window.webkitIDBKeyRange || window.msIDBKeyRange;
    if (!myIndexdDB) {
      window.alert(
        "Su navegador no soporta una versión estable de indexedDB. Tal y como las características no serán validas"
      );
    }
    return myIndexdDB;
  };
  API.CreateBBDDpostalCode = function () {
    fetch("/getcpExtremadura")
      .then((response) => response.json())
      .then((data) => {
        const myIndexdDB = browserCompatibility();
        let db = null;
        const dbNombre = "postalCodeBBDD";
        const request = myIndexdDB.open(dbNombre, 1);
        request.onerror = function (event) {
          alert("Fallo en la apertura: 1 " + event.target.message);
        };
        request.onupgradeneeded = function (event) {
          db = event.target.result;
          const store = db.createObjectStore("postalCode", {
            keyPath: "idCp",
            autoIncrement: true,
          });
          store.createIndex("postalCodeIndex", "postalCode", {
            unique: false,
          });
          store.transaction.oncomplete = function (event) {
            const customerObjectStore = db
              .transaction("postalCode", "readwrite")
              .objectStore("postalCode");
            for (let i in data) {
              //console.log(data[i]);
              customerObjectStore.add(data[i]);
            }
            alert("BBDD cargada");
          };
        };
      });
  };
  API.getCity = function (myCP) {
    return new Promise(function (resolve, reject) {
      const myIndexdDB = browserCompatibility();
      let db = null;
      const dbNombre = "postalCodeBBDD";
      const request = myIndexdDB.open(dbNombre, 1);

      request.onerror = function (e) {
        alert("Fallo en la apertura: " + e.target.message);
      };
      request.onsuccess = function (e) {
        db = e.target.result;
        const range = IDBKeyRange.only(myCP);
        const transaction = db.transaction(["postalCode"], "readwrite");
        const store = transaction.objectStore("postalCode");
        const index = store.index("postalCodeIndex");
        index.openCursor(range).onsuccess = function (e) {
          var cursor = e.target.result;
          console.log(e.target);
          if (cursor) {
            resolve(cursor.value.municipality);
          } else {
            reject("Wrong error postal code");
          }
        };
      };
    });
  };
  API.submit = function () {
    "use strict";
    var submit = $("submit");
    return {
      message: function (content) {
        submit.innerHTML = content;
      },
      off: function () {
        submit.style.display = "none";
      },
      on: function () {
        let aviso = true;
        for (let i = 0; i < sS.getItem("lenDataControls"); i++) {
          if (
            $(sS.getItem("dataControls" + i)).style.borderColor !=
            COLOR.VALIDRGB
          ) {
            aviso = false;
            break;
          }
        }
        aviso
          ? ($("div_submit").style.display = "block")
          : ($("div_submit").style.display = "none");
      },
    };
  };
  API.error = function (params) {
    "use strict";
    let id = "";
    if (params) id = params.nodo.id;
    return {
      message: function (params) {
        $("boxerror_" + id).innerHTML = params.mensajeError || params;
      },
      off: function () {
        $("boxerror_" + id).classList.add("none");
        $("boxerror_" + id).style.display = "none";
      },
      on: function () {
        $("boxerror_" + id).classList.remove("none");
        $("boxerror_" + id).style.display = "block";
      },
    };
  };
  API.info = function () {
    "use strict";

    return {
      exist: function (params) {
        if ($("boxinfo_" + params.nodo.id)) {
          return true;
        } else {
          return false;
        }
      },
      message: function (params) {
        $("boxinfo_" + params.nodo.id).innerHTML = params.mensajeInfo;
      },
      off: function (params) {
        $("boxinfo_" + params.nodo.id).classList.add("none");
      },
      on: function (params) {
        $("boxinfo_" + params.nodo.id).classList.remove("none");
      },
    };
  };
  API.dataControl = function () {
    "use strict";
    return {
      get: function (params) {
        return params.node.value;
      },
      error: function (params) {
        params.nodo.style.borderColor = COLOR.ERROR;
        params.nodo.style.borderWidth = COLOR.ERRORBORDER;
      },
      valid: function (params) {
        params.nodo.style.borderColor = COLOR.VALID;
        params.nodo.style.borderWidth = COLOR.VALIDBORDER;
      },
      validData: function (params) {
        params.style.borderColor = COLOR.VALID;
        params.style.borderWidth = COLOR.VALIDBORDER;
      },
    };
  };
  API.saveDataControls = function () {
    const dataControlrequired = Qa("input[data-validate][required]");
    sS.setItem("lenDataControls", dataControlrequired.length);
    for (let i = 0; i < dataControlrequired.length; i++) {
      sS.setItem("dataControls" + i, dataControlrequired[i].id);
    }
    const divDataControls = Qa("div[data-divcontrol]");
    sS.setItem("lenDiv_DataControls", divDataControls.length);
    for (let i = 0; i < divDataControls.length; i++) {
      sS.setItem("div_DataControls" + i, divDataControls[i].id);
    }
  };
  API.getDataControls = function () {
    const dataControl = {};
    let father = "div_dataControl_";
    for (let i = 0; i < sS.getItem("lenDiv_DataControls"); i++) {
      let myInputId = $(sS.getItem("div_DataControls" + i)).id.slice(
        father.length
      );
      if (myInputId.indexOf("phone") != -1) {
        let myInputBoxinfoId = "boxinfo_" + myInputId;
        dataControl[$(myInputId).dataset.field] = $(myInputBoxinfoId).innerText;
      } else {
        dataControl[$(myInputId).dataset.field] = $(myInputId).value;
      }
    }
    return dataControl;
  };
  API.resetDataControl = function (dataControl) {
    if (!dataControl) {
      dataControl = API.getDataControls();
    }
    for (var key in dataControl) {
      let dataField = Q("input[data-field='" + key + "']");
      let control = dataField.id;
      $(control).style.backgroundColor = "";
      $("boxerror_" + control).style.display = "none";
      if ($("boxinfo_" + control)) {
        $("boxinfo_" + control).style.display = "block";
      }
    }
  };
  API.showItAllStrategy = function () {
    for (let i = 0; i < sS.getItem("lenDiv_DataControls"); i++) {
      $(sS.getItem("div_DataControls" + i)).style.display = "block";
    }
  };
  API.showOneToOneStrategy = function () {
    let father = "div_dataControl_";
    for (let i = 1; i < sS.getItem("lenDiv_DataControls"); i++) {
      if ($(sS.getItem("div_DataControls" + i)).style.display == "none") {
        let myInput = $(sS.getItem("div_DataControls" + (i - 1))).id.slice(
          father.length
        );
        if (
          $(sS.getItem("div_DataControls" + (i - 1))).style.display ==
            "block" &&
          ($(myInput).style.borderColor == COLOR.VALIDRGB ||
            !$(myInput).required)
        ) {
          $(sS.getItem("div_DataControls" + i)).style.display = "block";
        }
        break;
      }
    }
  };
  API.showIniStrategy = function (strategy) {
    if (strategy == STRATEGY.ALL) {
      sS.setItem("strategy", "API.showItAllStrategy()");
      API.showItAllStrategy();
    }
    if (strategy == STRATEGY.ONETOONE) {
      sS.setItem("strategy", "API.showOneToOneStrategy()");
      for (let i = 1; i < sS.getItem("lenDiv_DataControls"); i++) {
        $(sS.getItem("div_DataControls" + i)).style.display = "none";
      }
      $(sS.getItem("div_DataControls0")).style.display = "block";
    }
  };
  API.scrollTopButton = function (btn) {
    const $scrollBtn = d.querySelector(btn);
    w.addEventListener("scroll", (e) => {
      let scrollTop = w.pageYOffset || d.documentElement.scrollTop;
      scrollTop > 300
        ? $scrollBtn.classList.remove("hidden")
        : $scrollBtn.classList.add("hidden");
    });
    d.addEventListener("click", (e) => {
      if (e.target.matches(btn)) {
        w.scrollTo({
          behavior: "smooth",
          top: 0,
        });
      }
    });
  };
  API.serverResponse = function (response) {
    console.log("response", response);
    if (response.status == 404) {
      this.error().message("Error 404 ");
      this.error().on();
    }
    if (Array.isArray(response)) {
      if (response[0].error == 0) {
        console.log("resultado:", response[0].addClient);
        API.getGeo();
      } else if (response[0].error == 2) {
        for (let i = 0; i < response.length; i++) {
          $(response[i].submitName).style.display = "none";
          $(response[i].errorboxSubmit).style.display = "block";
          $(response[i].errorboxSubmit).innerHTML = response[i].message;
        }
      } else {
        for (let i = 0; i < response.length; i++) {
          let field = response[i].messageNameControl;
          console.log(field);
          let dataField = Q("input[data-field='" + field + "']");
          console.log(dataField);
          let control = dataField.id;
          $(control).style.backgroundColor = COLOR.ERRORBACKEND;
          $("boxerror_" + control).innerHTML = response[i].messageErrorControl;
          $("boxerror_" + control).style.display = "block";
          if ($("boxinfo_" + control)) {
            $("boxinfo_" + control).style.display = "none";
          }
        }
      }
    }
  };
  API.ajaxForm = function (props) {
    let { url, dataControl } = props;

    fetch(url, {
      method: "POST",
      body: JSON.stringify(dataControl),
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    })
      .catch((error) => {
        this.error.message(
          error.statusText || "Ocurrió un error al acceder al BackEnd"
        );
        this.error.on();
      })
      .then((res) => res.json())
      .then((response) => {
        this.loader().off();
        API.resetDataControl(dataControl);
        API.serverResponse(response);
      });
  };
  API.loader = function () {
    "use strict";

    return {
      exist: function () {
        if ($("loader")) {
          return true;
        } else {
          return false;
        }
      },
      message: function (message) {
        $("loader").innerHTML = message;
      },
      off: function () {
        $("loader").classList.add("none");
        $("loader").style.display = "none";
      },
      on: function () {
        $("loader").classList.remove("none");
        $("loader").style.display = "block";
      },
    };
  };
  API.ipRegister = function (data) {
    var url = "/ipRegister";
    fetch(url, {
      method: "POST",
      body: JSON.stringify(data),
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    })
      .then(location.reload())
      .catch((error) => {
        this.error.message(
          error.statusText || "Ocurrió un error al acceder al BackEnd"
        );
        this.error.on();
      });
  };
  API.getGeo = function () {
    var url = "http://www.geoplugin.net/json.gp";
    fetch(url)
      .then((res) => {
        return res.json();
      })
      .then((out) => {
        let data = {
          ip: out.geoplugin_request,
          city: out.geoplugin_city,
          country: out.geoplugin_countryName,
        };
        API.ipRegister(data);
      });
  };

  API.fillData = function (out) {
    const inputs = Qa("input[data-validate]");
    for (let i = 0; i < inputs.length; i++) {
      inputs[i].value = out[inputs[i].id];
      if (inputs[i].id == "phone_0") {
        inputs[i].value = out[inputs[i].id].split("-").pop();
        let idCountry = out[inputs[i].id].split("-").shift();
        $("select_phone_0").value = idCountry;
        let country = "";
        if (idCountry == "+34") {
          country = "es";
        }
        if (idCountry == "+33") {
          country = "fr";
        }
        if (idCountry == "+1") {
          country = "us";
        }
        $("litleImg_phone_0").src = "../assets/img/flags/" + country + ".png";
        $("boxinfo_phone_0").innerHTML = out[inputs[i].id];
        $("boxinfo_phone_0").style.display = "block";
      }
      API.dataControl().validData(inputs[i]);
    }
    API.submit().on();
  };

  API.updateAvatar = function () {
    let avatarFrame = $("avatar_frame");
    fetch("/getClientData")
      .then((res) => res.json())
      .then((out) => {
        avatarFrame.src = "assets/avatar/Avatar" + out[0].id + ".png";
      });
  };

  return API;
}
