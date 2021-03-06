; PROGRAM to read and plot satellite data
;----------------------------------------

; Plot of 1D MHD data either smpled in satbin or as cuts through 
;   2D or 3D simulation domains.
;    -> see also plotvarsimh (the resistive terms).

COMMON procommon, nsat,startime,itot,pi,ntmax, $
                  rhobd,pbd,vxbd,vybd,vzbd,bxbd,bybd,bzbd, $
                  xsi,ysi,zsi,vxsi,vysi,vzsi, $
                  time,bxs,bys,bzs,vxs,vys,vzs,rhos,ps,bs,ptots, $
                  jxs,jys,jzs,xs,ys,zs,cutalong
COMMON units, nnorm,bnorm,vnorm,pnorm,lnorm,tnorm,tempnorm,jnorm,$
              nfac,bfac,vfac,pfac,lfac,tfac,tempfac,jfac
COMMON ref, br,vr,rhor,pr,babr,ptotr,pbr,tempr,beta,t,$
            jr,er,rsat,vrsat,index,starttime,xtit,withps,$
            satchoice,withunits
COMMON simdat3, nx,ny,nz,x,y,z,dx,dy,dz,bx,by,bz,vx,vy,vz,rho,u,res,p,$
                jx,jy,jz,xmin,xmax,ymin,ymax,zmin,zmax,linealong,icut
COMMON pltvar, vplot,bplot
COMMON test, timeqs,nnn,neqs,veqs,bave,eeqs

  nsat = long(60) & ntmax = 4001 & pi = 3.1415926553
  startime = 0.0 & time = fltarr(ntmax)
  time2d=0.0 
  satch='2' & satchoice=satch
  cutalong='x' & linealong='y' & icut=1
  
  withps='n' & closeps='n' & psname='ps' & smo='n'
  whatindex='0' & withunits='n' & index=0 & rsfact=20. & shiftfact=100.
  coordstrn='' & pscoord='g' 
  varpresent='n' & htpresent='n' & withht='n' & beta0=6.

  countps=0
  xtit='x' 
  ebasis='b' & ebst='B'
  evo1=[1.,0.,0.] & evo2=[0.,1.,0.] & evo3=[0.,0.,1.] & ewo=[1.,1.,1.]

  slwal0 = 0.8 & slwal1 = 1.3 &  slht0 = 0.9 & slht1 = 1.1 &  itest=0
  succes=0  & iterror='n' & bntest=0 & satraj=1 & base=fltarr(3,3)
  base(0,*)=[1.,0.,0.] & base(1,*)=[0.,1.,0.] & base(2,*)=[0.,0.,1.]
  vht=[0.,0.,0.]

     nnorm = 3.                    ; for cm^(-3)
     bnorm = 50.0                    ; for nT
     lnorm = 6400.0                    ; for km
     vnorm = 21.8*bnorm/sqrt(nnorm)  ; for km/s
     pnorm = 0.01*bnorm^2.0/8.0/pi   ; for nPa
     tnorm = lnorm/vnorm              ; for s
;     boltz = 1.38*10^(-23)           ; 
     tempnorm = pnorm*10./1.38/1.16/nnorm  ; for keV
     jnorm=10000.*bnorm/4./pi/lnorm  ; in 10^-9 A/m^2


reads:
; READ INPUT DATA FOR NSAT SATELLITES
;------------------------------------
; determines: nsat,startime,itot,nnorm,bnorm,vnorm,pnorm,lnorm,tnorm,$
;              rhobd,pbd,vxbd,vybd,vzbd,bxbd,bybd,bzbd,$
;              xsat0,ysat0,zsat0,vxsat,vysat,vzsat,$
;              time,bxs,bys,bzs,vxs,vys,vzs,rhos,ps,bs,ptots,xs,ys,zs
  print, 'Choose format of sat data set: obtions:'
  print, 'Default choice:           b -> binary simulation data'
  print, '                          2 -> 2D grid'
  print, '                          3 -> 3D grid'
  read, satch
  if satch eq '' or satch eq 'b' then begin
    readsat & satchoice='b' & endif
  if satch eq '2' then begin
     read2sim,time2d
     satchoice=satch
     print,'cutalong=',cutalong
  endif
  if satch eq '3' then  begin
    read3sim,time2d
    satchoice=satch
    cut3d
    print,'cutalong=',cutalong,'  linealong=',linealong,'cut at ',icut
  endif
  if (satchoice ne 'b') and (satchoice ne '2') $
    and (satchoice ne '3')    then goto, reads

