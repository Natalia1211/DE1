SELECT * FROM birdstrikes.birdstrikes;
use birdstrikes
select cost from birdstrikes
select airline,cost from birdstrikes;
create table new_birdstrikes like birdstrikes
show tables

drop table new_birdstrikes
create table employee
(id integer not null,
employee_name varchar(500) not null)

INSERT INTO employee (id,employee_name) values(1,'student1');
INSERT INTO employee (id,employee_name) values(2,'student2');
INSERT INTO employee (id,employee_name) values(3,'student3');
select * from employee 
insert into employee (id,employee_name) values (4,'student4');
update employee set employee_name='Natalia Iriarte' where id='1';
update employee set employee_name='Sara patino' where id='2';
select * from employee
delete from employee where id='3'
delete from employee where id='4'
truncate employee

;


create user 'Nat'@'%' identified by 'Nat';
grant all on birdstrikes.employee to 'Nat'@'%';
drop user 'Nat'@'%'
use birdstrikes
select *,speed/2 from birdstrikes
select *,speed/2 as halfspeed from birdstrike
select state, cost from birdstrikes order by cost;

select distinct state from birdstrikes;
select distinct airline, damage from birdstrikes order by airline asc;
select cost, damage from birdstrikes order by cost desc limit 49,1;
select * from bridstrikes where state='Alabama';

select distinct state from birdstrikes where state like 'ala%';
SELECT DISTINCT state FROM birdstrikes WHERE state LIKE 'North _a%'
SELECT DISTINCT state FROM birdstrikes WHERE state NOT LIKE 'a%' ORDER BY state
SELECT DISTINCT(state) FROM birdstrikes WHERE state IS NOT NULL AND state != '' ORDER BY state;
SELECT DISTINCT(state) FROM birdstrikes WHERE state IS NOT NULL AND state != '' ORDER BY state;



SELECT * FROM birdstrikes WHERE state = 'Alabama' OR state = 'Missouri';
SELECT DISTINCT state FROM birdstrikes WHERE state IS NOT NULL AND state != '' ORDER BY state ;
--- Homework---
--- Exercise 5 ---
SELECT * FROM birdstrikes where state != '' and bird_size !='';
--Answer = Colorado---
--- Exercise 6 ---
select datediff(now(),(select flight_date from birdstrikes where state = 'colorado'and weekofyear(flight_date)=52)) ;
--- Answer = 7939 ---

