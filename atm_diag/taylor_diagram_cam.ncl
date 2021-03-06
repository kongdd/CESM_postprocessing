function taylor_diagram_cam  (wks:graphic \
                             ,RATIO[*][*]:numeric \
                             ,   CC[*][*]:numeric \
                             , BIAS[*][*]:numeric \
                             ,rOpts:logical)
;--------------------------------------------------------------------
; This version of taylor_diagram supports "paneling"
; It requires NCL version 4.2.0.a034 because it uses "gsn_create_legend"
;--------------------------------------------------------------------
;
; Generate a Taylor Diagram:
; Generate Multiple Aspects of Model Performance in a Single Diagram
; Taylor, K. E., J. Geophys. Res., 106, D7, 7183-7192, 2001
;
; An example:
; http://www.grida.no/climate/ipcc_tar/wg1/fig8-4.htm
;
; This expects one or more datasets. The left dimension 
; is the number of datasets. The rightmost is the number of pts.
;
; Markers are at: 
; http://www.ncl.ucar.edu/Document/Graphics/Resources/gs.shtml
;
; By default, the function can handle up to 10 variable comparisons..
; To expand ...  modify the 'Colors' and 'Markers' attributes.
; The user can change / add some default settings.
;
; The defaults that the user can modify:
;
; rOpts                 = True 
;                                  ; 'made-up' resources
; rOpts@Colors          =  (/ "blue"  , "red", "green", "cyan", "black" \
;                           , "purple", "brown", "yellow"/)
; rOpts@Markers         =  (/ 2, 3, 6, 14, 9, 12, 7, 4/) ; Marker Indices
; rOpts@markerTxOffset  = 0.0175   ; offset for text above marker
; rOpts@stnRad          = (/ 1. /) ;  (/ 0.50, 0.75, 1.5 /) 
; rOpts@centerDiffRMS   = False    ;  True mean draw additional radii from REF 
; rOpts@caseLabelsFontHeightF = 0.05
; rOpts@varLabelsFontHeightF  = 0.013
; rOpts@varLabelsYloc         = 0.65
; rOpts@caseLabelsXYloc       = (/ 0.70, 0.80 /)
; rOpts@legendWidth           = 0.015
; rOpts@legendHeight          = 0.030*nCase
; rOpts@taylorDraw            = True
; rOpts@taylorFrame           = True
;
;                                  ; standard NCL resources
; rOpts@tiMainString    = "Taylor" ; not using title makes plot bigger
; rOpts@gsMarkerSizeF   = 0.0085   ; marker size   
; rOpts@gsMarkerThicknessF = 1.0
; rOpts@txFontHeightF   = 0.0125   ; text size 
; rOpts@tiMainFontHeightF = 0.0225 ; tiMainString size
;
; It returns to the user a graphic object containing the 
; Taylor background and plotted x/y pts.
; This graphic object contains a simple Taylor background appropriate
; for standardized data and the markers for the datasets.
; ==================================================================
; This version allows paneling:
;      The 'cumbersome' "dum" variables were added by 
;      Adam Phillips to allow paneling via "gsn_add_?".
; ==================================================================
begin
  dimR                  = dimsizes(RATIO)
  nCase                 = dimR(0)    ; # of cases [models] 
  nVar                  = dimR(1)    ; # of variables
  
                                     ; x/y coordinates for plotting
  X    = new ( (/nCase,nVar/) , typeof(RATIO) )
  Y    = new ( (/nCase,nVar/) , typeof(RATIO) )

  do nc=0,nCase-1
     angle      = acos( CC(nc,:) )   ; array operation                                    
     X(nc,:)    = RATIO(nc,:)*cos( angle )     
     Y(nc,:)    = RATIO(nc,:)*sin( angle )    
  end do

  xyMin                 = 0.  
  xyOne                 = 1.00
  xyMax                 = 1.65
  xyMax_Panel           = xyMax+ 0.10            ; paneling purposes
 
  if (rOpts .and. isatt(rOpts,"txFontHeightF"))  then 
      FontHeightF       = rOpts@txFontHeightF    ; user wants to specify size
  else
      FontHeightF       = 0.0175
  end if
  
; ----------------------------------------------------------------
; Scan data for outliers. 
; Set a flag such that extra space will be allowed.
; ----------------------------------------------------------------
  if (any(CC.lt.0) .or. any(RATIO.gt.xyMax)) then
      outlier = True                             ; outliers present
  else
      outlier = False                            ; no outliers
  end if  
 
