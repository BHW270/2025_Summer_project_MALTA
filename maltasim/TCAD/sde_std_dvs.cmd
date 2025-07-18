;##################################################################################################################################
;##STD SINGLE DIODE GAUSS GEOMETRY##
;##################################################################################################################################


(sde:clear)
(sdegeo:set-default-boolean "ABA")
(sde:set-process-up-direction "+z")

;##################################################################################################################################
;## Parameter Definitions (from Workbench or script) ##
;##################################################################################################################################

(define p_minus_doping @p_minus@) ; P- substrate doping
(define n_minus_doping @n_minus@) ; N- blanket and octagon doping
(define n_plus_doping @n_plus@)   ; N+ peak doping in octagon center
(define central_gap @central_gap@) ; Diode center-to-center spacing
(define block_gap @block_gap@)     ; Gap between N- regions
(define p_well_depth @p_well_depth@)
(define p_well_doping @p_well_doping@)
(define block_width (- central_gap block_gap))
(define copper_height (/ (+ (+ block_width block_width) block_gap) 2))
(define nwell_width @nwell_width@)
(define n_minus_radius 5) ;should be changed to a node
(define n_plus_radius 3)
(define n_plus_depth 2)
; Derived constants
(define substrate_height 95)
(define n_blanket_thickness 5)
(define n_blanket_top (+ substrate_height n_blanket_thickness))
(define n_oct_radius 3.5)
(define nplus_radius 1.5)
(define nplus_gaussian_depth 2)
(define metal_thickness 0.05) ; Copper thickness = oxide thickness

;##################################################################################################################################
;## Copper Back Plate (Ground) ##
;##################################################################################################################################

(sdegeo:create-cuboid 
  (position 0 0 -1) 
  (position copper_height copper_height 0) 
  "Copper" "backplate")

;##################################################################################################################################
;## Geometry Construction ##
;##################################################################################################################################

; P- substrate
(sdegeo:create-cuboid (position 0 0 0) (position copper_height copper_height substrate_height) "Silicon" "p_minus_region")

; N- blanket layer across entire top (overwritten by octagons)
(sdegeo:create-cuboid (position 0 0 substrate_height) (position copper_height copper_height n_blanket_top) "Silicon" "n_minus_region")

;Very top P+ blanket 
(sdegeo:create-cuboid (position 0 0 (- n_blanket_top p_well_depth)) (position copper_height copper_height n_blanket_top) "Silicon" "p_well_region")

;Super thin silicon dioxide layerTop
(sdegeo:create-cuboid (position 0 0 n_blanket_top) (position copper_height copper_height (+ n_blanket_top 0.05)) "Oxide" "oxide_region")

; Create and extrude an octagon (utility)
(define (create-octagon center-x center-y z-pos radius material region-name extrude-height)
  (let ((oct-vertices
         (list
           (position (+ center-x radius) center-y z-pos)
           (position (+ center-x (* radius 0.7071)) (+ center-y (* radius 0.7071)) z-pos)
           (position center-x (+ center-y radius) z-pos)
           (position (+ center-x (* radius -0.7071)) (+ center-y (* radius 0.7071)) z-pos)
           (position (- center-x radius) center-y z-pos)
           (position (+ center-x (* radius -0.7071)) (+ center-y (* radius -0.7071)) z-pos)
           (position center-x (- center-y radius) z-pos)
           (position (+ center-x (* radius 0.7071)) (+ center-y (* radius -0.7071)) z-pos))))
    (sdegeo:create-polygon oct-vertices material region-name)
    (if (not (= extrude-height 0))
        (sdegeo:extrude (find-face-id (position center-x center-y z-pos)) extrude-height))))
        
