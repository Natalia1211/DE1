use classicmodels;
select distinct city from customers where country= 'usa';
drop table if exists citycode;
create table citycode(
	id integer not null,
    city varchar(50) not null,
    CodePhone int not null,
    primary key(id));
    
insert into citycode values (1, 'Las Vegas', 702);
insert into citycode values (2, 'San Rafael', 415);
insert into citycode values(3, 'San Francisco', 415);
insert into citycode values(4, 'NYC', 718);
insert into citycode values(5, 'Allentown', 610);
insert into citycode values(6, 'Burlingame', 650);
insert into citycode values(7, 'New Haven', 203);
insert into citycode values(8, 'Cambridge', 617);
insert into citycode values(9, 'Bridgewater', 508);
insert into citycode values(10, 'Brickhaven', 0);
insert into citycode values(11, 'Pasadena', 626);
insert into citycode values(12, 'Glendale', 623);
insert into citycode values(13, 'San Diego', 619);
insert into citycode values(14, 'White Plains', 914);
insert into citycode values(15, 'New Bedford', 508);
insert into citycode values(16, 'Newark', 862);
insert into citycode values(17, 'Philadelphia', 215);
insert into citycode values(18, 'Los Angeles', 213);
insert into citycode values(19, 'Boston', 617);
insert into citycode values(20, 'Nashua', 603);
insert into citycode values(21, 'San Jose', 415);
insert into citycode values(22, 'Burbank', 818);
insert into citycode values(23, 'Brisbane', 415);


drop procedure if exists HW5;
delimiter $$

create procedure HW5()
begin
	declare finish int default 0;
    declare phone varchar(50) default 'x';
    declare customerNumber int default 0;
    declare country varchar(50);
    declare city varchar(50);
    declare PhoneCode int;
    
    
    declare curHW5 
		cursor for 
			select customers.customerNumber, customers.phone, customers.country, citycode.city, citycode.CodePhone 
				FROM classicmodels.customers, classicmodels.citycode 
					where customers.city = citycode.city;
	declare continue handler for not found set finish = 1;
    
    Open curHW5;
		drop table if exists hw5;
        create table hw5 like customers;
        insert into hw5 select * from classicmodels.customers;
        alter table hw5 
			add PhoneCode varchar(50);
				update hw5 set PhoneCode=(select CodePhone from citycode where hw5.city = citycode.city);
		
	hw5loop: loop
        
			fetch curHW5 into customerNumber, Phone, country, city, PhoneCode;
            if finish = 1 then
				leave hw5loop;
			end if;
            IF country = 'USA'  THEN
				IF phone NOT LIKE '+%' THEN
					IF LENGTH(phone) = 10 THEN 
						SET  phone = CONCAT('+1-',PhoneCode,'-',phone);
						UPDATE classicmodels.hw5 
							SET hw5.phone=phone 
								WHERE hw5.customerNumber = customerNumber;
					end if;
				end if;
			end if;
	end loop hw5loop;
    CLOSE curHW5;
end$$
delimiter ;
call HW5();
select * from hw5 where country = 'USA';