
pco.SolveLink = 3;


Set cpu /cpu1 * cpu%max_cpu%/;
Set scpu(cpu, sim);

Parameter handles(cpu) grid handles;

loop(cpu, scpu(cpu, sim)$(ord(sim) > (ord(cpu) - 1) * floor(card(sim) / card(cpu))
                      and ord(sim) < (ord(cpu)    ) * floor(card(sim) / card(cpu)) + 1
                          ) = yes;
     );

loop(cpu,
   sim_subset(sim) = scpu(cpu, sim);
   Solve pco maximizing total_profit using mip scenario dict;
   handles(cpu) = pco.handle );    // save instance handle

repeat
   loop(cpu$handlecollect(handles(cpu)),
      display$handledelete(handles(cpu)) 'trouble deleting handles' ;
      handles(cpu) = 0 ) ;    // indicate that we have loaded the solution
   display$sleep(card(handles) * 5) 'was sleeping for some time';
until card(handles) = 0;
