#CREATING THE TABLES FOR THE DATA BASE
SET FOREIGN_KEY_CHECKS=0;

DROP SCHEMA IF EXISTS `vmc_db`;
CREATE SCHEMA IF NOT EXISTS `vmc_db`;
USE `vmc_db`;

DROP TABLE IF EXISTS `Vehicle_Type`;
CREATE TABLE IF NOT EXISTS `Vehicle_Type` (
  `Vehicle_Type_ID` INT NOT NULL,
  `Vehicle_Type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Vehicle_Type_ID`));

DROP TABLE IF EXISTS `after_trip_form`;
CREATE TABLE IF NOT EXISTS `after_trip_form` (
  `After_trip_form_ID` INT NOT NULL,
  `Start_Miles` INT NOT NULL,
  `End_Miles` INT NOT NULL,
  `Miles_Travelled` INT NOT NULL DEFAULT '0',
  `Fuel_Bought` CHAR(3) NOT NULL DEFAULT 'no',
  `Amount_of_fuel_bought` FLOAT NOT NULL DEFAULT '0',
  `Cost_of_fuel` FLOAT NOT NULL DEFAULT '0',
  `NCU_Credit_Card_num` BIGINT NULL DEFAULT '0',
  `Maintenance_Complaints` VARCHAR(255) NULL DEFAULT 'N/A',
  PRIMARY KEY (`After_trip_form_ID`));

DROP TABLE IF EXISTS `department`;
CREATE TABLE IF NOT EXISTS `department` (
  `Department_ID` INT NOT NULL AUTO_INCREMENT,
  `Department_Name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Department_ID`));



DROP TABLE IF EXISTS `vehicle_mile_rate`;
CREATE TABLE IF NOT EXISTS `vehicle_mile_rate` (
  `Rate_ID` INT NOT NULL,
  `Rate_Per_Mile` FLOAT NOT NULL,
  PRIMARY KEY (`Rate_ID`));


DROP TABLE IF EXISTS `parts_info`;
CREATE TABLE IF NOT EXISTS `parts_info` (
  `Part_ID` INT NOT NULL AUTO_INCREMENT,
  `Part_Name` VARCHAR(100) NOT NULL,
  `Left_in_Stock` INT NOT NULL,
  `Minium_Stock` INT NOT NULL,
  INDEX `Part_name` (`Part_name` ASC) VISIBLE,
  PRIMARY KEY (`Part_ID`));




