## Crow voice mod for nb for norns

Choose pitch out of 1 and envelope out of 2, or pitch out of 3 and envelope out of 4.

To get gates instead of envelopes, choose attack and release shapes of "now", and a sustain of 1.

To get triggers instead of envelopes, choose attack and decay shapes of "now" and a sustain of 0. 

The "tuned to" parameter should be what your oscillator outputs at 0V of pitch cv.

The "tune" parameter autmoatically tunes your oscillator. Patch your oscillator (or voice) to Norns left input (turn down the monitor), make it the only thing your Norns left input hears, and trigger `tune`. Norns will listen to your sound at 0v of pitch and automatically set the "tuned to" value accordingly.