; ----------------------------------------------------------------
; Part 1:
; base plot: Based upon request of Mark Stevens
; basic x-y and draw the 1.0 observed and the outer curve at 1.65
; ----------------------------------------------------------------

 ;print("============> taylor_diagram: Part 1 ")
  
  rxy                   = True       
  rxy@gsnDraw           = False
  rxy@gsnFrame          = False
  if (outlier) then
     rxy@vpYF           = 0.90
     scntr              = 0
  else
     rxy@vpYF           = 0.80
  end if
  rxy@vpHeightF         = 0.65
  rxy@vpWidthF          = 0.65  
  rxy@tmYLBorderOn      = False
  rxy@tmXBBorderOn      = False
  rxy@gsnTickMarksPointOutward = False  ; "hidden" resource

  rxy@tiYAxisString     = "Standardized Deviations (Normalized)"
  rxy@tiYAxisFontHeightF= FontHeightF                        ; default=0.025 
  
  rxy@tmXBMode          = "Explicit" 
  rxy@tmXBValues        = (/0.0,0.25,0.50,0.75,1.00,1.25,1.5/)    ; major tm
                                                                  ; default  "OBS" or "REF"
 ;rxy@tmXBLabels        = (/"0.00","0.25","0.50","0.75","REF" ,"1.25","1.50"/)
  rxy@tmXBLabels        = (/"    ","0.25","0.50","0.75","REF" ,"1.25","1.50"/)
  if (rOpts .and. isatt(rOpts,"OneX") )  then                     ; eg: rOpts@OneX="1.00" 
     ;rxy@tmXBLabels        = (/"0.00","0.25","0.50","0.75",rOpts@OneX,"1.25","1.50"/)
      rxy@tmXBLabels        = (/"    ","0.25","0.50","0.75",rOpts@OneX,"1.25","1.50"/)
  end if

  rxy@tmXBMajorLengthF  = 0.015      ; default=0.02 for a vpHeightF=0.6
  rxy@tmXBLabelFontHeightF = FontHeightF
  rxy@tmXBMinorOn       = False
  rxy@trXMaxF           = xyMax_Panel

  rxy@tmYLMode          = "Manual"
  rxy@tmYLMinorOn       = False
  rxy@tmYLMajorLengthF  = rxy@tmXBMajorLengthF
  rxy@tmYLLabelFontHeightF = FontHeightF
  rxy@tmYLMode          = "Explicit" 
  rxy@tmYLValues        = (/0.0, .25,0.50, 0.75, 1.00, 1.25, 1.5/) ; major tm
  rxy@tmYLLabels        = (/"0.00","0.25","0.50","0.75","1.00","1.25","1.50"/)
 ;rxy@tmYLLabels        = (/"    ","0.25","0.50","0.75","1.00","1.25","1.50"/)
  rxy@trYMaxF           = xyMax_Panel

  rxy@tmYRBorderOn      = False
  rxy@tmYROn            = False      ; Turn off right tick marks.

  rxy@tmXTBorderOn      = False
  rxy@tmXTOn            = False      ; Turn off right tick marks.

  rxy@xyDashPatterns    = (/ 0 /)    ; line characteristics (dash,solid)
  rxy@xyLineThicknesses = (/ 2./)    ; choose line thickness

  rxy@gsnFrame          = False      ; Don't advance the frame.

                                            ; create outer 'correlation axis'
  npts    = 200                        ; arbitrary
  xx      = fspan(xyMin,xyMax,npts) 
  yy      = sqrt(xyMax^2 - xx^2    )   ; outer correlation line (xyMax)

  sLabels = (/"0.0","0.1","0.2","0.3","0.4","0.5","0.6" \ ; correlation labels
             ,"0.7","0.8","0.9","0.95","0.99","1.0"     /); also, major tm
  cLabels = stringtofloat(sLabels)
  rad     = 4.*atan(1.0)/180.
  angC    = acos(cLabels)/rad                     ; angles: correlation labels
                                                                       
  if (rOpts .and. isatt(rOpts,"tiMainString")) then
      rxy@tiMainString      = rOpts@tiMainString
     ;rxy@tiMainOffsetYF    = 0.015               ; default  0.0
      if (isatt(rOpts,"tiMainFontHeightF")) then
           rxy@tiMainFontHeightF = rOpts@tiMainFontHeightF
      else
           rxy@tiMainFontHeightF = 0.0225         ; default  0.025              
      end if
  end if
  if (rOpts .and. isatt(rOpts,"gsnCenterString")) then
      rxy@gsnCenterString  = rOpts@gsnCenterString      ; only gsn_csm_xy
      if (rOpts .and. isatt(rOpts,"gsnCenterStringFontHeightF")) then
          rxy@gsnCenterStringFontHeightF = rOpts@gsnCenterStringFontHeightF 
      end if
  end if

