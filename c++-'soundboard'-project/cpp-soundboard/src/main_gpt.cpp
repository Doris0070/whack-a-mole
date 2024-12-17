#include <Arduino.h>
#include <cmath>
#include <LiquidCrystal.h>
#include <driver/adc.h>
#include "driver/i2s.h"
#include <mutex>
#include <thread>
#include <algorithm>
#include <numeric>
//libraries for timer (we want to get as close as 44.1khz samples/s as possible)
#include <iostream>
#include <vector>
#include "driver/timer.h"
//define pins
#define start_button 4
#define stop_button 5
#define button 6
#define audio_output 7
#define pot_audio 36
#define half_adc 128
#define max_adc 256
#define RS 17
#define E 18
#define D4 9
#define D5 10
#define D6 11
#define D7 12
//define timer var/const
#define SAMPLE_RATE 50000
#define recording_unit 31250
#define TARGET_TIME_US 20
#define TIMER_DIVIDER 80  // Timer divider (80 MHz / 80 = 1 MHz, 1 µs increments)
#define TIMER_GROUP TIMER_GROUP_0  // Timer group (can be 0 or 1)
#define TIMER_INDEX TIMER_0  // Timer index (can be 0 or 1)
//define music note duration
#define bpm_120 120
#define bpm_150 150
//all global variables
short int bpm;
long int bpm_unit;
short int unit_for_playing;
double pi = 2*acos(0.0);
float freq = 400 ;
double cycle = 0;
int pot_value = 0;
int debounce = 882;
long global_sine_wave_step_counter = 0;
boolean global_music_recording_or_replaying = false;
volatile bool timerExpired = false;
byte global_record_counter;
bool global_repaly_indicator;
int bpm_unit_step = 1;
int freq_button1[3] = {400, 600, 450};
int freq_button2[3] = {800, 700, 950};
int freq_button3[3] = {40, 80, 100};
constexpr int MAX_DAC_VALUE = 65535;   // 16-bit max value
constexpr int MID_DAC_VALUE = 32768;   // Midpoint of 16-bit DAC range
constexpr int POTENTIOMETER_MAX = 1023;
std::mutex mtx;
//precalls of functions
void record_loop(std::vector<short int>& buttonArray1, std::vector<short int>& buttonArray2, std::vector<short int>& buttonArray3);
void replay_loop(std::vector<short int>& buttonArray1, std::vector<short int>& buttonArray2, std::vector<short int>& buttonArray3, int pot_value);
std::vector<short int> buttonArray1;
std::vector<short int> buttonArray2;
std::vector<short int> buttonArray3;
void led_blink();
void replay_sign();
void recording_countdown();
void main_menu_screen();
void error_screen();
void main_menu_setup();
void set_bpm_loop();
void set_unit_loop();
void printArr(const std::vector<short int>& buttonArray1);
void internal_timer();
int DAC_value_calc(int bpm_unit, int bpm_unit_step, int freq_button1, int freq_button2, int freq_button3,int global_sine_wave_step_counter, std::vector<short>& buttonArray1,std::vector<short>& buttonArray2, std::vector<short>& buttonArray3);
void main_loop_core_0(void *pvParameters);
LiquidCrystal lcd(RS, E, D4, D5, D6, D7);
//create tasks for dual core operation
TaskHandle_t Task1;
TaskHandle_t Task2;

void IRAM_ATTR onTimer(void* arg) {
    timerExpired = true;
    timer_group_clr_intr_status_in_isr(TIMER_GROUP, TIMER_INDEX);
}

