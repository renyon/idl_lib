; START OF PROGRAM

  nr=101 
  r=findgen(nr) & rkm=r
  j=fltarr(nr,/NOZERO) & the=j & n=j & nl=j & m=j 
  b0=j & lb=j & db=j & dx=j 
  dcs=j & js=j & vash=j & vab0=j & vab1=j & tash=j & eash=j & ec=j 
  pi=3.14159
;-------------
; PARAMETER:
;-------------
; 1) AREA
;    l0-McIlwain Par; r0,r1-radial bounds in RE; re-RE
  re=6400.0
  l0=4 & r0=1.016 & r1=1.9
  dr=(r1-r0)/float(nr-1) & r=dr*r+r0 & rkm=(r-1.0)*re

; 2) Dipole field strength
;    b0-dipole field in nT; the-dipole latitude from north; 
;    lb-field line length for l0=const in RE;
  the = 180.0/3.14159*asin(sqrt(r/l0))
  fromzenith=180.0/3.14159*atan( 0.5*3.14159/180.0*the(0) )
  print, 'latitude from north    =', the(0)
  print, 'field elev from zenith =', fromzenith
  b0 = 29500.0*sqrt(4.0-3.0*r/l0)/r^3.0
  lb = re*l0*4.0/3.0*( $ 
          sqrt( (1.0-0.75*r0/l0)*(1.0-r0/l0) )$
        - sqrt( (1.0-0.75*r/l0)*(1.0-r/l0) )$
        + 0.5/sqrt(3.0)*alog( $
              (sqrt(0.75)*sqrt(1.0-r0/l0)+sqrt(1.0-0.75*r0/l0))$
             /(sqrt(0.75)*sqrt(1.0-r/l0)+sqrt(1.0-0.75*r/l0)) )  )

; 3) Mass density
;    n-number density r>1.05 !!!; m-effective ion mass;
  n0=10.0^5 & z0=200.0 & nmsp=5.0 & nbl=2.0
;  n = 5.0*n0/( exp(-2.173*(rkm-z0)/100.0)+exp(0.522*(rkm-z0)/100.0) )$
  n = 2.0*n0/( exp(-(rkm-z0)/50.0)+exp((rkm-z0)/500.0) )$
      + nmsp/(r-1.0)^1.5 + nbl/cosh(0.5*(r-10.0))
;  nl = n0/( exp(-4.173*(rkm-z0)/100.0)+exp(0.522*(rkm-z0)/100.0) )$
  nl = n0/( exp(-(rkm-z0)/50.0)+exp((rkm-z0)/500.0) )$
      + nmsp/(r-1.0)^1.5 + nbl/cosh(0.5*(r-10.0))
;Lysak:  
;  nl = 0.5*n0*exp( -10.0*(r-1.05) ) + nmsp/(r-1.0)^1.5
  z0=700.0 
  m = 0.0*m+1.0+6.0*( 1.0 - tanh((rkm-z0)/200.0) )

; 4) Electron Temperature in degrees Kelvin
  z0=150.0
  temp= 2800.0/( exp(-(rkm-z0)/20.0)+exp(-(rkm-z0)/3000.0) + 0.001)
  templ= 1500.0/( exp(-(rkm-z0)/20.0)+exp(-(rkm-z0)/3000.0) + 0.001)

; 8) Neutral Density

  nn0=10.0^10 & zn0=140.0 
  nn = 2.0*nn0*( exp(-(rkm-z0)/5.0)+exp(-(rkm-z0)/120.0) )+1.0
  nn1 = 0.5*nn0*( exp(-(rkm-z0)/5.0)+exp(-(rkm-z0)/80.0) )+1.0
  mn = 8.0+3.5*( 1.0 - tanh((rkm-z0)/50.0) )

; 9) Collision frequencies
; nei=electron-ion,  nin=ion-neutral, nen=electron-neutral

  nei=55.0*n/temp^1.5
  nei1=55.0*n/temp^1.5
  nen=10.0^(-10)*nn*(1.0+0.6/1000.0*temp)*sqrt(temp)      ;for O
  nen1=10.0^(-10)*nn*(1.0+0.6/1000.0*temp)*sqrt(temp)
  nin=5.0*10.0^(-10)*nn          ;rough guess for an average
  nin1=5.0*10.0^(-10)*nn        ;rough guess for an average


    pos1=[0.2,0.78,0.7,0.96]
    pos2=[0.2,0.55,0.7,0.73]
    pos3=[0.2,0.32,0.7,0.50]
    pos4=[0.2,0.09,0.7,0.27]

    again='y' & withps='n' & contin='y'
    while again eq 'y' do begin

      print, 'With postscript?'
      read, withps
       if withps eq 'y' then begin 
         set_plot,'ps'
        device,filename='arc.ps'
        device,/inches,xsize=8.,scale_factor=1.0,xoffset=0.5
        device,/inches,ysize=10.0,scale_factor=1.0,yoffset=0.5
        device,/times,/bold,font_index=3
       endif