;  NORMALISATION  
;-----------------
  parnorm   
  efieldsim,itot

  tminall=time(0)
  tmaxall=time(itot-1)
  tmin=tminall & tmax=tmaxall
  tvarmin=tmin & tvarmax=tmax
  delt=0.2*(tmax-tmin) & fdelt=0.4*delt


    t=time  &  it1=0 & it2=itot-1 & nt=itot
    iv1=0 & iv2=itot-1 & nv=itot
    xr=t & yr=t & zr=t & bxr=t & byr=t & bzr=t & vxr=t & vyr=t & vzr=t
    rhor=t & pr=t & br=t & ptotr=t & tempr=t
; SIMULATION COORDINATES:
; Boundary values:                  rhobd,pbd,vxbd,vybd,vzbd,bxbd,bybd,bzbd
; Probe coordinates and positions:  xsi,ysi,zsi,vxsi,vysi,vzsi
; Probe data:                       time, bxs, bys, bzs, vxs, vys, vzs,
;                                   rhos, ps, bs, ptots, xs, ys, zs
  
; declare some variable to record and print boundary values
  bmsp=fltarr(3) & bmsh=bmsp & vmsp=bmsp & vmsh=bmsp 
  bmsp(0)=bfac*bxbd(0) & bmsp(1)=bfac*bybd(0) & bmsp(2)=bfac*bzbd(0) 
  bmsh(0)=bfac*bxbd(1) & bmsh(1)=bfac*bybd(1) & bmsh(2)=bfac*bzbd(1) 
  vmsp(0)=0.0 & vmsp(1)=0.0 & vmsp(2)=0.0
  vmsh(0)=vfac*(vxbd(1)-vxbd(0))
  vmsh(1)=vfac*(vybd(1)-vybd(0))
  vmsh(2)=vfac*(vzbd(1)-vzbd(0))
  rhotmsp=fltarr(2) & rhotmsh=rhotmsp
  rhotmsp(0)=nfac*rhobd(0) & rhotmsp(1)=tempfac*pbd(0)/rhobd(0)
  rhotmsh(0)=nfac*rhobd(1) & rhotmsh(1)=tempfac*pbd(1)/rhobd(1)
  
satindex:
  parprint
    
