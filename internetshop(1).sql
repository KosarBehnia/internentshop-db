-- phpMyAdmin SQL Dump
-- version 4.7.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 18, 2019 at 06:26 PM
-- Server version: 10.1.26-MariaDB
-- PHP Version: 7.1.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `internetshop`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `shopnewnum` (IN `idorder` INT(10), IN `idshop` INT(10))  BEGIN
DECLARE n INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE numc INT DEFAULT 0;
DECLARE idp INT(10);

SELECT COUNT(*) FROM orderproduct INTO n;
SET i=0;
WHILE i<n DO 
SET idp = -1;
SELECT orderproduct.productID 
from orderproduct 
WHERE orderproduct.ID = i AND orderID = idorder INTO idp;

SELECT orderproduct.num
from orderproduct 
WHERE orderproduct.ID = i AND orderID = idorder INTO numc;

UPDATE product
SET number = number - numc
WHERE product.productID = idp AND product.ShopID = idshop;

SET i = i + 1;
END WHILE;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `chargeaccount` (`idc` INT(6), `price` FLOAT(7,2)) RETURNS INT(2) BEGIN
  DECLARE profit INT(2);
  SET profit = 1;
  UPDATE customer
  set credit =credit + price
  WHERE customer.id = idc;
  RETURN profit;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `completeorder` (`idorder` INT(10), `idcustomer` INT(10)) RETURNS INT(2) BEGIN
  DECLARE profit INT(2);
  DECLARE pricetotal integer;
  DECLARE pays char(100);
  
  SET pays = "";
  SET pricetotal = 0;
  SET profit = 1;
  Select sum( p*n) INTO     pricetotal
  from(
  SELECT product.price AS p,orderproduct.num AS n
  FROM `orders` , orderproduct , product
  WHERE `orders`.`orderID` = idorder AND
  orderproduct.orderid = idorder AND
  orderproduct.productid = product.productID)AS W;
  
  SELECT pay INTO pays
  FROM orders
  WHERE orders.orderID = idorder;
  
  IF(pays = "credit")
  THEN
  UPDATE customer
  SET credit = credit - pricetotal
  WHERE customer.ID = idcustomer;
  END IF;
  
  UPDATE shopdelivery
  SET credit = credit + .05*pricetotal
  WHERE shopdelivery.orderID = idorder;
  
  UPDATE shopdelivery
  SET `status` = "free"
  WHERE shopdelivery.orderID = idorder;
  
  UPDATE `orders`
  SET `status` = "completed"
  WHERE `orders`.`orderID`= idorder;
  
  DELETE FROM `temporary`
  WHERE `temporary`.`orderID` = idorder;  
  

 
  RETURN profit;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `password` char(32) NOT NULL,
  `Email` varchar(30) NOT NULL,
  `Name` varchar(15) NOT NULL,
  `FamilyName` varchar(15) NOT NULL,
  `PostalCode` int(10) NOT NULL,
  `Gender` set('male','female') NOT NULL,
  `Credit` int(15) NOT NULL,
  `ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`password`, `Email`, `Name`, `FamilyName`, `PostalCode`, `Gender`, `Credit`, `ID`) VALUES
('81dc9bdb52d04dc20036dbd8313ed055', 'fire@gmail.com', 'melika', 'barani', 1354, 'female', 40000, 10001),
('e10adc3949ba59abbe56e057f20f883e', 'arash@gmail.com', 'arash', 'barani', 1354, 'male', 20000, 10002),
('', 'atrina@gmail.com', 'atrina', 'abadi', 34562, 'female', -1, 20001),
('', 'atena@gmail.com', 'atena', 'asraii', 38962, 'female', -1, 20002),
('', 'amir@gmail.com', 'amir', 'anaby', 48762, 'male', -1, 20003);

-- --------------------------------------------------------

--
-- Table structure for table `customeraddress`
--

CREATE TABLE `customeraddress` (
  `customerid` int(10) NOT NULL,
  `Address` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customeraddress`
--

