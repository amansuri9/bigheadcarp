breed [ speakers speaker ]
breed [ bigheads bighead ]
breed [ normals normal ]
breed [ wave-components wave-component ] ;; These are all turtles. That are represented by waves.


;;;;;;;;;;;;;;;
;; Variables ;;
;;;;;;;;;;;;;;;

globals [
  speed-of-sound                        ;; Constant
  next-wave-id                          ;; Counters
  wave-interval                         ;; How many ticks between each wave?
  initial-wave-amplitude                ;;
  into-lake                             ;;
  wait-time                             ;;
]

bigheads-own [ energy                   ;; Bigheads have energy
               cruise-speed             ;; Bigheads have cruise-speed
               wiggle-angle             ;; Bigheads have wiggle-angle
               turn-angle               ;; Bigheads have turn-angle
]

normals-own [ energy
               cruise-speed
               wiggle-angle
               turn-angle]

wave-components-own [
  amplitude                             ;; the amplitude identifies the "intensity" for the model in this case
  wave-id                               ;; the wave-id identifies which wave this

]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup                                ;; Initializes the game
  clear-all
  ask patches [set pcolor blue]
  set-default-shape wave-components "wave particle"
  set-default-shape speakers "box"
  grow-resources                        ;; Growing resources such as plankton and detritus
  create-bigheads Number-of-Bigheads    ;; Creating the number of bigheads specified by user
   [ set color grey
     set shape "fish"
     set size 2
     ask bigheads
      [ setxy min-pxcor random-ycor ]
     set energy random 10               ;; Start with a random amt. of energy
     set cruise-speed 3                 ;; Cruise speed is the fishes normal swim speed;
     set wiggle-angle 5                 ;; This will be used to apply 'normal' movement, to simulate some sort of swimming behavior
     set turn-angle 10                  ;; Turn angle allows us to redirect the fish, this
  ]
  create-normals Number-of-Normals     ;; Creating the number of normals specified by user
   [ set color one-of remove gray base-colors
     set shape "turtle"
     set size 2
     ask normals
      [ setxy min-pxcor random-ycor ]
     set energy random 10               ;; Start with a random amt. of energy
     set cruise-speed 3                 ;; Cruise speed is the fishes normal swim speed;
     set wiggle-angle 5                 ;; This will be used to apply 'normal' movement, to simulate some sort of swimming behavior
     set turn-angle 10                  ;; Turn angle allows us to redirect the fish, this
   ]
  set speed-of-sound 757
  set initial-wave-amplitude 20         ;; How loud is the wave when first emitted?
  set wave-interval 3                   ;; How often does the plane emit a wave?
  set next-wave-id 0                    ;; Initialize a counter for wave

  create-speakers 1                     ;; Creating the speakers (position, size, and color)
   [ set ycor -16
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 16
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 0
     set xcor 25
     set size 1
     set color red
   ]

  create-speakers 1
   [ set ycor 8
     set xcor 25
     set size 1
     set color red
   ]

  create-speakers 1
   [ set ycor -8
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor -12
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 12
    set xcor 25
    set size 1
    set color red
   ]
  create-speakers 1
   [ set ycor 4
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor -4
     set xcor 25
     set size 1
     set color red
   ]
create-endzone                          ;; Calling the barrier setup method
reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to go                                  ;; The main procedure
  if (into-lake = 20)                  ;; If this many fish get passed the barrier then simulation is terminated
  [
    user-message (word "Full Scale Invasion! Time Taken to Cross Barrier = " ticks " isecs ")
    stop
  ]
  if not any? bigheads [ stop ]        ;; Model stops when there are no bigheads left
  grow-resources                       ;; Growing detritus and plankton
  ask bigheads
   [ wiggle
     fd 1
     eat-plankton
     eat-detritus
     reproduce
     death
   ]
   ask normals
    [ wiggle
      fd 1
      eat-plankton
      reproduce
      death
    ]
  die-endzone                                                         ;; Call the make bigheads die when theycross the barrier
  continue-to-lake                                                    ;; Call the make normal die when they cross the barrier
  ask bigheads                                                        ;; Bigheads run away when the speakers go off under the radius specified by user
    [ if any? wave-components in-radius radius [bk 3 rt 180] ]
  if ticks mod wave-interval = 0 [ ask speakers [ emit-wave ] ]       ;; Emit the sound wave
  ask wave-components                                                 ;; Creating the waves
  [ if not can-move? 0.5 [ die ]
    fd 0.5
    set amplitude amplitude - 0.5
    set color scale-color red amplitude 0 initial-wave-amplitude
    if amplitude < 0.5 [ die ]
  ]
  tick
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Other Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;


