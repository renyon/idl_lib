; PROGRAM to data and normals
;----------------------------------------
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
COMMON pariter, niter,titer,slpwal,slpht,velht,evmax,evmin,evrat,evtit

  nsat = long(60) & ntmax = 4001 & pi = 3.1415926553
  startime = 0.0 & time = fltarr(ntmax)
  time2d=0.0 
  satch='2' & satchoice=satch
  cutalong='x' & linealong='y' & icut=1
  
  withps='n' & wps='n' & closeps='n' & psname='ps' & smo='n'
  whatindex='0' & withunits='n' & index=0 & rsfact=20. & shiftfact=100.
  coordstrn='' & pscoord='g' 
  deltab=0.02 &  absmin=0.0 & absmax=0.0
  countps=0 & vardat='n'

  xtit='x' 
  ebasis='b' & ebst='B'
  evo1=[1.,0.,0.] & evo2=[0.,1.,0.] & evo3=[0.,0.,1.] & ewo=[1.,1.,1.]

  slwal0 = 0.85 & slwal1 = 1.15 &  slht0 = 0.9 & slht1 = 1.1 &  itest=0
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
  delt=0.05*(tmax-tmin) & fdelt=0.1*delt


    t=time  &  it1=0 & it2=itot-1 & nt=itot
    iv1=0 & iv2=itot-1 & nv=itot & tvmin=t(0) & tvmax=t(iv2)
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
  print, '        Time range for variance analysis (v):',tfac*tvmin,tfac*tvmax
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

  print, '               s  -> Start search and plot results'
  print, '               sp -> Search and plot results to postscript'
  print, '               u  -> Range and increment for search'
  print, '               h  -> Change required slope for HT frame'
  print, '               w  -> Change required slope for Walen relation'
  print, '               m  -> Choose test mode: i=0 -> Walen rel and HT frame'
  print, '                                       i=1 -> Walen rel only'
  print, '                                       i=2 -> HT frame only'
  print, '               b  -> define necessary delta b'
  print, '               bn -> define variance test:i=0 -> b-field'
  print, '                                       i=1 -> e-field'

  print, '               p  -> Postscrip output'
  print, '               q  -> TERMINATE'
  read, whatindex
  if ( (whatindex ne '') and  (whatindex ne 'i') $
     and (whatindex ne 'n') and (whatindex ne 'o') and (whatindex ne 'p') $
     and (whatindex ne 't') and (whatindex ne 'tt') and (whatindex ne 'r') $
     and (whatindex ne 'l') and (whatindex ne 'd') and (whatindex ne 'c') $
     and (whatindex ne 'e') and (whatindex ne 'f') and (whatindex ne 'g') $
     and (whatindex ne 's') and (whatindex ne 'u') and (whatindex ne 'h') $
     and (whatindex ne 'w') and (whatindex ne 'm') and (whatindex ne 'b') $
     and (whatindex ne 'bn') and (whatindex ne 'q') and (whatindex ne 'sp')$
                )    then begin
    index=fix(whatindex)
    print, 'Chosen satellite index: ',index
    if index gt nsat-1 then begin 
       print, 'Probe index is too large -> return to menue!'
    endif  
    vardat='n'
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
  if whatindex eq 't' then begin
     plotrange, time,tfac, tmin,tmax,it1,it2,nt,success
     if success eq 'none' then goto, cut
     vardat='n'
  endif
  if whatindex eq 'tt' then begin
     tmin=time(0) & tmax=time(itot-1)
     vardat='n'
  endif
    if whatindex eq 'q' then stop
 
  if whatindex eq 'r' then begin
    ddelt=shiftfact/100.*(tmax-tmin) & tmin=tmin+ddelt & tmax=tmax+ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
    vardat='n'
  endif
  if whatindex eq 'l' then begin
    ddelt=shiftfact/100.*(tmax-tmin) & tmin=tmin-ddelt & tmax=tmax-ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
    vardat='n'
  endif
  if whatindex eq 'd' then begin
    print,'Present shift factor=',shiftfact,' in % of delta t'
    print,'Input new factor!' & read, shiftfact & goto, cut
  endif
  if whatindex eq 'c' then begin
    ddelt=rsfact/200.*(tmax-tmin) & tmin=tmin+ddelt & tmax=tmax-ddelt
    vardat='n'
  endif
  if whatindex eq 'e' then begin
    ddelt=rsfact/200.*(tmax-tmin) & tmin=tmin-ddelt & tmax=tmax+ddelt
    if((tmin lt tminall) or (tmin gt tmaxall)) then tmin=tminall
    if((tmax lt tminall) or (tmax gt tmaxall)) then tmax=tmaxall
    vardat='n'
  endif
  if whatindex eq 'f' then begin
    print,'Present resize factor=',rsfact,' in % of delta t'
    print,'Input new factor!' & read, rsfact & goto, cut
  endif
  if whatindex eq 'b' then begin
    print,'Present delta b=',bfac*deltab
    print,'New delta b!' & read, deltab & deltab=deltab/bfac
    goto, cut
  endif
  if whatindex eq 'g' then begin
     if smo eq 'y' then print, 'Smoothing velocity is presently on!'$ 
       else print, 'Smoothing velocity is presently off!'
     print, 'Switch smoothing on (y) or off (n):'
     read, smo
     if smo ne 'y' then smo='n'
     goto, cut
  endif
  if whatindex eq 'u' then begin
     print, 'Old period (minutes):', delt
     print, 'Old increment (as fraction of period):', fdelt
     print, 'Input new values:'
     read, delt, fdelt
     vardat='n'
     goto, cut
  endif
  if whatindex eq 'h' then begin
     print, 'Old slope for HT search:', slht0, slht1
     print, 'Input new value:'
     read, slht0, slht1
     vardat='n'
     goto, cut
  endif
  if whatindex eq 'w' then begin
     print, 'Old slope for Walen search:', slwal0, slwal1
     print, 'Input new value:'
     read, slwal0, slwal1
     vardat='n'
     goto, cut
  endif
  if whatindex eq 'm' then begin
     print, 'Old value for itest:', itest
     print, 'Input new value:'
     read, itest
     vardat='n'
     goto, cut
  endif

  if whatindex eq 'bn' then begin
     print, 'Old value for bntest:', bntest
     print, 'Input new value:'
     read, bntest
     vardat='n'
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

  if ( (whatindex eq 's') or (whatindex eq 'sp') ) then begin
