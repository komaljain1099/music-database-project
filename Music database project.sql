create database music_database;
use music_database;
select * from album2;

select * from invoice;
## Who is the senior most employee based on job title?

select * from employee1
order by levels desc
limit 1;

##Which Countries have the most invoice?

select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc;

##What are top 3 values of Total invoice
select total from invoice
order by total desc
limit 3;


##Which city has the best customers? We would like throw a promotional music festival in the city we made the most money .
## Write a query that returns one city that has the highest sum of invoice totals .
## Return both the city name & sum of all invoice totals

select * from invoice;
select sum(total) as invoice_total , billing_city 
from invoice
group by billing_city
order by invoice_total desc;

##Who is the best customer? The Customer who has spent the most money will be declared as the best customer.
#Write a query that returns the person who has spent the most money.
select customer.customer_id,customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice ON customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1;

##Write query to return the email, first name , last name & Genre of all Rock Music liseners. Return Your 
##list ordered alphabetically by email starting with A.

select distinct email, first_name , last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(	
	select track_id from track 
    join genre on track.genre_id = genre.genre_id
    where genre.name like 'ROCK'
)
order by email;

use music_database;

select * from employee1;
select * from track;
select * from genre;

##Let's invite the artists who have written the most rock music in our dataset.
##write a query that returns the artist name and total track count of them top 10
##rock bands.
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track 
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
join genre on genre.genre_id = track.genre_id 
where genre.name like 'Rock'
group by artist.artist_id,
		artist.name
order by number_of_songs desc
limit 10;


##Return all the track names that have a song length longer than the average song length.
##Return the name and milliseconds for each track. Order by the song length with the longest songs listed first 
Select name, milliseconds
from track
where milliseconds > (
	select avg (milliseconds) as avg_track_length
    from track)
order by milliseconds desc;


##Find how much amount spent by each customer on artists?
#Write a query to return customer name, artist name and total spent
with best_selling_artist as (
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by 1, 2
order by 3 desc
limit 1)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(inl.unit_price*inl.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line inl on inl.invoice_id = i.invoice_id
join track t on t.track_id = inl.track_id
join album2 alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


## We want to find out the most popular music Genre for each country. We determines the most popular genre
## as the genre with the highest amount of purchases. Write a query that returns each country along with
# top Genre. For countries where the maximum number of purchases is shared return all Genre.

#### Method 1
with popular_genre as 
(
	select count(invoice_line.quantity) as purchases, customer.country, genre.genre_id,
    row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as rowno
    from invoice_line
    join invoice on invoice.invoice_id = invoice_line.invoice_id
    join customer on customer.customer_id = invoice.customer_id
    join track on track.track_id = invoice_line.track_id
    join genre on genre.genre_id = track.genre_id
    group by 2,3
    order by 2 asc, 1 desc
    )
    select * from popular_genre where rowno<=1;
    
    
    ###  Method 2
    with recursive 
		sales_per_country as(
			select count(*) as purchase_per_genre, customer.country, genre.name, genre.genre_id
            from invoice_line
            join invoice on invoice.invoice_id = invoice_line.invoice_id
            join customer on customer.customer_id = invoice.customer_id
            join track on track.track_id = invoice_line.track_id
            join genre on genre.genre_id = track.genre_id
            group by 2,3,4
            order by 2
	),
    max_genre_per_country as (select max(purchase_per_genre) as max_genre_number , country
    from sales_per_country
    group by 2
    order by 2)
    
select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country .country
where sales_per_country.purchase_per_genre = max_genre_per_country.max_genre_number;

##Write a query that determines the customer that has spent the ,ost on music for each country.
#Write a query that returns the country along with the top customer and how much they spent. 
#For countries where the top amount spent is shared, provide all customers who spent this amount.alter

with Recursive
	customer_with_country as (
		select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
        from invoice
        join customer on customer.customer_id	= invoice.customer_id
        group by 1,2,3,4
        order by 1,5 desc),
        
	country_max_spending as(
		select billing_country, max(total_spending) as max_spending
        from customer_with_country
        group by billing_country)
        
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;
