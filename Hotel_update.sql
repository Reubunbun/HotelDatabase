/*Update 1 - Update the public rating of the Finzels Reach Hotel to be 8.0.*/
UPDATE Hotel
SET rating = 8.0
WHERE hotelID = 1;

/*Update 2 - Joe Smiths books a double bed in the Finzels Reach Hotel today, the check-in date is 26/12/2020, the check-out date is 29/12/2020, 1 adult and 1 child, with breakfast. He chose to ‘pay on arrival’.*/
INSERT INTO CardDetail VALUES('4785220055652556', '2024-12-00');
INSERT INTO Customer VALUES(
  NULL, 'Mr', 'Joe', 'Smiths', '9 Grove Road', 'EX4 6PN', '4785220055652556', 'j.smith@gmail.com', '07947852103'
);
INSERT INTO Booking VALUES(
  NULL, CURDATE(), NULL, 'cashArrive', NULL, FALSE
);
INSERT INTO Reservation VALUES(
  1, 204,
  (
    SELECT bookingReference
    FROM booking
    ORDER BY bookingReference DESC LIMIT 1
  ),
  (
    SELECT CustomerID
    FROM Customer
    ORDER BY CustomerID DESC LIMIT 1
  ),
  '2020-12-26', '2020-12-29', 1, 1, '', TRUE, 'Joe Smiths'
);

/*Update 3 - A Customer cancels their booking by offering their booking ID.*/
UPDATE Booking
SET cancellationDate = CURDATE();
WHERE bookingReference = 224277048;

/*Update 4 - The Finzels Reach Hotel decreases the discount of all family rooms to 5%.*/
UPDATE RoomPricing
SET discount = 5
WHERE
  roomType = 'Double'
  AND hotelID = 1;

/*Update 5 - All the rooms on the first floor (starting with digit 1) in the Finzels Reach Hotel are set to be refurbished from 01/6/2019 to 10/6/2019.*/
UPDATE room
SET
  refurbishmentStart = '2019-06-01',
  refurbishmentEnd = '2019-06-10'
WHERE
  LEFT(roomNumber, 1) = 1 --first digit of room number
  AND hotelID = 1;
