///////////////////////////////////////////
// Ramy Tadros & Arash Fayyazi 8/15/2018 //
/////// SFQ Interface - Version-5
//////////////////////////////////////////
//`timescale 1ps/1fs

///////////////////////////////////////////////////
interface SFQ;
	parameter real pw=`pw;  //sfq pulse width

	logic data=0;
	logic sent=0;
	
	modport tx (output sent, data, import send);
	modport rx (input data, output sent, import receive, isReceived);
	
	task send ();
		begin
			data <= 1'b1;
			sent <= 1'b1;
			data <= #pw 1'b0;
		end
	endtask

	task receive ();
			@(posedge data);
	endtask
	
	function isReceived;
		input dump;
		isReceived = sent;
		sent <= 1'b0;
	endfunction
	
	function isStored;
		input dump;
		isStored = sent;
	endfunction

endinterface : SFQ
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module SFQtimingcheck1 (clk,data);	
	input clk, data;
	specify
		specparam hold = `thold, setup = `tsetup;
		$setuphold(posedge clk, posedge data, setup, hold);
	endspecify
endmodule
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module SFQtimingcheck2 (clk,data1, data2);	
	input clk, data1, data2;
	specify
		specparam hold = `thold, setup = `tsetup;
		$setuphold(posedge clk, posedge data1, setup, hold);
		$setuphold(posedge clk, posedge data2, setup, hold);
	endspecify
endmodule
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module SFQgateDelay (out,in);
	input in;
	output out;
	
	buf g0 (out, in);
	
	specify
		specparam delay = `tgate;
		(in => out) = delay;
	endspecify
endmodule
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module SFQpropagationDelay;
	logic in, out, state;
	
	SFQgateDelay g0 (out,in);
	
	initial begin
		state = 1'b0;
		in = 1'b0;
	end
	
	task tPD ();
		in = !state;
		wait (out==in);
	endtask
endmodule
///////////////////////////////////////////////////
