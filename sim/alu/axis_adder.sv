`timescale 1 ns / 1 ns

module axis_adder(
	input aclk,
	input aresetn,
	
	IAxiStream.Slave a,
	IAxiStream.Slave b,
	IAxiStream.Master  result
);	
		
	logic ex;
	
	assign a.tready = 1;
	assign b.tready = 1;
	
	assign result.tlast = result.tvalid;
	assign result.tid = 0;
	
	Addition_Subtraction adder(
		a.tdata,
		b.tdata,
		0,
		ex,
		result.tdata 
	);
		
	always_ff@(posedge aclk)
		if (!aresetn)
			result.tvalid <= 0;
		else
			result.tvalid <= a.tvalid & b.tvalid;
endmodule