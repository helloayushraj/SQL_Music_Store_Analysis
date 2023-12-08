-- MUSIC_STORE_ANALYSIS

select * from album; 
select * from artist;
select * from customer; 
select * from employee; 
select * from genre; 
select * from invoice; 
select * from invoice_line; 
select * from media_type; 
select * from playlist; 
select * from playlist_track; 
select * from track; 

/*
1. Who is the senior most employee based on job title?
*/ 

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1; 


/*
2.Which countries have the most Invoices?
*/

SELECT 
      billing_country as country,
      COUNT(invoice_id) as no_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoices DESC;


/*
3.What are top 3 values of total invoice?
*/

SELECT total  FROM invoice
ORDER BY total DESC
LIMIT 3;


/*
4.Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals?
*/

SELECT 
     billing_city  as city_name,
	 SUM(total) as total_invoice
	 FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;


/*
5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money?
*/

SELECT 
        c.customer_id,
		c.first_name,
		c.last_name,
		SUM(i.total) as spent_money
FROM customer c
INNER JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY spent_money DESC
LIMIT 1;
 
 
/*
6. Write query to return the email, first name, last name, & Genre of all Rock Music
   listeners. Return your list ordered alphabetically by email starting with A?
*/

SELECT 
		DISTINCT cu.email,
		cu.first_name,
		cu.last_name
FROM customer cu
INNER JOIN invoice i
ON cu.customer_id = i.customer_id
INNER JOIN invoice_line il
ON i.invoice_id = il.invoice_id
INNER JOIN track tr
ON il.track_id = tr.track_id
INNER JOIN genre gn
ON tr.genre_id = gn.genre_id
WHERE gn.name = 'Rock'
ORDER BY email ASC;

/*
7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
*/

SELECT 
		ar.artist_id,
		ar.name as artist_name,
		COUNT(ar.artist_id) as no_of_songs
FROM artist ar
INNER JOIN album al
ON ar.artist_id = al.artist_id
INNER JOIN track tr
ON al.album_id = tr.album_id
INNER JOIN genre gn
ON tr.genre_id = gn.genre_id
WHERE gn.name = 'Rock'
GROUP BY ar.artist_id
ORDER BY no_of_songs DESC
LIMIT 10;

/*
8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first ?
*/

SELECT 
		name as track_name,
		milliseconds as track_length_in_ms
FROM track
WHERE milliseconds > 
                      (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;
                  

/*
9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/
select * from invoice_line;

WITH best_selling_artist
as (
    SELECT 
			ar.artist_id as artist_id,
			ar.name as artist_name,
	        SUM(il.unit_price*il.quantity) as total_spent
	FROM artist ar
	INNER JOIN album al
	  ON ar.artist_id = al.artist_id
	INNER JOIN track tr
	  ON al.album_id = tr.album_id
	INNER JOIN invoice_line il
	  ON tr.track_id = il.track_id
	GROUP BY ar.artist_id
	ORDER BY total_spent DESC
	LIMIT 1
)	
SELECT 
		c.customer_id,
		c.first_name,c.last_name,
		bsa.artist_name,
		SUM(il.unit_price*il.quantity) as amount_spent
FROM invoice i
INNER JOIN customer c
  ON c.customer_id = i.customer_id
INNER JOIN invoice_line il
  ON i.invoice_id = il.invoice_id
INNER JOIN track t
  ON t.track_id = il.track_id
INNER JOIN album alb
  ON alb.album_id = t.album_id
INNER JOIN best_selling_artist bsa
  ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/*
10. We want to find out the most popular music Genre for each country. We determine the
   most popular genre as the genre with the highest amount of purchases. Write a query
   that returns each country along with the top Genre. For countries where the maximum
   number of purchases is shared return all Genres
*/

WITH popular_genre as
(
	SELECT 
			COUNT(invoice_line.quantity) as purchases,
			customer.country, 
	        genre.name  as genre_name, 
			genre.genre_id,
			ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) as rowno
	FROM invoice_line
	INNER JOIN invoice
	  ON invoice.invoice_id = invoice_line.invoice_id
	INNER JOIN customer
	  ON customer.customer_id = invoice.customer_id
	INNER JOIN track
	  ON track.track_id = invoice_line.track_id
	INNER JOIN genre 
	  ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE rowno <=1;


/*
11. Write a query that determines the customer that has spent the most on music for each
   country. Write a query that returns the country along with the top customer and how
   much they spent. For countries where the top amount spent is shared, provide all
   customers who spent this amount
*/

 
WITH customer_with_country
as (
SELECT 
			cu.customer_id,
			cu.first_name,
			cu.last_name,
			i.billing_country,
			SUM(i.total),
			ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) as row_no
FROM customer cu
INNER JOIN invoice i
ON cu.customer_id = i.customer_id
GROUP BY 1,2,3,4
 )
SELECT * FROM customer_with_country WHERE row_no <=1 











