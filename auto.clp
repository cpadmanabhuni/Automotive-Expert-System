
;;;======================================================
;;;   Automotive Expert System
;;;
;;;     This expert system diagnoses some simple
;;;     problems with a car.
;;;
;;;     CLIPS Version 6.3 Example
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then yes 
       else no))


;;;***************
;;;* QUERY RULES *
;;;***************


(defrule determine-problem-type ""
   (not (problem-type ?))
   (not (repair ?))
   =>
   (assert (problem-type
      (ask-question "What is the problem type (engine/tyres/dent/headlight/brake)? "
                    engine tyres dent headlight brake))))


;;;*************************
;;;* QUERY RULES FOR ENGINE*
;;;*************************


(defrule determine-engine-state ""
   (problem-type engine)
   (not (engine-starts ?))
   (not (repair ?))
   =>
   (assert (engine-starts (yes-or-no-p "Does the engine start (yes/no)? "))))
   
(defrule determine-runs-normally ""
   (problem-type engine)
   (engine-starts yes)
   (not (repair ?))
   =>
   (assert (runs-normally (yes-or-no-p "Does the engine run normally (yes/no)? "))))

(defrule determine-rotation-state ""
   (problem-type engine)
   (engine-starts no)
   (not (repair ?))   
   =>
   (assert (engine-rotates (yes-or-no-p "Does the engine rotate (yes/no)? "))))
   
(defrule determine-sluggishness ""
   (problem-type engine)
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-sluggish (yes-or-no-p "Is the engine sluggish (yes/no)? "))))
   
(defrule determine-misfiring ""
   (problem-type engine)
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-misfires (yes-or-no-p "Does the engine misfire (yes/no)? "))))

(defrule determine-knocking ""
   (problem-type engine)
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-knocks (yes-or-no-p "Does the engine knock (yes/no)? "))))

(defrule determine-low-output ""
   (problem-type engine)
   (runs-normally no)
   (not (repair ?))
   =>
   (assert (engine-output-low
               (yes-or-no-p "Is the output of the engine low (yes/no)? "))))

(defrule determine-gas-level ""
   (problem-type engine)
   (engine-starts no)
   (engine-rotates yes)
   (not (repair ?))
   =>
   (assert (tank-has-gas
              (yes-or-no-p "Does the tank have any gas in it (yes/no)? "))))

(defrule determine-battery-state ""
   (problem-type engine)
   (engine-rotates no)
   (not (repair ?))
   =>
   (assert (battery-has-charge
              (yes-or-no-p "Is the battery charged (yes/no)? "))))

(defrule determine-point-surface-state ""
   (problem-type engine)
   (or (and (engine-starts no)      
            (engine-rotates yes))
       (engine-output-low yes))
   (not (repair ?))
   =>
   (assert (point-surface-state
      (ask-question "What is the surface state of the points (normal/burned/contaminated)? "
                    normal burned contaminated))))

(defrule determine-conductivity-test ""
   (problem-type engine)
   (engine-starts no)      
   (engine-rotates no)
   (battery-has-charge yes)
   (not (repair ?))
   =>
   (assert (conductivity-test-positive
              (yes-or-no-p "Is the conductivity test for the ignition coil positive (yes/no)? "))))
              
              
;;;*************************
;;;* QUERY RULES FOR TYRES *
;;;*************************


(defrule determine-tyre-state ""
   (problem-type tyres)
   (not (tyre-inflated ?))
   (not (repair ?))
   =>
   (assert (tyres-inflated (yes-or-no-p "Are the tyres inflated (yes/no)? "))))
   
(defrule determine-check-puncture ""
   (problem-type tyres)
   (tyres-inflated no)
   (not (repair ?))
   =>
   (assert (tyres-puncture (yes-or-no-p "Are the tyres punctured (yes/no)? "))))
   
(defrule determine-check-alignment ""
   (problem-type tyres)
   (tyres-inflated yes)
   (not (repair ?))
   =>
   (assert (tyres-alignment (yes-or-no-p "Are the tyres aligned (yes/no)? "))))
   