to grow-resources                         ;; Creating growth for detritus and plankton
  ask patches
    [ if pcolor = blue
      [ if random-float 1000 < detritus-grow-rate
          [ set pcolor brown ]
        if random-float 1000 < plankton-grow-rate
          [ set pcolor green ]
      ]
    ]
end

;; Patch procedure
;; Counts the total amplitude of the waves on this patch,
;; Making sure not to count two components of the same wave.

to-report amplitude-here [ids-to-exclude]
  let total-amplitude 0
  let components wave-components-here
  if count components > 0
   [ let wave-ids-here remove-duplicates [ wave-id ] of components        ;; Get list of the wave-ids with components on this patch
     foreach ids-to-exclude [ id -> set wave-ids-here remove id wave-ids-here
    ]
    foreach wave-ids-here [ id -> set total-amplitude total-amplitude +   ;; For each wave id, sum the maximum amplitude here
        [amplitude] of max-one-of components with [ wave-id = id ]
          [ amplitude ]
    ]
  ]
  report total-amplitude
end

to wiggle                                 ;; Fishes procedure
  rt random 45
  lt random 45
  if not can-move? 1 [ rt 180 ]
   set energy energy - 0.5
end

to eat-plankton                           ;; Eating procedure of plankton for both fish
  if pcolor = green
  [ set pcolor blue
    set energy energy + plankton-energy   ;; Gain "plankton-energy" by eating plankton
  ]
end

to eat-detritus                           ;; Eating procedure of detritus for ONLY bighead
  ;; gain "Detritus-energy" by eating detritus
  if pcolor = brown
  [ set pcolor blue
    set energy energy + detritus-energy ] ;; Gain "plankton-energy" by eating plankton
end

to reproduce                              ;; Reproduction procedure for both fish
  if energy > birth-threshold
    [ set energy energy / 2               ;; Give birth to a new fish, taking lots of energy
      hatch 1 [ fd 1 ] ]
end

to death                                  ;; Death procedure for both fish
  if energy < 0 [ die ]                   ;; Die if they run out of energy
end

to emit-wave                              ;; Wave procedure
  let j 0
  let num-wave-components Str-of-wave     ;; Number of components in each wave
  hatch-wave-components num-wave-components
   [ set size 1
     set j j + 1
     set amplitude initial-wave-amplitude
     set wave-id next-wave-id
     set heading j * ( 360.0 / num-wave-components )
     if show-amplitudes? [ hide-turtle ]
   ]
  set next-wave-id next-wave-id + 1
end


;; Creating the barrier on the right side of the field
;; Color of the barrier is yellow

to create-endzone
  ask patches with [pxcor > (max-pxcor - 2)]
    [ set pcolor yellow ]
end

;; Make bigheads die when the patch under them is yellow
;; Also keeping track of their deaths

to die-endzone
  ask bigheads [ if pcolor = yellow [ set into-lake into-lake + 1 die ] ]
end

;; Make normals die once they reach the yellow because we
;; Are not measuring if they pass the barier

to continue-to-lake
  ask normals [ if pcolor = yellow [ die ] ]
end


to draw                                    ;; Drawing the movement of the fish both bigheads and normal - assigned to a button
  ask bigheads [ pd ]
end

to stop-draw                               ;; Canceling the drawing procedure above - assigned to a button
  ask bigheads [pu]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Based on Vetter Et Al Swimming Pool ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to replicate_setup
    clear-all
  ask patches [set pcolor blue]
  set-default-shape wave-components "wave particle"
  set-default-shape speakers "square"
  set wait-time 25
  set-default-shape bigheads "fish"
  create-bigheads Number-of-Bigheads
   [ set color grey
     set size 2
     set xcor 0
     set ycor 0
     set energy random 10                   ;; Start with a random amt. of energy
     set cruise-speed 3                     ;; Cruise speed is the fishes normal swim speed;
     set wiggle-angle 5                     ;; This will be used to apply 'normal' movement, to simulate some sort of swimming behavior
     set turn-angle 10                      ;; Turn angle allows us to redirect the fish, this
   ]

  set speed-of-sound 757
  set initial-wave-amplitude 20            ;; How loud is the wave when first emitted?
  set wave-interval 3                      ;; How often does the plane emit a wave?
  set next-wave-id 0                       ;; Initialize a counter

  create-speakers 1
   [ set ycor -20
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 20
     set xcor 25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor -20
     set xcor -25
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 20
     set xcor -25
     set size 1
     set color red
   ]
  reset-ticks
