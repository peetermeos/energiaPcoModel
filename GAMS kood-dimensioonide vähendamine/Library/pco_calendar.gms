********************************************************************************
** Calendar and time definitions                                               *
**                                                                             *
** 30. dets 2013                                                               *
** Peeter Meos                                                                 *
**                                                                             *
********************************************************************************

$setglobal  year_1 2013
$set        year_2 2030
$eval days jdate(%year_2%, 12, 31) - jdate(%year_1%, 1, 1) + 1

Set
  cal_time     "Overall calendar time set" /1         * %days%/
  time_hour    "Model hours"       /1         * 24/
  day          "Calendar days"     /1         * 31/
  weekday      "Weekdays"          /1         * 7/
  month        "Calendar months"   /1         * 12/
  quarter      "Calendar quarters" /Q1, Q2, Q3, Q4/
  year         "Calendar year"     /%year_1% * %year_2%/

  q_months(quarter, month)  "Tuple coupling month number and quarter numbers"
  /
  Q1.(1,2,3)
  Q2.(4,5,6)
  Q3.(7,8,9)
  Q4.(10,11,12)
  /
;

alias(y2, year);
alias(month2, month);

Parameter wacc(year);
$load wacc=intressimaar

Parameter days_in_month(month)
/1  31, 2  28, 3  31,  4 30,  5 31,  6 30
 7  31, 8  31, 9  30, 10 31, 11 30, 12 31/
;

********************************************************************************
** This bit takes two $set variables (algus_kp and lopp_kp) presented in       *
** DDMMYY format but not as a string but as a number and by division separates *
** it into days, months and years.                                             *
********************************************************************************
$evalglobal beg_day   trunc(%beg_date% / 1E6)
$evalglobal beg_month trunc((%beg_date% - (%beg_day% * 1E6)) / 1E4)
$evalglobal beg_year  %beg_date% - (%beg_day% * 1E6) - (%beg_month% * 1E4)

$evalglobal end_day   trunc(%end_date% / 1E6)
$evalglobal end_month trunc((%end_date% - (%end_day% * 1E6)) / 1E4)
$evalglobal end_year  %end_date% - (%end_day% * 1E6) - (%end_month% * 1E4)

$drop year_2
$drop days

Set cal_time_sub(cal_time);
cal_time_sub(cal_time)$(jdate(%year_1%, 1, ord(cal_time)) ge jdate(%beg_year%, %beg_month%, %beg_day%)
                    and jdate(%year_1%, 1, ord(cal_time)) le jdate(%end_year%, %end_month%, %end_day%)) = yes;

********************************************************************************
** Now we need to create the main time set for the model - time_t              *
** In case of resolutions less than a day, one unit represents one day         *
** Otherwise one unit represents one month                                     *
**                                                                             *
********************************************************************************
$if "%slot%" == "T"  $libinclude pco_calendar_day
$if "%slot%" == "PK" $libinclude pco_calendar_day
$if "%slot%" == "PV" $libinclude pco_calendar_day
$if "%slot%" == "K"  $libinclude pco_calendar_month

$ifthen.two set max_marg
  $$eval marg_end min(%max_marg%, %last_t%)

Set
  time_t_marg(time_t)   "Subset of time for marginal calc"  /1          * %marg_end%/
;
$endif.two

Sets
  slot                  "Set of time slots"  
  slot_hours(slot, weekday, time_hour) "Tuple coupling time slots and weekday hours"
;

Parameter slot_hour_dist(time_hour, weekday);

* Remondipäevad
alias(time_t, time_t2)

Parameter
  hours_in_year(year)         "Hours in year"
  hours_in_month(year, month) "Hours in month"
;

hours_in_month(year, month) = 24 * (days_in_month(month) + gleap(jdate(first_year + ord(year) - 1, ord(month), 1)));
hours_in_year(year)       = sum(month, hours_in_month(year, month));

