module main(
    input clk,
    input [3:0] btn,
    input [7:0] sw,
    input comp,
    output reg [4:0] dac,
    output strobe,
    output data,
    output shift_clk
);
    /*
    Top module. The following modules will be used in this:
        -debounce
        -tick
        -adc
        -recorder
        -led_bar
        -sevseg_disp (your module from Project 2)

    Inputs:
        -btn[0] is the record button and btn[1] is the play button. Both
         must be debounced before going into the recorder.
        -sw[1:0] selects the memory bank.
        -comp is the comparator output.

    Connections:
        -tick's output is the tick input to the recorder.
        -The adc's start input is high when tick is high and the recorder
         is not playing. The ADC runs all the time except during playback.
        -The adc's result is the sample input to the recorder.
        -The dac output comes from the adc, except during playback. During
         playback, it is the recorder's out with a 0 added as the LSB,
         {out, 1'b0}, since only the upper 4 bits are stored.

    Display:
        -The LEDs show the adc's result using the led_bar module. During
         playback, they show the recorder's out instead.
        -The seven-segment display shows the bank number, and the decimal
         point is on while recording. sevseg_in and sevseg_dp are already
         connected to the inputs of your sevseg_disp module, so you just
         need to assign them. The autograder checks sevseg_in and
         sevseg_dp, not the seven_seg output.

    You can change any of the wires declared below to regs.
    */
    wire [7:0] seven_seg;
    wire [7:0] led;
    wire [3:0] sevseg_in;
    wire sevseg_dp;
    shift_reg sreg(led, seven_seg, clk, strobe, data, shift_clk);
    sevseg_disp disp(sevseg_in, sevseg_dp, seven_seg);
    //Do not modify above this line

     wire [4:0] adc_dac;
    wire [3:0] adc_result;

    wire rec_db;
    wire play_db;
    wire tick_sig;

    wire recording;
    wire playing;
    wire [3:0] playback_out;

    wire [3:0] display_value;

    debounce db_rec (
        .clk(clk),
        .btn(btn[0]),
        .btn_db(rec_db)
    );

      debounce db_play (
        .clk(clk),
        .btn(btn[1]),
        .btn_db(play_db)
    );


      tick tick_gen (
        .clk(clk),
        .tick(tick_sig)
    );

     adc adc1 (
        .clk(clk),
        .start(tick_sig && !playing),
        .comp(comp),
        .dac(adc_dac),
        .result(adc_result)
    );

     recorder rec1 (
        .clk(clk),
        .tick(tick_sig),
        .rec(rec_db),
        .play(play_db),
        .bank(sw[1:0]),
        .sample(adc_result),
        .recording(recording),
        .playing(playing),
        .out(playback_out)
    );

     assign display_value = playing ? playback_out : adc_result;

    led_bar led1 (
        .in(display_value),
        .led(led)
    );


     always @* begin
        if (playing)
            dac = {playback_out, 1'b0};
        else
            dac = adc_dac;
    end


 assign sevseg_in = {2'b00, sw[1:0]};


 assign sevseg_dp = recording;
    




endmodule
