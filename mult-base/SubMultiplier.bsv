   package SubMultiplier;
     
         interface Multiplier_ifc;
              method Action start(Bit#(8) x, Bit#(8) y);
	      method Bit#(8) result(); 
         endinterface
	
	 module mkMultiplier(Multiplier_ifc);  
            Reg#(Bit#(8)) product <- mkReg(0);
            Reg#(Bit#(8)) d       <- mkReg(0);
            Reg#(Bit#(8)) r       <- mkReg(0);	   
            
	   rule multiply (r!= 0);
              if (r[0] == 1) product <= product + d;
	       d<= d <<1;
	       r<= r >>1 ;   
           endrule

           method Action start(Bit#(8) x,Bit#(8) y) if (r == 0);
	       d<=x;  r<=y;
           endmethod 

           
	    method Bit#(8) result() if (r == 0); 
              return product;
           endmethod

	endmodule 


	module tbmkMultiplier();
          
              Reg#(int) state <-mkReg(0);
              Multiplier_ifc m <- mkMultiplier	();

               rule step1;
	            m.start(9,5);
                    state <= 1 ;
               endrule 
 
               rule finish (state == 1);
	               $display("product = %d", m.result());
		       $finish();
	       endrule 
       endmodule 

endpackage       
