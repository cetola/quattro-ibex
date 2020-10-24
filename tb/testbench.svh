/*
The main testbench class.

This class instantiates the tester, coverage, and scoreboard classes as
well as passing the needed signals (BFM) to each class.
*/

class testbench;

    tester    tester_h;
    coverage  coverage_h;
    scoreboard scoreboard_h;

    virtual vip_bfm bfm;

    function new (virtual vip_bfm b);
        bfm = b;
    endfunction : new

    task execute();
        tester_h    = new(bfm);
        coverage_h   = new(bfm);
        scoreboard_h = new(bfm);

        fork
            tester_h.execute();
            coverage_h.execute();
            scoreboard_h.execute();
        join_none
    endtask : execute
endclass : testbench
