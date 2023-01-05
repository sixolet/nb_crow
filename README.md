## Crow voice mod for nb for norns

Choose pitch out of 1 and envelope out of 2, or pitch out of 3 and envelope out of 4.

To get gates instead of envelopes, choose attack and release shapes of "now", and a sustain of 1.

To get triggers instead of envelopes, choose attack and decay shapes of "now" and a sustain of 0. 

The "tuned to" parameter should be what your oscillator outputs at 0V of pitch cv.

The "tune" parameter is experimental. You are supposed to be able to patch your oscillator to crow input 1, and trigger "tune", and it will detect the right pitch to put in "tuned to". Unfortunately, I don't think Crow is accurate enough about pitch tracking for this to work well. It should get you in the ballpark though.