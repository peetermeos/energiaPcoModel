********************************************************************************
**                                                                             *
** Calendar definition for the model. Defines time structures for both         *
** model time and real world time. Creates tuples connecting them.             *
** Calculates tuples for holidays.                                             *
**                                                                             *
** This file is for time resolution for day and less.                          *
** For monthly resolution have a look at pco_calendar_month                    *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

********************************************************************************
** Daily resolution for time_t, we go from 1 to whatever number of days needed *
********************************************************************************
$evalglobal last_t  jdate(%end_year%, %end_month%, %end_day%) - jdate(%beg_year%, %beg_month%, %beg_day%) + 1

Set time_t "Model time"  /1 * %last_t%/;

Set time_t_s "Model time subset";
time_t_s(time_t) = yes;

$macro  year_number(time_t)  gyear(jdate(%beg_year%, %beg_month%, %beg_day% + ord(time_t) - 1))
$macro month_number(time_t) gmonth(jdate(%beg_year%, %beg_month%, %beg_day% + ord(time_t) - 1))
$macro   day_number(time_t)   gday(jdate(%beg_year%, %beg_month%, %beg_day% + ord(time_t) - 1))
$macro wkday_number(time_t)   gdow(jdate(%beg_year%, %beg_month%, %beg_day% + ord(time_t) - 1))

$macro wkday_number_cal(cal_time) gdow(jdate(%year_1%, 1, ord(cal_time)))
$macro wkday_number_cal_sub(cal_time_sub) gdow(jdate(%beg_year%, %beg_month%, ord(cal_time_sub)))

* Calculating days in month, taking leap years into account
$macro days_in_month_l(year, month) (days_in_month(month) + gleap(jdate(first_year + \
                                                ord(year) - 1, ord(month), 1)))

$macro days_in_t(time_t) 1

* We are cleaning half a production unit (ie boiler) at a time
$macro cleaning_coeff 0.5
$macro period_switch 0

***********************************************************************************************
**                                                                                            *
** Tuples connecting model time and real world time                                           *
**                                                                                            *
** Peeter Meos, 15. august 2014                                                               *
**                                                                                            *
***********************************************************************************************


Set
  date_cal(time_t, year, month) "Tuple connecting model time to calendar time (days)"
  day_cal(time_t, day)          "Tuple connecting day number in a month to calendar days"
  cal_t(time_t, cal_time)       "Tuple connecting model time to calendar time"
;

date_cal(time_t, year, month)$
    (year_number(time_t) =  %year_1% + ord(year) - 1
 and month_number(time_t) = ord(month)
    ) = yes;

day_cal(time_t, day)$(
      day_number(time_t) = ord(day)
    ) = yes;

cal_t(time_t, cal_time)$(
      jdate(%beg_year%, %beg_month%, %beg_day% + ord(time_t) - 1)
      =
      jdate(%year_1%, 1, ord(cal_time))
    ) = yes;

***********************************************************************************************
**                                                                                            *
** Now when time_t set has been created, we are adding day type definition                    *
** Parameter  values are (0 - regular working day, 1 - Saturday, 2 - Sunday or holiday)       *
**                                                                                            *
** Peeter Meos, 15. august 2014                                                               *
**                                                                                            *
***********************************************************************************************
Parameter day_type(time_t);

* Easy stuff first, Saturdays and Sundays
day_type(time_t)$(wkday_number(time_t) = 6) = 1;
day_type(time_t)$(wkday_number(time_t) = 7) = 2;

* Non-moving holidays
* 1 January
day_type(time_t)$(month_number(time_t) = 1  and day_number(time_t)   = 1)  = 2;
* 24. February
day_type(time_t)$(month_number(time_t) = 2  and day_number(time_t)   = 24) = 2;
* 1. May
day_type(time_t)$(month_number(time_t) = 5  and day_number(time_t)   = 1)  = 2;
* 23. June
day_type(time_t)$(month_number(time_t) = 6  and day_number(time_t)   = 23) = 2;
* 24. July
day_type(time_t)$(month_number(time_t) = 6  and day_number(time_t)   = 24) = 2;
* 20. August
day_type(time_t)$(month_number(time_t) = 8  and day_number(time_t)   = 20) = 2;
* 24. December
day_type(time_t)$(month_number(time_t) = 12 and day_number(time_t)   = 24) = 2;
* 25. December
day_type(time_t)$(month_number(time_t) = 12 and day_number(time_t)   = 25) = 2;
* 26. December
day_type(time_t)$(month_number(time_t) = 12 and day_number(time_t)   = 26) = 2;

* Now moving holidays - easter, ascension etc
Scalar e_k, e_m, e_s, e_a, e_d, e_r, e_og, e_sz, e_oe, easter;

loop(year,
  e_k    = floor(div(%year_1% + ord(year) - 1, 100));
  e_m    = 15 + floor(div(3 * e_k + 3, 4)) - floor(div(8 * e_k + 13, 25));
  e_s    = 2  - floor(div(3 * e_k + 3, 4));
  e_a    = mod(%year_1% + ord(year) - 1, 19);
  e_d    = mod(19 * e_a + e_m, 30);
  e_r    = floor(div(e_d, 29)) + (floor(div(e_d, 28)) - floor(div(e_d, 29))) * floor(div(e_a, 11));
  e_og   = 21 + e_d - e_r;
  e_sz   = 7 - mod(%year_1% + ord(year) - 1 + floor(div(%year_1% + ord(year) - 1, 4)) + e_s, 7);
  e_oe   = 7 - mod(e_og - e_sz, 7);
  easter = jdate(%year_1% + ord(year) - 1, 3, e_og + e_oe) + 1;

* Easter Friday
  day_type(time_t)$(ord(time_t) = jdate(first_year, first_month, 1) + easter + 1 - 2) = 2;

* Ascension
  day_type(time_t)$(ord(time_t) = jdate(first_year, first_month, 1) + easter + 1) = 2;

* Nelipühade 1 püha
  day_type(time_t)$(ord(time_t) = jdate(first_year, first_month, 1) + easter + 1 + 50) = 2;
);

***********************************************************************************************
**                                                                                            *
** Calculation of fixed storage time in model time                                            *
**                                                                                            *
** Peeter Meos                                                                                *
***********************************************************************************************
$ifthen.fix set fix_st

* The date given in fix_ladu needs to be calculated into day number.
$evalglobal fix_day   trunc(%fix_st% / 1E6)
$evalglobal fix_month trunc((%fix_st% - (%fix_day% * 1E6)) / 1E4)
$evalglobal fix_year  %fix_st% - (%fix_day% * 1E6) - (%fix_month% * 1E4)

$evalglobal fix_date  jdate(%fix_year%, %fix_month%, %fix_day%) - jdate(%beg_year%, %beg_month%, %beg_day%) + 1

$drop fix_day
$drop fix_month
$drop fix_year

$endif.fix
