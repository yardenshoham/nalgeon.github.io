create table expenses (
    year integer,
    month integer,
    income integer,
    expense integer
);

insert into expenses
(year, month, income, expense)
values
(2020, 1, 94, 82),
(2020, 2, 94, 75),
(2020, 3, 94, 104),
(2020, 4, 100, 94),
(2020, 5, 100, 99),
(2020, 6, 100, 105),
(2020, 7, 100, 95),
(2020, 8, 100, 110),
(2020, 9, 104, 104),
(2020, 10, 104, 100),
(2020, 11, 104, 98),
(2020, 12, 104, 106);

create table sales (
    year integer,
    quarter integer,
    amount integer
);

insert into sales values
(2019, 1, 155040),
(2019, 2, 162600),
(2019, 3, 204120),
(2019, 4, 200700),
(2020, 1, 242040),
(2020, 2, 338040),
(2020, 3, 287520),
(2020, 4, 377340);
