`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Program Name: printer
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: testbench
//////////////////////////////////////////////////////////////////////////////////

program printer#(
	parameter DATA_SIZE = 32,
	parameter PATH = "./sample_decoder/output_samples.txt"
)(
	input aclk,
	input aresetn,
	IAxiStream.Slave  in_data,
	input testend
);
	bit[DATA_SIZE - 1 : 0] tmp;
	int fd;
	
	initial
		begin
		#1;
		in_data.tready = 0;
		
		tmp = 0;
		
		fd = $fopen(PATH, "w");
		$fdisplay(fd, "-------New Signal--------");
		//$display("File for loader %s was opened successfully : %0d", PATH, fd);

		
		while(!testend)
			begin
			@(posedge aclk);
			if (in_data.tvalid)
				begin
				//wait(in_data.tvalid);
				#1 in_data.tready = 1;
				tmp = in_data.tdata;
				
				@(posedge aclk);
				#1 in_data.tready = 0;

				$fdisplay(fd, "%0d", tmp);
				$display("Print data %0d", tmp);
				end
			end
		$fclose(fd);
		
		$display("End print");
		
		#1000;	
		$finish;
		end
	
endprogram