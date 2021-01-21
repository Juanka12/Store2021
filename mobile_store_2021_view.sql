-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 21-01-2021 a las 10:01:42
-- Versión del servidor: 10.4.11-MariaDB
-- Versión de PHP: 7.4.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `mobile_store_2021_view`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddClient` (IN `myName` VARCHAR(50), IN `mySurname` VARCHAR(100), IN `myNifNie` VARCHAR(9), IN `myMobile` VARCHAR(20), IN `myEmail` VARCHAR(100), IN `myBirdate` DATE, IN `myCP` VARCHAR(5), IN `myAddress` VARCHAR(100), OUT `response` BOOLEAN)  NO SQL
BEGIN
DECLARE message varchar(2000) DEFAULT "";
DECLARE  myAvatar varchar(10) DEFAULT "avatar.png";
CALL mobile_store_2021.AddClient(myName, mySurname, myNifNie, myMobile, myEmail, myBirdate, myCP,myAddress, myAvatar,message);
IF locate("Error",message) THEN SET response = false;
 ELSE  SET response = true;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVisit` (IN `myPage` VARCHAR(30), OUT `message` VARCHAR(100))  NO SQL
BEGIN


INSERT INTO mobile_store_2021_page.`visit`(`idPage`) VALUES ((SELECT idPage FROM mobile_store_2021_page.`page` WHERE pageName = myPage));
IF ROW_COUNT() > 0 THEN SET message = "OK: Visita Registrada";
ELSE SIGNAL SQLSTATE '42S02';
SET message = "Error: Visita NO Registrada";
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `blockIP` (IN `myIP` VARCHAR(16))  NO SQL
BEGIN
CALL mobile_store_2021.blockIP(myIP);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `BlockUser` (IN `myUser` VARCHAR(16))  NO SQL
BEGIN
CALL mobile_store_2021.BlockUser(myUser);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CPExist_postalcode` (IN `myCP` VARCHAR(5), OUT `message` BOOLEAN)  NO SQL
BEGIN

SET message = (SELECT count(*) FROM mobile_store_2021.`postalcode` WHERE `postalCode` = myCP);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EmailExist_client` (IN `myEmail` VARCHAR(150), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT count(*) FROM mobile_store_2021.`client` WHERE `emailClient` = myEmail);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `emptyUUID` (IN `myUUID` VARCHAR(50))  NO SQL
BEGIN
CALL mobile_store_2021.emptyUUID(myUUID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetClient` (IN `myEmail` VARCHAR(150), OUT `myUser` VARCHAR(16), OUT `myPass` VARCHAR(9))  NO SQL
BEGIN
SET myUser = (SELECT user FROM mobile_store_2021.client WHERE emailClient = myEmail);
SET myPass = (SELECT password FROM mobile_store_2021.client WHERE emailClient = myEmail);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetClientID` (IN `myuser` VARCHAR(100), OUT `myid` TINYINT(4))  NO SQL
BEGIN
SET myid = (SELECT `idClient` FROM mobile_store_2021.`client` WHERE `user` = myuser);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCountVisit` (IN `myPage` VARCHAR(30), OUT `countVisit` INT)  NO SQL
BEGIN

SET countVisit =  (SELECT count(*) FROM mobile_store_2021_page.`visit` WHERE `idPage`= (SELECT `idPage` FROM mobile_store_2021_page.`page` WHERE `pageName` = myPage));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCpExtremadura` ()  NO SQL
BEGIN

CALL mobile_store_2021.GetCpExtremadura();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDataClient` (IN `_id` INT(4), OUT `_name` VARCHAR(50), OUT `_surname` VARCHAR(100), OUT `_nif` CHAR(9), OUT `_mobile` CHAR(20), OUT `_email` VARCHAR(150), OUT `_birth` DATE, OUT `_postalc` VARCHAR(5), OUT `_address` VARCHAR(100), OUT `_user` VARCHAR(30), OUT `_pass` VARCHAR(50))  NO SQL
BEGIN
SET _name = (SELECT nameClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _surname = (SELECT surnameClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _nif = (SELECT nifClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _mobile = (SELECT mobileClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _email = (SELECT emailClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _birth = (SELECT birthdateClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _postalc = (SELECT postalCodeClient FROM mobile_store_2021.client WHERE idClient = _id);
SET _address = (SELECT clientAddress FROM mobile_store_2021.client WHERE idClient = _id);
SET _user = (SELECT user FROM mobile_store_2021.client WHERE idClient = _id);
SET _pass = (SELECT password FROM mobile_store_2021.client WHERE idClient = _id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMail` (IN `myUser` VARCHAR(16), OUT `myEmail` VARCHAR(150))  NO SQL
BEGIN
SET myEmail = (SELECT emailClient FROM mobile_store_2021.client WHERE user = myUser);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPage` (IN `myPage` VARCHAR(100), OUT `htmlTxt` VARCHAR(30000))  NO SQL
BEGIN

CALL mobile_store_2021_page.GetPage((SELECT `idPage` FROM mobile_store_2021_page.page WHERE `pageName` = myPage), htmlTxt);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `isUserBlocked` (IN `myUser` VARCHAR(16), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT blocked FROM mobile_store_2021.client WHERE user = myUser);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MobileExist_client` (IN `myMobile` VARCHAR(20), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT count(*) FROM mobile_store_2021.`client` WHERE `mobileClient` = myMobile);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NifExist_client` (IN `myNif` VARCHAR(9), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT count(*) FROM mobile_store_2021.`client` WHERE `nifClient` = myNif);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PasswordExist_client` (IN `myUser` VARCHAR(30), IN `myPass` VARCHAR(50), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT count(*) FROM mobile_store_2021.`client` WHERE `user` = myUser && `password` = md5(myPass));

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegisterIP` (IN `myip` VARCHAR(20), IN `mycity` VARCHAR(100), IN `mycountry` VARCHAR(100), IN `idclient` TINYINT(16))  NO SQL
BEGIN
CALL mobile_store_2021.RegisterIP(idclient,myip,mycity,mycountry);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `setUUID` (IN `myUser` VARCHAR(16), IN `myUUID` VARCHAR(50))  NO SQL
BEGIN
CALL mobile_store_2021.setUUID(myUser,myUUID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UnlockUser` (IN `myUUID` VARCHAR(50), IN `myUser` VARCHAR(16))  NO SQL
BEGIN
CALL mobile_store_2021.UnlockUser(myUUID,myUser);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateClient` (IN `myname` VARCHAR(50), IN `mysurname` VARCHAR(100), IN `mynif` CHAR(9), IN `myphone` CHAR(20), IN `myemail` VARCHAR(150), IN `mybirth` DATE, IN `mypostalc` VARCHAR(5), IN `myaddress` VARCHAR(100), IN `myid` TINYINT(4))  NO SQL
BEGIN
CALL mobile_store_2021.UpdateClient(myname,mysurname,mynif,myphone,myemail,mybirth,mypostalc,myaddress,myid);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateClientLogin` (IN `myuser` VARCHAR(30), IN `myid` TINYINT(4))  NO SQL
BEGIN
CALL mobile_store_2021.UpdateClientLogin(myuser,myid);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UserExist_client` (IN `myUser` VARCHAR(30), OUT `message` BOOLEAN)  NO SQL
BEGIN
SET message = (SELECT count(*) FROM mobile_store_2021.`client` WHERE `user` = myUser);

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lolo`
--

CREATE TABLE `lolo` (
  `ddfd` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `lolo`
--

INSERT INTO `lolo` (`ddfd`) VALUES
(0),
(45);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