; Fetch octagon vertexes
(define (octagon-vertexes center-x center-y z-pos radius depth)
          (list
            (position (+ center-x radius) center-y z-pos)
            (position (+ center-x (* radius 0.7071)) (+ center-y (* radius 0.7071)) z-pos)
            (position center-x (+ center-y radius) z-pos)
            (position (+ center-x (* radius -0.7071)) (+ center-y (* radius 0.7071)) z-pos)
            (position (- center-x radius) center-y z-pos)
            (position (+ center-x (* radius -0.7071)) (+ center-y (* radius -0.7071)) z-pos)
            (position center-x (- center-y radius) z-pos)
            (position (+ center-x (* radius 0.7071)) (+ center-y (* radius -0.7071)) z-pos)
            (position (+ center-x radius) center-y z-pos)
            
            (position (+ center-x radius) center-y (- z-pos depth))
            (position (+ center-x (* radius 0.7071)) (+ center-y (* radius 0.7071)) (- z-pos depth))
            (position center-x (+ center-y radius) z-pos)
            (position (+ center-x (* radius -0.7071)) (+ center-y (* radius 0.7071)) (- z-pos depth))
            (position (- center-x radius) center-y z-pos)
            (position (+ center-x (* radius -0.7071)) (+ center-y (* radius -0.7071)) (- z-pos depth))
            (position center-x (- center-y radius) z-pos)
            (position (+ center-x (* radius 0.7071)) (+ center-y (* radius -0.7071)) (- z-pos depth))
            (position (+ center-x radius) center-y z-pos)
            ))


; Create the N- openings, needs to be done for all 4 (use unique region names per instance)
(create-octagon  (/ copper_height 2 ) (/ copper_height 2 ) substrate_height n_minus_radius "Silicon" "n_minus_opening_1" n_blanket_thickness)
;(create-octagon  (/ copper_height 4 ) (* copper_height (/ 3 4) ) substrate_height n_minus_radius "Silicon" "n_minus_opening_2" n_blanket_thickness)
;(create-octagon  (* copper_height (/ 3 4) ) (* copper_height (/ 3 4) ) substrate_height n_minus_radius "Silicon" "n_minus_opening_3" n_blanket_thickness)
;(create-octagon  (* copper_height (/ 3 4) ) (/ copper_height 4 ) substrate_height n_minus_radius "Silicon" "n_minus_opening_4" n_blanket_thickness)

; Create N++ wells, each well has a dummy below and true region above, all with unique names, each dummy should be N- 
(create-octagon (/ copper_height 2 ) (/ copper_height 2 ) substrate_height n_plus_radius "Silicon" "n_minus_dummy_1" (- n_blanket_thickness n_plus_depth))
(create-octagon (/ copper_height 2 ) (/ copper_height 2 ) (- n_blanket_top n_plus_depth) n_plus_radius "Silicon" "n_plus_region_1" n_plus_depth)

;(create-octagon (/ copper_height 4 ) (* copper_height (/ 3 4) ) substrate_height n_plus_radius "Silicon" "n_minus_dummy_2" (- n_blanket_thickness n_plus_depth))
;(create-octagon (/ copper_height 4 ) (* copper_height (/ 3 4) ) (- n_blanket_top n_plus_depth) n_plus_radius "Silicon" "n_plus_region_2" n_plus_depth)

;(create-octagon (* copper_height (/ 3 4) ) (* copper_height (/ 3 4) ) substrate_height n_plus_radius "Silicon" "n_minus_dummy_3" (- n_blanket_thickness n_plus_depth))
;(create-octagon (* copper_height (/ 3 4) ) (* copper_height (/ 3 4) ) (- n_blanket_top n_plus_depth) n_plus_radius "Silicon" "n_plus_region_3" n_plus_depth)

;(create-octagon (* copper_height (/ 3 4) ) (/ copper_height 4 ) substrate_height n_plus_radius "Silicon" "n_minus_dummy_4" (- n_blanket_thickness n_plus_depth))
;(create-octagon (* copper_height (/ 3 4) ) (/ copper_height 4 ) (- n_blanket_top n_plus_depth) n_plus_radius "Silicon" "n_plus_region_4" n_plus_depth)


;Place copper octagons on top of the N++ wells 
(create-octagon (/ copper_height 2 ) (/ copper_height 2 ) (- n_blanket_top 0.05) n_plus_radius "Copper" "n_copper_1" 1)
;(create-octagon (/ copper_height 4 ) (* copper_height (/ 3 4) ) (- n_blanket_top 0.05)  n_plus_radius "Copper" "n_copper_2" 1)
;(create-octagon (* copper_height (/ 3 4) ) (* copper_height (/ 3 4)) (- n_blanket_top 0.05) n_plus_radius "Copper" "n_copper_3" 1)
;(create-octagon (* copper_height (/ 3 4) ) (/ copper_height 4 ) (- n_blanket_top 0.05)  n_plus_radius "Copper" "n_copper_4" 1)

