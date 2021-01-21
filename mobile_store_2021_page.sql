-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 21-01-2021 a las 10:01:34
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
-- Base de datos: `mobile_store_2021_page`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBody` (IN `idPage` INT, OUT `bodyTxt` VARCHAR(300000))  NO SQL
BEGIN
DECLARE idRama INT DEFAULT 0;
DECLARE branchTxt VARCHAR(20000)  DEFAULT "";
DECLARE done BOOLEAN DEFAULT FALSE;

DECLARE cursor_Brach  CURSOR FOR SELECT `idBranch` FROM `branch` WHERE `idPage`= idPage AND `fatherNode`= 0  ORDER BY `branch`.`orderNode` ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_Brach;
FETCH cursor_Brach INTO idRama;
SET bodyTxt = "<body>";

WHILE !done DO
    CALL GetBranchs(idRama, branchTxt);
    SET bodyTxt = concat(bodyTxt, branchTxt);    
	FETCH cursor_Brach INTO idRama;	
END WHILE;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBodyTemp` (IN `idPage` INT, OUT `body` VARCHAR(20000))  NO SQL
BEGIN
DECLARE fatherAux int DEFAULT 0;
DECLARE branchAux int DEFAULT 0;
DECLARE nodeAux int DEFAULT 0;
DECLARE isBranch bool DEFAULT 0;

DECLARE branchs int DEFAULT 0;

DECLARE meLevel int;
DECLARE meOrder int;
DECLARE meFather int;
DECLARE meNode int DEFAULT 0;
DECLARE meVisit  bool DEFAULT 0;
DECLARE meBranch int DEFAULT 0;
DECLARE meIsBranch bool DEFAULT 0;

DECLARE etiqueta VARCHAR(20000)  DEFAULT "";

DECLARE cursor_body CURSOR FOR SELECT `hierarchicalLevel`,  `orderNode`, `fatherNode`, `idNode`,`visited`, `idBranch`,  `nodeyn` FROM body WHERE  `finished` = 0  and  `fatherNode` = fatherAux ORDER BY 1,2;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET @finCursor = TRUE;


IF addBodyTemp(idPage) THEN 
		SET body = "<body>";
		SET branchs  = getBranchs();    
END IF;
WHILE  branchs > 0 DO     
	OPEN cursor_body;	   
    SET @finCursor = FALSE;   
	FETCH cursor_body INTO meLevel, meOrder,  meFather, meNode, meVisit,  meBranch, meIsBranch;
    IF @finCursor THEN 
    	IF updateBranchFinish(branchAux) THEN  
    		IF isBranch THEN SET etiqueta = getCloseTag(nodeAux);  
    		END IF; 
        END IF;
        SET fatherAux  = 0; 
       ELSE  SET branchAux = meBranch;
    	     SET nodeAux = meNode;     
    	     SET fatherAux  = meBranch; 
             SET isBranch = meIsBranch;
             IF  !meVisit THEN
             		IF updateBodyVisitedTrue(meBranch) THEN
			 			 IF !isBranch THEN IF updateBranchFinish(meBranch) THEN
             									SET etiqueta =  getLeaf(meNode);
             									SET fatherAux = 0; 
                                            END IF;
                                ELSE
        							SET etiqueta =  getStartTag(meNode);            
      	                    END IF;
                        END IF;     
                    ELSE SET etiqueta = "";
   	          END IF;              
    END IF; 
    SET body = concat(body, etiqueta); 
    CLOSE cursor_body;
    SET branchs  = getBranchs();
END WHILE;

SET body = concat(body, "</body>"); 

             
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBranchs` (IN `myIdBranch` INT, OUT `branchTxt` VARCHAR(20000))  NO SQL
BEGIN

DECLARE branch VARCHAR(20000)  DEFAULT " ";
DECLARE branchSon VARCHAR(20000)  DEFAULT "";
DECLARE branchLeaf VARCHAR(20000)  DEFAULT "";

DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE idSon INT DEFAULT 0;
DECLARE myIdNode int DEFAULT (SELECT `idNode` FROM `branch` WHERE `idBranch`= myIdBranch);


DECLARE cursor_Branch  CURSOR FOR SELECT `idBranch` FROM `branch` WHERE `fatherNode`= myIdBranch ORDER BY `branch`.`orderNode` ASC;


DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
SET max_sp_recursion_depth=12;
 SET branch = concat(branch, getStartTag(myIdNode));
 
IF isChildren(myIdBranch)THEN   
	OPEN cursor_Branch;    
  	FETCH cursor_Branch INTO idSon;    
    WHILE !done DO   	
          CALL GetBranchs(idSon, branchSon);        
          SET branch = concat(branch, branchSon);        
          FETCH cursor_Branch INTO idSon;	
          
    END WHILE;   
	CLOSE cursor_Branch; 
END IF;	
CALL GetLeafsOfBranch(myIdBranch, branchLeaf);
SET branch = concat(branch, branchLeaf, getCloseTag(myIdNode));
SET branchTxt = branch;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFileCssPath` (IN `idPage` INT, OUT `cssout` VARCHAR(2000))  NO SQL
BEGIN

DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE css varchar(100) DEFAULT "";
DECLARE ruta varchar(100) DEFAULT "";
DECLARE orden int DEFAULT 0;

DECLARE cursor_css CURSOR FOR SELECT f.`pathFileCss`, f.`nameFileCss`, p.orderPage FROM `filecss`f, page_filecss p WHERE p.idPage = idPage AND f.`idFileCss` = p.IdFileCss ORDER BY 3;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_css;
FETCH cursor_css INTO ruta, css,orden;  
SET cssout = "";
WHILE  done = FALSE DO
	SET cssout = concat(cssout,"<link type='text/css' rel='stylesheet' href='",ruta,"/",css,".css'>");
    FETCH cursor_css INTO ruta,css,orden;      