cut: 
;the line under is moved here from above 

  iterror='n'
  print, '   Present time(plot) range:',tfac*tmin, tfac*tmax
  print, '   Maximum Time(plot) range:',tfac*tminall, tfac*tmaxall
  print, '   Selected test: itest=',itest
  print, '   Selected variance method=',bntest
  print, '   Required slope for Walenrel (min,max):',slwal0,slwal1
  print, '   Required slope for HT frame(min,max):',slht0,slht1
  print, '   Search interval (min) and increment analysis:',delt,fdelt
  if smo eq 'y' then print, 'Smoothing velocity is presently on!'$ 
       else print, 'Smoothing velocity is presently off!'
  
  print, 'CHOOSE PROBE INDEX: '
  print, 'Present choices:  Probe index ='+string(index,'(i3)')
  if withunits eq 'n' then print, '        Simulation units' else $
                         print, '        Physical units'
  print, '        Time range for variance analysis (v):',tfac*tvarmin,tfac*tvarmax
  print, '        Variance plots (h) and (r) use basis from:  ', ebst
                         
  print, 'OPTIONS: integer  -> Probe index'
  print, '          return  -> No changes applied'
  print, '               i  -> Show probe indices and parameters again'
  print, '               n  -> Normalized units'
  print, '               o  -> Physical units'
  print, '               t  -> Time(data) range for plots'
  print, '               tt  -> Set time range back to total range'
  print, '               r  -> shift interval right by ',shiftfact,'% delta t'
  print, '               l  -> shift interval  left by ',shiftfact,'% delta t'
  print, '               d  -> change shiftfactor in % of delta t'
  print, '               c  -> contract interval by',rsfact,'% delta t'
  print, '               e  -> expand interval by',rsfact,'% delta t'
  print, '               f  -> change contract/expand factor in % of delta t'
  print, '               g  -> smooth on (y) and off (n) (for analysis only)'
  print, '               s  -> Set variance time range to plotrange'
  print, '               u  -> Select variance time different from plotrange'
  print, '               v  -> compute magnetic/electric field variance + coord'
  print, '               vp  -> postscript of variance + coord'
  print, '               x  -> switch to magnetic field variancdhtpree coord'
  print, '               y  -> switch to electric field variance coord'
  print, '               z  -> switch back to GSM coordinates'
  print, '               w  -> dHT frame and Walen relation'
  print, '               wp  -> postcript of dHT and Walen plots'
  print, '               pp  -> power spectrum'
  print, '               ppp  -> postcript of power spectrum plots'
  print, '               h  -> plot V-Vht, current withht=',withht
  print, '                                       determine Vht first!!'
  print, '               b  -> change crit. plasma current beta=',beta0
  print, '               p  -> Postscript output'
  print, '               q  -> TERMINATE'
  read, whatindex
  if ( (whatindex ne '') and  (whatindex ne 'i') $
     and (whatindex ne 'n') and (whatindex ne 'o') and (whatindex ne 'p') $
     and (whatindex ne 't') and (whatindex ne 'tt') and (whatindex ne 'r') $
     and (whatindex ne 'l') and (whatindex ne 'd') and (whatindex ne 'c') $
     and (whatindex ne 'e') and (whatindex ne 'f') and (whatindex ne 'g') $
     and (whatindex ne 's') and (whatindex ne 'u') and (whatindex ne 'v') $
     and (whatindex ne 'x') and (whatindex ne 'y') and (whatindex ne 'z') $
     and (whatindex ne 'w') and (whatindex ne 'wp') and (whatindex ne 'vp') $
     and (whatindex ne 'h') and (whatindex ne 'b') and (whatindex ne 'q') $
     and (whatindex ne 'pp') and (whatindex ne 'ppp') )    then begin
    index=fix(whatindex)
    print, 'Chosen satellite index: ',index
    if index gt nsat-1 then begin 
       print, 'Probe index is too large -> return to menue!'
    endif  
    htpresent='n' & varpresent='n'
  endif
  if whatindex eq '' then print,'index=',index,' not altered'
  if whatindex eq 'i' then goto, satindex
  if whatindex eq 'n' then begin
    withunits='n' & parnorm
  endif
  if whatindex eq 'o' then begin
    withunits='y' & parnorm
    t=tfac*time
  endif
  if whatindex eq 'h' then begin
    if withht eq 'y' then withht='n' else withht='y'
  endif
  if whatindex eq 'b' then begin
    print, 'Enter new vritical beta'
    read, beta0
  endif
  if whatindex eq 'p' then begin
     withps = 'y'
     !P.THICK=2.
     !X.THICK=1.5
     !Y.THICK=1.5
     !P.CHARTHICK=2.
     psname='satp'+string(index,'(i2.2)')+'p'+string(countps,'(i2.2)')
     countps=countps+1 & set_plot,'ps'
     device,/color,bits=8
     device,filename=psname+'.ps'
     device, /landscape, /helvetica, /bold
;     device, /landscape, /helvetica, /bold, font_index=3
     device, /inches, xsize=10., ysize=8., scale_factor=0.95, $
                      xoffset=0.5,yoffset=10.1
  endif
  if whatindex eq 't' then begin
     plotrange, time,tfac, tmin,tmax,it1,it2,nt,success
     if success eq 'none' then goto, cut
  endif
  if whatindex eq 'tt' then begin
     tmin=time(0) & tmax=time(itot-1)
  endif
    if whatindex eq 'q' then stop
 
  if whatindex eq 'r' then begin
    ddelt=shiftfact/100.*(tmax-tmin) & tmin=tmin+ddelt & tmax=tmax+ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
  endif
  if whatindex eq 'l' then begin
    ddelt=shiftfact/100.*(tmax-tmin) & tmin=tmin-ddelt & tmax=tmax-ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
  endif
  if whatindex eq 'd' then begin
    print,'Present shift factor=',shiftfact,' in % of delta t'
    print,'Input new factor!' & read, shiftfact & goto, cut
  endif
  if whatindex eq 'c' then begin
    ddelt=rsfact/200.*(tmax-tmin) & tmin=tmin+ddelt & tmax=tmax-ddelt
  endif
  if whatindex eq 'e' then begin
    ddelt=rsfact/200.*(tmax-tmin) & tmin=tmin-ddelt & tmax=tmax+ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
  endif
  if whatindex eq 'f' then begin
    print,'Present resize factor=',rsfact,' in % of delta t'
    print,'Input new factor!' & read, rsfact & goto, cut
  endif
  if whatindex eq 'g' then begin
     if smo eq 'y' then print, 'Smoothing velocity is presently on!'$ 
       else print, 'Smoothing velocity is presently off!'
     print, 'Switch smoothing on (y) or off (n):'
     read, smo
     if smo ne 'y' then smo='n'
     goto, cut
  endif
  if whatindex eq 's' then begin
     print, 'Analysis time range set to tmin, tmax:', tmin, tmax
     tvarmin=tmin & tvarmax=tmax
     goto, cut
  endif
  if whatindex eq 'u' then begin
     print,'Set analysis time range!'
     print,'Input tmin>=',tfac*tminall,'  and tmax<=',tfac*tmaxall
     print,'Present plot range', tfac*tmin, tfac*tmax
     read, tvarmin,tvarmax
     tvarmin=tvarmin/tfac & tvarmax=tvarmax/tfac
     if((tvarmin lt tminall) or (tvarmin ge tmaxall) $
                          or (tvarmin gt tvarmax)) then tvarmin=tminall
     if((tvarmax le tminall) or (tvarmax gt tmaxall)) then tvarmax=tmaxall
     goto, cut
  endif

