/*Query 1 - List all Bristol hotels with a public rating higher than 8.5 and with free parking*/
SELECT *
from Hotel h
INNER JOIN City c ON h.postcode = c.postcode
INNER JOIN isFree f ON h.hotelID = h.hotelID
WHERE
  h.rating > 8.5
  AND c.city = 'Bristol'
  AND f.facilityName = 'Parking'
  AND f.free = TRUE
  AND f.hotelID = h.hotelID;

/*Query 2 - List all available double rooms in all Bristol hotels on 26/12/2020, ordered by the price without breakfasts, offering basic room information and hotel information*/
SELECT
  r.roomNumber,
  r.roomType AS 'Type',
  h.hotelName AS 'Hotel name',
  CONCAT(h.street, ', ', c.city, ', ', h.postcode) AS Address,
  IF (
    DATEDIFF( '2020-12-26', CURDATE() ) > h.gracePeriod, --The amount of time between now and 26/12/2018
    round( price * ( 1 - (rp.discount /100) ), 2 ),      --Discount if above is greater than grace grace period
    rp.price                                             --Regular price otherwise
  ) AS Price,
  h.breakfastPrice AS 'Breakfast price'
FROM Room r
INNER JOIN Hotel h ON r.hotelID = h.hotelID
INNER JOIN city c ON c.postcode = h.postcode
INNER JOIN roomPricing rp ON rp.hotelID = r.hotelID AND rp.roomType = r.roomType
WHERE
  NOT EXISTS (  --No results should show from the following query
    SELECT *
    FROM
      RoomsBooked rb,
      Room room
    WHERE
      '2020-12-26' >= rb.checkInDate AND '2020-12-26' < rb.checkOutDate AND --Someone checked in on or after 26th, and checks out after.
      r.roomNumber = rb.roomNumber AND --Room number is the same as the booked room's number
      h.hotelID = rb.hotelID AND       --The booked room is from the same hotel
      rb.cancellationDate IS NULL OR   --The booked room wasn't cancelled
      '2020-12-26' BETWEEN room.refurbishmentStart AND room.refurbishmentEnd  --The room is being refurbished
      AND r.roomNumber = room.roomNumber --The refurbished room is the same as the prior room number
      AND h.hotelID = room.hotelID       --The refurbished room is from the same hotel
  )
  AND r.roomType LIKE '%Double%'
  AND c.city = 'Bristol'
ORDER BY Price ASC;

/*Query 3 - Display Ian Cooper’s booking information, and how much he has paid.*/
SELECT
  CONCAT(cus.title, '. ', cus.fName,' ', cus.sName) AS 'Name',
  b.bookingReference,
  res.checkInDate,
  res.checkOutDate,
  h.hotelName,
  CONCAT(h.street, ', ', c.city, ', ', h.postcode) AS Address,
  IF (
    DATEDIFF(res.checkInDate, b.bookingDate) > h.gracePeriod, --If the time between booking and checking in is more than the grace period
    SUM ( --Discounted price for each of the days stayed
      round( price * ( 1 - (rp.discount/100) ), 2 ) * DATEDIFF(res.checkOutDate, res.checkInDate)
    ) + IF ( --Add on the price for breakfast (if they want it)
      res.wantBreakfast,
      h.breakfastPrice * ( SUM(numberOfChildren) + SUM(numberOfAdults) ) * DATEDIFF( res.checkOutDate, res.checkInDate), --Breakfast price * (total guests) * (total days stayed)
      0
    ),
    SUM ( --Regular price for each of the days stayed
      rp.price * DATEDIFF(res.checkOutDate, res.checkInDate)
    ) + IF ( --Add on the price for breakfast (if they want it)
      res.wantBreakfast,
      h.breakfastPrice * ( SUM(numberOfChildren) + SUM(numberOfAdults) ) * DATEDIFF(res.checkOutDate, res.checkInDate),
      0
    )
  ) AS Price,
  b.paymentMethod,
  IF (b.paymentCompleted, 'Paid', 'Pending') AS 'Payment Status'
FROM Room r
INNER JOIN Hotel h ON r.hotelID = h.hotelID
INNER JOIN city c ON c.postcode = h.postcode
INNER JOIN roomPricing rp ON rp.hotelID = r.hotelID AND rp.roomType = r.roomType
INNER JOIN reservation res ON r.roomNumber = res.roomNumber AND r.hotelID = res.hotelID
INNER JOIN Booking b ON b.bookingReference = res.bookingReference
INNER JOIN customer cus ON cus.customerID = res.customerID
WHERE EXISTS ( --Ian Cooper's booking reference
  SELECT *
  FROM RoomsBooked
  WHERE b.bookingReference = 224277048
);

