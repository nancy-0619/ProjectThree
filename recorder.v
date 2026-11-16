module recorder(
    input clk,
    input tick,
    input rec,
    input play,
    input [1:0] bank,
    input [3:0] sample,
    output recording,
    output playing,
    output reg [3:0] out
);
    /*
    Records ADC samples into one of 4 memory banks, and plays them back.

    Memory:
        -Instantiate 4 memory modules, one for each bank. Bank 0 is the
         first memory module, bank 1 is the second, and so on.
        -All of the memory modules share the same waddr (the record
         address), wdata (sample), and raddr (the play address).
        -Only the selected bank's memory module has its we input high.
        -out is the rdata output of the selected bank's memory module.
        -Each bank has an 8 bit "last" register that holds the address of
         the last sample recorded in that bank. These all start at 0.
        -bank selects which bank is recorded to or played from. If it
         changes, the new bank is used right away.

    Recording (rec is the debounced record button):
        -recording is high while rec is high and the bank is not full.
        -A record address register starts at 0. While rec is low, it is
         set to 0, so every press records from the start of the bank.
        -At each positive clock edge where recording and tick are both high:
            -sample is written to the current bank at the record address
            -that bank's last register is set to the record address
            -the record address increases by 1, unless it is 255. If it is
             255, the bank is full, and recording goes low until rec is
             released and pressed again.

    Playback (play is the debounced play button):
        -playing is high while play is high and rec is low. Recording
         takes priority over playback.
        -A play address register starts at 0. While playing is low, it is
         set to 0, so every press plays from the start of the bank.
        -At each positive clock edge where playing and tick are both high,
         the play address increases by 1. If the play address is greater
         than or equal to the bank's last register, it goes back to 0
         instead. This loops over the recording.
    */
    //Do not modify above this line
    reg [7:0] waddr;
    reg [7:0] raddr;
    reg full;
    reg [7:0] last [0:3];   // last address recorded for each memory bank

    wire [3:0] rdata0, rdata1, rdata2, rdata3;
    wire we0, we1, we2, we3;

    // Recording takes priority over playback
    assign recording = rec && !full;
    assign playing = play && !rec;

    // Make the selected bank's write enable high
    assign we0 = recording && tick && (bank == 2'd0);
    assign we1 = recording && tick && (bank == 2'd1);
    assign we2 = recording && tick && (bank == 2'd2);
    assign we3 = recording && tick && (bank == 2'd3);

    // Initialize registers
    integer i;
    initial begin
        waddr = 8'b0;
        raddr = 8'b0;
        full = 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
            last[i] = 8'b0;
        end
    end

    // Instantiate memory banks
    memory mem0 (
        .clk(clk),
        .we(we0),
        .waddr(waddr),
        .wdata(sample),
        .raddr(raddr),
        .rdata(rdata0)
    );

    memory mem1 (
        .clk(clk),
        .we(we1),
        .waddr(waddr),
        .wdata(sample),
        .raddr(raddr),
        .rdata(rdata1)
    );

    memory mem2 (
        .clk(clk),
        .we(we2),
        .waddr(waddr),
        .wdata(sample),
        .raddr(raddr),
        .rdata(rdata2)
    );

    memory mem3 (
        .clk(clk),
        .we(we3),
        .waddr(waddr),
        .wdata(sample),
        .raddr(raddr),
        .rdata(rdata3)
    );

    // Select active memory bank to set it's rdata as the output
    always @* begin
        case(bank)
            2'd0: out = rdata0;
            2'd1: out = rdata1;
            2'd2: out = rdata2;
            2'd3: out = rdata3;
            default: out = 4'b0;
        endcase
    end

    //Recording
    always @(posedge clk) begin
        if(!rec) begin
            waddr <= 8'd0;   // Reset recorder back to starting address
            full <= 1'b0;    // Reset full flag
        end
        else if(recording && tick) begin
            last[bank] <= waddr;    // Update last written address in the specific bank
            if(waddr == 8'd255) begin   // Update flag once waddr reaches 255
                full <= 1'b1;
            end
            else begin  // Increment waddr address by one
                waddr <= waddr + 8'd1;
            end
        end
    end

    //Playback
    always @(posedge clk) begin
        if(!playing) begin
            raddr <= 8'd0;
        end
        else if(tick) begin
            if(raddr >= last[bank]) begin
                raddr <= 8'd0;
            end
            else begin
                raddr <= raddr + 8'd1;
            end 
        end
    end
endmodule
