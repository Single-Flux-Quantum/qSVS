///////////////////////////////////////////
//////// Ramy Tadros & Arash Fayyazi 11/29/2018 ////////////
/////// AQFP Auxiliary types/interfaces/modules - Version-4
//////////////////////////////////////////

//-----------------------------------------------------------------------------------------------------
// -------------------------- MAIN LIBRARY AUXILIARY MODULES ------------------------------------------
//-----------------------------------------------------------------------------------------------------

typedef enum logic[1:0] {q0 = 2'b11, qZ =2'b00, qX=2'b10, q1=2'b01} logicAQFP;
typedef enum {noDir, inToOut, outToIn} dirAQFP;
typedef enum {noPhase, phase1, phase2, phase3, phase4} phaseAQFP;


interface ioAQFP;
	
	logicAQFP data = qZ;
	
	modport tx (output data, import send);
	modport rx (input data, import sample);

	task send;
		input logicAQFP val;
		if ( (val == q0) || (val == q1) ) 
			data <= val;
		else
			data <= qX;	
	endtask
	
	task resetSend;
		data <= qZ;
	endtask
	
	task sample;
		output logicAQFP val;
		begin
			val = data;
		end
	endtask

endinterface : ioAQFP

interface clkAQFP;
	logic xio = 1'b0;
	logic dcio = 1'b0;
endinterface : clkAQFP

//-----------------------------------------------------------------------------------------------------
// -------------------------- MAIN LIBRARY AUXILIARY MODULES ------------------------------------------
//-----------------------------------------------------------------------------------------------------

///////////////////////////////////////////////////
module AQFPtimingcheck1 (clk,data);
	input clk, data;
	specify
		specparam hold = `thold, setup = `tsetup;
		$setuphold(posedge clk , posedge data[0], setup, hold);
		$setuphold(posedge clk , posedge data[1], setup, hold);
	endspecify
endmodule //timincheck
///////////////////////////////////////////////////

///////////////////////////////////////////////////
// The following 3 modules should be one only in case of SDF back annotation
module AQFPmoduleDelay_CK (out,in);
	input in;
	output out;
	
	buf g0 (out, in);
	
	specify
		specparam delay = `clkDelay;
		(in => out) = delay;
	endspecify
endmodule //ModuleDelay_CK

module AQFPmoduleDelay_DATA (out,in);
	input in;
	output out;
	
	buf g0 (out, in);
	
	specify
		specparam delay = `gateDelay;
		(in => out) = delay;
	endspecify
endmodule //ModuleDelay_DATA

module AQFPmoduleDelay_PW (out,in);
	input in;
	output out;
	
	buf g0 (out, in);
	
	specify
		specparam delay = `dataPW;
		(in => out) = delay;
	endspecify
endmodule //ModuleDelay_PW
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module AQFPclockDelay;
	logic in, out;
	
	AQFPmoduleDelay_CK g0 (out,in);
	
	initial begin
		in = 1'b0;
	end
	
	task tPD;
		in = !in;
		wait (out==in);
	endtask
endmodule
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module AQFPsendModule (interface out);
	logic inDATA, outDATA, inPW, outPW;
	
	AQFPmoduleDelay_DATA gDATA (outDATA,inDATA);
	AQFPmoduleDelay_PW gPW (outPW, inPW);
	
	initial begin
		inDATA = 1'b0;
		inPW = 1'b0;
	end
	
	task send;
		input logicAQFP val;
		inDATA = !inDATA;
		wait (outDATA==inDATA);
		out.send(val);
		inPW = !inPW;
		wait (outPW==inPW);
		out.resetSend();
	endtask
endmodule
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module AQFPclockPhase (interface clkin, clkout);
	AQFPclockDelay gPD ();
	
	dirAQFP xDir = noDir;
	dirAQFP dcDir = noDir;
	phaseAQFP phase = noPhase;
	
	logic localClk = 1'b0;
	logic error = 1'b0;
	
	always @(clkin.dcio, clkout.dcio)
		if ( (clkin.dcio == 1'b1) && (clkout.dcio == 1'b0) ) begin 
			//posedge dcin
			dcDir = inToOut;
			clkout.dcio = 1'b1;
		end
		else if ( (clkin.dcio == 1'b0) && (clkout.dcio == 1'b1) ) begin 
			//posedge dcout
			dcDir = outToIn;
			clkin.dcio = 1'b1;
		end
		else //negedge dcin or negedge dcout
			error = 1'b1;
	
	always @(clkin.xio)
		if (xDir==noDir) begin
			xDir = inToOut;
			gPD.tPD();
			clkout.xio <= clkin.xio;
		end
		else if ( (xDir==inToOut)	&& (clkout.xio	!= clkin.xio) ) begin
			gPD.tPD();
			clkout.xio <= clkin.xio;
		end
		else if ( (xDir==outToIn) && (clkin.xio == clkout.xio) )
			;
		else
			error = 1'b1;
			
	always @(clkout.xio)
		if (xDir==noDir) begin
			xDir = outToIn;
			gPD.tPD();
			clkin.xio <= clkout.xio;
		end
		else if ( (xDir==outToIn)	&& (clkin.xio	!= clkout.xio) ) begin
			gPD.tPD();
			clkin.xio <= clkout.xio;
		end
		else if ( (xDir==inToOut) && (clkin.xio == clkout.xio) )
			;
		else
			error = 1'b1;
			
	always @(dcDir, xDir)
		if ( (dcDir!=noDir) && (xDir!=noDir) )
			if ( (xDir==inToOut) && (dcDir==inToOut) )
				phase = phase1;
			else if ( (xDir==outToIn) && (dcDir==inToOut) ) 
				phase = phase3;
			else if ( (xDir==inToOut) && (dcDir==outToIn) )
				phase = phase2;
			else if ( (xDir==outToIn) && (dcDir==outToIn) )
				phase = phase4;		
	
	task waitForSamplingPt;
		begin
			wait(phase!=noPhase);
			case (phase)
				phase1: @(posedge clkin.xio);
				phase2: @(negedge clkin.xio);
				phase3: @(negedge clkout.xio);
				phase4: @(posedge clkout.xio);
			endcase
			localClk <= 1'b1;
			localClk <= #`localClkPW 1'b0;
		end
	endtask		
	