void setup(){
    Serial.begin(9600);
    lcd.begin(16, 2);
    pinMode(audio_output, OUTPUT);
    pinMode(pot_audio, INPUT);
    pinMode(start_button, INPUT_PULLDOWN);
    pinMode(button, INPUT_PULLDOWN);
    pinMode(stop_button, INPUT_PULLDOWN);
    adc1_config_width(ADC_WIDTH_BIT_12);
    adc1_config_channel_atten(ADC1_CHANNEL_0,ADC_ATTEN_DB_0);
    bpm = bpm_120;
    unit_for_playing = 16;
    std::unique_lock<std::mutex> lock(mtx);
    bpm_unit = (240.0 / bpm) / unit_for_playing * 1000 * 1000;
    lock.unlock();
    //dual core processing setup
    xTaskCreatePinnedToCore(
        main_loop_core_0,
        "Task1",
        4096,  // Reasonable stack size
        NULL,
        0,
        &Task1,
        0  // Assign to core 0
    );
    //i2s
    /*
    i2s_config_t i2s_config = {
        .mode = static_cast<i2s_mode_t>(I2S_MODE_MASTER | I2S_MODE_TX),  // Master mode, Transmit only
        .sample_rate = SAMPLE_RATE,
        .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,  // 16-bit samples
        .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,  // Stereo
        .communication_format = I2S_COMM_FORMAT_STAND_I2S,
        .intr_alloc_flags = 0,  // Default interrupt priority
        .dma_buf_count = 8,    // Number of buffers
        .dma_buf_len = 1024,   // Size of each buffer
        .use_apll = false,
        .tx_desc_auto_clear = true  // Automatically clear the descriptor on underrun
    };
    i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
    i2s_pin_config_t pin_config = {
    .bck_io_num = 26,
    .ws_io_num = 25,
    .data_out_num = 22,
    .data_in_num = -1
    };
    i2s_set_pin(I2S_NUM_0, &pin_config);
    */
    //internal timer config
    timer_config_t config = {
    .alarm_en = TIMER_ALARM_EN,
    .counter_en = TIMER_PAUSE,
    .intr_type = TIMER_INTR_LEVEL,
    .counter_dir = TIMER_COUNT_UP,
    .auto_reload = TIMER_AUTORELOAD_EN,
    .divider = TIMER_DIVIDER
    };
    // Initialize and configure the timer
    timer_init(TIMER_GROUP, TIMER_INDEX, &config);
    timer_set_counter_value(TIMER_GROUP, TIMER_INDEX, 0); // Set counter to 0
    timer_set_alarm_value(TIMER_GROUP, TIMER_INDEX, TARGET_TIME_US); // Set alarm
    timer_enable_intr(TIMER_GROUP, TIMER_INDEX); // Enable interrupts
    timer_isr_register(TIMER_GROUP, TIMER_INDEX, &onTimer, nullptr, ESP_INTR_FLAG_IRAM, nullptr);
    Serial.write("finished setup---");
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// core 0 loop //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main_loop_core_0(void *pvParameters) {
    for (;;) {
        timerExpired = false;
        timer_set_counter_value(TIMER_GROUP, TIMER_INDEX, 0);
        timer_start(TIMER_GROUP, TIMER_INDEX);
        while (!timerExpired) {
            if (global_record_counter != 0) {
                Serial.println(DAC_value_calc(bpm_unit, bpm_unit_step, *freq_button1, *freq_button2, *freq_button3, global_sine_wave_step_counter, buttonArray1, buttonArray2, buttonArray3));
            } else if (global_repaly_indicator != false) {
                Serial.println(DAC_value_calc(bpm_unit, bpm_unit_step, *freq_button1, *freq_button2, *freq_button3, global_sine_wave_step_counter, buttonArray1, buttonArray2, buttonArray3));
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// core 1 loop //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void loop() {
    buttonArray1.clear();
    buttonArray2.clear();
    buttonArray3.clear();
    main_menu_screen();
    delay(100);
    global_record_counter = 3;

    if (digitalRead(button) == HIGH) {
        main_menu_setup();
    } else if (digitalRead(start_button) == HIGH) {
        record_loop(buttonArray1, buttonArray2, buttonArray3);
    }

    //Serial.printf("One time unit: %ld, BPM: %d, Note Unit: %d\n", bpm_unit, bpm, unit_for_playing);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// core 1 functions /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main_menu_setup() {
    int menu_option = 0;
    //Serial.write("In setup menu---\n");
    while (true) {
        // Display the current menu option
        lcd.clear();
        if (menu_option == 0) {
            lcd.setCursor(0, 0);
            lcd.print("Set BPM       <");
            lcd.setCursor(0, 1);
            lcd.print("Set Unit");
        } else {
            lcd.setCursor(0, 0);
            lcd.print("Set BPM");
            lcd.setCursor(0, 1);
            lcd.print("Set Unit      <");
        }

        // Handle button presses
        if (digitalRead(button) == HIGH) {
            delay(200); // Debounce delay
            menu_option = (menu_option + 1) % 2;
        } else if (digitalRead(start_button) == HIGH) {
            delay(200); // Debounce delay
            if (menu_option == 0) {
                set_bpm_loop();
            } else {
                set_unit_loop();
            }
        } else if (digitalRead(stop_button) == HIGH) {
            delay(200); // Debounce delay
            //Serial.write("Exiting setup menu---\n");
            return; // Exit the menu
        }
        delay(100); // Small delay to prevent excessive looping
    }
}

void set_bpm_loop() {
    int bpm_options[] = {120, 150, 240};
    int current_bpm_index = 0;
    while (true) {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Set BPM: ");
        lcd.print(bpm_options[current_bpm_index]);
        lcd.setCursor(0, 1);
        lcd.print("Press Btn to Set");

        if (digitalRead(button) == HIGH) {
            delay(200); // Debounce delay
            current_bpm_index = (current_bpm_index + 1) % 3;
        } else if (digitalRead(start_button) == HIGH) {
            delay(200); // Debounce delay
            std::unique_lock<std::mutex> lock(mtx);
            bpm = bpm_options[current_bpm_index];  // Save updated BPM
            bpm_unit = (240.0 / bpm) / unit_for_playing * 1000 * 1000;  // Update bpm_unit
            lock.unlock();
            //Serial.printf("Updated BPM to: %d\n", bpm);
            return;  // Exit
        } else if (digitalRead(stop_button) == HIGH) {
            delay(200); // Debounce delay
            //Serial.write("Exiting BPM setup without changes---\n");
            return;  // Exit without changes
        }
        delay(100);
    }
}

void set_unit_loop() {
    int unit_options[] = {1, 2, 4, 8, 16, 32, 64};
    int current_unit_index = 0;
    while (true) {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Set Unit: ");
        lcd.print(unit_options[current_unit_index]);
        lcd.setCursor(0, 1);
        lcd.print("Press Btn to Set");

        if (digitalRead(button) == HIGH) {
            delay(200); 
            current_unit_index = (current_unit_index + 1) % 7;
        } else if (digitalRead(start_button) == HIGH) {
            delay(200); 
            std::unique_lock<std::mutex> lock(mtx);
            unit_for_playing = unit_options[current_unit_index];  // Save updated unit
            bpm_unit = (240.0 / bpm) / unit_for_playing * 1000 * 1000;  // Update bpm_unit
            lock.unlock();
            //Serial.printf("Updated Unit to: %d\n", unit_for_playing);
            return;  // Exit
        } else if (digitalRead(stop_button) == HIGH) {
            delay(200); // Debounce delay
            //Serial.write("Exiting Unit setup without changes---\n");
            return;  
        }
        delay(100);
    }
}

void record_loop(std::vector<short>& buttonArray1, std::vector<short>& buttonArray2, std::vector<short>& buttonArray3) {
    //setup 
    //Serial.write("Entered recording loop---\n");
    led_blink();
    recording_countdown();
    //recording loop
    global_music_recording_or_replaying = true;
    unsigned long startMillis = millis();
    for(;global_record_counter != 0; global_record_counter--){
        while (millis() - startMillis < 30000 && digitalRead(stop_button) == LOW) {
            unsigned long record_loop_start_micros = micros();
            int i = 0;
            while(micros() - record_loop_start_micros < bpm_unit && digitalRead(stop_button) == LOW){
                for(; i < 1; i++){
                    short int buttonState = digitalRead(button) == HIGH ? analogRead(pot_audio) : 0;
                    if(global_record_counter == 3){
                        std::unique_lock<std::mutex> lock(mtx);
                        buttonArray1.push_back(buttonState);
                        //(buttonState == 1) ? Serial.println("Button ON---") : Serial.println("Button OFF---");
                        lock.unlock();
                    } else if(global_record_counter == 2){
                        std::unique_lock<std::mutex> lock(mtx);
                        buttonArray2.push_back(buttonState);
                        //(buttonState == 1) ? Serial.println("Button ON---") : Serial.println("Button OFF---");
                        lock.unlock();
                    } else if(global_record_counter == 1){
                        std::unique_lock<std::mutex> lock(mtx);
                        buttonArray3.push_back(buttonState);
                        //(buttonState == 1) ? Serial.println("Button ON---") : Serial.println("Button OFF---");
                        lock.unlock();
                    } else{
                        //do nothing as it shouldnt come to here because outer while loop
                    }
                    //Serial.print("Vector size: ");
                    //Serial.println(buttonArray1.size());
                    printArr(buttonArray1);
                }
                if (digitalRead(stop_button) == HIGH) {
                    //Serial.write("Stop button pressed! Exiting record loop---\n");
                    break;
                }
            }
            i = 0;
            if (digitalRead(stop_button) == HIGH) {
                //Serial.write("Stop button pressed! Exiting record loop---\n");
                break;
            }
        }
    }
    global_record_counter = 0;
    global_music_recording_or_replaying = false;
    //Serial.write("Stop button triggered or 30s elapsed. Entering replay loop---\n");
    replay_loop(buttonArray1, buttonArray2, buttonArray3, pot_value);
    //Serial.write("Finished replay, returning to main menu---\n");
}

void replay_loop(std::vector<short int>& buttonArray1, std::vector<short int>& buttonArray2, std::vector<short int>& buttonArray3, int pot_value) {
    led_blink();
    //Serial.write("replay loop entered---");
    replay_sign();
    //log_i("Button array size: %d ", buttonArray1.size());
    // Loop until stop_button is pressed
    /*
    global_music_recording_or_replaying = true;
    while (digitalRead(stop_button) == LOW) {
        for (size_t i = 0; i < buttonArray1.size() && digitalRead(stop_button) == LOW; i++) {
            unsigned long replay_loop_start_micros = micros();
            int j = 0;
            while(micros() - replay_loop_start_micros < bpm_unit && digitalRead(stop_button) == LOW){
                for(; j < 1; j++){
                    Serial.printf("[%d] [%s]", i, buttonArray1[i] != 0 ? "init 1": "init 0" );
                    Serial.println("");
                    std::unique_lock<std::mutex> lock(mtx);
                    digitalWrite(audio_output, buttonArray1[i] != 0 ? HIGH : LOW);
                    lock.unlock();
                    if(digitalRead(stop_button) == LOW) Serial.write("stop button triggered\n");
                    if(digitalRead(stop_button) == HIGH) break;
                }
            }
            j = 0;
        }
        Serial.println("one loop finished\n");
    }
    global_music_recording_or_replaying = false;
    return;
    */
   global_repaly_indicator == true;
   while(digitalRead(stop_button)  == LOW){
    //do nothing
   }
   global_repaly_indicator == false;
   return;
}

void main_menu_screen(){
    lcd.setCursor(0, 0);
    lcd.print("                ");
    lcd.setCursor(0, 1);
    lcd.print("                ");
    lcd.setCursor(0, 0);
    lcd.print("MAIN MENU");
    lcd.setCursor(0, 1);
    lcd.print("bpm:");
    lcd.setCursor(4, 1);
    lcd.print(bpm);
    lcd.setCursor(8, 1);
    lcd.print("units:");
    lcd.setCursor(14, 1);
    lcd.print(unit_for_playing); 
}

void recording_countdown(){
    lcd.setCursor(0, 0);
    lcd.print("                ");
    lcd.setCursor(0, 1);
    lcd.print("                ");
    lcd.setCursor(0, 0);
    lcd.print("recording in:");
    lcd.setCursor(0, 1);
    lcd.print("3");
    delay(1000);
    lcd.setCursor(0, 0);
    lcd.print("recording in:");
    lcd.setCursor(0, 1);
    lcd.print("2");
    delay(1000);
    lcd.setCursor(0, 0);
    lcd.print("recording in:");
    lcd.setCursor(0, 1);
    lcd.print("1");
    delay(1000);
    lcd.setCursor(0, 0);
    lcd.print("recording");
    lcd.setCursor(0, 1);
    lcd.print("in progress");
}

void replay_sign(){
    lcd.setCursor(0, 0);
    lcd.print("                ");
    lcd.setCursor(0, 1);
    lcd.print("                ");
    lcd.setCursor(0, 0);
    lcd.print("replay mode");
    lcd.setCursor(0, 1);
    lcd.print("                ");
}
/*
void error_screen(){
    lcd.setCursor(0, 0);
    lcd.print("                ");
    lcd.setCursor(0, 1);
    lcd.print("                ");
    lcd.setCursor(0, 0);
    lcd.print("error");
    lcd.setCursor(0, 1);
    lcd.print("                ");
    delay(2000);
}
*/
void led_blink(){
    for(int i = 0; i < 5; i++){
        digitalWrite(audio_output, HIGH);
        delay(50);                      
        digitalWrite(audio_output, LOW);
        delay(50); 
    }
}

void printArr(const std::vector<short int>& buttonArray1) {
    //Serial.print("button array: ");
    for (int i = 0; i < buttonArray1.size(); i++) {
        //Serial.print(buttonArray1[i]);  // Print the value
        if (i < buttonArray1.size() - 1) {
        //    Serial.print(",");  // Print a comma between values
        }
    }
    //Serial.println();  // End the line
}

/* //internal timer
void internal_timer() {
    timerExpired = false;  // Reset flag
    timer_set_counter_value(TIMER_GROUP, TIMER_INDEX, 0);  // Reset timer counter
    timer_start(TIMER_GROUP, TIMER_INDEX);  // Start timer

    // Wait for the timer to expire
    while (!timerExpired) {
        // Optional: Add button check here for early exit
        if (digitalRead(stop_button) == HIGH) return;
    }
}
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// core 0 functions //////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

//dual core processing on core 0

int DAC_value_calc(
    int bpm_unit,                     // The base unit for beats per minute (used in sine wave calculation).
    int bpm_unit_step,                // Step size for incrementing the sine wave counter relative to bpm.
    int freq_button1,                 // Frequency associated with button 1.
    int freq_button2,                 // Frequency associated with button 2.
    int freq_button3,                 // Frequency associated with button 3.
    int global_sine_wave_step_counter, // Global counter for sine wave steps.
    std::vector<short>& buttonArray1, // Array holding values for button 1 (e.g., potentiometer readings).
    std::vector<short>& buttonArray2, // Array holding values for button 2.
    std::vector<short>& buttonArray3  // Array holding values for button 3.
) {
    if (bpm_unit_step <= 0) {
        bpm_unit_step = bpm_unit / TARGET_TIME_US;         // Reset bpm_unit_step to bpm_unit when it reaches zero.
        global_sine_wave_step_counter++; // Increment the global sine wave step counter.
    }
    
    // Determine the largest size among the button arrays to standardize their sizes.
    size_t max_size = std::max({ buttonArray1.size(), buttonArray2.size(), buttonArray3.size() });

    // Ensure all button arrays are the same size by padding with zeros.
    buttonArray1.resize(max_size, 0);
    buttonArray2.resize(max_size, 0);
    buttonArray3.resize(max_size, 0);

    // Initialize the DAC value to a midpoint value.
    double dac_value = MID_DAC_VALUE;

    // Group button arrays into a vector for easier iteration.
    std::vector<std::vector<short>> buttonArrays = { buttonArray1, buttonArray2, buttonArray3 };

    // Group frequency arrays into a vector.
    std::vector<int> frequencies = { freq_button1, freq_button2, freq_button3 };

    // Iterate over each button array.
    for (size_t button_idx = 0; button_idx < buttonArrays.size(); ++button_idx) {
        auto& buttonArray = buttonArrays[button_idx];
        auto freq_array = frequencies[button_idx];

        // Calculate the current position in the button array based on the global sine wave step counter.
        size_t current_position = (global_sine_wave_step_counter / bpm_unit_step) % buttonArray.size();

        // Read the potentiometer value for the current position.
        short potentiometer_value = buttonArray[current_position];

        if (potentiometer_value > 0) {
            // Add contributions from each frequency for this button.
            double frequency = freq_array; // Use the single frequency value directly
            double sine_component = std::sin(
                2 * M_PI * frequency * (global_sine_wave_step_counter / static_cast<double>(bpm_unit))
            );

            // Scale the contribution and add to the DAC value.
            dac_value += ((potentiometer_value / static_cast<double>(POTENTIOMETER_MAX)) * 32767.0 * sine_component);
        }
    }

    // Update bpm_unit_step and global_sine_wave_step_counter.
    bpm_unit_step--; // Decrease bpm_unit_step as per the instructions.

    // Clamp the DAC value to the 16-bit range.
    if (dac_value > MAX_DAC_VALUE) dac_value = MAX_DAC_VALUE;
    if (dac_value < 0) dac_value = 0;

    return static_cast<int>(dac_value);
}