;     if whatindex eq 'sp' then withps='y'
     testvarsim,tmin,tmax,smo,iterror
     if iterror eq 'y' then goto, cut
     intbd,tmin,tmax,itot,time,ih1,ih2
     filename='cvar'+':'+string(ih1,'(i3.3)')+'_'+string(ih2,'(i3.3)')+'.txt'
     if whatindex eq 'sp' then begin
       wps='y' & openw,7,filename
     endif
     walendhtsearch,itest,smo,tmin,tmax,delt,fdelt,$
                 slwal0,slwal1,slht0,slht1,t1a,t2a,totnumint,wps,deltab,$
                 absmin,absmax,bntest
     if whatindex eq 'sp' then begin
       wps='n' & close,7
     endif
     vardat='y'
  endif else totnumint=0


  if whatindex eq 'p' or whatindex eq 'sp' then begin
     withps = 'y'
     !P.THICK=2.
     !X.THICK=1.5
     !Y.THICK=1.5
     !P.CHARTHICK=2.
     psname='satvar'+string(index,'(i2.2)')+'p'+string(countps,'(i2.2)')
     countps=countps+1 & set_plot,'ps'
     device,/color,bits=8
     device,filename=psname+'.ps'
     device, /landscape, /helvetica, /bold
;     device, /landscape, /helvetica, /bold, font_index=3
     device, /inches, xsize=10., ysize=8., scale_factor=0.95, $
                      xoffset=0.5,yoffset=10.1
  endif


  print,'1. tfac', tfac
plotall:
  plotvars,coordstrn,base
  if (withps ne 'y') then  window,0,xsize=900,ysize=720,title='Overview Plot'
  plotwaldhtsim,tfac*tmin,tfac*tmax, strnn,totnumint,t1a,t2a,coordstrn,$
             delt,fdelt,slht0,slht1,slwal0,slwal1,itest,deltab,bntest,vardat
  if withps eq 'y' then  begin 
     withps = 'n' & closeps='n' & device,/close & set_plot,'x'
     !P.THICK=1. & !X.THICK=1. & !Y.THICK=1. & !P.CHARTHICK=1.
  endif
goto, cut

end