;;taylor  = gsn_xy(wks,xx,yy,rxy)                 ; Create and draw XY plot.
  taylor  = gsn_csm_xy(wks,xx,yy,rxy)             ; Create and draw XY plot.

  rsrRes  = True
  rsrRes@gsLineThicknessF  = rxy@xyLineThicknesses(0)  ; line thickness
  rsrRes@gsLineDashPattern = 0                    ; solid line pattern
                                                  ; draw x and y to xyMax
  dum0 = gsn_add_polyline(wks,taylor,(/0.,  0. /),(/0.,xyMax/), rsrRes)
  dum1 = gsn_add_polyline(wks,taylor,(/0.,xyMax/),(/0.,  0. /), rsrRes)

  xx   = fspan(xyMin, xyOne ,npts)                ; draw 1.0 standard radius
  yy   = sqrt(xyOne - xx^2)   
  rsrRes@gsLineDashPattern = 1                    ; dashed line pattern
  rsrRes@gsLineThicknessF  = rxy@xyLineThicknesses(0)  ; line thickness
  dum2 = gsn_add_polyline(wks,taylor,xx,yy, rsrRes)
  delete(xx)
  delete(yy)
                                                  
  if (rOpts .and. isatt(rOpts,"stnRad") ) then
      rsrRes@gsLineThicknessF  = 1   ; rxy@xyLineThicknesses(0)  
      nStnRad = dimsizes(rOpts@stnRad)

      dum3  = new(nStnRad,graphic)
      do n=0,nStnRad-1
         rr = rOpts@stnRad(n)
         xx = fspan(xyMin, rr ,npts) 
         yy = sqrt(rr^2   - xx^2)   
         dum3(n) = gsn_add_polyline(wks,taylor,xx,yy, rsrRes)
      end do
      taylor@$unique_string("dum")$ = dum3

      delete(xx)
      delete(yy)
  end if

  getvalues taylor                                ; get style info from taylor
    "tmYLLabelFont"        : tmYLLabelFont        ; use for correlation axis
    "tmYLLabelFontHeightF" : tmYLLabelFontHeightF
  end getvalues


; ----------------------------------------------------------------
; Part 2:
; Correlation labels
; ----------------------------------------------------------------

 ;print("============> taylor_diagram: Part 2 ")

  radC    = xyMax                                  ; for correlation labels
  xC      = radC*cos(angC*rad)
  yC      = radC*sin(angC*rad)
; added to get some separation
  xC      = xC + 0.020*cos(rad*angC)
  yC      = yC + 0.060*sin(rad*angC)

  txRes               = True                      ; text mods desired
  txRes@txFontHeightF = FontHeightF               ; match YL 
  txRes@tmYLLabelFont = tmYLLabelFont             ; match YL
  txRes@txAngleF      = -50.
  if (.not.isatt(rOpts,"drawCorLabel") .or. rOpts@drawCorLabel) then 
      dum4 = gsn_add_text(wks,taylor,"Correlation",1.40,1.20,txRes)
	 taylor@$unique_string("dum")$ = dum4
  end if
  txRes@txAngleF      = 0.0 
  txRes@txFontHeightF = FontHeightF*0.50          ; bit smaller