END WHILE;
CLOSE cursor_css;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFileCssWeb` (IN `idPage` INT, OUT `cssout` VARCHAR(2000))  NO SQL
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE href varchar(100) DEFAULT "";
DECLARE integrity varchar(100) DEFAULT "";
DECLARE crossorigin varchar(100) DEFAULT "";
DECLARE orden int DEFAULT 0;

DECLARE cursor_css CURSOR FOR SELECT c.`href`,c.`integrity`,c.`crossorigin`, p.order FROM `filecssweb` c, page_filecssweb p WHERE p.idPage = idPage AND p.idCssWeb = c.`idCssWeb` ORDER BY 4;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_css;
FETCH cursor_css INTO href, integrity, crossorigin, orden;  
SET cssout = "";
WHILE  done = FALSE DO
	SET cssout = concat(cssout,"<link rel='stylesheet' href='",href,"'>");
    FETCH cursor_css INTO href, integrity, crossorigin, orden;       

END WHILE;
CLOSE cursor_css;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFileJsPath` (IN `myIdPage` INT, OUT `jsout` VARCHAR(8000))  NO SQL
BEGIN

DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE js varchar(100) DEFAULT "";
DECLARE ruta varchar(100) DEFAULT "";
DECLARE orden int DEFAULT 0;
DECLARE modul boolean DEFAULT false;

DECLARE cursor_js CURSOR FOR SELECT f.pathFileJs, f.fileJs, p.`orderFileJs`,f.module FROM `page_filejs` p, filejs f WHERE p.`idPage` = myIdPage and f.idFileJs = p.`IdFileJs` ORDER BY 3;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_js;
FETCH cursor_js INTO ruta, js, orden, modul;  
SET jsout = "";
WHILE  done = FALSE DO

  IF (modul) THEN
	SET jsout = concat(jsout,"<script src='",ruta,"/",js,".js'type='module'></script>");
     ELSE SET jsout = concat(jsout,"<script src='",ruta,"/",js,".js'></script>");
    END IF;
    FETCH cursor_js INTO ruta, js, orden, modul; 

END WHILE;
CLOSE cursor_js;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFileJsWeb` (IN `myIdPage` INT, OUT `jsout` VARCHAR(2000))  NO SQL
BEGIN

DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE file varchar(100) DEFAULT "";
DECLARE orden int DEFAULT 0;

DECLARE cursor_fileweb CURSOR FOR SELECT f.href, p.`order` FROM `page_filejsweb` p, filejsweb f 
WHERE p.`idPage` = myIdPage and p.`idjsweb`= f.idJsWeb ORDER by 2;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_fileweb;
FETCH cursor_fileweb INTO file,orden;  
SET jsout = "";
WHILE  done = FALSE DO
	SET jsout = concat(jsout,"<script src='",file,"'></script>");
    FETCH cursor_fileweb INTO file,orden;       

END WHILE;
CLOSE cursor_fileweb;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHead` (IN `idPage` INT, OUT `head` VARCHAR(2000))  NO SQL
BEGIN

DECLARE subheading varchar(2000) DEFAULT "";

SET head = concat( "<head>", "<title>", getTitlePage(idPage), "</title>");


CALL GetMetadata(idPage,subheading);
SET head = concat(head, subheading);


CALL GetHeadScriptStart(idPage,subheading);
SET head = concat(head, subheading);

CALL GetLinkHref(idPage,subheading);
SET head = concat(head, subheading);

CALL GetFileCssPath(idPage,subheading);
SET head = concat(head, subheading);

CALL GetFileCssWeb(idPage,subheading);
SET head = concat(head, subheading,"</head>");

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHeadScriptEnd` (IN `myIdPage` INT, OUT `headScript` VARCHAR(1000))  NO SQL
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE script varchar(200) DEFAULT "";  
DECLARE orden int DEFAULT 0;

DECLARE cursor_headScript CURSOR FOR SELECT h.script, ph.`orderScript` FROM `page_headscript` ph, headscript h WHERE ph.`idHeadscript` = h.idHeadScript and ph.`idPage`= myIdPage 
and !ph.`start` ORDER BY 2;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cursor_headScript;
FETCH cursor_headScript INTO script, orden;  
SET headScript = "";
REPEAT
	SET headScript = concat(headScript, script);
   FETCH cursor_headScript INTO script, orden;        
UNTIL done = TRUE
END REPEAT;
CLOSE cursor_headScript;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetHeadScriptStart` (IN `myIdPage` INT, OUT `headScript` VARCHAR(1000))  NO SQL
BEGIN
DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE script varchar(200) DEFAULT "";  
DECLARE orden int DEFAULT 0;

DECLARE cursor_headScript CURSOR FOR SELECT h.script, ph.`orderScript` FROM `page_headscript` ph, headscript h WHERE ph.`idHeadscript` = h.idHeadScript and ph.`idPage`= myIdPage 
and ph.`start` ORDER BY 2;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cursor_headScript;
FETCH cursor_headScript INTO script, orden;  
SET headScript = "";
REPEAT
	SET headScript = concat(headScript, script);
   FETCH cursor_headScript INTO script, orden;        
UNTIL done = TRUE
END REPEAT;
CLOSE cursor_headScript;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLeafsOfBranch` (IN `myIdBranch` INT, OUT `leafs` VARCHAR(20000))  NO SQL
BEGIN

DECLARE myIdLeaf INT DEFAULT 0;
DECLARE done BOOLEAN DEFAULT FALSE;
DECLARE cursor_Leaf  CURSOR FOR SELECT `idLeaf` FROM `forest` WHERE `idBranch`= myIdBranch ORDER BY `forest`.`OrderComponent` ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_Leaf;
FETCH cursor_Leaf INTO myIdLeaf;
SET leafs ="";
REPEAT 
    SET leafs = concat(leafs, getLeaf(myIdLeaf));
	FETCH cursor_Leaf INTO myIdLeaf;
	UNTIL done = TRUE
END REPEAT;
CLOSE cursor_Leaf;
IF leafs IS null THEN
	SET leafs="";
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLinkHref` (IN `idPage` INT, OUT `linkHref` VARCHAR(2000))  NO SQL
BEGIN

DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE sublinkHref varchar(200) DEFAULT "";
DECLARE orden int DEFAULT 0;

DECLARE cursor_link CURSOR FOR SELECT l.linkHref, p.`orderPageLinkHref` FROM `page_filelinkhref`  p, filelinkhref l WHERE `idPage` = idPage AND p.`IdLinkHref` = l.IdLinkHref ORDER BY 2;


DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_link;
FETCH cursor_link INTO sublinkHref,orden;  
SET linkHref = "";
REPEAT
	SET linkHref = concat(linkHref, sublinkHref);
    FETCH cursor_link INTO sublinkHref,orden;       
