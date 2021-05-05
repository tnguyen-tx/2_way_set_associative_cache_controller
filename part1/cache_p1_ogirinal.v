
`timescale 1ns / 1ns
module Cache (
	input 			 	clk,
	input 			 	reset,
	input [7:0]		 	pr_din,
	output[7:0] 	 	pr_dout,
	input [5:0] 	 	pr_addr,
	input 			 	pr_rd,
	input 			 	pr_wr,
	output              pr_done,
	input [15:0]		bus_din,
	output reg [15:0] 	bus_dout,
	input 	    	 	bus_done,
	output reg 	  	 	bus_rd,
	output reg 	   	 	bus_wr,
	output reg [4:0] 	bus_addr);

	reg [2:0] tag [0:3];
	reg [7:0] data[0:7];
	reg [3:0] valid ;
	reg [3:0] dirty ;
	integer i;
	
	reg [3:0] state;
	wire hit;
	wire [1:0] pr_cblk;
    wire       pr_word;
	wire [2:0] pr_tag;
	wire [4:0] pr_bus_addr;


	// Address breakdown
	assign pr_cblk = pr_addr[2:1];
    assign pr_word = pr_addr[0];
	assign pr_tag = pr_addr[5:3];				
	assign pr_bus_addr = pr_addr[5:1];

	localparam QInitial		= 	4'b0001,
			   QMonitor		=	4'b0010,
			   QWB			=	4'b0100,
			   QFetch		=	4'b1000;

	// Completed...You may change if needed but we recommend keeping this
	assign req = (pr_rd || pr_wr);
	assign pr_done = req & hit;
	       

	// You complete (change the assignments below to the appropriate logic)
	assign hit = 1'bx ;
	assign pr_dout = 8'bxxxxxxxx;
	
	// For each state consider any changes necessary to the registered signals:
	//   state, valid and dirty bits, tags and data
	// You can access a desired element of the tag, valid, or dirty array by  
	//   using array indexes (e.g. tag[pr_cblk]). 
	// Remember you can concatenate signals like:  { data[15:8], pr_data[7:0] } 
	always @(posedge clk)
	begin
	if(reset)
		state<=QInitial;
	else
		case (state)
			QInitial:
			begin
				valid<=4'b0000;
				dirty<=4'b0000;
				for (i=0; i<4; i=i+1)
					tag[i]<=0;

					state <= QMonitor;
			end
			QMonitor:
			begin

			
			
			end
			// Hint: you only need to update signals when the WB is complete 
			QWB:
			begin




			end			
			
			// Hint: you only need to update signals when the fetch is complete 
			QFetch:
			begin



			end
			
		endcase	
	end
	
	// Output Function Logic
	// Produce the bus/memory signals:
	//    bus_rd, bus_wr, bus_dout, and bus_addr
	always @*
	begin
		case (state)
			QInitial:
			begin
				bus_rd<=0;
				bus_wr<=0;
				bus_addr<=5'b0;
				bus_dout <= 16'b0;
			end
			
			QMonitor:
			begin


			end
			
			QWB:
			begin



			end
			QFetch:
			begin



			end
		endcase	
	end
endmodule