; first page
  !P.REGION=[0.,0.,1.0,1.25]

  print, 'plot 1. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max(n)
    amin = min(n)
    plot_io, rkm, n,$
        title='Number Density [cm!U-3!N]',$
        font=3, yrange=[amin, amax], ystyle=1
;    oplot, rkm, nl, line=2
;    oplot, k, q(2,0:nx-1), line=2
;    oplot, k, q(3,0:nx-1), line=3
    !P.POSITION=pos2
    amax = max([nn,nn1])
    amin = min([nn,nn1])
    plot_io, rkm, nn,$
        title='Neutral Density [cm!U-3!N]',$
        font=3, yrange=[amin,amax]
    oplot, rkm, nn1, line=2
    !P.POSITION=pos3
    amax = max([nei,nei1])
    amin = min([nei,nei1])
    plot_io, rkm, nei,$
        title='Electron Ion Collision Frequency [s!U-1!N]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, nei1, line=2
    !P.POSITION=pos4
    amax = max([nen,nen1])
    amin = min([nen,nen1])
    plot_io, rkm, nen,$
        title='Electron Neutral Collision Frequency [s!U-1!N]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, nen1, line=2






;    !P.POSITION=pos4
;;    amax = max([temp,templ])
;;    amin = min([temp,templ])
;    amax = max(temp)
;    amin = min(temp)
;    plot_io, rkm, temp,$
;        title='Electron Temperature [K]',$
;        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
;;    oplot, rkm, templ, line=2
  endif


  print, 'plot 2. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([db,db1])
    amin = min([db,db1])
    plot, rkm, db,$
        title='Perpendicular Magnetic Field [nT]',$
        font=3, yrange=[0, amax], ystyle=1
    oplot, rkm, db1, line=2
    !P.POSITION=pos2
    amax = max([dcs,dcs1])
    amin = min([dcs,dcs1])
    plot, rkm, dcs,$
        title='Current Sheet Width [km]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, dcs1, line=2
    !P.POSITION=pos3
    amax = max([dx,dx1])
    amin = min([dx,dx1])
    plot, rkm, dx,$
        title='Arc Length [km]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, dx1, line=2
    !P.POSITION=pos4
    amax = max([vab0,vab1])
    amin = min([vab0,vab1])
    plot_io, rkm, vab0,$
        title='Alfven Velocity in Dipole Field [km s!U-1!N]',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, vab1, line=2
  endif


  print, 'plot 2a. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([j,j1])
    amin = min([j,j1])
    plot, rkm, j,$
        title='Current Density [A/m^2]',$
        font=3, yrange=[0,amax], ystyle=1
    oplot, rkm, j1, line=2
    !P.POSITION=pos2
    amax = max([resfac,resfac1])
    amin = min([resfac,resfac1])
    plot_io, rkm, resfac,$
        title='Anomalous Resistivity [Ohm m]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, resfac1, line=2
    !P.POSITION=pos3
    amax = max([res,res1])
    amin = min([res,res1])
    plot_io, rkm, res,$
        title='Collisional Resistivity [Ohm m]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, res1, line=2
    !P.POSITION=pos4
    cond=1./res & cond1=1./(res+resfac)
    amax = max([cond,cond1])
    amin = min([cond,cond1])
    plot_io, rkm, cond,$
        title='Conductivity [Mho/m]',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, cond1, line=1
  endif


  print, 'plot 3. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([vash,vash1])
    amin = min([vash,vash1])
    plot_io, rkm, vash,$
        title='Alfven Velocity in Perp Field [km s!A-1!N]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, vash1, line=2
    !P.POSITION=pos2
    amax = max([tash,tash1])
    amin = min([tash,tash1])
    plot_io, rkm, tash,$
        title='Alfven Time in Perp Field [s]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, tash1, line=2
    !P.POSITION=pos3
    amax = max([eash,eash1])
    amin = min([eash,eash1])
    plot_io, rkm, eash,$
        title='Parall. Electric Field [mV m!U-1!N](upper limit)',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, eash1, line=2
    !P.POSITION=pos4
    amax = max([ec,ec1])
    amin = min([ec,ec1])
    plot_io, rkm, ec,$
        title='Convection Electric Field [mV m!U-1!N]',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, ec1, line=2

  endif


  print, 'plot 4. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([nn,nn1])
    amin = min([nn,nn1])
    plot_io, rkm, nn,$
        title='Neutral Density [cm!U-3!N]',$
        font=3, yrange=[amin,amax]
    oplot, rkm, nn1, line=2
    !P.POSITION=pos2
    amax = max([nei,nei1])
    amin = min([nei,nei1])
    plot_io, rkm, nei,$
        title='Electron Ion Collision Frequency [s!U-1!N]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, nei1, line=2
    !P.POSITION=pos3
    amax = max([nen,nen1])
    amin = min([nen,nen1])
    plot_io, rkm, nen,$
        title='Electron Neutral Collision Frequency [s!U-1!N]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, nen1, line=2
    !P.POSITION=pos4
    amax = max([nin,nin1])
    amin = min([nin,nin1])
    plot_io, rkm, nin,$
        title='Ion Neutral Collision Frequency [s!U-1!N]',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, nin1, line=2

  endif


  print, 'plot 5. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([noei,noei1])
    amin = min([noei,noei1])
    plot_io, rkm, noei,$
        title='Normalized Nu_ei',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, noei1, line=2
    !P.POSITION=pos2
    amax = max([noen,noen1])
    amin = min([noen,noen1])
    plot_io, rkm, noen,$
        title='Normalized Nu_en',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, noen1, line=2
    !P.POSITION=pos3
    amax = max([noin,noin1])
    amin = min([noin,noin1])
    plot_io, rkm, noin,$
        title='Normalized Nu_in',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, noin1, line=2
    !P.POSITION=pos4
    amax = max([lambda,lambda1])
    amin = min([lambda,lambda1])
    plot_io, rkm, lambda,$
        title='Normalized Electron Inertia',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, lambda1, line=2

  endif


  print, 'plot 6. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([etaei,etaei1])
    amin = min([etaei,etaei1])
    plot_io, rkm, etaei,$
        title='Normalized Resistivity from e-i C',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, etaei1, line=2
    !P.POSITION=pos2
    amax = max([etaen,etaen1])
    amin = min([etaen,etaen1])
    plot_io, rkm, etaen,$
        title='Normalized Resistivity from e-n C',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, etaen1, line=2
    !P.POSITION=pos3
    amax = max([etain,etain1])
    amin = min([etain,etain1])
    plot_io, rkm, etain,$
        title='Normalized Resistivity from i-n C',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, etain1, line=2
    !P.POSITION=pos4
    amax = max([eta,eta1])
    amin = min([eta,eta1])
    plot_io, rkm, eta,$
        title='Total Normalized Resistivity by Collisions',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, eta1, line=2

  endif

  print, 'plot 7. page?'
  read, contin
  if (contin eq '' or contin eq 'y') then begin
    !P.CHARSIZE=2  
    !P.MULTI=[0,0,4]
    !P.POSITION=pos1
    amax = max([taudiff,taudiff1])
    amin = min([taudiff,taudiff1])
    plot_io, rkm, taudiff,$
        title='Diffussion Time [s]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, taudiff1, line=2
    !P.POSITION=pos2
    amax = max([taurek,taurek1])
    amin = min([taurek,taurek1])
    plot_io, rkm, taurek,$
        title='Tearing/Rekonnection Time [s]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, taurek1, line=2
    !P.POSITION=pos3
    amax = max([ediff,ediff1])
    amin = min([ediff,ediff1])
    plot_io, rkm, ediff,$
        title='Diffussion Electric Field  [micro V/m]',$
        font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, ediff1, line=2
    !P.POSITION=pos4
    amax = max([erek,erek1])
    amin = min([erek,erek1])
    plot_io, rkm, erek,$
        title='Rekonnection Electric Field  [micro V/m]',$
        xtitle='r / km', font=3, yrange=[amin,amax], ystyle=1
    oplot, rkm, erek1, line=2

 

  endif

 
      print, 'again?'
      read, again



  if withps eq 'y' then device,/close
  set_plot,'x'

  endwhile

end