/*Query 4 - Find all the hotels whose double bedroom prices are higher than the average double bedroom price on 26/12/2020.*/
CREATE VIEW Temp AS SELECT --Create a temporary view that stores all double bedrooms with desired variables to later be used
  IF (
    DATEDIFF( '2020-12-26', CURDATE() ) > h.gracePeriod,
    ROUND( price * ( 1 - (rp.discount /100) ), 2 ),
    rp.price
  ) AS Price,
  h.hotelName,
  CONCAT(h.street, ', ', c.city, ', ', h.postcode) AS Address
FROM Room r
INNER JOIN Hotel h ON r.hotelID = h.hotelID
INNER JOIN roomPricing rp ON rp.hotelID = r.hotelID AND rp.roomType = r.roomType
INNER JOIN city c ON c.postcode = h.postcode
WHERE r.roomType LIKE '%Double%';

SELECT DISTINCT
  Price
  ,hotelName
  ,Address
FROM TEMP
HAVING Price < ( SELECT AVG(Price) FROM TEMP );

DROP VIEW Temp;


/*Query 5 - Produce a booking status report on all the rooms in the Finzels Reach Hotel on 26/12/2020.*/
SELECT
  r.roomNumber,
  'available' AS 'Status'
FROM Room r
WHERE --Rooms that are available
  NOT EXISTS ( --If any result shows the room is not available
    SELECT *
    FROM
      RoomsBooked rb,
      Room room
    WHERE
      '2020-12-26' >= rb.checkInDate AND '2020-12-26' < rb.checkOutDate --26th is inbetween booked room's checkin and checkout dates, or the day someone checks in
      AND r.roomNumber = rb.roomNumber
      AND r.hotelID = rb.hotelID
      AND rb.cancellationDate IS NULL
      OR '2020-12-26' BETWEEN room.refurbishmentStart AND room.refurbishmentEnd --26th is inbetween refurbishment dates
      AND r.roomNumber = room.roomNumber
      AND r.hotelID = room.hotelID
  )
  AND r.hotelID = 1 --Finzels Reach is ID 1
UNION
SELECT
  roomNumber,
  'Booked' AS 'Status'
FROM RoomsBooked
WHERE --Rooms that are booked
  '2020-12-26' >= checkInDate AND '2020-12-26' < checkOutDate
  AND hotelID = 1
  AND cancellationDate IS NULL
UNION
SELECT
  roomNumber,
  'refurbishment' AS 'Status'
FROM Room
WHERE --Rooms that are being refurbished
  '2020-12-26' BETWEEN refurbishmentStart AND refurbishmentEnd
  AND hotelID = 1;


/*Query 6 - List how many rooms there are in the Finzels Reach Hotel for each room type.*/
SELECT
  roomType,
  Count(roomType) AS 'Quantity'
FROM room
WHERE hotelID = 1
GROUP BY roomType;

/*Query 7 - Count how many adult guests will be staying in the Finzels Reach Hotel on 26/12/2020.*/
SELECT SUM(numberOfAdults) AS 'Number of adults'
FROM RoomsBooked
WHERE
  hotelID = 1
  AND '2020-12-26' >= checkInDate AND '2020-12-26' < checkOutDate
  AND cancellationDate IS NULL;

/*Query 8 - List all the availability for the Room 204 in the Finzels Reach Hotel in from 25/12/2020 to 30/12/2020. On each day, list the booking customer’s name if it is booked.*/
SELECT
  roomNumber,
  CONCAT(
    IF(checkInDate >= '2020-12-25', checkInDate, '2020-12-25'), --Room is unavailable the day a customer checks in
    ' to ',
    IF(checkOutDate <= '2020-12-30', DATE_SUB(checkoutDate, INTERVAL 1 DAY), '2020-12-30') --Room is available the day a customer checks out, so minus 1 from the checkout date, if the checkout date is the 30th
  ) AS 'Dates Unavailable',
  CONCAT(title, '. ', fName, ' ', sName) AS 'Booked By'
FROM RoomsBooked
WHERE
  checkInDate <= '2020-12-30' AND checkOutDate > '2020-12-25'
  AND cancellationDate IS NULL
  AND hotelID = 1
  AND roomNumber = 204
ORDER BY checkInDate;


/*Query 9 - List how many breakfasts have been ordered in the Finzels Reach hotel on 26/12/2020.*/
SELECT SUM(numberOfAdults) + SUM(numberOfChildren) AS 'Breakfast ordered'
FROM RoomsBooked
WHERE
  wantBreakFast = TRUE
  AND '2020-12-26' > checkInDate AND '2020-12-26' <= checkOutDate
  AND cancellationDate IS NULL;