;;dum0 = gsn_add_text(wks,taylor,"OBSERVED",1.00,0.075,txRes)

  plRes               = True
  plRes@gsLineThicknessF = 2.
  
  txRes@txJust        = "CenterLeft"              ; Default="CenterCenter".
  txRes@txFontHeightF = FontHeightF               ; match YL 
 ;txRes@txBackgroundFillColor = "white"

  tmEnd = 0.975
  radTM = xyMax*tmEnd                             ; radius end: major TM 
  xTM   = new( 2 , "float")
  yTM   = new( 2 , "float")

  dum5 = new(dimsizes(sLabels),graphic)
  dum6 = dum5

  do i=0,dimsizes(sLabels)-1                      ; Loop to draw strings
    txRes@txAngleF = angC(i)
    dum5(i) = gsn_add_text(wks, taylor, sLabels(i),xC(i),yC(i),txRes) ; cor label
    xTM(0)   = xyMax*cos(angC(i)*rad)             ; major tickmarks at
    yTM(0)   = xyMax*sin(angC(i)*rad)             ; correlation labels
    xTM(1)   = radTM*cos(angC(i)*rad)             
    yTM(1)   = radTM*sin(angC(i)*rad)
    dum6(i) = gsn_add_polyline(wks,taylor,xTM,yTM,plRes)
  end do
                                                  ; minor tm locations
  mTM     = (/0.05,0.15,0.25,0.35,0.45,0.55,0.65 \ 
             ,0.75,0.85,0.91,0.92,0.93,0.94,0.96,0.97,0.98  /)
  angmTM  = acos(mTM)/rad                         ; angles: correlation labels
  radmTM  = xyMax*(1.-(1.-tmEnd)*0.5)             ; radius end: minor TM 

  dum7 = new(dimsizes(mTM),graphic)

  do i=0,dimsizes(mTM)-1                          ; manually add tm
    xTM(0)   = xyMax*cos(angmTM(i)*rad)           ; minor tickmarks
    yTM(0)   = xyMax*sin(angmTM(i)*rad)
    xTM(1)   = radmTM*cos(angmTM(i)*rad)          
    yTM(1)   = radmTM*sin(angmTM(i)*rad)
    dum7(i)  = gsn_add_polyline(wks,taylor,xTM,yTM,plRes)
  end do
                                                  ; added for Wanli
  if (rOpts .and. isatt(rOpts,"ccRays") ) then
      angRL = acos(rOpts@ccRays)/rad             ; angles: radial lines

      rlRes = True
      rlRes@xyDashPattern    = 4  ; line pattern
      rlRes@xyLineThicknessF = 1  ; choose line thickness

      dum8 = new(dimsizes(angRL),graphic)
      do i=0,dimsizes(angRL)-1
         xRL     = xyMax*cos(angRL(i)*rad)
         yRL     = xyMax*sin(angRL(i)*rad)
         dum8(i) = gsn_add_polyline(wks,taylor,(/0, xRL /),(/0,  yRL  /),rlRes)
      end do
      taylor@$unique_string("dum")$ = dum8
  end if
  
; ----------------------------------------------------------------
; Part 3:
; Concentric about 1.0 on XB axis
; I think this is correct. Still test mode.
; ----------------------------------------------------------------

 ;print("============> taylor_diagram: Part 3 ")

  if (rOpts .and. isatt(rOpts,"centerDiffRMS") \
            .and. rOpts@centerDiffRMS) then
      respl                    = True                ; polyline mods desired
      respl@gsLineThicknessF   = 1.0                 ; line thickness
      respl@gsLineColor        = "Black"             ; line color     
      respl@gsLineDashPattern  = 2                   ; short dash lines
      
      dx   = 0.25
      ncon = 4                                       ; 0.75, 0.50, 0.25, 0.0
      npts = 100                                     ; arbitrary
      ang  = fspan(180,360,npts)*rad

      dum9 = new(ncon,graphic)

      do n=1,ncon 
         rr  = n*dx            ; radius from 1.0 [OBS] abscissa
         xx  = 1. + rr*cos(ang)
         yy  = fabs( rr*sin(ang) )
         if (n.le.2) then
             dum9(n-1) = gsn_add_polyline(wks,taylor,xx,yy,respl)
         end if
         if (n.eq.3) then
             n3 = floattointeger( 0.77*npts ) 
             dum9(n-1) = gsn_add_polyline(wks,taylor,xx(0:n3),yy(0:n3),respl)
         end if
         if (n.eq.4) then
             n4 = floattointeger( 0.61*npts ) 
             dum9(n-1) = gsn_add_polyline(wks,taylor,xx(0:n4),yy(0:n4),respl)
         end if
      end do
      delete(ang)
      delete(xx)
      delete(yy)
      taylor@$unique_string("dum")$ = dum9

  end if
