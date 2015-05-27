********************************************************************************
**                                                                             *
** Calendar definition for the model. Defines time structures for both         *
** model time and real world time. Creates tuples connecting them.             *
** Calculates tuples for holidays.                                             *
**                                                                             *
** This file is for time resolution for day and less.                          *
** For smaller resolutions have a look at pco_calendar_day                     *
**                                                                             *
**  31. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

********************************************************************************
** Monthly resolution for time_t, day and weekday numbers are irrelevant       *
********************************************************************************
$show
$ife "%end_year% > %beg_year%" $eval last_t (12 - %beg_month% + 1) + %end_month% + (%end_year% - %beg_year% - 1) * 12

$ifthene %end_year% == %beg_year%
$evalglobal last_t %end_month% - %beg_month% + 1
$endif

Set  time_t  "Model time" /1 * %last_t%/;

Set time_t_s "Model time subset";
time_t_s(time_t) = yes;

$macro  year_number(time_t)  gyear(jdate(%beg_year%, %beg_month% + ord(time_t) - 1, %beg_day%))
$macro month_number(time_t) gmonth(jdate(%beg_year%, %beg_month% + ord(time_t) - 1, %beg_day%))
$macro   day_number(time_t) 1
$macro wkday_number(time_t) 1
$macro wkday_number_cal(cal_time) gdow(jdate(%beg_year%, 1, ord(cal_time) -2))
$macro wkday_number_cal_sub(cal_time_sub) gdow(jdate(%beg_year%, %beg_month%, ord(cal_time_sub)))

* In month in this case we have only one time unit
$macro days_in_month_l(year, month) 1

* Boiler cleanings happen once in two weeks
$macro cleaning_coeff 1/11
$macro period_switch 1

$macro days_in_t(time_t) sum((year, month)$y_m_t, days_in_month(month)              \
                           + gleap(jdate(%beg_year% + ord(year) - 1, ord(month), 1)))


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
  cal_t(time_t, cal_time)       "Tuple connecting model time to calendar time (hours)"
;

date_cal(time_t, year, month)$
    (year_number(time_t) =  %year_1% + ord(year) - 1
 and month_number(time_t) = ord(month)
    ) = yes;

day_cal(time_t, day) = yes;

cal_t(time_t, cal_time)$(
      gyear(jdate(%beg_year%, %beg_month% + ord(time_t) - 1, 1)) =  gyear(jdate(%year_1%, 1, ord(cal_time)))
      and
      gmonth(jdate(%beg_year%, %beg_month% + ord(time_t) - 1, 1))=  gmonth(jdate(%year_1%, 1, ord(cal_time)))
    ) = yes;

***********************************************************************************************
**                                                                                            *
** With montly resolution it makes no sense to calculate holidays.                            *
**                                                                                            *
** Peeter Meos, 15. august 2014                                                               *
**                                                                                            *
***********************************************************************************************

Parameter day_type(time_t);
day_type(time_t) = 0;

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

$ife "%fix_year% > %beg_year%" $evalglobal fix_date (12 - %beg_month% + 1) + %fix_month% + (%fix_year% - %beg_year% - 1) * 12

$ifthene %fix_year% == %beg_year%
$evalglobal fix_date %fix_month% - %beg_month% + 1
$endif

$drop fix_day
$drop fix_month
$drop fix_year

$endif.fix