DROP TABLE IF EXISTS `parts_used`;
CREATE TABLE IF NOT EXISTS `parts_used` (
  `Parts_Used_ID` INT NOT NULL,
  `Part_ID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `Mechanic_Signed_Out` INT NOT NULL,
  PRIMARY KEY (`Parts_Used_ID`, `Part_ID`, `Quantity`),
  INDEX `Part_ID` (`Part_ID` ASC) VISIBLE,
  INDEX `Mechanic_Signed_Out` (`Mechanic_Signed_Out` ASC) VISIBLE,
  CONSTRAINT `parts_used_ibfk_1`
    FOREIGN KEY (`Part_ID`)
    REFERENCES `parts_info` (`Part_ID`));


DROP TABLE IF EXISTS `detailed_maintenance`;
CREATE TABLE IF NOT EXISTS `detailed_maintenance` (
  `Maintenance_ID` INT NOT NULL,
  `Maintenance_Notes` VARCHAR(255) NULL DEFAULT NULL,
  `Parts_used` INT NOT NULL,
  `Date_Of_Admission` DATE NOT NULL,
  `Release_Date` DATE NOT NULL,
  PRIMARY KEY (`Maintenance_ID`),
  INDEX `Parts_used` (`Parts_used` ASC) VISIBLE,
  CONSTRAINT `detailed_maintenance_ibfk_1`
    FOREIGN KEY (`Parts_used`)
    REFERENCES `parts_used` (`Parts_Used_ID`));



DROP TABLE IF EXISTS `Maintenance`;
CREATE TABLE IF NOT EXISTS `Maintenance` (
  `Maintenance_ID` INT NOT NULL AUTO_INCREMENT,
  `Maintenance_type` VARCHAR(100) NOT NULL,
  `Vehicle` VARCHAR(8) NOT NULL,
  `Sign_Off_Mechanic` VARCHAR(100) NOT NULL,
  `Detailed_maintenance_ID` INT NOT NULL,
  PRIMARY KEY (`Maintenance_ID`),
  INDEX `Vehicle_ID` (`Vehicle` ASC) VISIBLE,
  INDEX `Sign_Off_Mechanic` (`Sign_Off_Mechanic` ASC) VISIBLE,
  INDEX `Detailed_maintenance_ID` (`Detailed_maintenance_ID` ASC) VISIBLE,
  CONSTRAINT `maintenance_ibfk_3`
    FOREIGN KEY (`Detailed_maintenance_ID`)
    REFERENCES `detailed_maintenance` (`Maintenance_ID`));



DROP TABLE IF EXISTS `vehicle`;
CREATE TABLE IF NOT EXISTS `vehicle` (
  `Vehicle_ID` VARCHAR(8) NOT NULL,
  `Model` VARCHAR(100) NOT NULL,
  `Manufacturer` VARCHAR(100) NOT NULL,
  `Vehicle_Type` INT NOT NULL,
  `Rate` INT NOT NULL,
  PRIMARY KEY (`Vehicle_ID`),
  INDEX `vehicle_ibfk_1_idx` (`Vehicle_Type` ASC) VISIBLE,
  INDEX `vehicle_ibfk_2_idx` (`Rate` ASC) VISIBLE,
  CONSTRAINT `vehicle_ibfk_1`
    FOREIGN KEY (`Vehicle_Type`)
    REFERENCES `Vehicle_Type` (`Vehicle_Type_ID`),
  CONSTRAINT `vehicle_ibfk_2`
    FOREIGN KEY (`Rate`)
    REFERENCES `vehicle_mile_rate` (`Rate_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `vehicle_id2`
    FOREIGN KEY (`Vehicle_ID`)
    REFERENCES `Maintenance` (`Vehicle`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

DROP TABLE IF EXISTS `trip_bill`;
CREATE TABLE IF NOT EXISTS `trip_bill` (
  `Bill_ID` INT NOT NULL,
  `Department_For` INT NOT NULL,
  `Encurred_by` INT NOT NULL,
  `Vehicle_Used` VARCHAR(8) NOT NULL,
  `Total` FLOAT NOT NULL DEFAULT '0',
  PRIMARY KEY (`Bill_ID`),
  INDEX `department_reservation_idx` (`Department_For` ASC) VISIBLE,
  INDEX `enccured_by_idx` (`Encurred_by` ASC) VISIBLE,
  INDEX `Vehicle_id_idx` (`Vehicle_Used` ASC) VISIBLE,
  CONSTRAINT `department_reservation`
    FOREIGN KEY (`Department_For`)
    REFERENCES `department` (`Department_ID`),
  CONSTRAINT `vehicle_used`
    FOREIGN KEY (`Vehicle_Used`)
    REFERENCES `vehicle` (`Vehicle_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);



DROP TABLE IF EXISTS  `reservations`;
CREATE TABLE IF NOT EXISTS `reservations` (
  `Reservation_ID` INT NOT NULL AUTO_INCREMENT,
  `Vehicle` VARCHAR(8) NOT NULL,
  `Department_Reserved_for` INT NOT NULL,
  `Faculty_Member_Driving` INT NOT NULL,
  `Destination` VARCHAR(100) NOT NULL,
  `Reservation_Date` DATE NOT NULL,
  `Staff_Sign_Out` TINYINT(1) NOT NULL DEFAULT '0',
  `Faculty_member_Sign_out` TINYINT(1) NOT NULL DEFAULT '0',
  `After_trip_form_ID` INT NOT NULL,
  `Trip_bill_ID` INT NOT NULL,
  PRIMARY KEY (`Reservation_ID`),
  INDEX `After_trip_form_ID` (`After_trip_form_ID` ASC) VISIBLE,
  INDEX `Trip_bill_ID` (`Trip_bill_ID` ASC) VISIBLE,
  INDEX `vehicle_used_idx` (`Vehicle` ASC) VISIBLE,
  CONSTRAINT `reservations_ibfk_2`
    FOREIGN KEY (`After_trip_form_ID`)
    REFERENCES `after_trip_form` (`After_trip_form_ID`),
  CONSTRAINT `reservations_ibfk_3`
    FOREIGN KEY (`Trip_bill_ID`)
    REFERENCES `trip_bill` (`Bill_ID`),
  CONSTRAINT `vehicle_used2`
    FOREIGN KEY (`Vehicle`)
    REFERENCES `vehicle` (`Vehicle_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

DROP TABLE IF EXISTS  `department_has_reservations`;
CREATE TABLE IF NOT EXISTS `department_has_reservations` (
  `department_id` INT NOT NULL,
  `reservation_id` INT NOT NULL,
  PRIMARY KEY (`reservation_id`),
  INDEX `department_idx` (`department_id` ASC) VISIBLE,
  CONSTRAINT `department`
    FOREIGN KEY (`department_id`)
    REFERENCES `vmc_db`.`department` (`Department_ID`),
  CONSTRAINT `reservation`
    FOREIGN KEY (`reservation_id`)
    REFERENCES `reservations` (`Reservation_ID`));

DROP TABLE IF EXISTS `employee`;
CREATE TABLE IF NOT EXISTS `employee` (
  `Employee_ID` INT NOT NULL AUTO_INCREMENT,
  `ForeName` VARCHAR(100) NOT NULL DEFAULT '',
  `Surname` VARCHAR(100) NOT NULL DEFAULT '',
  `Can_Sign_off` CHAR(3) NOT NULL DEFAULT 'no',
  `Department_ID` INT NOT NULL DEFAULT '0',
  PRIMARY KEY (`Employee_ID`),
  INDEX `Department_ID` (`Department_ID` ASC) VISIBLE,
  CONSTRAINT `employee_ibfk_1`
    FOREIGN KEY (`Department_ID`)
    REFERENCES `department` (`Department_ID`));
    
    
DROP TABLE IF EXISTS `Order_Parts`;
CREATE TABLE IF NOT EXISTS `Order_Parts`
(
`Order_ReminderID` INT NOT NULL AUTO_INCREMENT,
`Part_name` VARCHAR(100) NOT NULL DEFAULT '',
`Amount_Needed` INT NOT NULL DEFAULT 0,
PRIMARY KEY(`Order_ReminderID`),

CONSTRAINT `parts_info_ibfk_1`
	FOREIGN KEY (`Part_name`)
    REFERENCES `parts_info` (`Part_name`));

#triggers

#calcuating the total amout of miles driven on a trip
#drop trigger if exists Miles_Driven;
create trigger Miles_Driven
before INSERT
on after_trip_form
for each row 
set  new.Miles_Travelled = 
new.End_Miles-
new.Start_Miles;


#notifying somone that a part needs to be ordered WHEN THE PART IS INITALLY ADDED TO THE DATA BASE
delimiter ??
create trigger check_part_AFTER_INSERT

after insert
on parts_info for each row
begin
	if new.Minium_stock>new.Left_in_stock then
		insert into Order_parts(part_name,Amount_needed) values (new.part_name,(new.Minium_stock-new.Left_in_stock));
	end if;
end ??
delimiter ;

#notifying somone that a part needs to be ordered AFTER TE DATABASE HAS BEEN UPDATED
delimiter ??
create trigger check_part_WHEN_UPDATED

after update
on parts_info for each row
begin
	if new.Minium_stock>new.Left_in_stock then
		insert into Order_parts(part_name,Amount_needed) values (new.part_name,(new.Minium_stock-new.Left_in_stock));
	end if;
end ??
delimiter ;


#INSERTING INTO THE DATA BASE

#MILE RATES

INSERT INTO Vehicle_Mile_Rate VALUES (1,'0.75');
INSERT INTO Vehicle_Mile_Rate VALUES (2,'1.25');
INSERT INTO Vehicle_Mile_Rate VALUES (3,'1.5');
INSERT INTO Vehicle_Mile_Rate VALUES (4,'1.5');
INSERT INTO Vehicle_Mile_Rate VALUES (5,'2');

#VEHCILE TYPES

INSERT INTO Vehicle_Type VALUES(1,'car');
INSERT INTO Vehicle_Type VALUES(2,'Van');
INSERT INTO Vehicle_Type VALUES(3,'4X4');
INSERT INTO Vehicle_Type VALUES(4,'SUV');
INSERT INTO Vehicle_Type VALUES(5,'Lorry');

#VEHICLES

INSERT INTO Vehicle VALUES ('fx57 lna','Focus','Ford',1,1);
INSERT INTO Vehicle VALUES ('fx57 lnb','7.5T','Scania',5,5);
INSERT INTO Vehicle VALUES ('fx57 lnc','Sprinter','Mercedes',2,2);
INSERT INTO Vehicle VALUES ('fx57 lnd','Mondeo','Ford',1,1);
INSERT INTO Vehicle VALUES ('fx57 lne','Transit','Ford',2,2);
INSERT INTO Vehicle VALUES ('fx57 lnf','Corsa','Vauxhall',1,1);
INSERT INTO Vehicle VALUES ('fx57 lng','SLK','Mercedes',1,1);
INSERT INTO Vehicle VALUES ('fx57 lnh','Defender','Land Rover',3,3);
INSERT INTO Vehicle VALUES ('fx57 lni','Golf','Volkswagen',1,1);
INSERT INTO Vehicle VALUES ('fx57 lnj','G-Wagon','Mercedes',4,4);

#DEPARTMENTS

INSERT INTO Department(Department_Name) VALUES ('School of Chemistry');
INSERT INTO Department(Department_Name) VALUES ('School of Computer Science');
INSERT INTO Department(Department_Name) VALUES ('School of Biology');
INSERT INTO Department(Department_Name) VALUES ('School of Engineering');
INSERT INTO Department(Department_Name) VALUES ('School of Maths');
INSERT INTO Department(Department_Name) VALUES ('School of English');
INSERT INTO Department(Department_Name) VALUES ('School of Medicine');
INSERT INTO Department(Department_Name) VALUES ('School of Business');
INSERT INTO Department(Department_Name) VALUES ('School of Games Computing');
INSERT INTO Department(Department_Name) VALUES ('Mechanic');

#EMPLOYEES

INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Dwayne','Johnson','2');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Skyler','White','5');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Optimus','Prime','7');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Quandale','Dingle','10');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Oompa','Lumpa','8');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Scooby','Doo','6');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Charles','Fox','3');
INSERT INTO Employee(Forename,Surname,Department_ID,Can_Sign_off) VALUES ('Sussy','Amoogoose','10','yes');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Mark','Zuckerberg','1');
INSERT INTO Employee(Forename,Surname,Department_ID) VALUES ('Arnold','schwarzenegger','4');
#PARTS
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES('Other Problem parts required orders','0','0');
#ford focus
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford focus oil','52','75');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford focus oil filter','13','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford focus air filter','5','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford focus belt 1','3','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford focus belt 2','7','5');#5
#Scania lorry
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Scania 7.5T oil','60','100');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Scania 7.5T oil filter','2','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Scania 7.5T air filter','4','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Scania 7.5T belt 1','5','15');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Scania 7.5T belt 2','7','15');#10
#Mercedes sprinter
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes sprinter oil','64','60');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes sprinter oil filter','13','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes sprinter air filter','13','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes sprinter belt 1','17','20');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes sprinter belt 2','10','20');#15
#Ford Mondeo
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Mondeo oil','50','55');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Mondeo oil filter','7','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Mondeo air filter','7','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Mondeo belt 1','2','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Mondeo belt 2','3','5');#20
#Ford Transit
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Transit oil','60','60');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Transit oil filter','4','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Transit air filter','5','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Transit belt 1','6','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Ford Transit belt 2','8','10');#25
#Vauxhall Corsa
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Vauxhall Corsa oil','45','50');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Vauxhall Corsa oil filter','2','6');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Vauxhall Corsa air filter','3','6');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Vauxhall Corsa belt 1','3','8');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Vauxhall Corsa belt 2','3','8');#30
#Mercedes SLK
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes SLK oil','65','65');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes SLK oil filter','4','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes SLK air filter','3','3');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes SLK belt 1','5','6');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes SLK belt 2','7','7');#35
#Landrover Defender
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Landrover Defender oil','70','80');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Landrover Defender oil filter','4','7');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Landrover Defender air filter','6','7');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Landrover Defender belt 1','2','10');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Landrover Defender belt 2','9','10');
# Volkswagon Golf
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Volkswagon Golf oil','35','35');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Volkswagon Golf oil filter','5','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Volkswagon Golf air filter','5','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Volkswagon Golf belt 1','2','2');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Volkswagon Golf belt 2','2','2');
#Mercedes G-Wagon
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes G-Wagon oil','35','70');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes G-Wagon oil filter','5','12');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes G-Wagon air filter','7','12');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes G-Wagon belt 1','3','5');
INSERT INTO Parts_Info(Part_Name,Left_in_Stock,Minium_Stock) VALUES ('Mercedes G-Wagon belt 2','2','5');



