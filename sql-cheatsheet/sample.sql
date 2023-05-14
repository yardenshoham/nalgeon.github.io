create table employees (
    id integer primary key,
    name varchar(50),
    city varchar(50),
    department varchar(50),
    salary integer
);

insert into employees
(id, name, city, department, salary)
values
(11, 'Diane', 'London', 'hr', 70),
(12, 'Bob', 'London', 'hr', 78),
(21, 'Emma', 'London', 'it', 84),
(22, 'Grace', 'Berlin', 'it', 90),
(23, 'Henry', 'London', 'it', 104),
(24, 'Irene', 'Berlin', 'it', 104),
(25, 'Frank', 'Berlin', 'it', 120),
(31, 'Cindy', 'Berlin', 'sales', 96),
(32, 'Dave', 'London', 'sales', 96),
(33, 'Alice', 'Berlin', 'sales', 100);

create table if not exists jobs(
    id integer primary key,
    company_id integer,
    name text
);

insert into jobs(id, company_id, name)
values
    (1, 10, 'Data Analyst'),
    (2, 20, 'Go Developer'),
    (3, 20, 'ML Engineer'),
    (4, 99, 'UI Designer')
;

create table if not exists companies(
    id integer primary key,
    name text
);

insert into companies(id, name)
values
    (10, 'Google'),
    (20, 'Amazon'),
    (30, 'Meta')
;