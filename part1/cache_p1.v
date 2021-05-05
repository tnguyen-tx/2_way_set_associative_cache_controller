
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

	assign req = (pr_rd || pr_wr);
	assign pr_done = req & hit;
	       

	assign hit = ({1'b1,pr_tag}=={valid[pr_cblk],tag[pr_cblk]})? 1'b1:1'b0;
	assign pr_dout = pr_word ? data[pr_cblk*2+1] : data[pr_cblk*2];
	
	//   state, valid and dirty bits, tags and data
	always @(posedge clk or posedge reset)
	begin
		if(reset) begin
		state<=QInitial;
				valid <= 4'b0000;
				dirty <= 4'b0000;
				bus_rd <= 0;
				bus_wr <= 0;
				for (i=0; i<4; i=i+1)
					tag[i] <= 0;
		end
	else
		case (state)
			QInitial:
			begin
				if (req)state <= QMonitor;
				else state <= QInitial;
			end
			QMonitor:
			begin
				if (hit) begin
					if (pr_rd) begin
					end
					else if (pr_wr) begin
						if (pr_word==0) data[pr_cblk*2] <= pr_din[7:0];
						else data[pr_cblk*2+1] <= pr_din[7:0];
						valid[pr_cblk] <= 1;
						dirty[pr_cblk] <= 1;
					end
					else begin end
						state <= QMonitor;
				end
				else begin
					if (dirty[pr_cblk]==1) begin
						state <= QWB;
					end
					else state <= QFetch;
				end
			end
			QWB:
			begin
				if (bus_done) begin 
					state <= QFetch;
					data[pr_cblk*2] <= 0;
					data[pr_cblk*2+1] <= 0;
					tag[pr_cblk] <= 0;
					valid[pr_cblk] <= 0;
					dirty[pr_cblk] <= 0;
				end
				else state <= QWB;
			end			
			
			QFetch:
			begin
				if (bus_done == 1'b1) begin
					data[pr_cblk*2] <= bus_din[7:0];
					data[pr_cblk*2+1] <= bus_din[15:8];
					tag[pr_cblk] <= bus_addr[4:2];
					valid[pr_cblk] <= 1;
					dirty[pr_cblk] <= 0;
					state <= QMonitor;
				end
				else begin
					state <= QFetch;
				end
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
				bus_rd = 0;
				bus_wr = 0;
				bus_addr = 5'b0;
				bus_dout = 16'b0;
			end
			
			QMonitor:
			begin
				bus_rd = 'bz;
				bus_wr = 'bz;
				bus_addr = 5'bz;
				bus_dout = 16'bz;
			end
			
			QWB:
			begin
				bus_rd = 'b0;
				bus_wr = 'b1;
				bus_addr = {tag[pr_cblk],pr_cblk};
				bus_dout = {data[pr_cblk*2+1],data[pr_cblk*2]};
			end
			QFetch:
			begin
				bus_rd = 'b1;
				bus_wr = 'b0;
				bus_addr = pr_addr[5:1];
				bus_dout = 16'bz;
			end
		endcase	
	end
endmodule
