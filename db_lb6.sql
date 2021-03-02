-- query 1
select first_name, last_name, title
from customer
cross join(
    select title, film_id
    from film
    where film_id in (
        select film_id
        from film_category
        where category_id in (
            select category_id
            from category where name='Horror' or name='Sci-Fi'))
    and (rating='R' or rating='PG-13')) as films
where not exists (select customer_id, film_id
                  from inventory
                  left join rental r on inventory.inventory_id = r.inventory_id
                  where r.customer_id = customer.customer_id and films.film_id = inventory.film_id
);

-- optimization of query 1
select first_name, last_name, title
from customer
cross join(
    select title, film_id
    from film
    where film_id in (
        select film_id
        from film_category
        where category_id in (
            select category_id
            from category where name='Horror' or name='Sci-Fi'))
    and (rating='R' or rating='PG-13')) as films
where (customer.customer_id, films.film_id) not in (
    select customer_id, film_id
    from inventory left join rental r on inventory.inventory_id = r.inventory_id
);

-- query 2
select store_id from store where address_id in (
    select address_id from (
        select a.address_id, sum(amount)
        from payment
        left join customer c on c.customer_id = payment.customer_id
        left join address a on c.address_id = a.address_id
        left join city c2 on a.city_id = c2.city_id
        where date_trunc('month', payment_date) in (select date_trunc('month', max(payment_date)) from payment)
        group by c2.city, a.address_id) as total_amount
);

-- optimization of query 2
create index date_index on payment using btree(payment_date);