; ---------------------------------------------------------------
; Part 4:
; generic resources that will be applied to all users data points
; of course, these can be changed 
; http://www.ncl.ucar.edu/Document/Graphics/Resources/gs.shtml
; ---------------------------------------------------------------

 ;print("============> taylor_diagram: Part 4 ")

  if (rOpts .and. isatt(rOpts,"Markers")) then
      Markers = rOpts@Markers
  else
    ;;Markers = (/ 4, 6, 8,  0, 9, 12, 7, 2, 11, 16/) ; Marker Indices
      Markers = (/ 7, 7, 7,  7, 7,  7, 7, 7,  7,  7/) ; Marker Indices
  end if

  if (rOpts .and. isatt(rOpts,"Colors")) then
      Colors  = rOpts@Colors
  else
      Colors  = (/ "red", "blue", "green", "cyan", "orange" \
                 , "purple", "brown", "yellow", "purple", "black"/)
  end if

  if (rOpts .and. isatt(rOpts,"gsMarkerThicknessF")) then
      gsMarkerThicknessF = rOpts@gsMarkerThicknessF
  else
      gsMarkerThicknessF = 1.0
  end if

  if (rOpts .and. isatt(rOpts,"gsMarkerSizeF")) then
      gsMarkerSizeF      = rOpts@gsMarkerSizeF
  else
      gsMarkerSizeF      = 0.0085                  ; Default: 0.007
  end if

  gsRes = True
  gsRes@gsMarkerThicknessF = gsMarkerThicknessF      ; default=1.0
  gsRes@gsMarkerSizeF      = gsMarkerSizeF           ; Default: 0.007 

  ptRes = True                        ; text options for points
  ptRes@txJust             = "BottomCenter"; Default="CenterCenter".
  ptRes@txFontThicknessF   = 1.2      ; default=1.00
  ptRes@txFontHeightF      = 0.0125   ; default=0.05
  if (rOpts .and. isatt(rOpts,"txFontHeightF")) then
      ptRes@txFontHeightF  = rOpts@txFontHeightF  
  end if

  markerTxYOffset          = 0.0175   ; default
  if (rOpts .and. isatt(rOpts,"markerTxYOffset")) then
      markerTxYOffset = rOpts@markerTxYOffset             ; user defined offset
  end if

  dum10 = new((nCase*nVar),graphic)
  dum11 = dum10
  dum12 = dum10  

;; Up-front info. for bias labelling.

  BiasMarkerScale = (/1.0,0.75,1.0,1.25,1.50/)
  BiasLabels = (/"<1%","1-5%","5-10%","10-20%",">20%"/)
  BiasLevels = (/1.,5.,10.,20./)

  do n=0,nCase-1
     gsRes@gsMarkerIndex   = Markers(n)             ; marker style 
     gsRes@txFontColor     = Colors(n)              ; marker color
     ptRes@txFontColor     = Colors(n)    ; make font same color
     gsRes@gsMarkerColor   = Colors(n)   
    do i=0,nVar-1
                                                    ; Marker type (index)
      if (.not.ismissing(BIAS(n,i))) then 
       if (BIAS(n,i).ge.0) then                    ; %
           gsRes@gsMarkerIndex = 7                  ; up-triangle
       end if
 
       if (BIAS(n,i).lt.0) then                    ; %
           gsRes@gsMarkerIndex = 8                  ; down-triangle
       end if
                                                   
       if (abs(BIAS(n,i)).le.BiasLevels(0)) then                    ; %
           gsRes@gsMarkerIndex = 4                  ; hollow_circle
       end if       
      
       scaleMarkerSize = BiasMarkerScale(0) ; For the 'near obs.' classification.

       if (abs(BIAS(n,i)).gt.BiasLevels(0) .and. abs(BIAS(n,i)).le.BiasLevels(1)) then
           scaleMarkerSize = BiasMarkerScale(1)
       end if
       if (abs(BIAS(n,i)).gt.BiasLevels(1) .and. abs(BIAS(n,i)).le.BiasLevels(2)) then
           scaleMarkerSize = BiasMarkerScale(2)
       end if
       if (abs(BIAS(n,i)).gt.BiasLevels(2) .and. abs(BIAS(n,i)).le.BiasLevels(3)) then
           scaleMarkerSize = BiasMarkerScale(3)
       end if
       if (abs(BIAS(n,i)).gt.BiasLevels(3)) then
           scaleMarkerSize = BiasMarkerScale(4)
       end if

       gsRes@gsMarkerSizeF      = gsMarkerSizeF*scaleMarkerSize 
      ;print(sprintf("%6.2f",BIAS(n,i))+"   "+gsRes@gsMarkerIndex \
      ;                                +"   "+sprintf("%6.4f",gsRes@gsMarkerSizeF) \
      ;                                +"   "+scaleMarkerSize)

       ptRes@txPerimOn = False
       if (abs(BIAS(n,i)).eq.min(abs(BIAS(0:nCase-1,i)))) then
         ptRes@txPerimSpaceF = 0.2
         ptRes@txPerimThicknessF = 0.2
         ptRes@txBackgroundFillColor = Colors(n)
         ptRes@txFontColor = "White"         
       end if

       if (outlier .and.  (CC(n,i).lt.0  .or. RATIO(n,i).gt.xyMax)) then