#AFTER TRIP FORMS


INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles) VALUES ('0','0','0');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles) VALUES ('1','69','420');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num,Maintenance_Complaints) VALUES ('2','245','478','yes','20','55','1111222233334444','vehicle steering appears to be sloppy');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num)  VALUES('3','6002','6523','yes','55','128','22223333344445555');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles) VALUES ('4','7888','7992');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num) VALUES ('5','11286','11612','yes','35','62','3333444455556666');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num) VALUES ('6','684','756','yes','12','25','22223333344445555');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num,Maintenance_Complaints) VALUES ('7','4298','5321','yes','120','130','6666777788889999','vehicle has rumbling at the back when driving above 20mph');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles) VALUES ('8','100645','100832');
INSERT INTO After_Trip_Form (After_trip_form_ID,Start_Miles,End_Miles,Fuel_Bought,Amount_of_fuel_bought,Cost_of_fuel,NCU_Credit_Card_num) VALUES('9','5621','5938','yes','62','70','6666777788889999');
INSERT INTO After_Trip_Form(After_trip_form_ID,Start_Miles,End_Miles) VALUES ('10','86969','87024');


#ANNUAL MAINTENANCE

#ford mondeo
INSERT INTO Parts_Used VALUES ('1','21','50','8');
INSERT INTO Parts_Used VALUES ('1','22','2','4');
INSERT INTO Parts_Used VALUES ('1','23','2','8');
#Slk
INSERT INTO Parts_Used VALUES ('4','31','50','4');
INSERT INTO Parts_Used VALUES ('4','32','2','8');
INSERT INTO Parts_Used VALUES ('4','33','2','8');
#golf
INSERT INTO Parts_Used VALUES ('5','41','50','4');
INSERT INTO Parts_Used VALUES ('5','42','2','4');
INSERT INTO Parts_Used VALUES ('5','43','2','4');
#corsa
INSERT INTO Parts_Used VALUES ('8','26','50','8');
INSERT INTO Parts_Used VALUES ('8','27','2','8');
INSERT INTO Parts_Used VALUES ('8','28','2','8');
#defender
INSERT INTO Parts_Used VALUES ('9','36','50','8');
INSERT INTO Parts_Used VALUES ('9','37','2','4');
INSERT INTO Parts_Used VALUES ('9','38','2','8');
#g wagon
INSERT INTO Parts_Used VALUES ('10','46','50','4');
INSERT INTO Parts_Used VALUES ('10','47','2','8');
INSERT INTO Parts_Used VALUES ('10','48','2','8');