(defrule determine-check-movement ""
   (problem-type tyres)
   (tyres-inflated yes)
   (tyres-alignment yes)
   (not (repair ?))
   =>
   (assert (tyres-movement (yes-or-no-p "Are the tyres moving freely (yes/no)? "))))
   
(defrule determine-check-vibration ""
   (problem-type tyres)
   (tyres-inflated yes)
   (tyres-alignment yes)
   (tyres-movement yes)
   (not (repair ?))
   =>
   (assert (tyres-vibration (yes-or-no-p "Are the tyres vibrating (yes/no)? "))))
   
 
(defrule determine-check-mud ""
   (problem-type tyres)
   (tyres-inflated yes)
   (tyres-alignment yes)
   (tyres-movement yes)
   (tyres-vibration yes)
   (not (repair ?))
   =>
   (assert (tyres-mud-present (yes-or-no-p "Is mud or dirt present in rims (yes/no)? "))))
   
(defrule determine-check-tyre-noise ""
   (problem-type tyres)
   (tyres-inflated yes)
   (tyres-alignment yes)
   (tyres-movement yes)
   (tyres-vibration yes)
   (tyres-mud-present no)
   (not (repair ?))
   =>
   (assert (tyres-noise-present (yes-or-no-p "Is there excessive play or noise from the wheel bearings (yes/no)? "))))



;;;*****************************
;;;* QUERY RULES FOR HEADLIGHT *
;;;*****************************



(defrule determine-headlight-type ""
   (problem-type headlight)
   (not (headlight-type ?))
   (not (repair ?))
   =>
   (assert (headlight-type
      (ask-question "Is the headlight (fluctuating/dim/always_off)? "
                    fluctuating dim always_off))))
   
(defrule determine-check-alternator ""
   (problem-type headlight)
   (headlight-type fluctuating)
   (not (repair ?))
   =>
   (assert (headlight-connections-tight (yes-or-no-p "Are the connections tight (yes/no)? "))))
   
(defrule determine-dim-type ""
   (problem-type headlight)
   (headlight-type dim)
   (not (repair ?))
   =>
   (assert (dim-type
      (ask-question "Is the headlight always dim or when something like AC is turned ON (always/not_always)? "
                    always not_always))))
   
(defrule determine-alternator ""
   (problem-type headlight)
   (headlight-type dim)
   (dim-type not_always)
   (not (repair ?))
   =>
   (assert (check-alternator (yes-or-no-p "Is the alternator old (yes/no)? "))))
   
   
   
;;;**************************
;;;* QUERY RULES FOR BRAKES *
;;;**************************


(defrule determine-hard-brake ""
   (problem-type brake)
   (not (hard-brake ?))
   (not (repair ?))
   =>
   (assert (hard-brake (yes-or-no-p "Are the brake pedals hard (yes/no)? "))))
   
(defrule determine-car-unused ""
   (problem-type brake)
   (hard-brake yes)
   (not (repair ?))
   =>
   (assert (brake-car-unused (yes-or-no-p "Has the car been unused for a long time (yes/no)? "))))
   
(defrule determine-brake-squishy ""
   (problem-type brake)
   (hard-brake no)
   (not (repair ?))
   =>
   (assert (brake-squishy (yes-or-no-p "Does the brake pedal feels Squishy (yes/no)? "))))
   
(defrule determine-brake-master-cylinder ""
   (problem-type brake)
   (hard-brake no)
   (brake-squishy yes)
   (not (repair ?))
   =>
   (assert (brake-master-cylinder (yes-or-no-p "Is there a sign of leakage of fluid in the master cylinder (yes/no)? "))))
   
(defrule determine-brake-side-pull ""
   (problem-type brake)
   (hard-brake no)
   (brake-squishy no)
   (not (repair ?))
   =>
   (assert (brake-side-pull (yes-or-no-p "Does the car pulls to one side when braking (yes/no)? "))))
  
