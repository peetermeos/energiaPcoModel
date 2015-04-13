    / prod((opt_paev2, aasta, kuu)$(paev_kalendriks(opt_paev2, aasta, kuu)
                                    and ord(opt_paev2) le ord(opt_paev)),
           (1 + intressimaar(aasta)/365)
          )