INSERT INTO `customeraddress` (`customerid`, `Address`) VALUES
(10001, 'poonak'),
(10001, 'valiasr'),
(10002, 'gisha'),
(10002, 'vanak'),
(20001, 'valiasr str'),
(20002, 'vanak'),
(20003, 'poonak');

-- --------------------------------------------------------

--
-- Table structure for table `customertelephone`
--

CREATE TABLE `customertelephone` (
  `Telephone` int(10) NOT NULL,
  `customerid` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customertelephone`
--

INSERT INTO `customertelephone` (`Telephone`, `customerid`) VALUES
(97653, 10002),
(10001, 876543);

-- --------------------------------------------------------

--
-- Table structure for table `deliverylog`
--

CREATE TABLE `deliverylog` (
  `logID` int(20) NOT NULL,
  `deliveryID` int(10) NOT NULL,
  `ShopID` int(11) NOT NULL,
  `status` varchar(20) NOT NULL,
  `credit` int(20) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `deliverylog`
--

INSERT INTO `deliverylog` (`logID`, `deliveryID`, `ShopID`, `status`, `credit`, `time`) VALUES
(57, 30001, 50001, 'free', 10000, '2019-01-18 08:19:23'),
(58, 30002, 50002, 'free', 10000, '2019-01-18 08:20:05'),
(59, 30003, 50001, 'free', 10000, '2019-01-18 08:20:39'),
(60, 30001, 50001, 'on-way', 10000, '2019-01-18 08:38:31'),
(61, 30001, 50001, 'on-way', 10000, '2019-01-18 08:38:31'),
(62, 30003, 50001, 'on-way', 10000, '2019-01-18 08:40:21'),
(63, 30003, 50001, 'on-way', 10000, '2019-01-18 08:40:21'),
(64, 30002, 50002, 'on-way', 10000, '2019-01-18 08:43:25'),
(65, 30002, 50002, 'on-way', 10000, '2019-01-18 08:43:25'),
(66, 30001, 50001, 'on-way', 10500, '2019-01-18 08:45:01'),
(67, 30001, 50001, 'free', 10500, '2019-01-18 08:45:01'),
(68, 30001, 50001, 'on-way', 10500, '2019-01-18 08:49:26'),
(69, 30001, 50001, 'on-way', 10500, '2019-01-18 08:49:26'),
(70, 30001, 50001, 'free', 10500, '2019-01-18 08:53:51'),
(71, 30002, 50002, 'free', 10000, '2019-01-18 08:53:56'),
(72, 30003, 50001, 'free', 10000, '2019-01-18 08:54:01'),
(73, 30001, 50001, 'on-way', 10500, '2019-01-18 09:04:44'),
(74, 30001, 50001, 'on-way', 10500, '2019-01-18 09:04:44'),
(75, 30003, 50001, 'on-way', 10000, '2019-01-18 09:07:33'),
(76, 30003, 50001, 'on-way', 10000, '2019-01-18 09:07:33'),
(77, 30003, 50001, 'free', 10000, '2019-01-18 09:15:48'),
(78, 30001, 50001, 'free', 10500, '2019-01-18 09:15:56'),
(79, 30001, 50001, 'on-way', 10500, '2019-01-18 09:17:56'),
(80, 30001, 50001, 'on-way', 10500, '2019-01-18 09:17:56'),
(81, 30001, 50001, 'free', 10500, '2019-01-18 09:22:16'),
(82, 30001, 50001, 'on-way', 10500, '2019-01-18 09:22:44'),
(83, 30001, 50001, 'on-way', 10500, '2019-01-18 09:22:44'),
(84, 30003, 50001, 'on-way', 10000, '2019-01-18 09:24:43'),
(85, 30003, 50001, 'on-way', 10000, '2019-01-18 09:24:43'),
(86, 30001, 50001, 'on-way', 11050, '2019-01-18 09:25:43'),
(87, 30001, 50001, 'free', 11050, '2019-01-18 09:25:43'),
(88, 30002, 50002, 'on-way', 10000, '2019-01-18 09:28:31'),
(89, 30002, 50002, 'on-way', 10000, '2019-01-18 09:28:31'),
(90, 30001, 50001, 'on-way', 11050, '2019-01-18 09:30:39'),
(91, 30001, 50001, 'on-way', 11050, '2019-01-18 09:30:39'),
(92, 30001, 50001, 'free', 11050, '2019-01-18 09:33:35'),
(93, 30002, 50002, 'free', 10000, '2019-01-18 09:35:00'),
(94, 30003, 50001, 'free', 10000, '2019-01-18 09:35:06'),
(95, 30001, 50001, 'free', 0, '2019-01-18 09:35:11'),
(96, 30002, 50002, 'free', 0, '2019-01-18 09:35:15'),
(97, 30003, 50001, 'free', 0, '2019-01-18 09:35:18'),
(98, 30001, 50001, 'on-way', 0, '2019-01-18 09:41:12'),
(99, 30001, 50001, 'on-way', 0, '2019-01-18 09:41:12'),
(100, 30001, 50001, 'on-way', 550, '2019-01-18 09:44:16'),
(101, 30001, 50001, 'free', 550, '2019-01-18 09:44:16'),
(102, 30002, 50002, 'on-way', 0, '2019-01-18 09:45:15'),
(103, 30002, 50002, 'on-way', 0, '2019-01-18 09:45:15'),
(104, 30001, 50001, 'on-way', 550, '2019-01-18 09:46:36'),
(105, 30001, 50001, 'on-way', 550, '2019-01-18 09:46:36'),
(106, 30001, 50001, 'on-way', 1050, '2019-01-18 09:47:48'),
(107, 30001, 50001, 'free', 1050, '2019-01-18 09:47:48'),
(108, 30002, 50002, 'on-way', 950, '2019-01-18 09:48:33'),
(109, 30002, 50002, 'free', 950, '2019-01-18 09:48:33');

-- --------------------------------------------------------

--
-- Stand-in structure for view `maxnumber`
-- (See below for the actual view)
--
CREATE TABLE `maxnumber` (
`shopID` int(10)
,`maxnum` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `moncust`
-- (See below for the actual view)
--
CREATE TABLE `moncust` (
`customerid` int(10)
,`scust` decimal(42,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `newcustomer`
--

CREATE TABLE `newcustomer` (
  `Name` varchar(15) NOT NULL,
  `Familyname` varchar(15) NOT NULL,
  `Email` varchar(30) NOT NULL,
  `Address` varchar(200) NOT NULL,
  `Telephone` int(10) NOT NULL,
  `PostalCode` int(10) NOT NULL,
  `Gender` set('female','male') NOT NULL,
  `ID` int(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `newcustomer`
--

INSERT INTO `newcustomer` (`Name`, `Familyname`, `Email`, `Address`, `Telephone`, `PostalCode`, `Gender`, `ID`) VALUES
('amir', 'anaby', 'amir@gmail.com', 'poonak', 92335323, 48762, 'male', 20003),
('atena', 'asraii', 'atena@gmail.com', 'vanak', 92165413, 38962, 'female', 20002),
('atrina', 'abadi', 'atrina@gmail.com', 'valiasr str', 92165623, 34562, 'female', 20001);

--
-- Triggers `newcustomer`
--
DELIMITER $$
CREATE TRIGGER `before_insert_newcustomer` AFTER INSERT ON `newcustomer` FOR EACH ROW BEGIN
INSERT INTO customer(ID, `password`, Email,  Name , Familyname, PostalCode, Gender, credit) VALUES (NEW.ID, "", NEW.Email, NEW.Name, NEW.Familyname, NEW.Postalcode, NEW.Gender,-1);
INSERT INTO customeraddress(customerid, Address) VALUES (NEW.ID, NEW.Address);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orderlog`
--

CREATE TABLE `orderlog` (
  `logID` int(20) NOT NULL,
  `orderID` int(15) NOT NULL,
  `status` varchar(20) NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderlog`
--

INSERT INTO `orderlog` (`logID`, `orderID`, `status`, `time`) VALUES
(45, 60001, 'registered', '2019-01-18 08:38:31'),
(46, 60001, 'delivered', '2019-01-18 08:38:31'),
(47, 60002, 'denied', '2019-01-18 08:40:21'),
(48, 60003, 'registered', '2019-01-18 08:43:25'),
(49, 60003, 'delivered', '2019-01-18 08:43:25'),
(50, 60001, 'completed', '2019-01-18 08:45:01'),
(51, 60006, 'denied', '2019-01-18 08:49:26'),
(52, 60001, 'registered', '2019-01-18 09:04:44'),
(53, 60001, 'delivered', '2019-01-18 09:04:44'),
(54, 60002, 'registered', '2019-01-18 09:07:33'),
(55, 60002, 'delivered', '2019-01-18 09:07:33'),
(56, 60001, 'registered', '2019-01-18 09:17:56'),
(57, 60001, 'delivered', '2019-01-18 09:17:56'),
(58, 60001, 'registered', '2019-01-18 09:22:44'),
(59, 60001, 'delivered', '2019-01-18 09:22:44'),
(60, 60002, 'registered', '2019-01-18 09:24:43'),
(61, 60002, 'delivered', '2019-01-18 09:24:43'),
(62, 60001, 'completed', '2019-01-18 09:25:43'),
(63, 60003, 'registered', '2019-01-18 09:28:31'),
(64, 60003, 'delivered', '2019-01-18 09:28:31'),
(65, 60004, 'denied', '2019-01-18 09:30:39'),
(66, 60004, 'denied', '2019-01-18 09:34:25'),
(67, 60001, 'denied', '2019-01-18 09:36:22'),
(68, 60001, 'registered', '2019-01-18 09:36:57'),
(69, 60001, 'delivered', '2019-01-18 09:36:57'),
(70, 60001, 'registered', '2019-01-18 09:41:12'),
(71, 60001, 'delivered', '2019-01-18 09:41:12'),
(72, 60002, 'denied', '2019-01-18 09:43:05'),
(73, 60001, 'completed', '2019-01-18 09:44:16'),
(74, 60003, 'registered', '2019-01-18 09:45:15'),
(75, 60003, 'delivered', '2019-01-18 09:45:15'),
(76, 60004, 'registered', '2019-01-18 09:46:36'),
(77, 60004, 'delivered', '2019-01-18 09:46:36'),
(78, 60004, 'completed', '2019-01-18 09:47:48'),
(79, 60003, 'completed', '2019-01-18 09:48:33');

-- --------------------------------------------------------

--
-- Table structure for table `orderproduct`
--

CREATE TABLE `orderproduct` (
  `orderID` int(15) NOT NULL,
  `productID` int(15) NOT NULL,
  `num` int(2) DEFAULT NULL,
  `ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderproduct`
--

INSERT INTO `orderproduct` (`orderID`, `productID`, `num`, `ID`) VALUES
(60001, 40001, 1, 1),
(60001, 40003, 1, 0),
(60002, 40003, 3, 2),
(60003, 40004, 3, 3),
(60003, 40005, 1, 5),
(60003, 40006, 1, 4),
(60004, 40003, 1, 6),
(60006, 40002, 1, 7);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `orderID` int(15) NOT NULL,
  `shopID` int(10) NOT NULL,
  `status` set('registered','delivered','denied','completed') NOT NULL,
  `pay` set('credit','bank') NOT NULL,
  `Date` date NOT NULL,
  `Address` varchar(200) NOT NULL,
  `customerid` int(10) DEFAULT NULL,
  `time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`orderID`, `shopID`, `status`, `pay`, `Date`, `Address`, `customerid`, `time`) VALUES
(60001, 50001, 'completed', 'bank', '2019-01-17', 'poonak', 10001, '12:00:00'),
(60002, 50001, 'denied', 'bank', '2019-01-17', 'gisha', 10002, '12:00:00'),
(60003, 50002, 'completed', 'bank', '2019-01-17', 'valiasr str', 20001, '12:00:00'),
(60004, 50001, 'completed', 'bank', '2019-01-17', 'poonak', 20003, '12:00:00');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `before_insert_orders` BEFORE UPDATE ON `orders` FOR EACH ROW BEGIN
DECLARE Iddelivery INT(20);
IF(NEW.status = "delivered")
THEN

SELECT shopdelivery.deliveryID INTO Iddelivery
FROM shopdelivery
WHERE shopdelivery.ShopID = NEW.shopID AND 
shopdelivery.`status` = "free"
LIMIT 1;


UPDATE shopdelivery 
SET `status` = "on-way"
WHERE shopdelivery.deliveryID = Iddelivery;

UPDATE shopdelivery 
SET shopdelivery.orderID = NEW.orderID
WHERE shopdelivery.deliveryID = Iddelivery;

END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `orderlog` AFTER INSERT ON `orders` FOR EACH ROW INSERT INTO orderlog VALUES(null, NEW.orderID, NEW.status, NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `orderlogupdate` AFTER UPDATE ON `orders` FOR EACH ROW INSERT INTO orderlog VALUES(null, NEW.orderID, NEW.status, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `productID` int(15) NOT NULL,
  `ShopID` int(10) NOT NULL,
  `name` varchar(15) NOT NULL,
  `price` int(8) NOT NULL,
  `number` int(2) NOT NULL,
  `discount` int(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`productID`, `ShopID`, `name`, `price`, `number`, `discount`) VALUES
(40001, 50001, 'water', 1000, 10, 10),
(40002, 50002, 'milk', 3000, 5, 20),
(40003, 50001, 'cake', 10000, 1, 30),
(40004, 50002, 'pencil', 2000, 4, 0),
(40005, 50002, 'book', 5000, 3, 10),
(40006, 50002, 'Notebook', 6000, 4, 20),
(40006, 50003, 'Notebook', 2000, 10, 0);

-- --------------------------------------------------------

--
-- Table structure for table `shop`
--

CREATE TABLE `shop` (
  `ID` int(10) NOT NULL,
  `Name` varchar(20) NOT NULL,
  `City` varchar(20) NOT NULL,
  `Address` varchar(200) NOT NULL,
  `Phone` int(10) NOT NULL,
  `Manager` varchar(20) NOT NULL,
  `StartTime` time NOT NULL,
  `FinishTime` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shop`
--

INSERT INTO `shop` (`ID`, `Name`, `City`, `Address`, `Phone`, `Manager`, `StartTime`, `FinishTime`) VALUES
(50001, 'refah', 'shiraz', 'zargari', 3825615, 'anna', '08:00:00', '20:00:00'),
(50002, 'caren', 'shiraz', 'maliabad', 4625615, 'helena', '09:00:00', '19:00:00'),
(50003, 'harmony', 'shiraz', 'zargari', 4625678, 'mitra', '08:00:00', '10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `shopdelivery`
--

CREATE TABLE `shopdelivery` (
  `ShopID` int(10) NOT NULL,
  `deliveryID` int(10) NOT NULL,
  `orderID` int(20) NOT NULL,
  `name` varchar(15) NOT NULL,
  `familyname` varchar(15) NOT NULL,
  `phone` int(10) NOT NULL,
  `address` varchar(200) NOT NULL,
  `status` set('free','on-way') NOT NULL,
  `credit` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shopdelivery`
--

INSERT INTO `shopdelivery` (`ShopID`, `deliveryID`, `orderID`, `name`, `familyname`, `phone`, `address`, `status`, `credit`) VALUES
(50001, 30001, 60004, 'ehsan', 'ebrahimi', 93176442, '', 'free', 1050),
(50002, 30002, 60003, 'kevan', 'ebrahimi', 931768842, '', 'free', 950),
(50001, 30003, 60002, 'kevan', 'ebrahimi', 93197842, '', 'free', 0);

--
-- Triggers `shopdelivery`
--
DELIMITER $$
CREATE TRIGGER `delivermanCHANGE` AFTER UPDATE ON `shopdelivery` FOR EACH ROW INSERT INTO deliverylog VALUES(null, NEW.deliveryID, NEW.shopID, NEW.status,NEW.credit, NOW())
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delivermanLOG` AFTER INSERT ON `shopdelivery` FOR EACH ROW INSERT INTO deliverylog VALUES(null, NEW.deliveryID, NEW.shopID, NEW.status,NEW.credit, NOW())
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `shopprocess`
--

CREATE TABLE `shopprocess` (
  `ProcessID` int(10) NOT NULL,
  `ShopID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `shopsupport`
--

CREATE TABLE `shopsupport` (
  `ShopID` int(10) NOT NULL,
  `SupportID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `temporary`
--

CREATE TABLE `temporary` (
  `orderID` int(15) DEFAULT NULL,
  `shopID` int(10) DEFAULT NULL,
  `status` set('registered','delivered','denied','compelete') DEFAULT NULL,
  `pay` set('credit','bank') DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Address` varchar(200) DEFAULT NULL,
  `customerid` int(10) DEFAULT NULL,
  `time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `temporary`
--

INSERT INTO `temporary` (`orderID`, `shopID`, `status`, `pay`, `Date`, `Address`, `customerid`, `time`) VALUES
(60002, 50001, 'registered', 'credit', '2019-01-17', 'vanak', 10002, '12:00:00'),
(60002, 50001, NULL, 'bank', '2019-01-17', 'gisha', 10002, '12:00:00'),
(60002, 50001, NULL, 'credit', '2019-01-17', 'gisha', 10002, '12:00:00');

--
-- Triggers `temporary`
--
DELIMITER $$
CREATE TRIGGER `before_insert` BEFORE INSERT ON `temporary` FOR EACH ROW BEGIN
DECLARE shopopent Time;
DECLARE shopcloset Time;
DECLARE crows INT;
DECLARE creq INT;
DECLARE cdelivery INT;
DECLARE stat char(100);
DECLARE stat2 char(100);
DECLARE paystat char(100);

SELECT starttime INTO shopopent
from  shop
WHERE shop.id = NEW.shopID;

SELECT finishtime INTO shopcloset
from  shop
WHERE shop.ID = NEW.shopID;

IF( shopopent < NEW.time AND NEW.time < shopcloset )
THEN
SELECT count(*) INTO crows
FROM orderproduct
WHERE orderproduct.orderID = NEW.orderID;

SELECT count(*) INTO creq
FROM orderproduct,product
WHERE orderproduct.orderID = NEW.orderID AND
orderproduct.productID = product.productID AND product.ShopID = NEW.ShopID AND
 orderproduct.num <= product.number;
 
 SET stat = "denied";
 IF(creq = crows)
 THEN 
 SELECT count(*) INTO cdelivery
 FROM shopdelivery
 WHERE shopdelivery.ShopID = NEW.shopID AND 
 shopdelivery.status = "free";
 IF(cdelivery > 0)
 THEN
 SET stat = "registered";
 SET stat2 = "delivered";
 END IF;
 END IF;
END IF;
  
IF(NEW.time < shopopent OR NEW.time > shopcloset)
THEN
SET stat = "denied" ;
END IF;

SET paystat = NEW.pay;
IF(NEW.orderID > 20000)
THEN
SET paystat = "bank";
END IF;
INSERT INTO orders(orderID, customerid,shopID,status,pay,
                  Date, time, Address)
                  VALUES (NEW.orderID, NEW.customerid, NEW.shopID, stat, paystat, NEW.Date, NEW.time, NEW.address);
IF(stat2 = "delivered")
THEN
UPDATE orders
SET status= stat2
WHERE orders.orderID= NEW.orderID;
CALL shopnewnum(NEW.orderID, NEW.shopID);
END IF;                  
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `w`
-- (See below for the actual view)
--
CREATE TABLE `w` (
`productID` int(15)
,`shopID` int(10)
,`snum` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Structure for view `maxnumber`
--
DROP TABLE IF EXISTS `maxnumber`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `maxnumber`  AS  select `w`.`shopID` AS `shopID`,max(`w`.`snum`) AS `maxnum` from `w` group by `w`.`shopID` ;

-- --------------------------------------------------------

--
-- Structure for view `moncust`
--
DROP TABLE IF EXISTS `moncust`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `moncust`  AS  select `orders`.`customerid` AS `customerid`,sum((`orderproduct`.`num` * `product`.`price`)) AS `scust` from ((`orderproduct` join `orders`) join `product`) where ((`orders`.`orderID` = `orderproduct`.`orderID`) and (`orderproduct`.`productID` = `product`.`productID`)) group by `orders`.`customerid` ;

-- --------------------------------------------------------

--
-- Structure for view `w`
--
DROP TABLE IF EXISTS `w`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `w`  AS  (select `orderproduct`.`productID` AS `productID`,`orders`.`shopID` AS `shopID`,sum(`orderproduct`.`num`) AS `snum` from (`orderproduct` join `orders`) where (`orderproduct`.`orderID` = `orders`.`orderID`) group by `orderproduct`.`productID`,`orders`.`shopID`) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `customeraddress`
--
ALTER TABLE `customeraddress`
  ADD PRIMARY KEY (`customerid`,`Address`);

--
-- Indexes for table `customertelephone`
--
ALTER TABLE `customertelephone`
  ADD PRIMARY KEY (`Telephone`),
  ADD KEY `customerid` (`customerid`);

--
-- Indexes for table `deliverylog`
--
ALTER TABLE `deliverylog`
  ADD PRIMARY KEY (`logID`);

--
-- Indexes for table `newcustomer`
--
ALTER TABLE `newcustomer`
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `orderlog`
--
ALTER TABLE `orderlog`
  ADD PRIMARY KEY (`logID`);

--
-- Indexes for table `orderproduct`
--
ALTER TABLE `orderproduct`
  ADD PRIMARY KEY (`orderID`,`productID`),
  ADD KEY `productID` (`productID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`orderID`),
  ADD KEY `shopID` (`shopID`),
  ADD KEY `customerid` (`customerid`) USING BTREE,
  ADD KEY `Address` (`Address`,`customerid`),
  ADD KEY `customerid_2` (`customerid`,`Address`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`productID`,`ShopID`),
  ADD KEY `ShopID` (`ShopID`) USING BTREE;

--
-- Indexes for table `shop`
--
ALTER TABLE `shop`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `shopdelivery`
--
ALTER TABLE `shopdelivery`
  ADD PRIMARY KEY (`deliveryID`),
  ADD KEY `ShopD` (`ShopID`);

--
-- Indexes for table `shopprocess`
--
ALTER TABLE `shopprocess`
  ADD PRIMARY KEY (`ProcessID`),
  ADD KEY `ShopP` (`ShopID`);

--
-- Indexes for table `shopsupport`
--
ALTER TABLE `shopsupport`
  ADD PRIMARY KEY (`SupportID`),
  ADD KEY `ShopID` (`ShopID`,`SupportID`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `deliverylog`
--
ALTER TABLE `deliverylog`
  MODIFY `logID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `orderlog`
--
ALTER TABLE `orderlog`
  MODIFY `logID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- AUTO_INCREMENT for table `shop`
--
ALTER TABLE `shop`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50004;

--
-- AUTO_INCREMENT for table `shopdelivery`
--
ALTER TABLE `shopdelivery`
  MODIFY `deliveryID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30004;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customeraddress`
--
ALTER TABLE `customeraddress`
  ADD CONSTRAINT `customeraddress_ibfk_1` FOREIGN KEY (`customerid`) REFERENCES `customer` (`ID`);

--
-- Constraints for table `orderproduct`
--
ALTER TABLE `orderproduct`
  ADD CONSTRAINT `orderproduct_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`productID`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`shopID`) REFERENCES `shop` (`ID`),
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`customerid`,`Address`) REFERENCES `customeraddress` (`customerid`, `Address`),
  ADD CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`customerid`) REFERENCES `customer` (`ID`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`ShopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shopdelivery`
--
ALTER TABLE `shopdelivery`
  ADD CONSTRAINT `ShopD` FOREIGN KEY (`ShopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shopprocess`
--
ALTER TABLE `shopprocess`
  ADD CONSTRAINT `ShopP` FOREIGN KEY (`ShopID`) REFERENCES `shop` (`ID`);

--
-- Constraints for table `shopsupport`
--
ALTER TABLE `shopsupport`
  ADD CONSTRAINT `ShopS` FOREIGN KEY (`ShopID`) REFERENCES `shop` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