;         print("X="+X(n,i)+", Y="+Y(n,i)+"  RATIO="+RATIO(n,i)+", CC="+CC(n,i)) 
          stRes = True                        ; text options for points
          stRes@txJust             = "BottomCenter"; Default="CenterCenter".
          stRes@txFontThicknessF   = 1.2      ; default=1.00
          stRes@txFontHeightF      = 0.0125   ; default=0.05
	  stmarkerTxYOffset= 0.014

          if (rOpts .and. isatt(rOpts,"txFontHeightF")) then
             stRes@txFontHeightF  = rOpts@txFontHeightF  
          end if

		if (scntr.le.5) then
		   yval = .16
		   xval = .228+(scntr*.1)
		end if
		if (scntr.ge.6.and.scntr.le.11) then
		   yval = .115
		   xval = .228+((scntr-6)*.1)
		end if
		if (scntr.ge.12.and.scntr.le.17) then
		   yval = .07 
		   xval = .228+((scntr-12)*.1)
		end if
		if (scntr.ge.18.and.scntr.le.23) then
		   yval = .025
		   xval = .228+((scntr-18)*.1)
		end if
		if (scntr.ge.24) then
		   print("Non-fatal error: More than 24 cases have correlations < 0 and/or ratios > 1.65. Only 20 cases will be shown beneath the taylor diagram.")
	        end if			
		gsn_polymarker_ndc(wks,xval,yval,gsRes) 
		gsn_text_ndc(wks,(i+0),xval,yval+stmarkerTxYOffset,ptRes)		
		gsn_text_ndc(wks,sprintf("%3.2f",RATIO(n,i)),xval+.035,yval+stmarkerTxYOffset-.0025,stRes)
		gsn_text_ndc(wks,"____",xval+.035,yval+stmarkerTxYOffset-.0052,stRes)
		gsn_text_ndc(wks,sprintf("%3.2f",CC(n,i)),xval+.035,yval+stmarkerTxYOffset-.02,stRes)		
		scntr = scntr+1
	  else	
                dum11(n*nVar+i) = gsn_add_polymarker(wks,taylor,X(n,i),Y(n,i),gsRes) 
		dum12(n*nVar+i) = gsn_add_text(wks,taylor,(i+0),X(n,i),Y(n,i)+markerTxYOffset,ptRes)
	  end if       
          ptRes@txFontColor = Colors(n)
          ptRes@txBackgroundFillColor = "Transparent"
      end if                       ; .not.ismissing(BIAS(n,1))
    end do
  end do
; ---------------------------------------------------------------
; Part 4a:  add bias legend
; ---------------------------------------------------------------


; Add bias sizing key to plot
 
      lgres                    = True
      lgres@lgPerimOn          = False         ; turn off perimeter
      lgres@lgMonoMarkerSize   = False
      lgres@lgMonoMarkerColor  = True
      lgres@vpWidthF           = 0.12 
      lgres@vpHeightF          = 0.15
      lgres@lgMarkerColor      = "Black"        ; colors of markers
      lgres@lgMarkerIndexes    = (/4,8,8,8,8/)     ; Markers 
      lgres@lgMarkerSizes      =  BiasMarkerScale*gsMarkerSizeF ; Marker size
      lgres@lgItemType         = "Markers"     ; draw markers only
      lgres@lgLabelFontHeightF = 0.05  ; font height of legend case labels  (controls : size of "-/+ Bias" legend)
      

      lgres@lgTitleFontHeightF = 0.01