#SAFETY CHECKS

INSERT INTO Parts_Used VALUES ('2','1','1','4');
INSERT INTO Parts_Used VALUES ('7','1','1','8');
#USER COMPLAINTS
INSERT INTO Parts_Used VALUES ('3','1','1','4');
INSERT INTO Parts_Used VALUES ('6','1','1','4');

#DETAILED MAINTENANCE
INSERT INTO Detailed_Maintenance VALUES ('1','Vehicle came in for a standard annual check, changed oil,oil filter and air filter','1','7-10-15','30-10-15');#FORD MONDEO
INSERT INTO Detailed_Maintenance VALUES ('2','Safety check, checking air bags,suspension and seatbelts','2','9-7-21','10-9-21');#SCANIA LORRY
INSERT INTO Detailed_Maintenance VALUES ('3','User complained about rumbling at the back of vehicle','3','16-9-21','30/10-21');#VAUXHALL CORSA
INSERT INTO Detailed_Maintenance VALUES ('4','Vehicle came in for a standard annual check, changed oil','4','7-10-21','9-10-21');#SLK
INSERT INTO Detailed_Maintenance VALUES ('5','Vehicle came in for a standard annual check, changed oil','5','10-10-21','12-10-21');#GOLF
INSERT INTO Detailed_Maintenance VALUES ('6','User reported "loose" feeling steering','6','7-10-21','30-11-21');#SPRINTER
INSERT INTO Detailed_Maintenance VALUES ('7','Safety check, checking air bags,suspension and seatbelts','7','7-11-21','8-11-21');#SLK
INSERT INTO Detailed_Maintenance VALUES ('8','Vehicle came in for a standard annual check, changed oil','8','1-12-21','3-12-21');#VAUXHALL CORSA
INSERT INTO Detailed_Maintenance VALUES ('9','Vehicle came in for a standard annual check, changed oil','9','3-12-21','6-12-21');#DEFENDER
INSERT INTO Detailed_Maintenance VALUES ('10','Vehicle came in for a standard annual check, changed oil','10','7-01-22','9-01-22');#G WAGON