UNTIL done = TRUE
END REPEAT;
CLOSE cursor_link;
 


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMetadata` (IN `myIdPage` INT, OUT `metadata` VARCHAR(2000))  NO SQL
BEGIN

DECLARE done BOOLEAN DEFAULT FALSE; 
DECLARE subMeta varchar(200) DEFAULT "";  
DECLARE orden int DEFAULT 0;
DECLARE cursor_meta CURSOR FOR SELECT m.`ValueMetaData`, p.orderPageMetaData
FROM `filemetadata` m, page_filemetadata p  WHERE m.`idMetaData` = p.idMetaData AND p.idPage = myIdPage ORDER BY 2;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN cursor_meta;
FETCH cursor_meta INTO subMeta,orden;  
SET metadata = "";
REPEAT
	SET metadata = concat(metadata, subMeta);
    FETCH cursor_meta INTO subMeta,orden;       
UNTIL done = TRUE
END REPEAT;
CLOSE cursor_meta;

 


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPage` (IN `idPage` INT, OUT `html` VARCHAR(8000))  NO SQL
BEGIN
DECLARE subhtml varchar(8000) DEFAULT "";

SET html ="<html lang='es'>";

CALL GetHead(idPage, subhtml);
SET html = concat(html, subhtml);

CALL GetBody(idPage, subhtml);
SET html = concat(html, subhtml);

CALL GetFileJsPath(idPage, subhtml);
SET html = concat(html, subhtml);

CALL GetFileJsWeb(idPage, subhtml);
SET html = concat(html, subhtml);

SET html = concat(html , "</body> </html>");


END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `addBodyTemp` (`IdPage` INT) RETURNS TINYINT(1) NO SQL
BEGIN

DECLARE state bool DEFAULT false;

DELETE FROM body;

INSERT INTO `body`(`hierarchicalLevel`, `orderNode`, `fatherNode`, `idNode`,  `idbranch`) SELECT a.`hierarchicalLevel`, a.`orderNode`, a.`fatherNode`, a.`idNode`, a.`idBranch`
FROM `branch` a, `branch` b
WHERE (a.`fatherNode` = b.`idBranch` or a.`fatherNode`= 0) AND a.`idPage` = IdPage
GROUP BY  a.`hierarchicalLevel`,  a.`orderNode`, a.`idNode`, a.`idBranch`;

IF ROW_COUNT() > 0 THEN SET state = true;
END IF;

INSERT INTO `body`(`hierarchicalLevel`, `orderNode`, `fatherNode`, `idNode`,  `idBranch`,`nodeyn`) SELECT a.`hierarchicalLevel` + 1, b.OrderComponent, b.idBranch, b.idLeaf, ((1000 *  b.idBranch) + b.idLeaf + b.OrderComponent), 0
FROM `branch` a, forest b
WHERE a.`idBranch` = b.idBranch AND a.`idPage` = IdPage;

IF ROW_COUNT() > 0 THEN SET state = true;
END IF;

return state;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getBranchs` () RETURNS INT(11) NO SQL
BEGIN

RETURN (select COUNT(*) from body where `finished` = 0);


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getCloseTag` (`myNode` INT) RETURNS VARCHAR(100) CHARSET utf8 COLLATE utf8_unicode_ci NO SQL
BEGIN

RETURN (SELECT `nodeFinish` FROM `node` WHERE `idNode` = myNode);


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getLeaf` (`myIdLeaf` INT) RETURNS VARCHAR(200) CHARSET utf8 COLLATE utf8_unicode_ci NO SQL
BEGIN

RETURN (SELECT `leaf` FROM `leaf` WHERE `idleaf` = myIdLeaf);


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getNodeFromBranch88888` (`meIdBranch` INT) RETURNS INT(11) NO SQL
BEGIN

RETURN (SELECT `idNode` FROM `branch` WHERE `idBranch`= meIdBranch);



END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getStartTag` (`myIdNode` INT) RETURNS VARCHAR(2000) CHARSET utf8 COLLATE utf8_unicode_ci NO SQL
BEGIN

RETURN (SELECT `nodeStar` FROM `node` WHERE `idNode` =  myIdNode);

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTitlePage` (`myIdPage` INT) RETURNS VARCHAR(200) CHARSET utf8 COLLATE utf8_unicode_ci NO SQL
BEGIN

RETURN (SELECT `titlePage` FROM `page` WHERE `idPage` = myIdPage);


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `isChildren` (`myIdBranch` INT) RETURNS TINYINT(1) NO SQL
BEGIN
IF (SELECT COUNT(*) FROM `branch` WHERE `fatherNode` = myIdBranch) THEN
	RETURN true;
END IF;
RETURN false;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `updateBodyVisitedTrue` (`myIdBranch` INT) RETURNS INT(11) NO SQL
BEGIN

UPDATE `body` SET `visited`= 1 WHERE `idBranch`= myIdBranch;

IF ROW_COUNT() > 0 THEN RETURN true;
  ELSE RETURN false;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `updateBranchFinish` (`myIdBranch` INT) RETURNS TINYINT(1) NO SQL
BEGIN

UPDATE `body` SET `finished`= 1 WHERE `idBranch`= myIdBranch; 
  
IF ROW_COUNT() > 0 THEN RETURN true;
  ELSE RETURN false;
END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `body`
--