;      lgres@lgTitleOffsetF     =
      lgres@lgTitleString      = "       - / +"
      lgres@lgLabelsOn         = False
      
     
; Down triangles - no text
      lbid = gsn_create_legend(wks,5,BiasLabels,lgres)
	 
      amres = True
      amres@amParallelPosF     =  -0.45           
      amres@amOrthogonalPosF   = -0.28             
      annoid1 = gsn_add_annotation(taylor,lbid,amres)	; add legend to plot


; Up triangles - with text     
      lgres@lgLabelsOn         = True
      lgres@lgTitleString      = "             Bias"
      lgres@lgMarkerIndexes(1:4)    =    lgres@lgMarkerIndexes(1:4)-1
      lbid = gsn_create_legend(wks,5,BiasLabels,lgres)
	 
      amres@amParallelPosF     =  -0.38           
      annoid1 = gsn_add_annotation(taylor,lbid,amres)	; add legend to plot

      delete(lgres)

; ---------------------------------------------------------------
; Part 5:  add case legend and variable labels 
; ---------------------------------------------------------------

;;; Add variable mean bias and RMSE'
; Calculate mean normalized bias and RMSE

      bias_mean =  new ( (/nCase/),typeof(RATIO) )
      rmse_mean =  new ( (/nCase/),typeof(RATIO) )

      do icase = 0,nCase-1
        bias_mean(icase) = sum(BIAS(icase,:))/nVar
        rmse_mean(icase) = sum(sqrt(RATIO(icase,:)^2+1.-2*RATIO(icase,:)*CC(icase,:)))/nVar
      end do

      bias_mean_ratio = bias_mean(:)/bias_mean(0)
      rmse_mean_ratio = rmse_mean(:)/rmse_mean(0)


 ;print("============> taylor_diagram: Part 5 ")

  if (rOpts .and. isatt(rOpts,"caseLabels")) then 
      if (isatt(rOpts,"caseLabelsXYloc")) then
          caseXloc = rOpts@caseLabelsXYloc(0)
          caseYloc = rOpts@caseLabelsXYloc(1)
      else
          caseXloc = 0.70                      ; default ndc
          caseYloc = 0.80
      end if

      if (isatt(rOpts,"caseLabelsFontHeightF")) then
          caseLabelsFontHeightF = rOpts@caseLabelsFontHeightF
      else
          caseLabelsFontHeightF = 0.15   ;+ hannay
      end if
      caseLabelsFontHeightF = 0.15   ;+ hannay


      lgres                    = True
      lgres@lgMarkerColors     = Colors(::-1)        ; colors of markers
      lgres@lgMarkerIndexes    = (/16,16,16,16,16/)       ; Markers 
      lgres@lgMarkerSizeF      = gsMarkerSizeF ; Marker size
      lgres@lgItemType         = "Markers"     ; draw markers only
      lgres@lgLabelFontHeightF = caseLabelsFontHeightF  ; font height of legend case labels (the casename)
      lgres@lgLabelFontHeightF = 0.25  ; font height of legend case labels (the casename) ++ hannay

      if (isatt(rOpts,"legendWidth")) then
          lgres@vpWidthF       = rOpts@legendWidth
      else
          lgres@vpWidthF       = 0.15           ; width of legend (NDC)
      end if

      lgres@lgLabelPosition = "Right"
      if (isatt(rOpts,"legendHeight")) then
          lgres@vpHeightF      = rOpts@legendHeight
      else   
          lgres@vpHeightF      = 0.025*nCase   ; height of legend (NDC)
      end if
      lgres@lgPerimOn           = True         ; turn off perimeter
      lgres@lgLeftMarginF       = 0
      lgres@lgBoxLineThicknessF = 3
      lbid = gsn_create_legend(wks,nCase,rOpts@caseLabels(::-1),lgres)
	 
      amres = True
      amres@amParallelPosF     =  -0.36         
      amres@amOrthogonalPosF   =  0.07             
      annoid1 = gsn_add_annotation(taylor,lbid,amres)	; add legend to plot  +hannay