#DEPARTMENT HAS RESERVATIONS

INSERT INTO Department_has_reservations VALUES (2,1);
INSERT INTO Department_has_reservations VALUES (1,2);
INSERT INTO Department_has_reservations VALUES (3,3);
INSERT INTO Department_has_reservations VALUES (8,4);
INSERT INTO Department_has_reservations VALUES (8,5);
INSERT INTO Department_has_reservations VALUES (5,6);
INSERT INTO Department_has_reservations VALUES (2,7);
INSERT INTO Department_has_reservations VALUES (7,8);
INSERT INTO Department_has_reservations VALUES (5,9);
INSERT INTO Department_has_reservations VALUES (6,10);

#RESERVATIONS
INSERT INTO Reservations(Vehicle, Department_Reserved_for, Faculty_Member_Driving, Destination, Reservation_Date, Staff_Sign_Out, Faculty_member_Sign_out, After_trip_form_ID, Trip_bill_ID) VALUES('fx57 lna',2,1,'France','2021-04-23',1,1,1,1);#9
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lna',1,9,'Colchester zoo','2021-05-17',1,1,2,2);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lnc',3,6,'InGen Labs','2021-09-15',1,1,3,3);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lnd',8,5,'London','2021-06-26',4,4);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lnf',8,5,'University of Lincoln','2021-10-06',1,1,5,5);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lng',5,2,'Lincoln Stadium','2021-07-15',1,1,6,6);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lni',2,1,'Morrisons','2021-08-25',7,7);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lnj',7,3,'Mantah corp labs','2021-11-02',1,1,8,8);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lne',5,2,'York','2022-01-14',1,1,9,9);
INSERT INTO Reservations(Vehicle,Department_Reserved_for,Faculty_Member_Driving,Destination,Reservation_Date,Staff_Sign_Out,Faculty_member_Sign_out,After_trip_form_ID,Trip_bill_ID) VALUES('fx57 lnc',6,6,'Barnsley','2022-05-23',1,1,10,10);

