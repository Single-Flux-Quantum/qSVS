///////////////////////////////////////////
//////// Ramy Tadros 01/23/2019 ////////////
/////// AQFP/SFQ interfaces - Version-1
//////////////////////////////////////////

`include "./SFQ_library.sv"
`include "./AQFP_library.sv"

///////////////////////////////////////////////////
module SFQ_AQFP (interface SFQclkin, SFQin, AQFPclkin, AQFPclkout, AQFPout);
	//SFQclkin, SFQin: SFQ
	//AQFPout: ioAQFP
	//AQFPclkin, AQFPclkout: clkAQFP
	
	SFQ dumpOut ();
	SFQbuf1 DFF0 (SFQclkin, SFQin, dumpOut);
	
	logicAFQP val;
	AQFPclockPhase clk (AQFPclkin, AQFPclkout);
	AQFPsendModule snd (AQFPout);
	
	always begin
		clk.waitForSamplingPt();
		val = SFQin.isStored(1'b1) ? q1 : q0;
		snd.send(val);
	end

	SFQtimingcheck1 TC0 (clk.localClk, SFQin.data);	
	
endmodule //SFQ_AQFP
///////////////////////////////////////////////////

///////////////////////////////////////////////////
module AQFP_SFQ (interface AQFPin, AQFPclkin, SFQout);
	//AQFPin: ioAQFP
	//AQFPclkin: clkAQFP
	//SFQout: SFQ

	clkAQFP dumpClkOut ();
	AQFPclockPhase clk (AQFPclkin, dumpClkOut);
	
	SFQpropagationDelay gPD ();
	
	always begin
		clk.waitforSamplingPt();
		AQFPin.sample(val);
		if (val==q1) begin
			gPD.tPD();
			SFQout.send();
		end
	end
	
	AQFPtimingcheck TC0 (clk.localClk, AQFPin.data[0]);
	AQFPtimingcheck TC1 (clk.localClk, AQFPin.data[1]);

endmodule //AQFP_SFQ
///////////////////////////////////////////////////