/* 	always @(posedge error) begin
		$display ("\n(Error)~ illegal transition in module %m at time=%g",$realtime);
		$finish;
	end */
	
endmodule //clockPhase
/////////////////////////////////////////////////

//-----------------------------------------------------------------------------------------------------
// -------------------------- TESTBENCH AUXILIARY MODULES ------------------------------------------
//-----------------------------------------------------------------------------------------------------

///////////////////////////////////////////////////
module input_generator_clocked (interface sig,clkin,clkout);

	parameter integer timesq0 [] = '{0};
	parameter integer timesq1 [] = '{0};
	parameter real delay = 0;
	parameter real pw = 100;
	parameter real idelay = 0;
	parameter real clkdelay = 0;
	integer times0 [] = {0, timesq0, 0};
	integer times1 [] = {0, timesq1, 0};
	integer index0,index1;

	AQFPclockPhase clk (clkin, clkout);
	AQFPsendModule snd (sig);
	initial begin
		index0 = 1;
		index1 = 1;
		while ((times0[index0-1]<=times0[index0]) || (times1[index1-1]<=times1[index1])) begin
			//$display("Time: %g - %m receive a pulse",$time);
			if (((times0[index0] < times1[index1]) || (times1[index1] == 0)) && ~(times0[index0] == 0) ) begin
				repeat (times0[index0]-((times0[index0-1] > times1[index1-1])? times0[index0-1] : times1[index1-1]) ) begin
					clk.waitForSamplingPt();
					$display("Time0: %g - %m receive a 0 pulse",$time);
				end
				#delay; 
				snd.send(q0);
				index0 = index0 + 1;
			end
			else begin
				repeat (times1[index1]-((times0[index0-1] > times1[index1-1])? times0[index0-1] : times1[index1-1]) ) begin
					clk.waitForSamplingPt();
					$display("Time1: %g - %m receive a 1 pulse",$time);
				end
				#delay; 
				snd.send(q1);
				index1 = index1 + 1;
			end
		end
	end
	
endmodule //input_generator_clocked
///////////////////////////////////////////////////

///////////////////////////////////////////////////
`timescale 1ps/100fs
module clock_generatorP1 (interface clk);
	parameter period=100;
	parameter pw=`localClkPW;
	
	logic state=1;
	initial begin
		clk.dcio <= 1'b1;
	end
	always begin
		#(period/2) state = ~state;
		if (state) begin
			//$display("Time: %g - %m sent a pulse",$time);
			clk.xio = 1'b1;
			clk.xio <= #pw 1'b0;
		end
		
	end
	
endmodule //clock generator
///////////////////////////////////////////////////

///////////////////////////////////////////////////
`timescale 1ps/100fs
module clock_generatorP2 (interface clk);
	parameter period=100;
	parameter pw=`localClkPW;
	
	logic state=1;
	logic shift = 1;
	initial begin
		clk.dcio <= 1'b0;
		//#(3*period/4) state <= ~state;
/* 		#(period/4) state <= ~state;
		if (state) begin
			//$display("Time: %g - %m sent a pulse",$time);
			clk.xio = 1'b1;
			clk.xio <= #pw 1'b0;
		end */
	end
	always begin
		if (shift)
			#(3*period/4) shift = 1'b0;
		else begin
			#(period/2) state = ~state;
			if (state) begin
				//$display("Time: %g - %m sent a pulse",$time);
				clk.xio = 1'b1;
				clk.xio <= #pw 1'b0;
			end
		end
		
	end
	
endmodule //clock generator
///////////////////////////////////////////////////

///////////////////////////////////////////////////
`timescale 1ps/100fs
module clock_sink (clkAQFP clk);
	
endmodule //clock sink
///////////////////////////////////////////////////







