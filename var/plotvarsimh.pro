PRO plotvarsimh, min, max, strnn,coordstrn,base,eb1,eb2,eb3,vht,$
                htpresent,varpresent,beta0,tvarmin,tvarmax,smo

; Plot of 1D MHD data either smpled in satbin or as cuts through 
;   2D or 3D simulation domains. Here resistivity is considered.
;    -> see also plotvarsim (without the resistive terms.
; Note: Sat data does not yet include resitive terms.

COMMON procommon, nsat,startime,itot,pi,ntmax, $
                  rhobd,pbd,vxbd,vybd,vzbd,bxbd,bybd,bzbd, $
                  xsi,ysi,zsi,vxsi,vysi,vzsi, $
                  time,bxs,bys,bzs,vxs,vys,vzs,rhos,ps,bs,ptots, $
                  jxs,jys,jzs,xs,ys,zs,cutalong
COMMON units, nnorm,bnorm,vnorm,pnorm,lnorm,tnorm,tempnorm,jnorm,$
              nfac,bfac,vfac,pfac,lfac,tfac,tempfac,jfac
COMMON ref, br,vr,rhor,pr,babr,ptotr,pbr,tempr,beta,t, $
            jr,er,rsat,vrsat,index,starttime,xtit,withps,$
            satchoice,withunits
COMMON pltvar, vplot,bplot

    names=strarr(15) & names=replicate(' ',15)
    if coordstrn eq 'GSM' then begin
      ix='X' & iy='Y' & iz='Z'
    endif else begin
      ix='I' & iy='J' & iz='K'
    endelse

    if withunits eq 'n' then begin
      tempustr= '' & densustr= '' & pustr   = ''
      bustr   = '' & vustr   = '' & justr   = '' & eustr   = ''
   endif
    if withunits eq 'y' then begin
      tempustr= 'keV' & densustr= 'cm!U-3!N' & pustr   = 'nPa'
      bustr   = 'nT' & vustr   = 'km/s' & justr   = 'nA/m!U2!N'
      eustr   = 'mV/m'
   endif

  print,'BETA0:',beta0

;plotcoordinates for 2nd column
    dpx=0.41  & dpy=0.165
    xab=0.545 & xeb=xab+dpx 
    ylo1=0.55 & yup1=ylo1+dpy
    ylo2=ylo1-dpy & yup2=ylo1
    ylo3=ylo2-dpy & yup3=ylo2
    ylo4=ylo3-dpy & yup4=ylo3

;plotcoordinates for 1st column
    dpx=0.41  & dpy=0.165
    xap=0.055 & xep=xap+dpx 
    ylo0=0.715 & yup0=ylo0+dpy
    ylo1=ylo0-dpy & yup1=ylo0
    ylo2=ylo1-dpy & yup2=ylo1
    ylo3=ylo2-dpy & yup3=ylo2
    ylo4=ylo3-dpy & yup4=ylo3


      tvlct,[0,255,0,100,0,255,230],[0,0,255,100,255,0,230],$
                                    [0,0,0,255,255,255,0]
      red   = 1
      green = 2
      blue  = 3
      yebb  = 4
      grbl  = 5
      yell  = 6
    col1=0 & col2=yell & col3=green & col4=red
    
    erase
    !P.REGION=[0.,0.,1.0,1.0]
    !P.MULTI=[0,1,1]
    !P.CHARSIZE=1.
    !P.CHARTHICK=1.
    !P.FONT=-1
;    !X.TICKS=0
;    !Y.TICKS=0
    !X.TICKlen=0.04
    !Y.TICKlen=0.03
    !X.THICK=1
    !Y.THICK=1
    if withps eq 'y' then begin
      !P.CHARSIZE=0.8
      !P.CHARTHICK=3.
      !P.THICK=4.
      !P.FONT=2
      !X.THICK=3
      !Y.THICK=3
    endif
         
    print, 'min+max', min,max
    print, 't:', t
    intbd,min,max,itot,t,ips,ipe
    del = max-min



;   Temperature and Density
    !P.POSITION=[xap,ylo0,xep,yup0]
    dum=0.
    if ipe ge ips then begin
      tt1=fltarr(ipe-ips+1) & dum=[dum,rhor(ips:ipe)] & endif
    bmax=max(dum) & bmin=min(dum) & if bmax eq 0.0 then bmax=1.
    bmin=0.01 & delb=bmax-bmin & rhomax=bmax+0.05*delb & rhomin=bmin-0.05*delb
    plot, [min,max],[rhomin,rhomax],/nodata,ytick_get=yy,$
          xrange=[min,max],yrange=[rhomin,rhomax],$
	  title=strnn+' '+coordstrn,$
	  xstyle=1,ystyle=9,xtickname=names,/noerase
;	  xstyle=1,ystyle=2,xtickname=names,ytickname=names,/noerase
    if ipe ge ips then $
      oplot, t(ips:ipe), rhor(ips:ipe),line=0,color=blue
    xt0=min-0.10*del  &   yt0=bmin+0.62*delb    
    xt1=min-0.12*del  &   yt1=bmin+0.45*delb    
    xyouts, xt0, yt0, 'N',charsize=1
    xyouts, xt1, yt1,densustr,charsize=0.9
    xt0=max+0.08*del  &   yt0=bmin+0.62*delb    
    xt1=max+0.07*del  &   yt1=bmin+0.45*delb    
    xyouts, xt0, yt0, 'T',charsize=1
    xyouts, xt1, yt1,tempustr,charsize=0.9

    tempmax=max(tempr) & print, 'Temp, max: ',tempmax
    temprange = tempmax   & tempscale = (rhomax-rhomin)/1.1/temprange
	axis,yaxis=1,yrange=[-0.05,1.05*temprange],ystyle=1
    if ipe ge ips then $
	oplot, t(ips:ipe), tempscale*tempr(ips:ipe), line=2,color=red

;  Print plot info
    tdy=0.16*delb
    xt2=max+0.2*del &  xt2p=max+0.3*del 
    yt0=bmin+tdy & yt1=bmin+2.*tdy & yt2=bmin+3.*tdy & yt3=bmin+4.*tdy
    yt4=bmin+5.*tdy & yt5=bmin+6.*tdy
    xyouts, xt2, yt5+.3*tdy,'___',charsize=1
    xyouts, xt2, yt4+.3*tdy,'_  _',charsize=1
    xyouts, xt2, yt3+.3*tdy,'_ . _',charsize=1
    xyouts, xt2p, yt5,'N, p, x comp of V, B, J, E',charsize=1
    xyouts, xt2p, yt4,'T, p!DB!N, y components',charsize=1
    xyouts, xt2p, yt3,'p!Dtot!N,  z components ',charsize=1
    if varpresent eq 'y' then begin
     if withunits eq 'y' then tform='(f6.0)' else tform='(f6.2)'
     xyouts, xt2p, yt2,'Variance Interval:'+string(tfac*tvarmin,tform)+' - '$
             +string(tfac*tvarmax,tform),charsize=1
    endif
    if htpresent eq 'y' then begin
      vht1=base#vht 
     if withunits eq 'y' then tform='(f7.0)' else tform='(f7.2)'
     xyouts, xt2p, yt1,'HT velocity:'+string(vht1(0),tform)$
             +string(vht1(1),tform)+string(vht1(2),tform),charsize=1     
    endif


;   V
    !P.POSITION=[xap,ylo1,xep,yup1]
    dum=0.
    if ipe ge ips then begin
      tt1=fltarr(ipe-ips+1) & tt1(*)=vplot(0,ips:ipe) & dum=[dum,tt1] 
      tt2=fltarr(ipe-ips+1) & tt2(*)=vplot(1,ips:ipe) & dum=[dum,tt2] 
      tt3=fltarr(ipe-ips+1) & tt3(*)=vplot(2,ips:ipe) & dum=[dum,tt3] 
    endif
    bmax=max(dum) & bmin=min(dum) 
    if bmax le bmin then begin & bmax=1. & bmin=-1. & endif
    delb=bmax-bmin   & bmax=bmax+0.05*delb & bmin=bmin-0.05*delb
    plot, [min,max],[bmin,bmax],/nodata, $
          xrange=[min,max],yrange=[bmin,bmax],ytick_get=vv,$
	  xstyle=1,ystyle=1,xtickname=names,/noerase 
    if ipe ge ips then begin
      if (bmin*bmax lt 0.) then oplot, [t(ips),t(ipe)],[0.,0.],line=1
      oplot, t(ips:ipe), vplot(0,ips:ipe),line=0
      oplot, t(ips:ipe), vplot(1,ips:ipe),line=2,color=blue
      oplot, t(ips:ipe), vplot(2,ips:ipe),line=3,color=red
    endif
    xt0=min-0.12*del  &   yt0=bmin+0.62*delb    
    xt1=min-0.15*del  &   yt1=bmin+0.45*delb    
    xyouts, xt0, yt0, 'V', charsize=1
    xyouts, xt1, yt1,vustr,charsize=0.9
    print,'V:',vv

;   B
    !P.POSITION=[xap,ylo2,xep,yup2]
    dum=0.
    if smo eq 'y' then begin
      bplot(0,*)=smooth(bplot(0,*),3)
      bplot(1,*)=smooth(bplot(1,*),3)
      bplot(2,*)=smooth(bplot(2,*),3)
    endif
    if ipe ge ips then begin
      tt1=fltarr(ipe-ips+1) & tt1(*)=bplot(0,ips:ipe) & dum=[dum,tt1] 
      tt2=fltarr(ipe-ips+1) & tt2(*)=bplot(1,ips:ipe) & dum=[dum,tt2] 
      tt3=fltarr(ipe-ips+1) & tt3(*)=bplot(2,ips:ipe) & dum=[dum,tt3] 
    endif
    bmax=max(dum) & bmin=min(dum) 
    if bmax le bmin then begin & bmax=1. & bmin=-1. & endif
    delb=bmax-bmin  & bmax=bmax+0.05*delb & bmin=bmin-0.05*delb
    plot, [min,max],[bmin,bmax],/nodata, $
          xrange=[min,max],yrange=[bmin,bmax],ytick_get=vv,$
	  xstyle=1,ystyle=1,xtickname=names,/noerase 
    if ipe ge ips then begin
      if (bmin*bmax lt 0.) then oplot, [t(ips),t(ipe)],[0.,0.],line=1
      oplot, t(ips:ipe), bplot(0,ips:ipe),line=0
      oplot, t(ips:ipe), bplot(1,ips:ipe),line=2,color=blue
      oplot, t(ips:ipe), bplot(2,ips:ipe),line=3,color=red
    endif
    xt0=min-0.10*del  &   yt0=bmin+0.62*delb    
    xt1=min-0.11*del  &   yt1=bmin+0.45*delb    
    xyouts, xt0, yt0, 'B',charsize=1
    xyouts, xt1, yt1,bustr,charsize=0.9
    print,'B:',vv

;   Pressure, pr,pbr,ptotr
    !P.POSITION=[xap,ylo3,xep,yup3]
    dum=0. 
    eplot=er & title0=strnn+' '+coordstrn
    if smo eq 'y' then begin
      eplot(0,*)=smooth(eplot(0,*),3)
      eplot(1,*)=smooth(eplot(1,*),3)
      eplot(2,*)=smooth(eplot(2,*),3)
    endif
    if htpresent eq 'y' then begin 
      title0='' 
      exh=fltarr(3,itot) & eyh=exh & ezh=exh
      exh = vht(2)*br(1,*) - vht(1)*br(2,*)
      eyh = vht(0)*br(2,*) - vht(2)*br(0,*)
      ezh = vht(1)*br(0,*) - vht(0)*br(1,*)
      eh=[exh,eyh,ezh] & eplot=er-eh
    endif
    eplot=base#eplot  
    if ipe ge ips then begin
      tt1=fltarr(ipe-ips+1) & tt1(*)=eplot(0,ips:ipe) & dum=[dum,tt1] 
      tt2=fltarr(ipe-ips+1) & tt2(*)=eplot(1,ips:ipe) & dum=[dum,tt2] 
      tt3=fltarr(ipe-ips+1) & tt3(*)=eplot(2,ips:ipe) & dum=[dum,tt3] 
    endif
    bmax=max(dum) & bmin=min(dum) 
    if bmax le bmin then begin & bmax=1. & bmin=-1. & endif
    delb=bmax-bmin   & bmax=bmax+0.05*delb & bmin=bmin-0.05*delb
    plot, [min,max],[bmin,bmax],/nodata, $
          xminor=xminor, xrange=[min,max],yrange=[bmin,bmax],title='',$
;	  title=title0,$
	  xstyle=1,ystyle=2,xtickname=names,/noerase 
    if ipe ge ips then begin
      if (bmin*bmax lt 0.) then oplot, [t(ips),t(ipe)],[0.,0.],line=1
      oplot, t(ips:ipe), eplot(0,ips:ipe),line=0
      oplot, t(ips:ipe), eplot(1,ips:ipe),line=2,color=blue
      oplot, t(ips:ipe), eplot(2,ips:ipe),line=3,color=red
    endif
    xt0=min-0.12*del  &   yt0=bmin+0.62*delb    
    xt1=min-0.15*del  &   yt1=bmin+0.45*delb    
    if htpresent ne 'y' then xyouts, xt0, yt0, 'E',charsize=1 $
       else xyouts, xt0, yt0, 'E!Dht!N',charsize=1
    xyouts, xt1, yt1, eustr,charsize=0.9


;   J
    !P.POSITION=[xap,ylo4,xep,yup4]
    if (satchoice eq '2' or satchoice eq '3') then begin 
      jplot=jr & jplot=base#jplot
      if ipe ge ips then begin
        bmax=max(jplot(*,ips:ipe)) & bmin=min(jplot(*,ips:ipe))
      endif else begin
        bmax=1.e-9 & bmin=-1.e-9
      endelse 
      delb=bmax-bmin  & bmax=bmax+0.05*delb & bmin=bmin-0.05*delb
      plot, [min,max],[bmin,bmax],/nodata, ytick_get=vv,$
	  xrange=[min,max], yrange=[bmin,bmax], $
	  xstyle=1,ystyle=1,xtitle=xtit,/noerase
      if ipe ge ips then begin
      if (bmin*bmax lt 0.) then oplot, [t(ips),t(ipe)],[0.,0.],line=1
        oplot, t(ips:ipe), jplot(0,ips:ipe)
        oplot, t(ips:ipe), jplot(1,ips:ipe),line=2,color=blue
        oplot, t(ips:ipe), jplot(2,ips:ipe),line=3,color=red
      endif
      xt0=min-0.10*del  &   yt0=bmin+0.62*delb    
      xt1=min-0.14*del  &   yt1=bmin+0.45*delb    
      xyouts, xt0, yt0, 'J',charsize=1
      xyouts, xt1, yt1, justr,charsize=0.9
    endif






  return
end