;Place copper octagon at centre of the P blanket
(create-octagon (/ copper_height 2) (/ copper_height 2) n_blanket_top n_plus_radius "Copper" "p_copper_1" 1)
;##################################################################################################################################
;## Doping Definitions and Assignments ##
;##################################################################################################################################

;N- Blanket
(sdedr:define-gaussian-profile "n_blanket_gauss_profile"
  "PhosphorusActiveConcentration"
   "PeakPos" 0
  "PeakVal" n_minus_doping
  "Depth" 3
  "ValueAtDepth" (* 0.7 n_minus_doping)                          ; ← sets vertical spread [μm]
  "Gauss" "Factor" 0.7)                    			  ;These values are close to ideal     

(sdedr:define-refeval-window "n_blanket_window" "Rectangle"
  (position 0 0 100) 
  (position copper_height copper_height 100))

  
(sdedr:define-refeval-window "n_opening_window" "Polygon"
  (octagon-vertexes (/ copper_height 2) (/ copper_height 2) (+ substrate_height 5) 5 2)
)

	

;Opening
(sdedr:define-gaussian-profile "n_opening_gauss_profile"
  "PhosphorusActiveConcentration"
  "PeakPos" 0
  "PeakVal" (+ n_minus_doping p_well_doping)
  "Depth" p_well_depth
  "ValueAtDepth" (* 0.01 n_minus_doping)                          ; ← sets vertical spread [μm]
  "Gauss" "Factor" 0.01)    


;N+ Wells
(sdedr:define-refeval-window "n_plus_window_1" "Line"
  (position (/ copper_height 2) (/ copper_height 2) n_blanket_top)  ; Top of N+ region
  (position (/ copper_height 2) (/ copper_height 2) (- n_blanket_top n_plus_depth))  ; Bottom of N+ region
)

(sdedr:define-gaussian-profile "n_plus_gauss_profile"
  "PhosphorusActiveConcentration"
   "PeakPos" 0
  "PeakVal" n_plus_doping
  "StdDev" 0.8                          ; ← sets vertical spread [μm]
  "Gauss" "Factor" 0.4)               ;These values are close to ideal     



;P blanket
(sdedr:define-gaussian-profile "p_blanket_gauss_profile"
  "BoronActiveConcentration"
  "PeakPos" 0
  ;"PeakVal" 
  "PeakVal" p_well_doping
  "ValueAtDepth" (* p_well_doping 0.00001)
  "Depth" p_well_depth                          ; ← sets vertical spread [μm]
  "Gauss" "Factor" 0.001)                       ;These values are close to ideal   

(sdedr:define-refeval-window "p_blanket_window" "Rectangle"
  (position 0 0 100) 
  (position copper_height copper_height 100))

;Substrate
(sdedr:define-constant-profile "p_minus_profile" "BoronActiveConcentration" p_minus_doping)
(sdedr:define-constant-profile-region "p_minus_placement" "p_minus_profile" "p_minus_region")


(sdedr:define-analytical-profile-placement "n_minus_placement" "n_blanket_gauss_profile" "n_blanket_window" "Both" "NoRelpace" "Eval")  ;N- Placement
(sdedr:define-analytical-profile-placement "p_well_placement" "p_blanket_gauss_profile" "p_blanket_window" "Both" "NoRelpace" "Eval")	 ;P_blanket
(sdedr:define-analytical-profile-placement "n_plus_placement_1" "n_plus_gauss_profile" "n_plus_window_1" "Both" "NoRelpace" "Eval")      ;N+ well
(sdedr:define-analytical-profile-placement "n_opening_placement" "n_opening_gauss_profile" "n_opening_window" "Both" "Relpace" "Eval") ;N- opening 

;##################################################################################################################################
;## Ground Contact (Bottom Copper Plate) ##
;##################################################################################################################################

(sdegeo:define-contact-set "ground_contact" 1 (color:rgb 0 0 1) "##")
(sdegeo:set-current-contact-set "ground_contact")
(sdegeo:define-3d-contact 
  (list (car (find-face-id (position (/ copper_height 2) (/ copper_height 2) -1))))
  "ground_contact")

;##################################################################################################################################
;## Top Electrical Contacts on Copper ##
;##################################################################################################################################

(sdegeo:define-contact-set "n_contact" 2 (color:rgb 1 0 0) "##")
(sdegeo:set-current-contact-set "n_contact")