(defrule determine-brake-pedal-pulse ""
   (problem-type brake)
   (hard-brake no)
   (brake-squishy no)
   (brake-side-pull no)
   (not (repair ?))
   =>
   (assert (brake-pedal-pulse (yes-or-no-p "Does the brake pedal pulses Up/Down (yes/no)? "))))
   
(defrule determine-rotor-status ""
   (problem-type brake)
   (hard-brake no)
   (brake-squishy no)
   (brake-side-pull no)
   (brake-pedal-pulse yes)
   (not (repair ?))
   =>
   (assert (brake-rotors-thick (yes-or-no-p "Are the rotors still thick (yes/no)? "))))
   
   
;;;*******************************************
;;;* QUERY RULES FOR STEERING AND SUSPENSION *
;;;*******************************************





;;;***************************
;;;* REPAIR RULES FOR ENGINE *
;;;***************************


(defrule normal-engine-state-conclusions ""
   (problem-type engine)
   (runs-normally yes)
   (not (repair ?))
   =>
   (assert (repair "No repair needed.")))

(defrule engine-sluggish ""
   (problem-type engine)
   (engine-sluggish yes)
   (not (repair ?))
   =>
   (assert (repair "Clean the fuel line."))) 

(defrule engine-misfires ""
   (problem-type engine)
   (engine-misfires yes)
   (not (repair ?))
   =>
   (assert (repair "Point gap adjustment.")))     

(defrule engine-knocks ""
   (problem-type engine)
   (engine-knocks yes)
   (not (repair ?))
   =>
   (assert (repair "Timing adjustment.")))

(defrule tank-out-of-gas ""
   (problem-type engine)
   (tank-has-gas no)
   (not (repair ?))
   =>
   (assert (repair "Add gas.")))

(defrule battery-dead ""
   (problem-type engine)
   (battery-has-charge no)
   (not (repair ?))
   =>
   (assert (repair "Charge the battery.")))

(defrule point-surface-state-burned ""
   (problem-type engine)
   (point-surface-state burned)
   (not (repair ?))
   =>
   (assert (repair "Replace the points.")))

(defrule point-surface-state-contaminated ""
   (problem-type engine)
   (point-surface-state contaminated)
   (not (repair ?))
   =>
   (assert (repair "Clean the points.")))

(defrule conductivity-test-positive-yes ""
   (problem-type engine)
   (conductivity-test-positive yes)
   (not (repair ?))
   =>
   (assert (repair "Repair the distributor lead wire.")))

(defrule conductivity-test-positive-no ""
   (problem-type engine)
   (conductivity-test-positive no)
   (not (repair ?))
   =>
   (assert (repair "Replace the ignition coil.")))
   
   
;;;***************************
;;;* REPAIR RULES FOR TYRES  *
;;;***************************

(defrule normal-tyre-state-conclusions ""
   (problem-type tyres)
   (tyres-inflated yes)
   (tyres-alignment yes)
   (tyres-movement yes)
   (tyres-vibration no)
   (not (repair ?))
   =>
   (assert (repair "No repair needed.")))

   
(defrule tyres-punctured-yes ""
   (problem-type tyres)
   (tyres-puncture yes)
   (not (repair ?))
   =>
   (assert (repair "Get Punctured Repaired.")))
   
   
(defrule tyres-punctured-no ""
   (problem-type tyres)
   (tyres-puncture no)
   (not (repair ?))
   =>
   (assert (repair "Get Tyres Inflated.")))

(defrule tyres-aligned-no ""
   (problem-type tyres)
   (tyres-aligned no)
   (not (repair ?))
   =>
   (assert (repair "Get Tyres Aligned.")))
   
(defrule tyres-movement-no ""
   (problem-type tyres)
   (tyres-movement no)
   (not (repair ?))
   =>
   (assert (repair "Apply oil in the axle.")))
   
(defrule tyres-mud-yes ""
   (problem-type tyres)
   (tyres-mud-present yes)
   (not (repair ?))
   =>
   (assert (repair "Clean mud or dirt packed in the back of the rim.")))
   