; Units
  parnorm   ; probably not needed here
  efieldsim, itot
; Same for the boundary values
  bmsp(0)=bfac*bxbd(0) & bmsp(1)=bfac*bybd(0) & bmsp(2)=bfac*bzbd(0) 
  bmsh(0)=bfac*bxbd(1) & bmsh(1)=bfac*bybd(1) & bmsh(2)=bfac*bzbd(1) 
  vmsp(0)=0.0 & vmsp(1)=0.0 & vmsp(2)=0.0
  vmsh(0)=vfac*(vxbd(1)-vxbd(0))
  vmsh(1)=vfac*(vybd(1)-vybd(0))
  vmsh(2)=vfac*(vzbd(1)-vzbd(0))
  rhotmsp(0)=nfac*rhobd(0) & rhotmsp(1)=tempfac*pbd(0)/rhobd(0)
  rhotmsh(0)=nfac*rhobd(1) & rhotmsh(1)=tempfac*pbd(1)/rhobd(1)
  if (satchoice eq 'b')  then strnn='SIMSat '+string(index,'(i2.2)')
  if (satchoice eq '2')  then  begin
     if cutalong eq 'x' then str2d=' at y ='+string(ysi(index),'(f5.1)')
     if cutalong eq 'y' then str2d=' at x ='+string(xsi(index),'(f5.1)')
      strnn='Cut along '+cutalong+str2d $
                 +',  time ='+string(time2d,'(f5.0)')
  endif
  if (satchoice eq '3') then  begin
     if cutalong eq 'x' and linealong eq 'y' then $
         str3d = ' at y = '+string(ysi(index),'(f5.1)')$
                 +' and z = '+string(z(icut),'(f5.1)')
     if cutalong eq 'x' and linealong eq 'z' then $
         str3d = ' at y = '+string(y(icut),'(f5.1)')$
                 +' and z = '+string(zsi(index),'(f5.1)')
     if cutalong eq 'y' and linealong eq 'z' then $
         str3d = ' at x = '+string(x(icut),'(f5.1)')$
                 +' and z = '+string(zsi(index),'(f5.1)')
     if cutalong eq 'y' and linealong eq 'x' then $
         str3d = ' at x = '+string(xsi(index),'(f5.1)')$
                 +' and z = '+string(z(icut),'(f5.1)')
     if cutalong eq 'z' and linealong eq 'x' then $
         str3d = ' at x = '+string(xsi(index),'(f5.1)')$
                 +' and y = '+string(y(icut),'(f5.1)')
     if cutalong eq 'z' and linealong eq 'y' then $
         str3d = ' at x = '+string(x(icut),'(f5.1)')$
                 +' and y = '+string(ysi(index),'(f5.1)')
     strnn='Cut along '+cutalong+str3d $
                 +',  time ='+string(time2d,'(f5.0)')
  endif
  if ( (whatindex eq 'v') or (whatindex eq 'vp') ) then begin
     if (whatindex eq 'vp') then withps='y'
     testvarsim,tvarmin,tvarmax,smo,iterror
     if (withps ne 'y') then  $
       window,1,xsize=600,ysize=480,title='Variance Plot' $
     else begin
       withps='y'
       !P.THICK=2.
       !X.THICK=1.5
       !Y.THICK=1.5
       !P.CHARTHICK=2.
       intbd,tvarmin,tvarmax,itot,time,ih1,ih2
       psname='clv'+':'+string(ih1,'(i3.3)')+'_'+string(ih2,'(i3.3)')+'var'
       set_plot,'ps'
       device,/color,bits=8
       device,filename=psname+'.ps'
       device, /portrait, /helvetica, /bold
       device, /inches, xsize=8., ysize=6.4, scale_factor=0.8, $
                      xoffset=1.0,yoffset=5.3
     endelse
     varbe,tvarmin,tvarmax,withps,smo,eb1,eb2,eb3,ee1,ee2,ee3,strnn
     if withps eq 'y' then  begin 
       withps='n' & device,/close & set_plot,'x'
       !P.THICK=1. & !X.THICK=1. & !Y.THICK=1. & !P.CHARTHICK=1. 
     endif    
     varpresent='y'

  endif
  if ( (whatindex eq 'w') or (whatindex eq 'wp') ) then begin
     if (whatindex eq 'wp') then withps='y'
     testvarsim,tvarmin,tvarmax,smo,iterror
     if (withps ne 'y') then  $
       window,2,xsize=600,ysize=480,title='Walen and dHT Plot' $
     else begin
       withps='y'
       !P.THICK=2.
       !X.THICK=1.5
       !Y.THICK=1.5
       !P.CHARTHICK=2.
       intbd,tvarmin,tvarmax,itot,time,ih1,ih2
       psname='clw'+':'+string(ih1,'(i3.3)')+'_'+string(ih2,'(i3.3)')+'wht'
       set_plot,'ps'
       device,/color,bits=8
       device,filename=psname+'.ps'
       device, /portrait, /times, /bold
       device, /inches, xsize=8., ysize=6.4, scale_factor=0.65, $
                      xoffset=1.8,yoffset=0.8
     endelse
     testwal,tvarmin,tvarmax,withps,smo,strnn,vht,withunits
     if withps eq 'y' then  begin 
       withps='n' & device,/close & set_plot,'x'
       !P.THICK=1. & !X.THICK=1. & !Y.THICK=1. & !P.CHARTHICK=1.     
     endif    
     htpresent='y'
  endif  

  if ( (whatindex eq 'pp') or (whatindex eq 'ppp') ) then begin
     if (whatindex eq 'ppp') then withps='y'
     testvarsim,tvarmin,tvarmax,smo,iterror
     if (withps ne 'y') then  $
       window,3,xsize=600,ysize=480,title='Walen and dHT Plot' $
     else begin
       withps='y'
       !P.THICK=2.
       !X.THICK=1.5
       !Y.THICK=1.5
       !P.CHARTHICK=2.
       intbd,tvarmin,tvarmax,itot,time,ih1,ih2
       psname='pp'+'sat'+string(index,'(i2.2)')+'-'+string(ih1,'(i3.3)')$
                      +'_'+string(ih2,'(i3.3)')
       set_plot,'ps'
       device,/color,bits=8
       device,filename=psname+'.ps'
       device, /portrait, /helvetica, /bold
       device, /inches, xsize=8., ysize=6.0, scale_factor=0.95, $
                      xoffset=1.,yoffset=0.8
     endelse
     powerspectrum,tvarmin,tvarmax,withps,smo,withunits,strnn
     if withps eq 'y' then  begin 
       withps='n' & device,/close & set_plot,'x'
       !P.THICK=1. & !X.THICK=1. & !Y.THICK=1. & !P.CHARTHICK=1.     
     endif    
     htpresent='y'
  endif  
  
  if (whatindex eq 'x') then begin
     if varpresent  ne 'y' then begin
       print,'No variance coord present. Determine variance first!!!'
       goto, cut & endif
     coordstrn='B Coord.' & pscoord='b'
     base(0,*)=eb1 & base(1,*)=eb2 & base(2,*)=eb3
  endif
  if (whatindex eq 'y') then begin
     if varpresent  ne 'y' then begin
       print,'No variance coord present. Determine variance first!!!'
       goto, cut & endif
     coordstrn='E Coord.' & pscoord='e'
     base(0,*)=ee1 & base(1,*)=ee2 & base(2,*)=ee3
  endif
  if (whatindex eq 'z') then begin
     coordstrn='' & pscoord='g'
     base(0,*)=[1.,0.,0.] & base(1,*)=[0.,1.,0.] & base(2,*)=[0.,0.,1.]
  endif

plotall:
  print,'BETA0:',beta0
  if htpresent ne 'y' then withht='n'
  plotvars,coordstrn,base
  if (withps ne 'y') then  window,0,xsize=900,ysize=720,title='Overview Plot'
  plotvarsim,tfac*tmin,tfac*tmax, strnn,coordstrn,base,eb1,eb2,eb3,vht,$
                withht,varpresent,beta0,tvarmin,tvarmax
  if withps eq 'y' then  begin 
     withps = 'n' & closeps='n' & device,/close & set_plot,'x'
     !P.THICK=1. & !X.THICK=1. & !Y.THICK=1. & !P.CHARTHICK=1.
  endif
goto, cut

end
