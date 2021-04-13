`timescale 1ns / 100ps

module CacheMSI (
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
	input 	    	 	bus_done_in,
	output reg  	 	bus_done_out,
	input				bus_grant,
	output reg			bus_request,
	input [4:0] 		bus_addr_in,
	output reg [4:0]	bus_addr_out,
	input [2:0]			bus_op_in,
	output reg [2:0]	bus_op_out);

	localparam 	QInitial	= 		7'b0000001,
			   	QMonitor	=		7'b0000010,
				QFlush =   			7'b0000100,  
				QWB = 				7'b0001000,
			   	QBusRd	=			7'b0010000,
			   	QBusRdX	=			7'b0100000,
			   	QBusUpgr	=		7'b1000000;

	localparam 	BusNone		=	3'b000,
				BusRd		=	3'b001,
				BusUpgr		=	3'b010,
				BusFlush	=	3'b011,
				BusRdX		=	3'b100;

	localparam 	I		= 	2'b00,
				S		=	2'b01,
				M		=	2'b11;
				

	reg [2:0] tag [0:3];
	reg [7:0] data[0:7];
	reg [1:0] msi_state [0:3] ;
	integer i;

	reg [1:0] curr_msi_state;  // Dirty, Valid output of selected cache block
	
	reg [8:0] state;
	wire pr_hit;
	wire pr_req;
	wire bus_req;
	wire bus_hit;
	
	wire [1:0] pr_cblk;
	wire [1:0] bus_cblk;
    wire       pr_word;
	wire [2:0] pr_tag;
	wire [2:0] bus_tag;
	wire [4:0] pr_bus_addr;
	
	// Address breakdown
	assign pr_cblk = pr_addr[2:1];
    assign pr_word = pr_addr[0];
	assign pr_tag = pr_addr[5:3];
	assign pr_bus_addr = pr_addr[5:1];

	assign bus_cblk = bus_addr_in[1:0];
	assign bus_tag  = bus_addr_in[4:2];

	assign pr_dout = data [ {pr_cblk, pr_word} ];
	
	assign pr_req = (pr_rd || pr_wr);
	assign pr_hit = ( tag[ pr_cblk ] == pr_tag ) & msi_state[ pr_cblk ] != I ;
	assign bus_req = bus_op_in != BusNone;
	assign bus_hit =  (bus_req) && 
					  (msi_state[bus_cblk] != I) &&
				  	  (tag[bus_cblk] == bus_tag );
					  
	// pick MSI state (dirty and valid bit) from currently selected block 
	always @*
	begin
		if(bus_hit && bus_op_in != BusNone)
			curr_msi_state = {msi_state[bus_cblk]};
		else
			curr_msi_state = {msi_state[pr_cblk]};
	end	
	
	// You complete or add more signals
	assign pr_done = 0; // Change this


	
 
	// For each state consider any changes necessary to the internal and 
	// output signals:
	//   state, msi_state, tags and data
	// You can access a desired element of the tag, valid, or dirty array 
	//   by using array indexes (e.g. tag[pr_cblk]). 
	// Remember you can concatenate signals like: { data[15:8], pr_data[7:0] }
	always @(posedge clk)
	begin
	if(reset)
	begin
		state <= QInitial;
		reqFlag <= 0;
	end
	else
		case (state)
			QInitial:
			begin
				for (i=0; i<4; i=i+1)
				begin
					tag[i]<=0;
					msi_state[i] <= I;
				end
				state <= QMonitor;
			end
			
			QMonitor:
			begin
			
			end
			QFlush:
			begin
			
			end
			QWB:
			begin

			end
			QBusRd:
			begin

			end
			QBusRdX:
			begin

			end
			QBusUpgr:
			begin

			end
		endcase
	end
	
	
	// Output function logic
	//   Produce bus outputs:
	//     bus_request, bus_op_out, bus_dout, bus_done_out, and bus_addr_out
	always @*
	begin
		// Default values
		bus_op_out <= BusNone;
		bus_addr_out <= 5'b00000;
		bus_dout <= 16'h0000;
		bus_request <= 0;
		bus_done_out <= 0;
		if(state == QMonitor)
			begin

			end
		else if(state == QFlush)
			begin

			end
		else if(state == QWB) 
			begin

			end
		else if(state == QBusRd) 
			begin

			end
		else if(state == QBusRdX) 
			begin

			end
		else if(state == QBusUpgr) 
			begin

			end
	end
endmodule
