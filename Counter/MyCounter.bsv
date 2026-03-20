	interface Counter;
		method Bit#(8) read();
		method Action load(Bit#(8) newval);
		method Action increment();
	endinterface

       module mkCounter(Counter);
       
               Reg#(Bit#(8)) count_reg <- mkReg(0);
               
             method Bit#(8) read();
                return count_reg;
             endmethod
       
             method Action load(Bit#(8) newval);
                 count_reg <= newval ;
             endmethod

             method Action increment();
               count_reg <= count_reg + 1 ;
             endmethod 

        endmodule               

 
   module mktbCounter();
       Counter counter <- mkCounter();
       Reg#(Bit#(16)) state <-mkReg(0);

         rule step0(state == 0);
                 counter.load(42);
                  state <= 1;
           endrule
           
          rule step1(state == 1);
           if (counter.read() != 42) $display("FAIL : counter.load(42)");
              state <= 2;
            endrule
            
            rule step2(state <=10 );
            	counter.increment();
            	$display("Counter value : %d",counter.read());
            	state <= state + 1;
            endrule

            rule step3 (state == 11);
             $display("TEST FINISHED");
            $finish(0);
           endrule
   endmodule     
   


  
