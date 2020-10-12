CREATE TABLE City (
	postcode VARCHAR(8),
	city VARCHAR(20),
	PRIMARY KEY(postcode)
);

CREATE TABLE Hotel (
	hotelID INT NOT NULL AUTO_INCREMENT,
	hotelName VARCHAR(50),
	rating DECIMAL(3,1),
	street VARCHAR(40),
	postcode VARCHAR(8),
	phone CHAR(11),
	breakfastPrice DECIMAL(4,2),
	gracePeriod INT,
	PRIMARY KEY(hotelID),
	FOREIGN KEY(postcode) REFERENCES City(postcode)
);

CREATE TABLE RoomPricing(
	hotelID INT NOT NULL,
	roomType VARCHAR(15) NOT NULL,
	discount INT,
	price DECIMAL(6,2),
	PRIMARY KEY(hotelID,roomType)
);

CREATE TABLE Room(
	roomNumber INT NOT NULL,
	hotelID INT NOT NULL,
	roomType VARCHAR(15),
	refurbishmentStart DATE DEFAULT '0000-00-00',
	refurbishmentEnd DATE DEFAULT'0000-00-00',
	PRIMARY KEY(roomNumber,hotelID),
	FOREIGN KEY(hotelID) REFERENCES Hotel(hotelID),
	FOREIGN KEY(hotelID,roomType) REFERENCES RoomPricing(hotelID,roomType)
);

CREATE TABLE Facility(
	facilityName VARCHAR(25) NOT NULL PRIMARYKEY
);

CREATE TABLE CardDetail(
	cardNumber CHAR(16),
	expDate DATE,
	PRIMARY KEY(cardNumber)
);

CREATE TABLE Customer(
	customerID INT NOT NULL AUTO_INCREMENT,
	title VARCHAR(5),
	fName VARCHAR(20),
	sName VARCHAR(20),
	street VARCHAR(40),
	postcode VARCHAR(8),
	cardNumber CHAR(16),
	email VARCHAR(40),
	phone CHAR(11),
	PRIMARY KEY(customerID),
	FOREIGN KEY(postcode) REFERENCES city(postcode),
	FOREIGN KEY(cardNumber) REFERENCES CardDetail(cardNumber)
);

CREATE TABLE Booking(
	bookingReference INT(9) NOT NULL AUTO_INCREMENT,
	bookingDate Date,
	cancellationDate Date,
	paymentMethod ENUM('cardNow','cardArrive','cashArrive'),
	paymentTime DATETIME,
	paymentCompleted BOOLEAN,
	PRIMARY KEY(bookingReference)
);

CREATE TABLE IsFree(
	hotelID INT NOT NULL,
	facilityName VARCHAR(25),
	free BOOLEAN,
	PRIMARY KEY(hotelID,facilityName),
	FOREIGN KEY(hotelID) REFERENCES Hotel(hotelID),
	FOREIGN KEY(facilityName) REFERENCES Facility(facilityName)
);

CREATE TABLE Reservation(
	hotelID INT NOT NULL,
	roomNumber INT NOT NULL,
	bookingReference INT NOT NULL,
	customerID INT,
	checkInDate DATE,
	checkOutDate DATE,
	numberOfChildren INT,
	numberOfAdults INT,
	specialInstructions VARCHAR(300),
	wantBreakfast BOOLEAN,
	leadGuest VARCHAR(40),
	PRIMARY KEY(bookingReference,hotelID,roomNumber),
	FOREIGN KEY(hotelID) REFERENCES Room(hotelID),
	FOREIGN KEY(roomNumber) REFERENCES Room(roomNumber),
	FOREIGN KEY(bookingReference) REFERENCES Booking(bookingReference),
	FOREIGN KEY(customerID) REFERENCES Customer(customerID)
);

/* Filling with some test data */
INSERT INTO city VALUES('EX4 6PN', 'Exeter');
INSERT INTO city VALUES('EX4 9SD', 'Exeter');
INSERT INTO city VALUES('BS1 6BX', 'Bristol');
INSERT INTO city VALUES('BS1 3LP', 'Bristol');
INSERT INTO city VALUES('BS1 4ER', 'Bristol');
INSERT INTO city VALUES('BS1 4EB', 'Bristol');

INSERT INTO Hotel VALUES(NULL, 'Finzels Reach', 7.5, 'Finzels Reach', 'BS1 6BX', '08716222428', 10, 14);
INSERT INTO Hotel VALUES(NULL, 'HayMarket', 8.1, 'The Haymarket', 'BS1 3LP', '08715278156', 8.5, 14);
INSERT INTO Hotel VALUES(NULL, 'King Street', 8.8, 'Llandoger Trow, King Street', 'BS1 4ER', '08715278158', 0, 7);
INSERT INTO Hotel VALUES(NULL, 'Free Parking Bistol', 9.5, 'Free Parking Street', 'BS1 4EB', '01257894568', 15, 14);
INSERT INTO Hotel VALUES(NULL, 'Exeter Hotel', 9.2, 'Sidwell Street', 'EX4 9SD', '01392547851', 10, 30);

