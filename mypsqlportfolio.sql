

Q1 :Who is the senior most employeen based on job title?

SELECT * FROM employee
ORDER BY levels desc
LIMIT 1;

Q2 : which countries have the most invoices?
SELECT COUNT(*) as c,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY billing_country desc
LIMIT 3;

Q3 : what are top 3 values of total invoice
SELECT total from invoice
ORDER BY total desc
LIMIT 3;

Q4: Which city has the best customers? we would like to throw a promotional
Music festival in the city we made the most money. write a query that return
one city that has the highest sum of invoice totals.
return both the city name & sum of all invoice totals
SELECT * FROM invoice
SELECT sum(total) as invoice_total, billing_city 
FROM invoice
GROUP BY billing_city 
ORDER BY invoice_total desc;

Q5:Who is the best customer? The customer who has spent the most 
money will be declared the best customer. Write a query that retuns the 
person who has spent the most money

SELECT customer.customer_id,customer.first_name,customer.last_name, sum(total) as total
FROM customer
join invoice on customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc;










MODERATE LEVELS
Q1: Write a query to retun email,first_name, last_name, & genre of 
all rock music listeners. Retun your list order alphabetically by email 
starting with A

SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line on invoice_line.invoice_id = invoice.invoice_id
WHERE track_id in (
SELECT track_id from track 
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name like 'Rock'
)
ORDER BY email;

Q2: Lets invite the artist who have written the most rock music in our dataset.
Write a query that return the artist name and total track count of the top 10 rock 
bands.

SELECT COUNT(artist.artist_id) as aid, artist.name  from artist
JOIN album on album.artist_id = artist.artist_id
JOIN track on track.album_id =  album.album_id
JOIN genre on genre.genre_id = track.genre_id
WHERE genre.name like 'Rock'
GROUP BY artist.artist_id
ORDER BY aid desc
LIMIT 10;


Q3 : Retun all the track names have song length longer than the average 
song length. Retun the name and mileseconds for each track .
order by the song length with the longest songs listed first.


SELECT name, milliseconds from track
WHERE milliseconds >(
SELECT AVG(milliseconds) from track
)
ORDER BY milliseconds desc;





ADVANCED LEVEL
Q1: Find how much amount spent by each customer on artists?
Write a query to retun customer name, artistname and total spent 

WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line 
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id  
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT 
    c.customer_id,  
    c.first_name, 
    c.last_name, 
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id  -- Corrected the column for the JOIN
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name  -- Grouped by appropriate columns
ORDER BY amount_spent DESC;

Q2: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.



WITH popular_genre AS 
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name AS genre_name, 
        genre.genre_id,
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id 
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country ASC, purchases DESC
)
SELECT * 
FROM popular_genre 
WHERE RowNo = 1; 


Q3: Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH RECURSIVE customer_with_country AS (
    SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
    ORDER BY first_name, last_name DESC
),

country_max_spending AS (
    SELECT billing_country, MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)

SELECT 
    cc.billing_country, 
    cc.total_spending, 
    cc.last_name
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;