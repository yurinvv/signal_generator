`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yurin VV
// Create Date: 07.2022
// Program Name: loader
// Project Name: Some DAC
// Tool Versions: Vivado 2018.2
// Description: Reading test parameters from a file
//////////////////////////////////////////////////////////////////////////////////
program loader#(
	parameter DATA_SIZE = 32,
	parameter POINTS = 9,
	parameter PATH = "./params.txt"
)(
	IParams.out params,
	output bit update
);
	int i;
	int fd;
	string line;
	string paramSelect;
		
	initial
		begin		
		#1;
		
		// params aren't ready
		update = 0;
		i = 0;
		
		// params initialization
		for (int i = 0; i < POINTS; i++) begin
			params.linea[i] = 0;
			params.linet[i] = 0;
			end
			
		params.linenmb = 0;
		params.repeatcycle = 0;
		//
				
		// open file for reading
		fd = $fopen(PATH, "r");
		
		if(fd) 
			begin
			$display("File %s was opened successfully : %0d", PATH, fd);
					// $feof returns true when end of the file has reached
			while (!$feof(fd))
				begin
				//read line from the file
				$fgets(line, fd);
				
				//get rid of the '\n' character
				line = line.substr(0, line.len - 2);
				
				//fill params
				if (line == "LINEA" ||
					line == "LINET INT" ||
					line == "LINET FLOAT" ||
					line == "LINENMB" ||
					line == "REPEATCYCLE")
					begin
					paramSelect = line;
					i = 0;
					end
				else
					case(paramSelect)
					"LINEA":
						begin
						params.linea[i] = line.atoi();
						i++;
						end
					"LINET INT":
						begin
						params.linet_int[i] = line.atoi();
						i++;
						end
					"LINET FLOAT":
						begin
						params.linet[i] = line.atoi();
						i++;
						end
					"LINENMB": 
						params.linenmb = line.atoi();
					"REPEATCYCLE":
						begin
						params.repeatcycle = line.atoi();
						break;
						end
					endcase
					
				end
		
			end
		else
			$display("File %s was NOT opened successfully : %0d", PATH, fd);
					
		$fclose(fd);
		
		// params ready
		repeat(1)
			begin
			#5000 update = 1;
			#5000 update = 0;
			end
	end
endprogram

/*
$display(" %d ",A.len() );
$display(" %s ",A.getc(5) );
$display(" %s ",A.tolower);
$display(" %s ",B.toupper);
$display(" %d ",B.compare(A) );
$display(" %d ",A.compare("test") );
$display(" %s ",A.substr(2,3) ); A = "111";
$display(" %d ",A.atoi() );
*/

