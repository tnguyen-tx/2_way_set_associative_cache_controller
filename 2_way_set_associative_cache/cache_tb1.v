`timescale 1ns / 1ns
`include "cache_p1.v"
`include "memory.v"
//`include "datamem.txt"

module cache_tb;

	// Cache Inputs
	reg [7:0] pr_din;
	reg [5:0] pr_addr;
	reg       pr_rd;
	reg       pr_wr;
  
	
	reg clk;
	reg rst;

	// Cache Outputs and memory inputs
	
	wire        pr_done;
	wire [7:0] 	pr_dout;
	wire [15:0] bus_dout;
	wire 	   	bus_rd;
	wire 	   	bus_wr;
	wire [4:0] 	bus_addr;
	
	reg[16*8:0] op;	
	// bus output
	wire [15:0] bus_din;
	wire 	   	bus_done;
	
	localparam	QInitial	= 	4'b0001,
				QMonitor	=	4'b0010,
				QWB			=	4'b0100,
				QFetch		=	4'b1000;
	localparam CYCLETIME = 2;
	reg [16*8:0] state_string;
	
	// Instantiate the Unit Under Test (UUT)
	Cache cache (
		.clk(clk), 
		.reset(rst),
		.pr_dout(pr_dout), 
		.pr_din(pr_din), 
		.pr_addr(pr_addr), 
		.pr_rd(pr_rd), 
		.pr_wr(pr_wr), 
		.pr_done(pr_done),
		.bus_dout(bus_dout), 
		.bus_din(bus_din), 
		.bus_done(bus_done), 
		.bus_rd(bus_rd), 
		.bus_wr(bus_wr),
		.bus_addr(bus_addr)
	);
	
	Memory #(.INIT_FILE("datamem.txt")) dmem (	
		.addr(bus_addr), 
		.memread(bus_rd), 
		.memwrite(bus_wr), 
		.wdata(bus_dout),
		.clk(clk),
		.rst(rst),
		.rdata(bus_din),
		.mem_done(bus_done)
	);

	always @ (cache.state) // report the state in text format in the waveform
	begin : report_state	
		case (cache.state)
		QInitial: 			state_string  =   "  QInitial     ";
		QMonitor: 			state_string  =   "  QMonitor     ";
		QWB: 				state_string  =   "  QWB          ";
		QFetch: 			state_string  =   "  QFetch       ";
		default: 			state_string  =   "  Unknown	  ";
		
		endcase
	end
	
  always #1 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		pr_rd=0;
		pr_wr=0;
		#CYCLETIME;
		rst = 0;
		#CYCLETIME;
		
		// LW @1; 1
		op = "0:Load @1";
		pr_din = 8'bzzzzzzzz;
		pr_addr=1; 
		pr_rd=1;
		//CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(pr_dout == 8'h01);
		wait(cache.data[0] == 8'h00);
		wait(cache.data[1] == 8'h01);
		// SW 12@9;  
		op = "1:Store 12@9";
		pr_addr=9;
		pr_rd=0;
		pr_wr=1;
		pr_din=12;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[0] == 8'h08);
		wait(cache.data[1] == 8'h0c);
		
		// SW 13@9;
		op = "2:Store 13@9";
		pr_addr=9;
		pr_rd=0;
		pr_wr=1;
		pr_din=13;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[0] == 8'h08);
		wait(cache.data[1] == 8'h0d);
		
		// SW 14@1; WB 13-> mem[9], 4-> cache
		op = "3:Store 14@1";
		pr_addr=1;
		pr_rd=0;
		pr_wr=1;
		pr_din=14;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[0] == 8'h00);
		wait(cache.data[1] == 8'h0e);
		
		// LW @9; WB 14-> mem[1], mem[9]=13 -> Cache  
		op = "4:Load @9";
		pr_din = 8'bzzzzzzzz;
		pr_addr=9;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[0] == 8'h08);
		wait(cache.data[1] == 8'h0d);
		wait(pr_dout == 8'h0d);
		
		// LW @8; Hit!
		op = "5:Load @8";
		pr_din = 8'bzzzzzzzz;
		pr_addr=8;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(pr_dout == 8'h08);
		
		// SW 17@4 ; Miss
		op = "6:Store 17@4";
		pr_addr=4;
		pr_rd=0;
		pr_wr=1;
		pr_din=17;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[4] == 8'h11);
		wait(cache.data[5] == 8'h05);
		
		// LW @9 ; Hit
		op = "7:Load @9";
		pr_din = 8'bzzzzzzzz;
		pr_addr=9;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(pr_dout == 8'h0d);
		
		// LW @13 ; WB 17->mem[4], mem[13] -> Cache
		op = "8:Load @13";
		pr_din = 8'bzzzzzzzz;
		pr_addr=13;
		pr_rd=1;
		pr_wr=0;
		//#CYCLETIME;
		
		wait(pr_done && !clk);
		wait(pr_done && clk);
		wait(cache.data[4] == 8'h0c);
		wait(cache.data[5] == 8'h0d);
		wait(pr_dout == 8'h0d);
		
		op = "9:End";
		pr_din = 8'bzzzzzzzz;
		pr_rd=0;
		pr_wr=0;

		
		#10;
		$finish;
	end
	integer i;     
	initial begin
	//	$recordfile("waveform_direct_cache.trn");
	//	$recordvars();
	end
endmodule