CREATE TABLE `body` (
  `hierarchicalLevel` int(11) NOT NULL,
  `orderNode` int(11) NOT NULL,
  `fatherNode` int(11) NOT NULL,
  `idNode` int(11) NOT NULL,
  `visited` int(11) NOT NULL DEFAULT 0,
  `finished` int(11) NOT NULL DEFAULT 0,
  `idBranch` int(11) NOT NULL,
  `nodeyn` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `body`
--

INSERT INTO `body` (`hierarchicalLevel`, `orderNode`, `fatherNode`, `idNode`, `visited`, `finished`, `idBranch`, `nodeyn`) VALUES
(0, 10, 0, 1, 1, 1, 1, 1),
(0, 30, 0, 3, 1, 1, 3, 1),
(1, 20, 1, 2, 1, 1, 2, 1),
(1, 10, 1, 1, 1, 1, 1011, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `branch`
--

CREATE TABLE `branch` (
  `idBranch` int(11) NOT NULL,
  `idPage` tinyint(1) NOT NULL,
  `idNode` int(11) NOT NULL,
  `orderNode` int(11) NOT NULL,
  `fatherNode` int(11) NOT NULL,
  `hierarchicalLevel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `branch`
--

INSERT INTO `branch` (`idBranch`, `idPage`, `idNode`, `orderNode`, `fatherNode`, `hierarchicalLevel`) VALUES
(1, 1, 1, 10, 0, 0),
(2, 1, 2, 20, 0, 0),
(3, 1, 3, 30, 0, 0),
(4, 2, 1, 10, 0, 0),
(5, 2, 2, 20, 0, 0),
(6, 2, 3, 30, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filecss`
--

CREATE TABLE `filecss` (
  `idFileCss` tinyint(1) NOT NULL,
  `nameFileCss` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `pathFileCss` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `observations` varchar(100) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filecss`
--

INSERT INTO `filecss` (`idFileCss`, `nameFileCss`, `pathFileCss`, `observations`) VALUES
(1, 'style', 'assets/css', 'Curso 19-20'),
(2, 'switchDark', 'assets/css', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filecssweb`
--

CREATE TABLE `filecssweb` (
  `idCssWeb` int(4) NOT NULL,
  `href` varchar(300) COLLATE utf8_unicode_ci NOT NULL,
  `integrity` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `crossorigin` varchar(100) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filecssweb`
--

INSERT INTO `filecssweb` (`idCssWeb`, `href`, `integrity`, `crossorigin`) VALUES
(1, 'https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css', 'sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T', 'anonymous'),
(2, 'https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/css/bootstrap.min.css', '', ''),
(3, 'https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css\r\n', 'sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk', 'anonymous');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filejs`
--

CREATE TABLE `filejs` (
  `idFileJs` tinyint(1) NOT NULL,
  `fileJs` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `pathFileJs` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `observations` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `module` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filejs`
--

INSERT INTO `filejs` (`idFileJs`, `fileJs`, `pathFileJs`, `observations`, `module`) VALUES
(1, 'index', 'assets/js', '', 1),
(8, 'client', 'assets/js', 'perfil client', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filejsweb`
--

CREATE TABLE `filejsweb` (
  `idJsWeb` int(11) NOT NULL,
  `href` varchar(300) COLLATE utf8_unicode_ci NOT NULL,
  `observa` varchar(100) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filejsweb`
--

INSERT INTO `filejsweb` (`idJsWeb`, `href`, `observa`) VALUES
(1, 'https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js', 'jquery mínimo'),
(2, 'https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js', 'bootstrap js mínimo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filelinkhref`
--

CREATE TABLE `filelinkhref` (
  `IdLinkHref` tinyint(1) NOT NULL,
  `linkHref` varchar(200) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filelinkhref`
--

INSERT INTO `filelinkhref` (`IdLinkHref`, `linkHref`) VALUES
(3, '  <link href=\"https://cdnjs.cloudflare.com/ajax/libs/hamburgers/1.1.3/hamburgers.min.css\" rel=\"stylesheet\">  \r\n'),
(2, '  <link rel=\"shortcut icon\" src=\"assets/img/favicon.ico\">'),
(1, '<link href=\"https://fonts.googleapis.com/css?family=Roboto:400,700\" rel=\"stylesheet\">');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filemetadata`
--

CREATE TABLE `filemetadata` (
  `idMetaData` tinyint(1) NOT NULL,
  `ValueMetaData` varchar(200) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `filemetadata`
--

INSERT INTO `filemetadata` (`idMetaData`, `ValueMetaData`) VALUES
(1, '<meta charset=\"utf-8\">'),
(2, '<meta name=\"viewport\" content=\"width=device-width,initial-scale=1, userName-scalable=no\">'),
(3, ' <meta name=\"author\" content=\"Alumnos Segundo DAM curso 2019 - 2020\">');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `forest`
--

CREATE TABLE `forest` (
  `idBranch` int(11) NOT NULL,
  `idLeaf` int(11) NOT NULL,
  `OrderComponent` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `headscript`
--

CREATE TABLE `headscript` (
  `idHeadScript` int(11) NOT NULL,
  `script` varchar(200) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `headscript`
--

INSERT INTO `headscript` (`idHeadScript`, `script`) VALUES
(1, '  <script>document.getElementsByTagName(\"html\")[0].className += \" js\";</script>');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `leaf`
--

CREATE TABLE `leaf` (
  `idLeaf` int(11) NOT NULL,
  `leaf` varchar(2000) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `leaf`
--

INSERT INTO `leaf` (`idLeaf`, `leaf`) VALUES
(1, '<h1> DAM 2020 </h1>');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `node`
--

CREATE TABLE `node` (
  `idNode` int(11) NOT NULL,
  `nodeStar` varchar(2000) COLLATE utf8_unicode_ci NOT NULL,
  `nodeFinish` varchar(40) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `node`
--

INSERT INTO `node` (`idNode`, `nodeStar`, `nodeFinish`) VALUES
(1, '<div data-include=\"assets/subpage/header.html\" id=\"myHeader\" class=\"header\" data-dark>', '</div>'),
(2, '<main class=\"main-container\" id=\"myBody\">', '</main>'),
(3, '<div data-include=\"assets/subpage/footer.html\" id=\"myFooter\">', '</div>');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page`
--

CREATE TABLE `page` (
  `idPage` tinyint(1) NOT NULL,
  `pageName` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `titlePage` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `authorPage` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `language` varchar(5) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'es',
  `observations` varchar(200) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page`
--

INSERT INTO `page` (`idPage`, `pageName`, `titlePage`, `authorPage`, `language`, `observations`) VALUES
(1, 'index', 'Harnina Store', 'DAM 2020 - 2021', 'es', 'Página Inicio de la aplicación'),
(2, 'client', 'client harnina', 'DAM 20/21', 'es', 'Perfil cliente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filecss`
--

CREATE TABLE `page_filecss` (
  `idPage` tinyint(1) NOT NULL,
  `IdFileCss` tinyint(1) NOT NULL,
  `orderPage` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page_filecss`
--

INSERT INTO `page_filecss` (`idPage`, `IdFileCss`, `orderPage`) VALUES
(1, 1, 10),
(2, 1, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filecssweb`
--

CREATE TABLE `page_filecssweb` (
  `idPage` tinyint(4) NOT NULL,
  `idCssWeb` int(11) NOT NULL,
  `order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filejs`
--

CREATE TABLE `page_filejs` (
  `idPage` tinyint(1) NOT NULL,
  `IdFileJs` tinyint(1) NOT NULL,
  `orderFileJs` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page_filejs`
--

INSERT INTO `page_filejs` (`idPage`, `IdFileJs`, `orderFileJs`) VALUES
(1, 1, 10),
(2, 8, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filejsweb`
--

CREATE TABLE `page_filejsweb` (
  `idPage` tinyint(1) NOT NULL,
  `idjsweb` int(11) NOT NULL,
  `order` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filelinkhref`
--

CREATE TABLE `page_filelinkhref` (
  `idPage` tinyint(1) NOT NULL,
  `IdLinkHref` tinyint(1) NOT NULL,
  `orderPageLinkHref` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page_filelinkhref`
--

INSERT INTO `page_filelinkhref` (`idPage`, `IdLinkHref`, `orderPageLinkHref`) VALUES
(1, 1, 10),
(1, 2, 20),
(1, 3, 30),
(2, 1, 10),
(2, 2, 20),
(2, 3, 30);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_filemetadata`
--

CREATE TABLE `page_filemetadata` (
  `idPage` tinyint(1) NOT NULL,
  `idMetaData` tinyint(1) NOT NULL,
  `orderPageMetaData` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page_filemetadata`
--

INSERT INTO `page_filemetadata` (`idPage`, `idMetaData`, `orderPageMetaData`) VALUES
(1, 1, 10),
(1, 2, 30),
(1, 3, 20),
(2, 1, 10),
(2, 2, 20),
(2, 3, 30);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `page_headscript`
--

CREATE TABLE `page_headscript` (
  `idPage` tinyint(1) NOT NULL,
  `idHeadscript` int(11) NOT NULL,
  `orderScript` int(11) NOT NULL,
  `start` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `page_headscript`
--

INSERT INTO `page_headscript` (`idPage`, `idHeadscript`, `orderScript`, `start`) VALUES
(1, 1, 10, 1),
(2, 1, 10, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `visit`
--

CREATE TABLE `visit` (
  `idVisit` int(11) NOT NULL,
  `idPage` tinyint(1) NOT NULL,
  `dateVisit` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `visit`
--

INSERT INTO `visit` (`idVisit`, `idPage`, `dateVisit`) VALUES
(1, 1, '2020-09-21 18:15:35'),
(2, 1, '2020-09-22 09:59:16'),
(3, 1, '2020-09-22 10:00:54'),
(4, 1, '2020-09-22 10:10:18'),
(5, 1, '2020-09-22 10:41:52'),
(6, 1, '2020-09-22 11:50:32'),
(7, 1, '2020-09-22 17:23:20'),
(8, 1, '2020-09-23 04:37:04'),
(9, 1, '2020-09-23 04:40:47'),
(10, 1, '2020-09-23 04:55:25'),
(11, 1, '2020-09-23 04:58:17'),
(12, 1, '2020-09-23 05:03:23'),
(13, 1, '2020-09-23 05:09:15'),
(14, 1, '2020-09-23 05:11:15'),
(15, 1, '2020-09-23 05:11:29'),
(16, 1, '2020-09-23 05:15:33'),
(17, 1, '2020-09-23 05:19:24'),
(18, 1, '2020-09-23 11:38:31'),
(19, 1, '2020-09-23 13:25:27'),
(20, 1, '2020-09-23 17:48:28'),
(21, 1, '2020-09-24 12:52:48'),
(22, 1, '2020-09-24 17:23:09'),
(23, 1, '2020-09-24 18:21:44'),
(24, 1, '2020-09-24 20:28:56'),
(25, 1, '2020-09-24 21:23:41'),
(26, 1, '2020-09-25 08:39:31'),
(27, 1, '2020-09-25 13:18:43'),
(28, 1, '2020-09-26 11:05:01'),
(29, 1, '2020-09-26 11:38:20'),
(30, 1, '2020-09-27 16:40:39'),
(31, 1, '2020-09-28 09:45:54'),
(32, 1, '2020-09-29 09:57:49'),
(33, 1, '2020-09-29 17:37:51'),
(34, 1, '2020-09-30 13:46:09'),
(35, 1, '2020-10-01 13:59:39'),
(36, 1, '2020-10-02 06:27:23'),
(37, 1, '2020-10-02 09:16:54'),
(38, 1, '2020-10-02 13:12:08'),
(39, 1, '2020-10-02 20:31:54'),
(40, 1, '2020-10-03 12:59:25'),
(41, 1, '2020-10-04 06:38:52'),
(42, 1, '2020-10-04 07:12:03'),
(43, 1, '2020-10-04 08:02:00'),
(44, 1, '2020-10-04 10:21:14'),
(45, 1, '2020-10-04 13:03:27'),
(46, 1, '2020-10-04 16:54:33'),
(47, 1, '2020-10-05 09:49:04'),
(48, 1, '2020-10-06 08:10:28'),
(49, 1, '2020-10-06 10:39:12'),
(50, 1, '2020-10-06 17:41:35'),
(51, 1, '2020-10-06 20:17:19'),
(52, 1, '2020-10-07 11:34:13'),
(53, 1, '2020-10-07 12:31:19'),
(54, 1, '2020-10-07 17:42:03'),
(55, 1, '2020-10-08 13:20:52'),
(56, 1, '2020-10-08 20:21:15'),
(57, 1, '2020-10-09 08:49:38'),
(58, 1, '2020-10-09 17:59:02'),
(59, 1, '2020-10-09 21:01:39'),
(60, 1, '2020-10-09 21:09:12'),
(61, 1, '2020-10-10 10:01:10'),
(62, 1, '2020-10-10 16:50:56'),
(63, 1, '2020-10-10 20:58:23'),
(64, 1, '2020-10-11 11:34:41'),
(65, 1, '2020-10-12 09:55:38'),
(66, 1, '2020-10-12 12:39:14'),
(67, 1, '2020-10-12 17:36:10'),
(68, 1, '2020-10-14 06:02:28'),
(69, 1, '2020-10-14 10:27:36'),
(70, 1, '2020-10-14 12:45:02'),
(71, 1, '2020-10-14 13:29:34'),
(72, 1, '2020-10-15 12:21:42'),
(73, 1, '2020-10-15 12:21:43'),
(74, 1, '2020-10-15 13:20:55'),
(75, 1, '2020-10-15 16:27:47'),
(76, 1, '2020-10-15 22:49:48'),
(77, 1, '2020-10-16 08:30:27'),
(78, 1, '2020-10-16 17:44:17'),
(79, 1, '2020-10-16 20:19:52'),
(80, 1, '2020-10-16 23:18:39'),
(81, 1, '2020-10-17 09:42:14'),
(82, 1, '2020-10-17 12:03:14'),
(83, 1, '2020-10-17 17:17:19'),
(84, 1, '2020-10-19 09:48:04'),
(85, 1, '2020-10-19 19:41:24'),
(86, 1, '2020-10-20 08:18:33'),
(87, 1, '2020-10-20 10:01:10'),
(88, 1, '2020-10-20 10:57:26'),
(89, 1, '2020-10-20 11:39:00'),
(90, 1, '2020-10-20 11:54:12'),
(91, 1, '2020-10-20 16:45:06'),
(92, 1, '2020-10-21 12:54:42'),
(93, 1, '2020-10-21 18:11:00'),
(94, 1, '2020-10-21 20:30:03'),
(95, 1, '2020-10-22 13:40:45'),
(96, 1, '2020-10-22 13:42:11'),
(97, 1, '2020-10-22 17:52:32'),
(98, 1, '2020-10-22 18:07:58'),
(99, 1, '2020-10-22 18:25:06'),
(100, 1, '2020-10-22 18:58:06'),
(101, 1, '2020-10-22 19:24:01'),
(102, 1, '2020-10-23 08:17:12'),
(103, 1, '2020-10-23 09:40:36'),
(104, 1, '2020-10-23 16:50:46'),
(105, 1, '2020-10-23 20:21:45'),
(106, 1, '2020-10-24 09:26:40'),
(107, 1, '2020-10-24 19:50:21'),
(108, 1, '2020-10-24 21:10:07'),
(109, 1, '2020-10-25 09:58:21'),
(110, 1, '2020-10-25 11:13:56'),
(111, 1, '2020-10-25 17:29:02'),
(112, 1, '2020-10-25 19:14:32'),
(113, 1, '2020-10-26 10:48:01'),
(114, 1, '2020-10-26 13:19:34'),
(115, 1, '2020-10-26 18:24:07'),
(116, 1, '2020-10-27 08:09:58'),
(117, 1, '2020-10-27 09:15:52'),
(118, 1, '2020-10-27 12:03:37'),
(119, 1, '2020-10-27 17:54:18'),
(120, 1, '2020-10-27 19:54:05'),
(121, 1, '2020-10-28 08:34:43'),
(122, 1, '2020-10-28 12:06:19'),
(123, 1, '2020-10-28 14:02:03'),
(124, 1, '2020-10-28 18:54:06'),
(125, 1, '2020-10-29 13:19:13'),
(126, 1, '2020-10-29 18:28:43'),
(127, 1, '2020-10-30 08:05:25'),
(128, 1, '2020-10-30 09:17:49'),
(129, 1, '2020-10-30 19:01:56'),
(130, 1, '2020-10-31 06:26:41'),
(131, 1, '2020-11-01 07:52:56'),
(132, 1, '2020-11-01 19:42:30'),
(133, 1, '2020-11-02 07:39:36'),
(134, 1, '2020-11-02 17:42:25'),
(135, 1, '2020-11-03 08:12:16'),
(136, 1, '2020-11-03 09:08:55'),
(137, 1, '2020-11-03 12:00:02'),
(138, 1, '2020-11-03 17:51:44'),
(139, 1, '2020-11-04 08:28:31'),
(140, 1, '2020-11-04 09:07:48'),
(141, 1, '2020-11-04 11:49:46'),
(142, 1, '2020-11-04 12:30:47'),
(143, 1, '2020-11-04 17:17:12'),
(144, 1, '2020-11-04 18:20:14'),
(145, 1, '2020-11-04 18:26:34'),
(146, 1, '2020-11-04 20:35:17'),
(147, 1, '2020-11-05 12:33:12'),
(148, 1, '2020-11-05 18:27:13'),
(149, 1, '2020-11-06 08:01:24'),
(150, 1, '2020-11-06 09:19:45'),
(151, 1, '2020-11-06 18:16:00'),
(152, 1, '2020-11-06 19:40:52'),
(153, 1, '2020-11-07 09:29:14'),
(154, 1, '2020-11-08 18:52:26'),
(155, 1, '2020-11-09 09:42:16'),
(156, 1, '2020-11-10 20:14:00'),
(157, 1, '2020-11-11 07:12:51'),
(158, 1, '2020-11-11 08:46:01'),
(159, 1, '2020-11-11 09:08:35'),
(160, 1, '2020-11-11 13:21:33'),
(161, 1, '2020-11-11 18:39:57'),
(162, 1, '2020-11-12 06:12:47'),
(163, 1, '2020-11-12 13:22:06'),
(164, 1, '2020-11-12 19:33:11'),
(165, 1, '2020-11-13 20:41:10'),
(166, 1, '2020-11-14 12:43:45'),
(167, 1, '2020-11-15 13:03:51'),
(168, 1, '2020-11-15 14:07:28'),
(169, 1, '2020-11-15 17:29:03'),
(170, 1, '2020-11-16 11:45:46'),
(171, 1, '2020-11-16 12:31:50'),
(172, 1, '2020-11-17 08:20:47'),
(173, 1, '2020-11-17 10:15:50'),
(174, 1, '2020-11-17 17:10:19'),
(175, 1, '2020-11-17 19:28:47'),
(176, 1, '2020-11-17 20:21:08'),
(177, 1, '2020-11-18 10:03:24'),
(178, 1, '2020-11-18 11:45:48'),
(179, 1, '2020-11-18 12:32:40'),
(180, 1, '2020-11-18 18:29:03'),
(181, 1, '2020-11-18 19:24:47'),
(182, 1, '2020-11-18 19:25:43'),
(183, 1, '2020-11-19 13:56:10'),
(184, 1, '2020-11-19 19:30:56'),
(185, 1, '2020-11-19 19:55:04'),
(186, 1, '2020-11-19 20:22:17'),
(187, 1, '2020-11-21 17:08:35'),
(188, 1, '2020-11-21 17:10:17'),
(189, 1, '2020-11-21 17:13:10'),
(190, 1, '2020-11-21 17:33:25'),
(191, 1, '2020-11-21 18:55:55'),
(192, 1, '2020-11-21 19:21:36'),
(193, 1, '2020-11-21 19:23:14'),
(194, 1, '2020-11-21 19:25:59'),
(195, 1, '2020-11-21 20:07:20'),
(196, 1, '2020-11-21 20:12:51'),
(197, 1, '2020-11-21 20:14:05'),
(198, 1, '2020-11-21 20:36:32'),
(199, 1, '2020-11-21 20:41:42'),
(200, 1, '2020-11-21 20:55:22'),
(201, 1, '2020-11-21 21:31:56'),
(202, 1, '2020-11-23 20:25:43'),
(203, 1, '2020-11-23 20:29:28'),
(204, 1, '2020-11-23 20:33:02'),
(205, 1, '2020-11-23 20:34:41'),
(206, 1, '2020-11-24 18:45:15'),
(207, 1, '2020-11-24 18:55:01'),
(208, 1, '2020-11-25 19:06:25'),
(209, 1, '2020-11-25 19:09:33'),
(210, 1, '2020-11-25 19:14:35'),
(211, 1, '2020-11-25 19:54:55'),
(212, 1, '2020-11-25 20:18:00'),
(213, 1, '2020-11-25 20:55:04'),
(214, 1, '2020-11-25 20:56:11'),
(215, 1, '2020-11-25 20:58:44'),
(216, 1, '2020-11-25 21:02:01'),
(217, 1, '2020-11-25 21:02:38'),
(218, 1, '2020-11-25 21:04:52'),
(219, 1, '2020-11-25 21:05:45'),
(220, 1, '2020-11-25 21:06:21'),
(221, 1, '2020-11-25 21:08:07'),
(222, 1, '2020-11-25 21:08:54'),
(223, 1, '2020-11-25 21:17:31'),
(224, 1, '2020-11-25 21:19:16'),
(225, 1, '2020-11-25 21:25:54'),
(226, 1, '2020-11-25 21:31:10'),
(227, 1, '2020-11-26 18:50:18'),
(228, 1, '2020-11-26 19:50:41'),
(229, 1, '2020-11-30 20:24:34'),
(230, 1, '2020-12-03 23:25:09'),
(231, 1, '2020-12-05 22:27:18'),
(232, 1, '2020-12-05 22:43:25'),
(233, 1, '2020-12-05 23:18:33'),
(234, 1, '2020-12-06 16:52:19'),
(235, 1, '2020-12-06 19:08:19'),
(236, 1, '2020-12-06 23:18:38'),
(237, 1, '2020-12-08 00:24:21'),
(238, 1, '2020-12-08 00:28:02'),
(239, 1, '2020-12-08 00:29:30'),
(240, 1, '2020-12-08 00:30:08'),
(241, 1, '2020-12-08 00:32:00'),
(242, 1, '2020-12-08 00:33:16'),
(243, 1, '2020-12-08 00:36:21'),
(244, 1, '2020-12-08 00:40:01'),
(245, 1, '2020-12-12 22:05:16'),
(246, 1, '2020-12-12 22:09:27'),
(247, 1, '2020-12-12 22:34:40'),
(248, 1, '2020-12-12 22:37:29'),
(249, 1, '2020-12-12 22:38:13'),
(250, 1, '2020-12-12 22:39:43'),
(251, 1, '2020-12-12 22:40:42'),
(252, 1, '2020-12-12 22:47:40'),
(253, 1, '2020-12-12 22:48:29'),
(254, 1, '2020-12-12 22:49:03'),
(255, 1, '2020-12-12 22:51:02'),
(256, 1, '2020-12-12 22:51:52'),
(257, 1, '2020-12-12 22:53:09'),
(258, 1, '2020-12-12 22:53:41'),
(259, 1, '2020-12-12 22:54:44'),
(260, 1, '2020-12-12 22:56:21'),
(261, 1, '2020-12-12 22:58:12'),
(262, 1, '2020-12-12 23:03:52'),
(263, 1, '2020-12-12 23:09:03'),
(264, 1, '2020-12-12 23:11:50'),
(265, 1, '2020-12-12 23:12:44'),
(266, 1, '2020-12-12 23:21:06'),
(267, 1, '2020-12-16 17:42:48'),
(268, 1, '2020-12-16 17:58:35'),
(269, 1, '2020-12-16 18:15:42'),
(270, 1, '2020-12-17 19:40:05'),
(271, 1, '2020-12-17 20:25:46'),
(272, 1, '2020-12-17 20:51:49'),
(273, 1, '2020-12-19 16:48:19'),
(274, 1, '2020-12-19 17:59:55'),
(275, 1, '2020-12-23 15:11:06'),
(276, 1, '2020-12-23 15:20:36'),
(277, 1, '2021-01-02 22:42:30'),
(278, 1, '2021-01-03 00:33:25'),
(279, 1, '2021-01-03 18:57:41'),
(280, 1, '2021-01-03 22:59:23'),
(281, 1, '2021-01-03 23:03:57'),
(282, 1, '2021-01-03 23:14:06'),
(283, 1, '2021-01-04 00:09:16'),
(284, 1, '2021-01-08 21:42:35'),
(285, 1, '2021-01-08 23:44:44'),
(286, 1, '2021-01-09 00:17:28'),
(287, 1, '2021-01-10 15:32:16'),
(288, 1, '2021-01-10 22:17:40'),
(289, 1, '2021-01-12 09:23:03'),
(290, 1, '2021-01-12 09:24:53'),
(291, 1, '2021-01-16 22:00:12'),
(292, 1, '2021-01-19 10:17:55');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`idBranch`),
  ADD KEY `idPage` (`idPage`),
  ADD KEY `idDrawer` (`idNode`);

--
-- Indices de la tabla `filecss`
--
ALTER TABLE `filecss`
  ADD PRIMARY KEY (`idFileCss`);

--
-- Indices de la tabla `filecssweb`
--
ALTER TABLE `filecssweb`
  ADD PRIMARY KEY (`idCssWeb`);

--
-- Indices de la tabla `filejs`
--
ALTER TABLE `filejs`
  ADD PRIMARY KEY (`idFileJs`);

--
-- Indices de la tabla `filejsweb`
--
ALTER TABLE `filejsweb`
  ADD PRIMARY KEY (`idJsWeb`);

--
-- Indices de la tabla `filelinkhref`
--
ALTER TABLE `filelinkhref`
  ADD PRIMARY KEY (`IdLinkHref`),
  ADD UNIQUE KEY `linkHref` (`linkHref`);

--
-- Indices de la tabla `filemetadata`
--
ALTER TABLE `filemetadata`
  ADD PRIMARY KEY (`idMetaData`);

--
-- Indices de la tabla `forest`
--
ALTER TABLE `forest`
  ADD PRIMARY KEY (`idBranch`,`idLeaf`,`OrderComponent`),
  ADD KEY `IdComponent` (`idLeaf`);

--
-- Indices de la tabla `headscript`
--
ALTER TABLE `headscript`
  ADD PRIMARY KEY (`idHeadScript`),
  ADD UNIQUE KEY `script` (`script`);

--
-- Indices de la tabla `leaf`
--
ALTER TABLE `leaf`
  ADD PRIMARY KEY (`idLeaf`);

--
-- Indices de la tabla `node`
--
ALTER TABLE `node`
  ADD PRIMARY KEY (`idNode`);

--
-- Indices de la tabla `page`
--
ALTER TABLE `page`
  ADD PRIMARY KEY (`idPage`);

--
-- Indices de la tabla `page_filecss`
--
ALTER TABLE `page_filecss`
  ADD PRIMARY KEY (`idPage`,`IdFileCss`),
  ADD KEY `IdFileCss` (`IdFileCss`);

--
-- Indices de la tabla `page_filecssweb`
--
ALTER TABLE `page_filecssweb`
  ADD PRIMARY KEY (`idPage`,`idCssWeb`),
  ADD KEY `idCssWeb` (`idCssWeb`);

--
-- Indices de la tabla `page_filejs`
--
ALTER TABLE `page_filejs`
  ADD PRIMARY KEY (`idPage`,`IdFileJs`),
  ADD KEY `IdFileJs` (`IdFileJs`);

--
-- Indices de la tabla `page_filejsweb`
--
ALTER TABLE `page_filejsweb`
  ADD PRIMARY KEY (`idPage`,`idjsweb`),
  ADD KEY `idjsweb` (`idjsweb`);

--
-- Indices de la tabla `page_filelinkhref`
--
ALTER TABLE `page_filelinkhref`
  ADD PRIMARY KEY (`idPage`,`IdLinkHref`),
  ADD KEY `IdLinkHref` (`IdLinkHref`);

--
-- Indices de la tabla `page_filemetadata`
--
ALTER TABLE `page_filemetadata`
  ADD PRIMARY KEY (`idPage`,`idMetaData`),
  ADD KEY `idMetaData` (`idMetaData`);

--
-- Indices de la tabla `page_headscript`
--
ALTER TABLE `page_headscript`
  ADD PRIMARY KEY (`idPage`,`idHeadscript`),
  ADD KEY `idHeadscript` (`idHeadscript`);

--
-- Indices de la tabla `visit`
--
ALTER TABLE `visit`
  ADD PRIMARY KEY (`idVisit`),
  ADD KEY `idPage` (`idPage`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `branch`
--
ALTER TABLE `branch`
  MODIFY `idBranch` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `filecss`
--
ALTER TABLE `filecss`
  MODIFY `idFileCss` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `filecssweb`
--
ALTER TABLE `filecssweb`
  MODIFY `idCssWeb` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `filejs`
--
ALTER TABLE `filejs`
  MODIFY `idFileJs` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `filejsweb`
--
ALTER TABLE `filejsweb`
  MODIFY `idJsWeb` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `filelinkhref`
--
ALTER TABLE `filelinkhref`
  MODIFY `IdLinkHref` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `filemetadata`
--
ALTER TABLE `filemetadata`
  MODIFY `idMetaData` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `headscript`
--
ALTER TABLE `headscript`
  MODIFY `idHeadScript` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `leaf`
--
ALTER TABLE `leaf`
  MODIFY `idLeaf` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `node`
--
ALTER TABLE `node`
  MODIFY `idNode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `page`
--
ALTER TABLE `page`
  MODIFY `idPage` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `visit`
--
ALTER TABLE `visit`
  MODIFY `idVisit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=293;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `branch`
--
ALTER TABLE `branch`
  ADD CONSTRAINT `branch_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `branch_ibfk_2` FOREIGN KEY (`idNode`) REFERENCES `node` (`idNode`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `forest`
--
ALTER TABLE `forest`
  ADD CONSTRAINT `forest_ibfk_1` FOREIGN KEY (`idBranch`) REFERENCES `branch` (`idBranch`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `forest_ibfk_2` FOREIGN KEY (`idLeaf`) REFERENCES `leaf` (`idLeaf`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filecss`
--
ALTER TABLE `page_filecss`
  ADD CONSTRAINT `page_filecss_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filecss_ibfk_2` FOREIGN KEY (`IdFileCss`) REFERENCES `filecss` (`idFileCss`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filecssweb`
--
ALTER TABLE `page_filecssweb`
  ADD CONSTRAINT `page_filecssweb_ibfk_1` FOREIGN KEY (`idCssWeb`) REFERENCES `filecssweb` (`idCssWeb`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filecssweb_ibfk_2` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filejs`
--
ALTER TABLE `page_filejs`
  ADD CONSTRAINT `page_filejs_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filejs_ibfk_2` FOREIGN KEY (`IdFileJs`) REFERENCES `filejs` (`idFileJs`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filejsweb`
--
ALTER TABLE `page_filejsweb`
  ADD CONSTRAINT `page_filejsweb_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filejsweb_ibfk_2` FOREIGN KEY (`idjsweb`) REFERENCES `filejsweb` (`idJsWeb`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filelinkhref`
--
ALTER TABLE `page_filelinkhref`
  ADD CONSTRAINT `page_filelinkhref_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filelinkhref_ibfk_2` FOREIGN KEY (`IdLinkHref`) REFERENCES `filelinkhref` (`IdLinkHref`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_filemetadata`
--
ALTER TABLE `page_filemetadata`
  ADD CONSTRAINT `page_filemetadata_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_filemetadata_ibfk_2` FOREIGN KEY (`idMetaData`) REFERENCES `filemetadata` (`idMetaData`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `page_headscript`
--
ALTER TABLE `page_headscript`
  ADD CONSTRAINT `page_headscript_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `page_headscript_ibfk_2` FOREIGN KEY (`idHeadscript`) REFERENCES `headscript` (`idHeadScript`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `visit`
--
ALTER TABLE `visit`
  ADD CONSTRAINT `visit_ibfk_1` FOREIGN KEY (`idPage`) REFERENCES `page` (`idPage`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
