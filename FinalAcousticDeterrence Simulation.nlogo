breed [ speakers speaker ]
breed [ bigheads bighead ]
breed [ natives native ]
breed [ wave-components wave-component ] ;; These are all turtles. That are represented by waves.


;;;;;;;;;;;;;;;
;; Variables ;;
;;;;;;;;;;;;;;;

globals [
  speed-of-sound                        ;; Constant
  next-wave-id                          ;; Counters
  wave-interval                         ;; How many ticks between each wave?
  initial-wave-amplitude                ;; Corresponds to the intial wave strength
  into-lake                             ;; Number of bigheads that cross into the lake
  wait-time                             ;; The number of ticks before bighead begin to move
  bigheads-backwards                    ;; Bighead move backwards when encounting the barrier
  natives-backwards                     ;; Native migration downstream
]

bigheads-own [ energy                   ;; Bigheads have energy
               cruise-speed             ;; Bigheads have cruise-speed
               wiggle-angle             ;; Bigheads have wiggle-angle
               turn-angle               ;; Bigheads have turn-angle
]

natives-own [ energy
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
  create-bigheads number-of-bigheads    ;; Creating the number of bigheads specified by user
   [ set color grey
     set shape "fish"
     set size 2
     ask bigheads
      [ setxy min-pxcor + 3 random-ycor ]
     set energy random 10               ;; Start with a random amt. of energy
     set cruise-speed 3                 ;; Cruise speed is the fishes normal swim speed;
     set wiggle-angle 5                 ;; This will be used to apply 'normal' movement, to simulate some sort of swimming behavior
     set turn-angle 10                  ;; Turn angle allows us to redirect the fish, this
  ]
  create-natives number-of-natives     ;; Creating the number of natives specified by user
   [ set color yellow
     set shape "fish"
     set size 2
     ask natives
      [ setxy min-pxcor + 3 random-ycor ]
     set energy random 20               ;; Start with a random amt. of energy
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

to create-additional-speakers
    create-speakers 1                     ;; Creating an additional row of speakers (position, size, and color)
   [ set ycor -14
     set xcor 23
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 18
     set xcor 23
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 2
     set xcor 23
     set size 1
     set color red
   ]

  create-speakers 1
   [ set ycor 10
     set xcor 23
     set size 1
     set color red
   ]

  create-speakers 1
   [ set ycor -6
     set xcor 23
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor -10
     set xcor 23
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor 14
    set xcor 23
    set size 1
    set color red
   ]
  create-speakers 1
   [ set ycor 6
     set xcor 23
     set size 1
     set color red
   ]
  create-speakers 1
   [ set ycor -2
     set xcor 23
     set size 1
     set color red
   ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to go                                  ;; The main procedure
  if into-lake = 20                 ;; If this many fish get passed the barrier then simulation is terminated
  [

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
   ask natives
    [ wiggle
      fd 1
      eat-plankton
      reproduce
      death
    ]
  die-endzone                                                         ;; Call the make bigheads die when theycross the barrier
  continue-to-lake                                                    ;; Call the make native die when they cross the barrier
  ask bigheads                                                        ;; Bigheads run away when the speakers go off under the radius specified by user
    [ if any? wave-components in-radius detection_radius [bk 3 rt 180] ]
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
  let num-wave-components Strength-of-wave    ;; Number of components in each wave
  hatch-wave-components num-wave-components
   [ set size 1
     set j j + 1
     set amplitude initial-wave-amplitude
     set wave-id next-wave-id
     set heading j * ( 360.0 / num-wave-components )
     if hide-amplitudes? [ hide-turtle ]
   ]
  set next-wave-id next-wave-id + 1
end


;; Creating the barrier on the right side of the field
;; Color of the barrier is yellow

to create-endzone
  ask patches with [pxcor > (max-pxcor - 1)]
    [ set pcolor yellow ]

  ask patches with [pxcor < (max-pxcor - 89)]
  [set pcolor orange]
end

;; Make bigheads die when the patch under them is yellow
;; Also keeping track of their deaths

to die-endzone
  ask bigheads [ if pcolor = yellow [ set into-lake into-lake + 1 die ] ]

  ask bigheads [if pcolor = orange [set bigheads-backwards bigheads-backwards + 1 die]]
end

;; Make natives die once they reach the yellow because we
;; Are not measuring if they pass the barier

to spawn-native
  ask patches with [pcolor = orange]
  [sprout-natives 1]
end


to continue-to-lake
  ask natives [ if pcolor = yellow [ die spawn-native]]
  ask natives [if pcolor = orange [set natives-backwards natives-backwards + 1 die]]
end


to draw                                    ;; Drawing the movement of the fish both bigheads and natives - assigned to a button
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
  create-bigheads number-of-bigheads
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
10
10
830
385
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
15
435
132
468
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
145
435
225
468
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
1030
330
1090
375
Time
ticks
3
1
11

SLIDER
1105
470
1277
503
strength-of-wave
strength-of-wave
0
180
60.0
.5
1
NIL
HORIZONTAL

SLIDER
545
435
720
468
number-of-bigheads
number-of-bigheads
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
915
470
1090
503
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
915
505
1090
538
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
730
435
902
468
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
730
470
902
503
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
915
435
1087
468
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
850
50
1400
330
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
"Normals" 1.0 0 -11221820 true "" "plot count natives"

MONITOR
715
385
812
430
count bigheads
count bigheads
1
1
11

BUTTON
270
435
387
468
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
400
435
480
468
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
275
480
370
513
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
1105
505
1277
538
detection_radius
detection_radius
0
10
9.2
.2
1
NIL
HORIZONTAL

MONITOR
1090
330
1165
375
NIL
into-lake
17
1
11

SWITCH
1105
435
1280
468
hide-Amplitudes?
hide-Amplitudes?
0
1
-1000

SLIDER
545
470
720
503
number-of-natives
number-of-natives
0
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
850
330
937
375
NIL
count natives
17
1
11

BUTTON
380
480
475
513
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

BUTTON
35
480
205
513
NIL
create-additional-speakers\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
60
405
255
431
Real-World Simulation
14
0.0
1

TEXTBOX
315
405
545
431
Replicate Simulation
14
0.0
1

TEXTBOX
850
405
1000
423
Variable Parameters
14
0.0
1

TEXTBOX
1030
20
1205
51
Graphical / Numeric Output
14
0.0
1

MONITOR
1165
330
1287
375
bigheads-backwards
bigheads-backwards
0
1
11

MONITOR
1285
330
1402
375
NIL
natives-backwards
0
1
11

@#$#@#$#@
## WHAT IS IT?

Four aquatic, invasive species labeled as ‘Asian carp’ are currently threatening the ecological integrity of Lake Michigan. Two of these fish, silver carp (Hypohthalmichthys molitrix) and bighead carp (Hypohthalmichthys nobilis), have been identified as immediate threats warranting research and action.  Bighead carp, particularly, are filter-feeding planktivores that consume up to 40% of their own body-weight in food per day and can reproduce up to approximately 2 million eggs per year.  Since these fish out-compete other native species for natural resources and spawn at such dramatic rates, they are classified as an invasive species.  Unlike most native species, bighead carp are ostariophysans, meaning they possess Weberian ossicles (a series of small bones form a link between the inner-ear region and the swim bladder, facilitating sound reception), which allow for higher frequency hearing and sensitivity to broadband sound. 

In the simulation, bighead carp (the grey fish) represent the invasive species, while the yellow fish will represent the native species.  Plankton and detritus are also present in the field (green and brown, respectively) as resource on which the fish will feed.  The acoustic barrior is at the end of the field and emits sound waves by which the bighead carp will be deterred.  This model serves to show the versatility of agent-based modeling with complex population dynamics.  Two separate dynamics are of particular interest:

* The competitive nature between native and invasive species.
* The effects of accoustic deterrence on bighead carp populations.

## HOW IT WORKS

A field (body of water) was constructed with user-specified population sizes for the invasive & native species as well as for the resources.  Since bighead carp tend to dominate the ecological systems they invade, these specific turtles were coded to consume both phytoplankton and detritus, whereas native species only consume phytoplankton.  All turtles, both invasive and native, were given a movement radius from -45 to 45 degrees.  Initial energy were randomly assigned for both native and invasive species and deplete as the turtles move.  If a turtle has not consumed a resource before its energy level completely depletes, that particular turtle would die, leaving the field.  This demonstrates the detrimental impact the invasive species could have on the ecological system.

Spawning habits for both species are the same, with the only exception being that the invasive species reproduces at a much faster rate, given that bighead carp can produce up to approximately 2 million eggs per year.  Spawning commences when a user-specified birthing threshold for the energy level of the fish is met.  New fish would then enter the field with a randomly assigned energy level.

Finally, speakers were placed in the field as patches with a designated radius of sound projection.  Initial placement was based upon the positioning used during the primary research conducted on bighead carp using acoustic deterrence.  Placement was then adjusted as necessary, to accommodate a real world environment in which bighead carp are deterred from entering the Great Lakes.  The control trials form the primary research were recreated, to demonstrate the impact the acoustic deterrence has on the swimming patters of the invasive species.  When bighead carp travel within the designated radius of the sound projection, movement will be halted, a range of specified rotation will take place, and movement speed will increase for a short period of time as the fish swims away from the deterrence.

## HOW TO USE IT

To set up the field, click the "setup" button.  Several variable parameters have been implemented as sliders and can be adjusted according to what the user is choosing to investigate:

* "detritus-growth-rate" - the rate at which detritus will replinish with each tick

* "plankton-growth-rate" - the rate at which plankton will replinish with each tick

* "number-of-bigheads" - the number of bigheads to intially enter the field upon "go"

* "number-of-natives" - the number of natives to intially enter the field upon "go"

* "strength-0f-waves" - the strength at which acoustic waves emit from the speakers

* "radius" - the distance by patches that the bighead carp will detect and react to the barrier

* "birth-threshold" - the threshold at which at which the fish's energy level must be greater than in order to give birth

A switch has also been impleted that allows the user to turn off the visual effects of the sound waves to better analyze native fish behavior past the barrier. 


## THINGS TO NOTICE

Several output displays have been made available for the user to review.  Perhaps the most interesting is the graph of populations over time (ticks) which is inclusive of bigheads, natives, plankton, and detritus.  Output displays for the current number of bighead and natives in the field is also available for the user to analyze as the simulation runs.

Since the purpose of the model is to determine the effectiveness of an acoustic barrier, the number of bighead carp that cross the yellow boundary (get into the native ecosystem) are counted in an addition output display.  If 20 bighead carp get past the barrier and into the "end zone", the simulation will end and a message will display that an invasion has occured. 

## THINGS TO TRY

At what variable parameters will a bighead carp invasion be deterred for at least 30,000 ticks?

## EXTENDING THE MODEL

While only one configuration and count of speakers was coded in this model, this is by no means the best or most effective integration of acoustic deterrence.  Configurations taking into consideration both effectiveness as well as cost feasibility should be considered for future implementation.  This may also change based on the real-word environment in which the acoustic barrier is being integrated.  Several other assumptions made within this model could be further researched to provide more reliable results.

## REFERENCES

* Wilensky, U. (2001). NetLogo Rabbits Grass Weeds model. http://ccl.northwestern.edu/netlogo/models/RabbitsGrassWeeds. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U. (1997). NetLogo Doppler model. http://ccl.northwestern.edu/netlogo/models/Doppler. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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
    <exitCondition>ticks = 1000</exitCondition>
    <metric>into-lake</metric>
    <metric>count normals</metric>
    <metric>count bigheads</metric>
    <metric>;short simulations with steady states</metric>
    <metric>;reasonable values with trials to pick one set of values - results for all the parameters</metric>
    <metric>; long runs match short runs, make a qualitative states</metric>
    <metric>; short runs give same steady state over span of values</metric>
    <metric>; look for long term behavior types</metric>
    <metric>; look for bigh predicted behvavior</metric>
    <metric>; don't use excel</metric>
    <enumeratedValueSet variable="Number-of-Normals">
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Show-Amplitudes?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detritus-grow-rate">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plankton-grow-rate">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="str-of-wave">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-threshold">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number-of-Bigheads">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count bigheads</metric>
    <metric>count normals</metric>
    <metric>into-lake</metric>
    <enumeratedValueSet variable="Number-of-Bigheads">
      <value value="200"/>
    </enumeratedValueSet>
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