#MAINTENANCE
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lnd','8','1');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Safety Check','fx57 lnb','8','2');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Maintenance Complaint','fx57 lnf','8','3');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lng','8','4');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lni','8','5');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Maintenance Complaint','fx57 lnc','8','6');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Safety Check','7','fx57 lnh','7');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lnf','8','8');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lnh','8','9');
INSERT INTO maintenance(Maintenance_Type,Vehicle,Sign_Off_Mechanic,Detailed_maintenance_ID) VALUES ('Annual Service','fx57 lnj','8','10');

#TRIP BILL
INSERT INTO trip_bill VALUES(1,2,1,'fx57 lna',10);
INSERT INTO trip_bill VALUES(2,1,9,'fx57 lna',20);
INSERT INTO trip_bill VALUES(3,2,6,'fx57 lnc',30);
INSERT INTO trip_bill VALUES(4,8,5,'fx57 lnd',40);
INSERT INTO trip_bill VALUES(5,8,5,'fx57 lnf',50);
INSERT INTO trip_bill VALUES(6,5,2,'fx57 lng',60);
INSERT INTO trip_bill VALUES(7,2,1,'fx57 lni',70);
INSERT INTO trip_bill VALUES(8,7,3,'fx57 lnj',80);
INSERT INTO trip_bill VALUES(9,5,2,'fx57 lne',90);
INSERT INTO trip_bill VALUES(10,6,6,'fx57 lnc',100);