(defrule tyres-noise-yes ""
   (problem-type tyres)
   (tyres-noise-present yes)
   (not (repair ?))
   =>
   (assert (repair "Change Loose, worn or damaged wheel bearings.")))
   
   
;;;*******************************
;;;* REPAIR RULES FOR HEADLIGHTS *
;;;*******************************


(defrule headlight-connection-tight ""
   (problem-type headlight)
   (headlight-type fluctuating)
   (headlight-connections-tight yes)
   (not (repair ?))
   =>
   (assert (repair "Disconnect the battery and clean all contact points using a anti corossion liquid."))) 

(defrule headlight-fix-loose-connections ""
   (problem-type headlight)
   (headlight-type fluctuating)
   (headlight-connections-tight no)
   (not (repair ?))
   =>
   (assert (repair "Fix all loose connections.")))     

(defrule headlight-replace-bulb ""
   (problem-type headlight)
   (headlight-type dim)
   (dim-type always)
   (not (repair ?))
   =>
   (assert (repair "Replace the bulb.")))
   
(defrule replace-alternator ""
   (problem-type headlight)
   (headlight-type dim)
   (dim-type not_always)
   (check-alternator yes)
   (not (repair ?))
   =>
   (assert (repair "Replace alternator with high amperage.")))

(defrule repair-alternator ""
   (problem-type headlight)
   (headlight-type dim)
   (dim-type not_always)
   (check-alternator no)
   (not (repair ?))
   =>
   (assert (repair "Repair alternator.")))

(defrule repair-connector ""
   (problem-type headlight)
   (headlight-type always_off)
   (not (repair ?))
   =>
   (assert (repair "Inspect the electrical connector on back. If corroded, remove corrosion. Else replace connector.")))
   
   
;;;*******************************
;;;* REPAIR RULES FOR BRAKES     *
;;;*******************************


(defrule brake-car-unused-yes ""
   (problem-type brake)
   (hard-brake yes)
   (brake-car-unused yes)
   (not (repair ?))
   =>
   (assert (repair "Check for rusting near pedals."))) 
   
(defrule brake-car-unused-no ""
   (problem-type brake)
   (hard-brake yes)
   (brake-car-unused no)
   (not (repair ?))
   =>
   (assert (repair "Leaky vaccum or defective brake booster."))) 
   
(defrule brake-master-leakage-yes ""
   (problem-type brake)
   (brake-squishy yes)
   (brake-master-cylinder yes)
   (not (repair ?))
   =>
   (assert (repair "Fix the leakage."))) 

(defrule brake-master-leakage-no ""
   (problem-type brake)
   (brake-squishy yes)
   (brake-master-cylinder no)
   (not (repair ?))
   =>
   (assert (repair "Check for internal damamge. Replace the cylinder")))
   
(defrule brake-car-pull-yes ""
   (problem-type brake)
   (brake-side-pull yes)
   (not (repair ?))
   =>
   (assert (repair "Possibility of frozen caliper.")))  
   
(defrule brake-rotors-thick-yes ""
   (problem-type brake)
   (brake-rotors-thick yes)
   (not (repair ?))
   =>
   (assert (repair "Resurface Rotors.")))  
   
(defrule brake-rotors-thick-no ""
   (problem-type brake)
   (brake-rotors-thick no)
   (not (repair ?))
   =>
   (assert (repair "Replace the pads.")))  


;;;******************************
;;;* REPAIRS NOT MENTIONED      *
;;;******************************
   

(defrule no-repairs ""
  (declare (salience -10))
  (not (repair ?))
  =>
  (assert (repair "Take your car to a mechanic.")))

;;;********************************
;;;* STARTUP AND CONCLUSION RULES *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "The Engine Diagnosis Expert System")
  (printout t crlf crlf))

(defrule print-repair ""
  (declare (salience 10))
  (repair ?item)
  =>
  (printout t crlf crlf)
  (printout t "Suggested Repair:")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?item))