end

to replicate_go
   if not any? bigheads [ stop ]
  if wait-time < ticks
  [ ask bigheads
     [ wiggle
       fd 1
       eat-plankton
       eat-detritus
       reproduce
     ]
  ]
  ask bigheads
  [ if any? wave-components in-radius 4 [rt 180] ]
  if ticks mod wave-interval = 0 [ ask speakers [ emit-wave ] ] ;; Emit the sound wave

  ask wave-components
   [ if not can-move? 0.5 [ die ]        ;; Move waves
    fd 0.5
    set amplitude amplitude - 0.5
    set color scale-color red amplitude 0 initial-wave-amplitude
    if amplitude < 0.5 [ die ]
   ]
tick
end
@#$#@#$#@
GRAPHICS-WINDOW
240
20
1060
395
-1
-1
8.93
1
8
1
1
1
0
0
0
1
-45
45
-20
20
1
1
1
ticks
10.0

BUTTON
30
20
147
53
NIL
setup\n\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
155
20
225
53
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1275
290
1335
335
Time
ticks
3
1
11

SLIDER
40
100
212
133
str-of-wave
str-of-wave
0
180
60.0
.5
1
NIL
HORIZONTAL

SLIDER
40
140
215
173
Number-of-Bigheads
Number-of-Bigheads
0
100
200.0
1
1
NIL
HORIZONTAL

SLIDER
40
180
212
213
detritus-grow-rate
detritus-grow-rate
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
40
300
212
333
plankton-grow-rate
plankton-grow-rate
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
40
220
212
253
plankton-energy
plankton-energy
0
10
5.0
0.5
1
NIL
HORIZONTAL

SLIDER
40
260
212
293
Detritus-energy
Detritus-energy
0
10
5.0
0.5
1
NIL
HORIZONTAL

SLIDER
40
340
212
373
birth-threshold
birth-threshold
0
50
25.0
1
1
NIL
HORIZONTAL

PLOT
1095
10
1450
290
Living Things
Time
Pop
0.0
100.0
0.0
111.0
true
true
"set-plot-y-range 0 Number-of-bigheads" ""
PENS
"Plankton" 1.0 0 -10899396 true "" "plot count patches with [pcolor = green] / 4"
"Detritus" 1.0 0 -6459832 true "" "plot count patches with [pcolor = brown] / 4"
"Bigheads" 1.0 0 -2674135 true "" "plot count bigheads"
"Normals" 1.0 0 -11221820 true "" "plot count normals"

MONITOR
1180
290
1277
335
count bigheads
count bigheads
1
1
11

BUTTON
260
400
377
433
NIL
replicate_setup\n\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
380
400
477
433
NIL
replicate_go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
910
400
973
433
NIL
draw\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
40
380
212
413
radius
radius
0
10
2.0
.2
1
NIL
HORIZONTAL

MONITOR
1335
290
1450
335
NIL
into-lake
17
1
11

SWITCH
40
65
210
98
Show-Amplitudes?
Show-Amplitudes?
1
1
-1000

SLIDER
40
420
215
453
Number-of-Normals
Number-of-Normals
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
1095
290
1182
335
NIL
count normals
17
1
11

BUTTON
975
400
1062
433
NIL
stop-draw\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
false
0
Polygon -7500403 true true 0 90 45 135 255 135 300 195 0 195

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wave particle
true
0
Rectangle -7500403 true true 0 120 300 180

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Detritus-energy">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plankton-energy">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-Normals">
      <value value="66"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Show-Amplitudes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detritus-grow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="7.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plankton-grow-rate">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str-of-wave">
      <value value="52.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-threshold">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-Bigheads">
      <value value="8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 20000</exitCondition>
    <metric>count bigheads</metric>
    <metric>count normals</metric>
    <metric>into-lake</metric>
    <enumeratedValueSet variable="Number-of-Normals">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str-of-wave">
      <value value="60"/>
      <value value="90"/>
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-Bigheads">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