;(sdegeo:define-3d-contact 
;  (list (car (find-face-id (position (/ copper_height 2) (/ copper_height 2) (+ n_blanket_top 0.95)))))
;  "n_contact1")
  
  
;x 19   y 19  z 101  
(sdegeo:set-contact
  (find-face-id (position 19 19 101))
  "n_contact_1")

    
;(sdegeo:define-3d-contact 
;  (list (car (find-face-id (position (/ copper_height 4) (* copper_height (/ 3 4)) (+ n_blanket_top 0.95)))))
;  "n_contact2")
;(sdegeo:define-3d-contact 
;  (list (car (find-face-id (position (* copper_height (/ 3 4)) (* copper_height (/ 3 4)) (+ n_blanket_top 0.95)))))
;  "n_contact3")
;(sdegeo:define-3d-contact 
;  (list (car (find-face-id (position (* copper_height (/ 3 4)) (/ copper_height 4) (+ n_blanket_top 0.95)))))
;  "n_contact4")

;(sdegeo:define-contact-set "p_contact" 3 (color:rgb 0 1 0) "##")
;(sdegeo:set-current-contact-set "p_contact")

;(sdegeo:define-3d-contact 
;  (list (car (find-face-id (position (/ copper_height 2) (/ copper_height 2) (+ n_blanket_top 1)))))
;  "p_contact")


;##################################################################################################################################
;## Mesh (Optional, coarse for full structure) ##
;##################################################################################################################################

;BULK MESH
; Coarse mesh in the deep substrate (bulk P- region)
(sdedr:define-refinement-window "bulk_RW" "Cuboid"
  (position 0 0 0)
  (position copper_height copper_height substrate_height))
(sdedr:define-refinement-size "bulk_RS" 25 25 25 10 10 10)
(sdedr:define-refinement-placement "bulk_PL" "bulk_RS" "bulk_RW")

;DIODE MESHING   Apply to the P--N-
(sdedr:define-refinement-window "rw_bl" "Cuboid"
  (position 0 0 94)
  (position copper_height copper_height 97))
(sdedr:define-refinement-size "rs_bl" 0.4 0.4 0.4 0.1 0.1 0.1)
(sdedr:define-refinement-placement "pl_bl" "rs_bl" "rw_bl")

;Apply Strict meshing around N+
(sdedr:define-refinement-window "rw_nw" "Cuboid"
  (position 14 14 101.5)
  (position 21 21 94))
(sdedr:define-refinement-size "rs_nw" 0.4 0.4 0.4 0.1 0.1 0.1)
(sdedr:define-refinement-placement "pl_nw" "rs_nw" "rw_nw")


; Top-left diode
;(sdedr:define-refinement-window "rw_tl" "Cuboid"
;  (position 0 (+ (/ copper_height 2) (/ block_gap 2)) n_blanket_top)
;  (position (- (/ copper_height 2) (/ block_gap 2)) copper_height (+ n_blanket_top 1.05)))
;(sdedr:define-refinement-size "rs_tl" 0.4 0.4 0.4 0.1 0.1 0.1)
;(sdedr:define-refinement-placement "pl_tl" "rs_tl" "rw_tl")

; Top-right diode
;(sdedr:define-refinement-window "rw_tr" "Cuboid"
;  (position (+(/ copper_height 2) (/ block_gap 2)) (+(/ copper_height 2) (/ block_gap 2) ) n_blanket_top)
;  (position copper_height copper_height (+ n_blanket_top 1.05)))
;(sdedr:define-refinement-size "rs_tr" 0.4 0.4 0.4 0.1 0.1 0.1)
;(sdedr:define-refinement-placement "pl_tr" "rs_tr" "rw_tr")

; Bottom-right diode
;(sdedr:define-refinement-window "rw_br" "Cuboid"
;  (position (+ (/ copper_height 2) (/ block_gap 2)) 0 n_blanket_top)
;  (position copper_height (- (/ copper_height 2) (/ block_gap 2)) (+ n_blanket_top 1.05)))
;(sdedr:define-refinement-size "rs_br" 0.4 0.4 0.4 0.1 0.1 0.1)
;(sdedr:define-refinement-placement "pl_br" "rs_br" "rw_br")

(sde:build-mesh "snmesh" "-a -c boxmethod -r 2" "n@node@")
	
(display "Finished geometry and meshing for std sensor") (newline)

(sde:save-model "n@node@_std_sensor_sde")

