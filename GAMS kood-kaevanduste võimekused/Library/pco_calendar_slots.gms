********************************************************************************
**                                                                             *
** Definitions of time slots depending of the resolution of the model          *
**                                                                             *
**  27. Oct 2014                                                               *
**  Peeter Meos                                                                *
********************************************************************************

Parameter
  slot_length_orig(time_t, slot, t)   "Hours available in a given slot for a given production unit (h)"

  slot_length_s(sim, time_t, slot, t)  "Hours available in a given slot for a given production unit (h)"
  slot_length(time_t, slot, t)  "Hours available in a given slot for a given production unit (h)"
;

* Operational planning can be only hourly
$if "%MT%" == "OP" $set slot T

$ifthen.slott "%slot%" == "K"
$loaddc slot=slott_kuu slot_hour_dist=sloti_tunnid_kuu
$endif.slott

$ifthen.slott "%slot%" == "PV"
$loaddc slot=slott_paev slot_hour_dist=sloti_tunnid_paev
$endif.slott

$ifthen.slott "%slot%" == "PK"
$loaddc slot=slott_peak slot_hour_dist=sloti_tunnid_peak
$endif.slott

$ifthen.slott "%slot%" == "T"
$loaddc slot=slott_tund slot_hour_dist=sloti_tunnid_tund
$endif.slott

slot_length_orig(time_t, slot, t) = sum((cal_time_sub, weekday, time_hour)
                                                            $(cal_t(time_t, cal_time_sub)
                                                          and wkday_number_cal_sub(cal_time_sub) = ord(weekday)
                                                          and ord(slot) = slot_hour_dist(time_hour, weekday)
                                                              )
                                                            , 1);
slot_hours(slot, weekday, time_hour)$(ord(slot) = slot_hour_dist(time_hour, weekday)) = yes;

slot_length(time_t, slot, t) = slot_length_orig(time_t, slot, t);



