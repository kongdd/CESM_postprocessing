load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

   print( " plotting VVEL at "+ n_depth + " depth levels")
   
   fileid = addfile(file_netcdf,"r")
   vvel = fileid->VVEL
   if (isatt(vvel,"_FillValue"))
      missing = vvel@_FillValue
   else
      missing = 1e30
   end if
   units = vvel@units
   uvel = fileid->UVEL
   
   tlon = fileid->TLONG
   tlat = fileid->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   ulon = fileid->ULONG
   ulat = fileid->ULAT
   kmt = fileid->KMT
   kmu = fileid->KMU
   region_mask = fileid->REGION_MASK
   tarea = fileid->TAREA
   uarea = fileid->UAREA
   angle = fileid->ANGLE
   anglet = fileid->ANGLET
   z_t = fileid->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.

   nlev = 21
   coltab = new(nlev + 1,"integer")
   color1 = 2 
   coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
   coltab(0) = 0

   do l=0, n_depth-1
     dep =  depth(l)
     min_diff = min(abs(z_t - dep))
     klev_arr = ind(abs(dep-z_t) .eq. min_diff) ; if 2 depth are equally distant you get an array
     klev = klev_arr(0)
     delete(klev_arr)
     zdep = z_t(klev)
     if (dimsizes(dimsizes(vvel)) .eq. 4) then
        field = vvel(0,klev,:,:)
     else
        field = vvel(klev,:,:)
     end if
     if (dimsizes(dimsizes(uvel)) .eq. 4) then
        field_2 = uvel(0,klev,:,:)
     else
        field_2 = uvel(klev,:,:)
     end if
     ; rotate vector
     field = tofloat(field * cos(angle) - field_2 * sin(-angle))

;
;    "gauss" level type not supported yet
;
     if (cntrlvls .eq. "gauss") then
       print ("'gauss' CNTRLVLS not currently supported in NCL version of OMWG: using 'std' method") 
     end if

     if ( zdep .le. 200. ) then
       dmin = -50.0
       dmax = 50.0
     else if (zdep .le.   1800.) then
       dmin = -20.0
       dmax =  20.0
     else 
       dmin = -10.0
       dmax =  10.0
     end if
     end if
     dlev = (dmax-dmin) / (nlev - 1)
     lev  = dmin + ispan(0,nlev-1,1)*dlev

     depstr = sprintf("%.0f",dep)
     zdepstr = sprintf("%6.1fm",zdep)
     case_info = "VVEL at z="+zdepstr+", " + case_number + " " + time_info 
   
    ; wks = gsn_open_wks("x11","VVEL"+depstr)
     wks = gsn_open_wks(img_format,"VVEL"+depstr)
     gsn_define_colormap(wks,"table42")
   
     units = "cm s~S~-1~N~"
     opt = True
     opt@charsize = 0.9
     opt@landcolor = lndcolor
     opt@contourline = 2
     opt@xrange = (/ xr0,xr1/)
     opt@yrange = (/ yr0,yr1/)

     plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, tarea, case_info, \
               	          missing, units, dlev, lev, coltab, opt)
   end do
   
end
   
