module ram_module (
    input wire clk,                // Sistem saat sinyali
    input wire rst,                // Reset sinyali
    input wire [8:0] addr_in,     // Başlangıç adresi
    input wire en,                 // RAM okuma başlatma sinyali
	 input wire wren,
	 input [63:0] data_in,
    output reg [63:0] data_out_0,  // 64-bit veri çıkışı
    output reg [63:0] data_out_1,
    output reg [63:0] data_out_2,
    output reg [63:0] data_out_3,
    output reg [63:0] data_out_4,
    output reg [63:0] data_out_5,
    output reg [63:0] data_out_6,
    output reg [63:0] data_out_7,
    output reg [63:0] data_out_8,
    output reg [63:0] data_out_9,
    output reg [63:0] data_out_10,
    output reg [63:0] data_out_11,
    output reg ready               // Verinin hazır olduğunu gösteren sinyal
);

    // RAM boyutunu belirtelim (örneğin 1024 adres)
    reg [63:0] memory0 [0:511];    // 512 x 64-bit RAM
	 reg [63:0] memory1 [0:511];    // 512 x 64-bit RAM
	 reg [63:0] memory2 [0:511];    // 512 x 64-bit RAM
	 reg [63:0] memory3 [0:511];    // 512 x 64-bit RAM
	 reg [63:0] memory4 [0:511];    // 512 x 64-bit RAM
	 reg [63:0] memory5 [0:511];    // 512 x 64-bit RAM

    // Adresler ve paralel okuma için register tanımlamaları
    reg [8:0] addr_index[11:0];    // 12 adet 9-bit adres (512 hücrelik RAM için)
    integer i;
	 
	 initial begin
		/*$readmemh("data6_yeni.hex", memory0);
		$readmemh("data6_yeni.hex", memory1);
		$readmemh("data6_yeni.hex", memory2);
		$readmemh("data6_yeni.hex", memory3);
		$readmemh("data6_yeni.hex", memory4);
		$readmemh("data6_yeni.hex", memory5);*/
		$readmemh("data5.hex", memory0);
		$readmemh("data5.hex", memory1);
		$readmemh("data5.hex", memory2);
		$readmemh("data5.hex", memory3);
		$readmemh("data5.hex", memory4);
		$readmemh("data5.hex", memory5);
	 end
	 
	 
    // Okuma işlemi için state makinesi
    reg [1:0] state;

    parameter IDLE = 0, READ = 1, DONE = 2;

    // Resetleme ve başlangıç durumu
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            ready <= 0;
            data_out_0 <= 64'b0;
            data_out_1 <= 64'b0;
            data_out_2 <= 64'b0;
            data_out_3 <= 64'b0;
            data_out_4 <= 64'b0;
            data_out_5 <= 64'b0;
            data_out_6 <= 64'b0;
            data_out_7 <= 64'b0;
            data_out_8 <= 64'b0;
            data_out_9 <= 64'b0;
            data_out_10 <= 64'b0;
            data_out_11 <= 64'b0;
        end else if(wren && !en) begin
				// verilen adrese yaz
				memory0[addr_in] <= data_in;
				memory1[addr_in] <= data_in;
				memory2[addr_in] <= data_in;
				memory3[addr_in] <= data_in;
				memory4[addr_in] <= data_in;
				memory5[addr_in] <= data_in;
		  end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    if (en) begin
                        // 12 adresi hesapla (addr_in'den başla ve 11 adres sonrasına kadar)
                        for (i = 0; i < 12; i = i + 1) begin
                            addr_index[i] <= addr_in[8:0] + i[8:0];  // Başlangıç adresine 0,1,2,... ekle
                        end
                        state <= READ;
                    end
                end
                
                READ: begin
                    // Paralel okuma: her bir addr_index'teki veriyi memory'den oku
                    data_out_0 <= memory0[addr_index[0]];
                    data_out_1 <= memory0[addr_index[1]];
                    data_out_2 <= memory1[addr_index[2]];
                    data_out_3 <= memory1[addr_index[3]];
                    data_out_4 <= memory2[addr_index[4]];
                    data_out_5 <= memory2[addr_index[5]];
                    data_out_6 <= memory3[addr_index[6]];
                    data_out_7 <= memory3[addr_index[7]];
                    data_out_8 <= memory4[addr_index[8]];
                    data_out_9 <= memory4[addr_index[9]];
                    data_out_10 <= memory5[addr_index[10]];
                    data_out_11 <= memory5[addr_index[11]];
                    state <= DONE;
                end
                
                DONE: begin
                    ready <= 1;   // Veriler hazır
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