; Add mean RMSE and Bias info.

      xposs = 0.64
      yposs = 0.70
      xoffset = 0.06
      yspace = 0.02

      ngsRes = True
      ntxRes = True
      
      ntxRes@txFontHeightF = tmYLLabelFontHeightF*0.75

      gsn_text_ndc(wks, "RMSE", xposs+xoffset, yposs+0.025, ntxRes)
      gsn_text_ndc(wks, "Bias", xposs+2*xoffset, yposs+0.025, ntxRes)
      
      do nc=0,nCase-1
        ngsRes@gsMarkerIndex = Markers(nc)
        ngsRes@gsMarkerColor = Colors(nc)
        
        gsn_polymarker_ndc(wks, xposs, yposs - nc*yspace, ngsRes) 
        
        if (nc.eq.0) then
          ntxRes@txFontColor = "black"
        else
          if (rmse_mean_ratio(nc).ge.rmse_mean_ratio(0)) then
            ntxRes@txFontColor = "Firebrick"
          else
            ntxRes@txFontColor = "ForestGreen"
          end if
          ntxRes@txFontColor = "Black"
        end if
   
          
        gsn_text_ndc(wks, sprintf("%4.3f",rmse_mean_ratio(nc)), xposs+xoffset, yposs - nc*yspace, ntxRes)

        if (nc.eq.0) then
          ntxRes@txFontColor = "black"
        else
          if (bias_mean_ratio(nc).ge.bias_mean_ratio(0)) then
            ntxRes@txFontColor = "Firebrick"
          else
            ntxRes@txFontColor = "ForestGreen"
          end if
          ntxRes@txFontColor = "Black"
        end if

        gsn_text_ndc(wks,  sprintf("%4.3f",bias_mean_ratio(nc)), xposs+2.*xoffset, yposs - nc*yspace, ntxRes)

      end do

  end if



  if (rOpts .and. isatt(rOpts,"varLabels")) then 
      nVar    = dimsizes(rOpts@varLabels)

      if (isatt(rOpts,"varLabelsFontHeightF")) then
          varLabelsFontHeightF = rOpts@varLabelsFontHeightF
      else
          ;varLabelsFontHeightF = 0.013
          varLabelsFontHeightF = 0.008  ;+ hannay   : change size of variable names
      end if


      txres = True
      txres@txFontHeightF = varLabelsFontHeightF
      txres@txJust = "CenterLeft"              ; justify to the center left

     ;delta_y = 0.02       
      delta_y = 0.05   
      if (rOpts .and. isatt(rOpts,"varLabelsYloc")) then
          ys  = rOpts@varLabelsYloc            ; user specified
      else
          ys  = max( (/nVar*delta_y , 0.30/) )
      end if

      
      do i = 1,nVar     
         if (i.eq.1) then
             dum13 = new(nVar+1,graphic) ; +1 for the ensemble mean ('X') point
	 end if

         dum13(i-1) = gsn_add_text(wks,taylor,i-1+" - "+rOpts@varLabels(i-1), .06,ys,txres)
         ys = ys- delta_y
      end do

; Add ensemble mean point label
;      ys = ys+ (nVar+1)*delta_y
;'      dum13(nVar) = gsn_add_text(wks,taylor,"X - Variable Average", .06,ys,txres)

      taylor@$unique_string("dum")$ = dum13
  end if




 ;print("============> taylor_diagram: Part 5 ")

  taylor@$unique_string("dum")$ = dum0   ; x-axis
  taylor@$unique_string("dum")$ = dum1   ; y-axis
  taylor@$unique_string("dum")$ = dum2   ; 1.0 std curve
  taylor@$unique_string("dum")$ = dum5   ; labels [COR]
  taylor@$unique_string("dum")$ = dum6   ; major tm [COR]
  taylor@$unique_string("dum")$ = dum7   ; minor tm
  taylor@$unique_string("dum")$ = dum10  ; markers
  taylor@$unique_string("dum")$ = dum11  ; best case markers
  taylor@$unique_string("dum")$ = dum12  ; case markers
  taylor@$unique_string("dum")$ = dum13  ; text
  
 ;print("============> taylor_diagram: Part 6 ")

  if (.not.isatt(rOpts,"taylorDraw") .or. \
     (isatt(rOpts,"taylorDraw") .and. rOpts@taylorDraw)) then 
	draw(taylor)
  end if

 ;print("============> taylor_diagram: Part 7 ")

  if (.not.isatt(rOpts,"taylorFrame") .or. \
     (isatt(rOpts,"taylorFrame") .and. rOpts@taylorFrame)) then 
	frame(wks)
  end if

 ;print("============> taylor_diagram: Part 8: Exit ")

  return(taylor)
end