INSERT INTO RoomPricing VALUES(1, 'Double', 15, 75);
INSERT INTO RoomPricing VALUES(1, 'Single', 30, 65);
INSERT INTO RoomPricing VALUES(1, 'Family', 15, 90);
INSERT INTO RoomPricing VALUES(2, 'Twin', 10, 82);
INSERT INTO RoomPricing VALUES(2, 'Single', 12, 70);
INSERT INTO RoomPricing VALUES(2, 'Family', 5, 120);
INSERT INTO RoomPricing VALUES(3, 'Double', 20, 120);
INSERT INTO RoomPricing VALUES(3, 'Single', 0, 90);
INSERT INTO RoomPricing VALUES(3, 'Family', 25, 150);
INSERT INTO RoomPricing VALUES(3, 'Deluxe Single', 20, 160);
INSERT INTO RoomPricing VALUES(3, 'Ensuite Single', 10, 110);
INSERT INTO RoomPricing VALUES(4, 'Double', 20, 80);
INSERT INTO RoomPricing VALUES(4, 'Single', 30, 65);
INSERT INTO RoomPricing VALUES(4, 'Family', 20, 85);

INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(101, 1, 'Double');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(110, 1, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(116, 1, 'Family');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(105, 1, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(204, 1, 'Double');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(114, 2, 'Twin');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(104, 2, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(116, 2, 'Family');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(109, 2, 'Twin');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(129, 2, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(126, 3, 'Ensuite Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(201, 3, 'Deluxe Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(110, 3, 'Family');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(105, 3, 'Double');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(128, 3, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(111, 4, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(142, 4, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(119, 4, 'Double');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(132, 4, 'Single');
INSERT INTO Room (roomNumber, hotelID, roomType) VALUES(201, 4, 'Family');

INSERT INTO Facility VALUES('Parking');
INSERT INTO Facility VALUES('Wi-Fi');
INSERT INTO Facility VALUES('Air Conditioned');
INSERT INTO Facility VALUES('Lift Access');
INSERT INTO Facility VALUES('Restaurant');

INSERT INTO IsFree VALUES(1, 'Parking', TRUE);
INSERT INTO IsFree VALUES(1, 'Wi-Fi', TRUE);
INSERT INTO IsFree VALUES(1, 'Lift Access', TRUE);
INSERT INTO IsFree VALUES(1, 'Air Conditioned', TRUE);
INSERT INTO IsFree VALUES(2, 'Parking', FALSE);
INSERT INTO IsFree VALUES(2, 'Wi-Fi', TRUE);
INSERT INTO IsFree VALUES(2, 'Restaurant', FALSE);
INSERT INTO IsFree VALUES(2, 'Air Conditioned', TRUE);
INSERT INTO IsFree VALUES(3, 'Wi-Fi', FALSE);
INSERT INTO IsFree VALUES(3, 'Restaurant', FALSE);
INSERT INTO IsFree VALUES(3, 'Air Conditioned', TRUE);
INSERT INTO IsFree VALUES(3, 'Lift Access', TRUE);
INSERT INTO IsFree VALUES(4, 'Parking', TRUE);

INSERT INTO CardDetail VALUES('4546098711112340', '2020-10-00');
INSERT INTO CardDetail VALUES('6546098711112315', '2022-12-00');

INSERT INTO Customer VALUES(
	NULL, 'Mr', 'Ian', 'Cooper', '8 Grove Road', 'EX4 6PN', '4546098711112340', 'i.cooper@gmail.com', '07454245098'
);
INSERT INTO Customer VALUES(
	NULL, 'Mr', 'Bob', 'Bob', '10 Grove Road', 'EX4 6PN', '6546098711112315', 'b.bob@gmail.com', '07954245022'
);

INSERT INTO Booking VALUES(224277048, '2018-11-20', NULL, 'cardArrive', '2018-12-28 11:05:00', FALSE);
INSERT INTO Booking VALUES(224277049, '2018-11-20', NULL, 'cardArrive', '2018-12-28 11:05:00', FALSE);
INSERT INTO Booking VALUES(224277050, '2018-11-20', NULL, 'cardArrive', '2018-12-28 11:05:00', FALSE);

INSERT INTO Reservation VALUES(
	1, 101, 224277048, 1, '2018-12-26', '2018-12-28', 0, 2, 'Arrive around 10pm', TRUE, 'Ian Cooper'
);
INSERT INTO Reservation VALUES(
	1, 105, 224277048, 1, '2018-12-26', '2018-12-28', 0, 1, 'Arrive around 10pm', TRUE, 'Sarah Freeman'
);
INSERT INTO Reservation VALUES(
	1, 204, 224277049, 2, '2018-12-23', '2018-12-26', 0, 1, 'Arrive around 10pm', TRUE, 'Sarah Freeman'
);
INSERT INTO Reservation VALUES(
	1, 204, 224277050, 2, '2018-12-29', '2018-12-31', 0, 1, 'Arrive around 10pm', TRUE, 'Sarah Freeman'
);

/*Useful for queries*/
CREATE VIEW RoomsBooked AS
SELECT r.roomNumber, h.hotelID, res.checkInDate, res.checkOutDate, res.bookingReference, r.refurbishmentStart, r.refurbishmentEnd, res.numberOfAdults, res.numberOfChildren, cus.title, cus.fName, cus.Sname, cus.customerID, res.wantBreakfast, b.cancellationDate, h.hotelName
FROM Room r
INNER JOIN Hotel h ON r.hotelID = h.hotelID
INNER JOIN city c ON c.postcode = h.postcode
INNER JOIN Reservation res ON res.roomNumber = r.roomNumber
INNER JOIN customer cus ON cus.customerID = res.customerID
INNER JOIN Booking b ON b.bookingReference = res.bookingReference AND res.hotelID = r.hotelID
INNER JOIN RoomPricing rp ON rp.roomType = r.roomType AND rp.hotelID = r.hotelID;