#checking for parts that need ordering
select * from Order_Parts;

#viewing all available vehicle
drop view if exists Vehicle_Available;
create view Vehicle_Available as
select vehicle.Manufacturer,vehicle.Model from vehicle
where vehicle.vehicle_ID != All(select Vehicle from reservations where reservations.Reservation_Date = '2021-09-15');#vehicle gone is the mercededs sprinter

select * from Vehicle_Available;

#vehicle how many vehicles a department have used
select distinct count(vehicle ) as Amount_Of_Cars_Used, Department.Department_Name
from reservations
right join Department on reservations.Department_Reserved_for=Department.Department_ID
group by(Department_ID);

#miles driven in a year by a department
select Department_Name as 'Department', sum(after_trip_form.Miles_Travelled) as 'Miles Travelled'
from Department
inner join Department_has_reservations on Department.Department_ID=Department_has_reservations.Department_ID
inner join reservations on Department_has_reservations.Reservation_ID = reservations.reservation_ID
right join after_trip_form on reservations.after_trip_form_ID = after_trip_form.After_trip_form_ID
where year(reservations.Reservation_Date) and Department_Name = 'School of Computer Science'
group by Department.Department_ID;

#showing the details of a bill
select trip_bill.Bill_ID as 'Bill Number ',Department.department_name as 'Department billed',employee.Forename as 'Encurred by',vehicle.Model,trip_bill.Total

from trip_bill
#where Bill_ID = 1;
inner join
department on trip_bill.Department_For = Department.Department_ID
inner join
employee on trip_bill.Encurred_by = Employee.Employee_ID
inner join 
vehicle on trip_bill.Vehicle_Used = Vehicle.Vehicle_ID
where bill_id = 5;

#procedure to show those who didnt use the vehicles they reserved
drop procedure if exists NoDrive;
delimiter //
create procedure NoDrive(in test1 int)
begin
select employee.Forename,employee.surname from employee
join reservations on reservations.Faculty_Member_Driving = employee.employee_ID
where reservations.Faculty_member_sign_out = test1;
end //
delimiter ;

call NoDrive(0);


