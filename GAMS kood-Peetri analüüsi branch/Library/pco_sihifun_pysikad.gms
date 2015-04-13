********************************************************************************
* Plokkide ja kaevanduste püsikulud                                            *
* Taaniel Uleksin                                                              *
********************************************************************************

*Tootmisüksused
*Jaama tööjõukulud
-sum((aasta, kuu, jaam), (sum(t_el$(t_jaam(jaam, t_el)), p_work(aasta, kuu, t_el)) - yt_brigaadid(aasta, kuu, jaam))*b_toojoukulu(aasta, kuu, jaam))
*Ületunni brigaadid
-sum((aasta, kuu, jaam), yt_brigaadid(aasta, kuu, jaam)*b_toojoukulu(aasta, kuu, jaam)*yletunni_tootasu_koefitsient(aasta, kuu))
*Sundpuhkus
-sum((aasta, kuu, jaam),
(pl_toos(aasta, jaam) - yt_brigaadid(aasta, kuu, jaam) - sum(t_el$t_jaam(jaam, t_el), p_work(aasta, kuu, t_el)))*sundpuhkuse_koefitsient(aasta)*b_toojoukulu(aasta, kuu, jaam)
)

*Ploki hoolduskulud
-sum((aasta, kuu, t_el), h_kulu(aasta, kuu, t_el)*hoolduskulu(aasta, t_el)*0.25)
-sum((aasta, kuu, t_el), p_work(aasta, kuu, t_el)*hoolduskulu(aasta, t_el))
*Käivitamine pärast seisakut
-sum((aasta, kuu, t_el), k_kulu(aasta, kuu, t_el)*seisaku_lisahooldus_koefitsient(aasta)*hoolduskulu(aasta, t_el))

*- sum((t, aasta), ty_aktiivne(t, aasta) * pysikulud_ty(t, aasta))

*Kaevandused
-sum((k, aasta), k_aktiivne(k, aasta) * pysikulud_k(k, aasta))

*Logistika
-sum(aasta, pysikulud_l(aasta))
