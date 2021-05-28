
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

	reg [3:0] tag [0:3];
	reg [7:0] data[0:7];
	reg [3:0] valid ;
	reg [3:0] dirty ;
	reg [1:0] lru ;
	integer i;
	
	reg [3:0] state;
	reg hit;
	reg [1:0] pointer;
//	wire [1:0] pointer;
    wire       pr_word;
	//tag and set changed
	//thuy
	wire [3:0] pr_tag;
	wire 		pr_set;
	wire [4:0] pr_bus_addr;


	// Address breakdown
//	assign pointer = pr_addr[2:1];
    assign pr_word = pr_addr[0];
	//tag and set distribution, thuy
	assign pr_tag = pr_addr[5:2];				
	assign pr_set = pr_addr[1];
	assign pr_bus_addr = pr_addr[5:1];

	localparam QInitial		= 	4'b0001,
			   QMonitor		=	4'b0010,
			   QWB			=	4'b0100,
			   QFetch		=	4'b1000;

	assign req = (pr_rd || pr_wr);
	assign pr_done = req & hit;
	       

//	assign hit = ({1'b1,pr_tag,pr_set}=={valid[pointer],tag[pr_cblk]},())? 1'b1:1'b0;
	assign pr_dout = pr_word ? data[pointer*2+1] : data[pointer*2];

	//hit
	always @* begin
		if (pr_set==0) begin 
			if (valid[0]==1'b1 && tag[0]==pr_tag) begin
				pointer = 0;
				hit = 1'b1;
			end
			else if (valid[1]==1'b1 && tag[1] == pr_tag) begin
				pointer = 1;
				hit = 1'b1;
			end
			else begin
				pointer = 0;
				hit = 1'b0;
			end
		end
		else begin
			if (valid[0]==1'b1 && tag[0]==pr_tag) begin
				pointer = 2;
				hit = 1'b1;
			end
			else if (valid[1]==1'b1 && tag[1] == pr_tag) begin
				pointer = 3;
				hit = 1'b1;
			end
			else begin
				pointer = 0;
				hit = 1'b0;
			end
		end
	end

	//   state, valid and dirty bits, tags and data
	always @(posedge clk or posedge reset)
	begin
		if(reset) begin
		state<=QInitial;
				valid <= 4'b0000;
				dirty <= 4'b0000;
				lru <= 2'b00;
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
						case (pointer)
							0: lru[0] <= 1;
							1: lru[0] <= 0;
							2: lru[1] <= 1;
							3: lru[1] <= 0;
						endcase
					end
					else if (pr_wr) begin
						if (pr_word==0) data[pointer*2] <= pr_din[7:0];
						else begin 
							data[pointer*2+1] <= pr_din[7:0];
						end
						case (pointer)
							0: lru[0] <= 1;
							1: lru[0] <= 0;
							2: lru[1] <= 1;
							3: lru[1] <= 0;
						endcase
						valid[pointer] <= 1;
						dirty[pointer] <= 1;
					end
					else begin end
						state <= QInitial;
				end
				else begin
					if (pr_set == 1'b0) begin
						if (dirty[lru[0]] == 1'b1) begin
							state <= QWB;
						end
						else begin
							state <= QFetch;
						end
					end
					else begin
						if (dirty[2+lru[1]] == 1'b1) begin
							state <= QWB;
						end
						else begin
							state <= QFetch;
						end
					end

//					if (dirty[lru]== 1b'1 ) begin
//						state <= QWB;
//					end
//					else state <= QFetch;
				end
			end
			QWB:
			begin
				if (bus_done) begin 
					state <= QFetch;
					if (pr_set == 0) begin
						data[lru[0]*2] <= 0;
						data[lru[0]*2+1] <= 0;
						tag[lru[0]] <= 0;
						valid[lru[0]] <= 0;
						dirty[lru[0]] <= 0;
					end
					else begin
						data[4+lru[1]*2] <= 0;
						data[4+lru[1]*2+1] <= 0;
						tag[2+lru[1]] <= 0;
						valid[2+lru[1]] <= 0;
						dirty[2+lru[1]] <= 0;
					end

				end
				else state <= QWB;
			end			
			
			QFetch:
			begin
				if (bus_done == 1'b1) begin
					if (pointer == 0 || pointer == 1) begin
					case (lru[0])
							0: begin
								data[0] <= bus_din[7:0];
								data[1] <= bus_din[15:8];
								tag[0] <= bus_addr[4:1];
								valid[0] <= 1;
								dirty[0] <= 0;
								lru[0] <= 1;
							end
							1: begin
								data[2] <= bus_din[7:0];
								data[3] <= bus_din[15:8];
								tag[1] <= bus_addr[4:1];
								valid[1] <= 1;
								dirty[1] <= 0;
								lru[0] <= 0;
							end
					endcase
					end
					else begin
					case (lru[1])
							0: begin
								data[4] <= bus_din[7:0];
								data[5] <= bus_din[15:8];
								tag[2] <= bus_addr[4:1];
								valid[2] <= 1;
								dirty[2] <= 0;
								lru[1] <= 1;
							end
							1: begin
								data[6] <= bus_din[7:0];
								data[7] <= bus_din[15:8];
								tag[3] <= bus_addr[4:1];
								valid[3] <= 1;
								dirty[3] <= 0;
								lru[1] <= 0;
							end
					endcase
					end
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
				if (pr_set==0) begin
					bus_addr = {tag[lru[0]],pr_set};
					bus_dout = {data[lru[0]*2+1],data[lru[0]*2]};
				end
				else begin
					bus_addr = {tag[lru[1]],pr_set};
					bus_dout = {data[4+lru[1]*2+1],data[4+lru[1]*2]};
				end
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
