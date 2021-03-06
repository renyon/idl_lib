; START OF MAIN PROGRAM
;
; program needs update for vect, and laser 600 resolution
COMMON program_par, nx,nxn,nxf, ny,nyn,nyf, nz,nzn,nzf,$
                    x,y,z, xf,yf,zf, xn,yn,zn, iox,ioy,ioz, $
                    ioxf,ioyf,iozf, run, time
COMMON program_var, fp1,fp2,xsu,ysu,f0,xchoice,ychoice,far1,far2,xar,yar

; GRID FOR VELOCITY VECTORS
   nxn = 21   &   nyn = 21   &   nzn=21 
   fn1=fltarr(nxn,nyn) & fn2=fn1
; GRID FOR CONTOUR AND SURFACE PLOTS
   nxf = 121   &   nyf = 121  &  nzf=121 
   fa=fltarr(nxf,nyf) & fb=fa
  nx=long(131) & ny=long(126) & nz=long(126) 
  time=0.0 & fnumber=1
  fgroup='1' & group='1'
  name='' & wsmooth='' & again='y' & withps='n' & run=''  
  closeps='n' & jnew='y' & newplot='a' & coltab='o' & intplot='f'
  plane='x' & whatcut='x' & choice='f' & igrid=80
  jnew= 'y' & enew= 'y' & onedcut='f'
  oned0='1' & onedarr='1' & heado='' & onedco='x'
  names=strarr(15) &  names=replicate(' ',15)
  ctab=findgen(nxf) &   cbary=fltarr(2,nxf)
   contonly = 'n' & orient='l' & grayplot ='n' & colps ='n'
   wlong=900 & wshort=720 & wfact=1.0 &  wxf=1.0 & wyf=1.0 & psfact=0.9
   wsize=[700,900] & wsold=[0,0] & wino=0 & srat0=1.1
   nl1=9  &  nl2=9 
;-----------PARAMETER----------------
  xmin = -40. & ymin = -15.  & zmin = -2
  xmax =   5. & ymax =  15.  & zmax = 2.

; READ INPUT DATA OF DIMENSION NX, NY,NZ
;  read3d, dx,dxh,dy,dyh,dz,dzh, bx,by,bz,sx,sy,sz,rho,u,res
  read3sym, dx,dxh,dy,dyh,dz,dzh, bx,by,bz,sx,sy,sz,rho,u,res
  bx=smooth(bx,3) & by=smooth(by,3) & bz=smooth(bz,3)
  sx=smooth(sx,3) & sy=smooth(sy,3) & sz=smooth(sz,3)
  rho=smooth(rho,3) & u=smooth(u,3) & res=smooth(res,3)

  ex=bx & ey=bx & ez=bx & jx=bx & jy=bx & jz=bx
  testbd3, nx,ny,nz,x,y,z,xmin,xmax,ymin,ymax,zmin,zmax
    
  printstuff, bx,by,bz,sx,sy,sz,rho,u,res

; GRID FOR VELOCITY VECTORS 
grid3d, x,y,z,xmin,xmax,ymin,ymax,zmin,zmax,$
        nxn,nyn,nzn,xn,yn,zn,iox,ioy,ioz,dxn,dyn,dzn
; GRID FOR CONTOUR/SURFACE PLOTS
grid3d, x,y,z,xmin,xmax,ymin,ymax,zmin,zmax,$
        nxf,nyf,nzf,xf,yf,zf,ioxf,ioyf,iozf,dxf,dyf,dzf

  fgroup = '3' 
  head1='Magn. Field Bx' & head2='Magn. Field By'
  head3='Magn. Field Bz' & imt='b'
  f1=bx & f2=by & f3=bz & p=2*u^(5.0/3.0) & f4=p 
  
    choice = 'x' 
    plane='x' & nplane=nx & coord=x 
    if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
    cutata='x=' & cutatb=string(x(igrid),'(f5.1)')
    xtit='y'    & ytit='z'    & xchoice=y   & ychoice=z
    xpmin=ymin  & xpmax=ymax  & ypmin=zmin  & ypmax=zmax 
    fc1=f1(igrid,*,*) & fc1=reform(fc1) 
    fc2=f2(igrid,*,*) & fc2=reform(fc2) 
    fc3=f3(igrid,*,*) & fc3=reform(fc3) 
    xplot=y  &  yplot=z
    fa=interpolate(fc1,ioyf,iozf,/grid)
    fb=interpolate(fc2,ioyf,iozf,/grid)
    fc=interpolate(fc3,ioyf,iozf,/grid)
    xsu=yf & ysu=zf 

menu:
        if withps eq 'y' then  begin 
           print, 'close postscript device? <y> or <n>'
           read, closeps
        endif
        if closeps eq 'y' then begin
            withps = 'n' & closeps='n'
            device,/close
            set_plot,'x'
            !P.THICK=1.
        endif
        if (withps eq 'y') and closeps ne 'y' then $
          print, 'postscript device is still open!'
        if (intplot eq 't') then print, 'integration is still active!'
  print, plane, ' Coordinates:
  for i=0,nplane-1,2 do print, i,'  ',plane,'=',coord(i)
  print, 'Input - i =Grid Index of Chosen Plane(>0 and <',nplane-1,')'
  print, 'Options:   <integer> -> grid index'
  print, '                 <x> -> y,z-plane, x=const'
  print, '                 <y> -> z,x-plane, y=const'
  print, '                 <z> -> x,y-plane, z=const'
  print, '                 <a> -> contour plots'
  print, '                 <b> -> arrow plots'
  print, '                 <i> -> perpendicular integration'
  print, '                 <j> -> switch off integration'
  print, '                 <u> -> 1D cut'
  print, '                 <w> -> back to 2D cut'
  print, '            <return> -> no changes applied'
  print, '                 <f> -> choose fields'
  print, '                 <g> -> gif output'
  print, '                 <p> -> postscript output'
  print, '                 <r> -> close postscript'
  print, '                 <c> -> load colortables'
  print, '                 <o> -> use original colortables'
  print, '                 <k> -> contour plot only'
  print, '                 <l> -> switch to color'
  print, '                 <m> -> color postscript'
  print, '                 <n> -> grayscale postscript (default)'
  print, '                 <s> -> smooth grid oscillations'
  print, '                 <t> -> no smoothing'
  print, '                 <q> -> terminate'
  print, 'Present Choice: ', igrid
  read, choice 
  if choice eq 'q' then stop
  if choice eq 'x' then plane='x' 
  if choice eq 'y' then plane='y' 
  if choice eq 'z' then plane='z' 
  if choice eq 'a' then newplot='a'
  if choice eq 'b' then newplot='b'
  if choice eq 'i' then intplot='t'
  if choice eq 'j' then intplot='f'
  if choice eq 'u' then onedcut='t'
  if choice eq 'w' then onedcut='f'
  if choice eq '' then if newplot eq 'a' then newplot='b' else newplot='a' 
  if choice eq 'k' then contonly='y'
  if choice eq 'l' then contonly='n'
  if choice eq 'm' then colps='y'
  if choice eq 'n' then colps='n'
  if (choice ne '') and (choice ne 'f') and (choice ne 'g') $ 
     and (choice ne 'x') and (choice ne 'y') and (choice ne 'z') $ 
     and (choice ne 'a') and (choice ne 'b')  $ 
     and (choice ne 'p') and (choice ne 'r')  $ 
     and (choice ne 'i') and (choice ne 'j')  $ 
     and (choice ne 'k') and (choice ne 'l')  $ 
     and (choice ne 'm') and (choice ne 'n')  $ 
     and (choice ne 'u') and (choice ne 'w')  $ 
     and (choice ne 's') and (choice ne 't')  $ 
     and (choice ne 'c') and (choice ne 'o') then igrid=fix(choice)
  if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
  if choice eq 'c' then begin
     xloadct
     coltab='c'
     goto, menu
  endif
  if choice eq 'o' then coltab='o'
  if choice eq 'g' then begin
    if (withps eq 'n') then begin
           tvlct,r,g,b,/get
           imag=tvrd()
           write_gif,'im'+imt+newplot+'_t'+string(time,'(i3.3)')+'_'+plane+ $
                      string(igrid,'(i3.3)')+'.gif',imag, r,g,b
    endif
    if (withps ne 'n') then print, 'switch off postscript output first'
    goto, menu
  endif
  if choice eq 'p' then begin 
    withps = 'y'
    if contonly eq 'n' then begin 
      set_plot,'ps' & ncol=!D.TABLE_SIZE & print,!D.TABLE_SIZE
      !p.color=0
      if colps eq 'n' then $
         device,/color,bits_per_pixel=8, $
             filename= 'plo'+imt+newplot+'_t'+string(time,'(i3.3)') $
                       +'_'+plane+string(igrid,'(i3.3)')+'g.ps' $ 
      else $
         device,/color,bits_per_pixel=8, $
             filename='plo'+imt+newplot+'_t'+string(time,'(i3.3)') $
                       +'_'+plane+string(igrid,'(i3.3)')+'col.ps'
    endif
    if contonly eq 'y' then begin 
        set_plot,'ps' 
        device,bits_per_pixel=2,$
             filename='plo'+imt+newplot+'_t'+string(time,'(i3.3)')$
                       +'_'+plane+string(igrid,'(i3.3)')+'c.ps'
    endif
    if srat gt srat0 then  begin
        device,/landscape
        device,/inches,xsize=10.,scale_factor=1.0,xoffset= 0.3
        device,/inches,ysize=8.0,scale_factor=1.0,yoffset=10.25
    endif
    if srat le srat0 then  begin
        device,/portrait
        device,/inches,xsize=8.,scale_factor=1.0,xoffset= 0.2
        device,/inches,ysize=10.0,scale_factor=1.0,yoffset=0.75
    endif
    !P.THICK=2.
;        device,/times,/bold,font_index=3
  endif

  if choice eq 'r' then begin
     withps = 'n' & closeps='n'
     device,/close
     set_plot,'x'
     !P.THICK=1.
     goto, menu
  endif  
  
  if choice eq 's' then wsmooth='y'
  if choice eq 't' then wsmooth=''

if choice eq 'f' then begin
  print, 'Input Fieldgroup:'
  print, 'Options: 1 - rho, p'
  print, '         2 - velocity, v'
  print, '         3 - magnetic field b'
  print, '         4 - current density'
  print, '         5 - electric field'
  print, '         6 - res, ptot'
  print, '         7 - j_parall, e_parall'
  print, '         q - terminate'
  print, '    return - no changes applied'
  print, 'Present Choice: ', fgroup
  read, group & if group ne '' then fgroup=group
  if group eq '' then print, 'present choice=',group,' not altered'
  if fgroup eq 'q' then stop
  if fgroup eq '1' then begin
    head1='Density' & head2='Pressure' & imt='np'
    f1=rho & f2=2*u^(5.0/3.0) & endif
  if fgroup eq '2' then begin
    head1='Vel. Vx' & head2='Vel. Vy' & head3='Vel. Vz' & imt='v'
    f1=sx/rho & f2=sy/rho & f3=sz/rho & endif 
  if fgroup eq '3' then begin
    head1='Magn. Field Bx' & head2='Magn. Field By' & imt='b'
    head3='Magn. Field Bz'
    f1=bx & f2=by & f3=bz & endif 
  if (fgroup eq '4') or (fgroup eq '5') or (fgroup eq '6') $
     or (fgroup eq '7') then begin $
    head1='Curr. Dens. Jx' & head2='Curr. Dens. Jy' & imt='j'
    head3='Curr. Dens. Jz'
    if jnew eq 'y' then begin
      f1 = shift(bz,0,-1,0)-shift(bz,0,1,0)
      for j=1,ny-2 do f3(*,j,*)=dy(j)*f1(*,j,*)
      f2 = shift(by,0,0,-1)-shift(by,0,0,1)
      for k=1,nz-2 do f4(*,*,k)=dz(k)*f2(*,*,k)
      jx = f3-f4
      f1 = shift(bx,0,0,-1)-shift(bx,0,0,1)
      for k=1,nz-2 do f3(*,*,k)=dz(k)*f1(*,*,k)
      f2 = shift(bz,-1,0,0)-shift(bz,1,0,0)
      for i=1,nx-2 do f4(i,*,*)=dx(i)*f2(i,*,*)
      jy = f3-f4
      f1 = shift(by,-1,0,0)-shift(by,1,0,0)
      for i=1,nx-2 do f3(i,*,*)=dx(i)*f1(i,*,*)
      f2 = shift(bx,0,-1,0)-shift(bx,0,1,0)
      for j=1,ny-2 do f4(*,j,*)=dy(j)*f2(*,j,*)
      jz = f3-f4
      jx([0,nx-1],*,*)=0.0 & jy([0,nx-1],*,*)=0.0 & jz([0,nx-1],*,*)=0.0
      jx(*,[0,ny-1],*)=0.0 & jy(*,[0,ny-1],*)=0.0 & jz(*,[0,ny-1],*)=0.0 
      jx(*,*,[0,nz-1])=0.0 & jy(*,*,[0,nz-1])=0.0 & jz(*,*,[0,nz-1])=0.0 
      jnew='n'
    endif
    f1=jx & f2=jy & f3=jz 
  endif
  if fgroup eq '5' then begin
    head1='Electr. Field Ex' & head2='Electr. Field Ey'
    head3='Electr. Field Ez' & imt='e'
    if enew eq 'y' then begin
      ex=(sy*bz-sz*by)/rho+res*jx
      ey=(sz*bx-sx*bz)/rho+res*jy
      ez=(sx*by-sy*bx)/rho+res*jz 
      enew='n'
    endif
    f1=ex & f2=ey & f3=ez 
  endif
  if fgroup eq '6' then begin
    head1='Resistivity' & head2='Ptot' & imt='rp'
       f1 = res
       f2=2*u^(5.0/3.0)+bx*bx+by*by+bz*bz
  endif
  if fgroup eq '7' then begin
    head1='E parallel' & head2='J parallel' & imt='ej'
       f3 = sqrt(bx*bx+by*by+bz*bz)
       f2 = (jx*bx+jy*by+jz*bz)/f3
       f1= res*f2
  endif  
endif


if onedcut eq 't' then begin

  print, 'Options: 1 - array 1'
  print, '         2 - array 2'
  print, '         3 - array 3'
  print, '         b - back to main'
  read, oned0
  if oned0  eq '1' then onedarr='1'
  if oned0  eq '2' then onedarr='2'
  if oned0  eq '3' then onedarr='3'
  if oned0  eq 'b' then goto, menu
  if onedarr eq '1' then begin 
    fo=fc1 & heado=head1  &  endif
  if onedarr eq '2' then begin 
    fo=fc2 & heado=head2  &  endif
  if onedarr eq '1' then begin 
    fo=fc3 & heado=head3  &  endif

  print, 'Options: cut at const x'
  print, '         cut at const y'
  read, onedco
  if onedco  eq 'x' then begin
    onex=yplot & os=size(xplot) & onp=os(1) & ot=ytit
    for i=0,onp-1,2 do print, i,'  ',onedco,'=',xplot(i)
    print, 'Input - i = 3 grid indices of chosen coordinate'
    read, oi1, oi2, oi3
    of1=fo(oi1,*) & of2=fo(oi2,*) & of3=fo(oi3,*)
    omin=ypmin &  omax=ypmax 
    ofmax=max([of1,of2,of3]) & ofmin=min([of1,of2,of3])
    !P.REGION=[0.,0.,1.0,1.25]
    pos1=[0.1,0.05,0.7,0.4]
    !P.POSITION=pos1
    
    erase
    pspl='n' & psmem='f'
opl:
    !P.CHARSIZE=2  
    oxmin= 0.0    & oxmax=3.0  & odx=oxmax-oxmin
    ofmin=-0.25   & ofmax=1.0  & odf=ofmax-ofmin
    ochs=1.0
    plot, onex, of1,title=heado, xtitle=ot,xrange=[0.0, 3.0],$
          yrange=[-0.25,1.0],line=0,ystyle=1,charsize=1.5
    oplot, onex, of2,line=1
    oplot, onex, of3,line=2
    xyouts,charsize=ochs,oxmax+0.1*odx,ofmin+0.9*odf,$
                       'time:'+string(time,'(i3)')
    xyouts,charsize=ochs,oxmax+0.1*odx,ofmin+0.7*odf,$
                       cutata+cutatb
    xyouts,charsize=ochs,oxmax+0.1*odx,ofmin+0.6*odf,$
                       xtit+'='+string(xplot(oi1),'(f5.2)')
    xyouts,charsize=ochs,oxmax+0.1*odx,ofmin+0.5*odf,$
                       xtit+'='+string(xplot(oi2),'(f5.2)')
    xyouts,charsize=ochs,oxmax+0.1*odx,ofmin+0.4*odf,$
                       xtit+'='+string(xplot(oi3),'(f5.2)')

    if psmem eq 't' then begin
     device,/close & set_plot,'x'
    endif
    
    print,'postscript?'
    read, pspl
    if pspl eq 'y' then begin
        psmem='t'
        set_plot,'ps'
        device,filename='oned.ps'
        device,/inches,xsize=8.,scale_factor=1.0,xoffset=0.5
        device,/inches,ysize=10.0,scale_factor=1.0,yoffset=0.5
        device,/times,/bold,font_index=3
        goto, opl
    endif




  endif

goto, menu

endif







if intplot eq 'f' then begin 
  if plane eq 'x' then begin 
    plane='x' & nplane=nx & coord=x 
    if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
    cutata='x=' & cutatb=string(x(igrid),'(f5.1)')
    xtit='y'    & ytit='z'    & xchoice=y   & ychoice=z
    xpmin=ymin  & xpmax=ymax  & ypmin=zmin  & ypmax=zmax 
    if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
    fc1=f1(igrid,*,*) & fc1=reform(fc1) 
    fc2=f2(igrid,*,*) & fc2=reform(fc2) 
    fc3=f3(igrid,*,*) & fc3=reform(fc3) 
    if wsmooth eq 'y' then begin
       fc1=smooth(fc1,3) & fc2=smooth(fc2,3) & fc3=smooth(fc3,3)
    endif
    xplot=y  &  yplot=z
    fa=interpolate(fc1,ioyf,iozf,/grid)
    fb=interpolate(fc2,ioyf,iozf,/grid)
    fc=interpolate(fc3,ioyf,iozf,/grid)
    xsu=yf & ysu=zf 
  endif
  if plane eq 'y' then begin 
    plane='y' & nplane=ny & coord=y 
    cutata='y=' & cutatb=string(y(igrid),'(f5.1)')
    xtit='x'    & ytit='z'    & xchoice=x   & ychoice=z
    xpmin=xmax  & xpmax=xmin  & ypmin=zmin  & ypmax=zmax 
    fc1=f1(*,igrid,*) & fc1=reform(fc1) 
    fc2=f2(*,igrid,*) & fc2=reform(fc2) 
    fc3=f3(*,igrid,*) & fc3=reform(fc3) 
    if wsmooth eq 'y' then begin
       fc1=smooth(fc1,3) & fc2=smooth(fc2,3) & fc3=smooth(fc3,3)
    endif
    xplot=z  &  yplot=x
    fa=interpolate(fc1,ioxf,iozf,/grid)
    fb=interpolate(fc2,ioxf,iozf,/grid)
    fc=interpolate(fc3,ioxf,iozf,/grid)
    xsu=xf & ysu=zf 
  endif
  if plane eq 'z' then begin 
    plane='z' & nplane=nz & coord=z 
    if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
    cutata='z=' & cutatb=string(z(igrid),'(f5.1)')
    xtit='x'    & ytit='y'    & xchoice=x   & ychoice=y
    xpmin=xmin  & xpmax=xmax  & ypmin=ymin  & ypmax=ymax 
    fc1=f1(*,*,igrid) & fc2=f2(*,*,igrid) & fc3=f3(*,*,igrid)  
    fc1=reform(fc1) & fc2=reform(fc2) & fc3=reform(fc3) 
    if wsmooth eq 'y' then begin
       fc1=smooth(fc1,3) & fc2=smooth(fc2,3) & fc3=smooth(fc3,3)
    endif
    xplot=x  &  yplot=y
    fa=interpolate(fc1,ioxf,ioyf,/grid)
    fb=interpolate(fc2,ioxf,ioyf,/grid)
    fc=interpolate(fc3,ioxf,ioyf,/grid)
    xsu=xf & ysu=yf 
  endif
endif
  
  
if intplot eq 't' then begin
  if plane eq 'x' then begin 
    plane='x' & nplane=nx & coord=x 
    cutata='intx' & cutatb=''
    xtit='y'    & ytit='z'    & xchoice=y   & ychoice=z
    xpmin=ymin  & xpmax=ymax  & ypmin=zmin  & ypmax=zmax 
    fc1=0.5/dx(2)*f1(2,*,*) & for k=3,nx-3 do fc1=fc1+0.5/dx(k)*f1(k,*,*)
    fc2=0.5/dx(2)*f2(2,*,*) & for k=3,nx-3 do fc2=fc2+0.5/dx(k)*f2(k,*,*)
    fc3=0.5/dx(2)*f3(2,*,*) & for k=3,nx-3 do fc3=fc3+0.5/dx(k)*f3(k,*,*)
    fc1=reform(fc1) & fc2=reform(fc2) & fc3=reform(fc3) 
    xplot=y  &  yplot=z
    fa=interpolate(fc1,ioyf,iozf,/grid)
    fb=interpolate(fc2,ioyf,iozf,/grid)
    fc=interpolate(fc3,ioyf,iozf,/grid)
    xsu=yf & ysu=zf 
  endif
  if plane eq 'y' then begin 
    plane='y' & nplane=ny & coord=y 
    cutata='inty' & cutatb=''
    xtit='x'    & ytit='z'    & xchoice=x   & ychoice=z
    xpmin=xmax  & xpmax=xmin  & ypmin=zmin  & ypmax=zmax 
    fc1=0.5/dy(2)*f1(*,2,*) & for k=3,ny-3 do fc1=fc1+0.5/dy(k)*f1(*,k,*)
    fc2=0.5/dy(2)*f2(*,2,*) & for k=3,ny-3 do fc2=fc2+0.5/dy(k)*f2(*,k,*)
    fc3=0.5/dy(2)*f3(*,2,*) & for k=3,ny-3 do fc3=fc3+0.5/dy(k)*f3(*,k,*)
    fc1=reform(fc1) & fc2=reform(fc2) & fc3=reform(fc3) 
    xplot=z  &  yplot=x
    fa=interpolate(fc1,ioxf,iozf,/grid)
    fb=interpolate(fc2,ioxf,iozf,/grid)
    fc=interpolate(fc3,ioxf,iozf,/grid)
    xsu=xf & ysu=zf 
  endif
  if plane eq 'z' then begin 
    plane='z' & nplane=nz & coord=z 
    if (igrid lt 0) or (igrid ge nplane) then igrid=nplane/2
    cutata='intz' & cutatb=''
    xtit='x'    & ytit='y'    & xchoice=x   & ychoice=y
    xpmin=xmin  & xpmax=xmax  & ypmin=ymin  & ypmax=ymax 
    fc1=0.5/dz(2)*f1(*,*,2) & for k=3,nz-3 do fc1=fc1+0.5/dz(k)*f1(*,*,k)
    fc2=0.5/dz(2)*f2(*,*,2) & for k=3,nz-3 do fc2=fc2+0.5/dz(k)*f2(*,*,k)
    fc3=0.5/dz(2)*f3(*,*,2) & for k=3,nz-3 do fc3=fc3+0.5/dz(k)*f3(*,*,k)
    fc1=reform(fc1) & fc2=reform(fc2) & fc3=reform(fc3) 
    xplot=x  &  yplot=y
    fa=interpolate(fc1,ioxf,ioyf,/grid)
    fb=interpolate(fc2,ioxf,ioyf,/grid)
    fc=interpolate(fc3,ioxf,ioyf,/grid)
    xsu=xf & ysu=yf 
  endif
endif



  
  xpos =xpmax+0.04*(xpmax-xpmin)
  yposa=ypmin+0.3*(ypmax-ypmin)
  yposb=ypmin+0.22*(ypmax-ypmin)
  ypos1=ypmin+0.4*(ypmax-ypmin)
  ypos2=ypmin+0.6*(ypmax-ypmin)
  ypos3=ypmin+0.75*(ypmax-ypmin)
  ypos4=ypmin+0.67*(ypmax-ypmin)
  ypos5=ypmin+0.95*(ypmax-ypmin)
  ypos6=ypmin+0.87*(ypmax-ypmin)
  xpost=xpmin+0.2*(xpmax-xpmin)
  ypost=ypmax+0.01*(ypmax-ypmin)

  delx=abs(xpmax-xpmin) & dely=abs(ypmax-ypmin) & srat=dely/delx
  difx=xpmax-xpmin & dify=ypmax-ypmin
  print,'delx',delx,dely,srat
  if srat gt srat0 then orient='l' else orient='p' 
  wxf=1. & wyf=1.  & xyrat=1.25
   if orient eq 'l' then begin
     ytit1=''
     xtit0=xtit
     psize=0.3 & sb0=2.4 & sb1=4.0
     if (srat lt sb0) then  begin
       wyf=(srat/sb0)^(0.7)
       dpx=psize
       if withps eq 'y' then  dpy=xyrat*srat*psize
       if withps eq 'n' then  dpy=xyrat*psize*sb0*(srat/sb0)^(0.3)
     endif
     if (srat ge sb0) and (srat lt sb1) then  begin
       wxf=(sb0/srat)^(0.7)
       dpy=xyrat*sb0*psize
       if withps eq 'y' then dpx=psize*sb0/srat
       if withps eq 'n' then dpx=psize*(sb0/srat)^0.3 
     endif
     if (srat ge sb1) then  begin
       wxf=(sb0/sb1)^(0.7)
       dpy=xyrat*sb0*psize
       if withps eq 'y' then dpx=psize*sb0/sb1
       if withps eq 'n' then dpx=psize*(sb0/sb1)^0.3 
     endif
     if withps eq 'y' then begin
       dpx=psfact*dpx & dpy=psfact*dpy
     endif 
     print, srat, dpx, dpy
     xinter=0.05 & cbthick=0.1*dpx & cbdist1=0.045 & cbdist2=0.055
     if withps eq 'n' then begin
      xinter=xinter/wxf & cbthick=cbthick/wxf 
      cbdist1=cbdist1/wxf & cbdist2=cbdist2/wxf
     endif
     xleft=0.5-0.5*xinter-dpx 
     xa1=xleft                & xe1=xleft+dpx  
     xa2=xe1+xinter           & xe2=xa2+dpx
     xcb1=xa1-cbdist1-cbthick & xcb2=xe2+cbdist2
     ylo=0.065                & yup=ylo+dpy
     pos1=[xa1,ylo,xe1,yup]  & pos2=[xcb1,ylo,xcb1+cbthick,yup]
     pos3=[xa2,ylo,xe2,yup]  & pos4=[xcb2,ylo,xcb2+cbthick,yup]
     hop=0.025 
     pos3a=[xa2-0.5*hop,ylo,xe2-0.5*hop,yup]
     pos4a=[xcb2+hop,ylo,xcb2+hop,yup]

     wsize=[wlong,wshort]  &  wsize=fix(wfact*wsize)
     wsize(0)=wxf*wsize(0) & wsize(1)=wyf*wsize(1)
     if (wsize(0) ne wsold(0)) or (wsize(1) ne wsold(1))  then $
       window,wino,xsize=wsize(0),ysize=wsize(1),title=run 
     wsold = wsize

     xpos=findgen(4)
     xpos(0)=xpmax+0.006*delx/dpxcolortab0
     xpos(1)=xpmin-0.03*delx/dpx
     xpos(2)=xpmax-0.12*delx
     xpos(3)=xpmax-0.005*delx/dpx
     ypos=findgen(10)
     ypos(0)=ypmin+0.2*dely            ; location for 'time'
     ypos(1)=ypos(0)-0.025*dely/dpy   ; next line
     ypos(2)=ypos(0)+0.075*dely/dpy   ; location 'CASE'
     ypos(3)=ypmin+.85*dely             ; location 'Max='
     ypos(4)=ypos(3)-0.025*dely/dpy   ; next line
     ypos(5)=ypmin+.65*dely    ; location 'Min='
     ypos(6)=ypos(5)-0.025*dely/dpy   ; next line
     ypos(7)=ypmin+.86*dely
     ypos(8)=ypmax+.04*dely
     ypos(9)=ypmin-.05*dely

   endif

   if orient eq 'p' then begin
     ytit1=ytit
     xtit0=''
     psize=0.4 & sb0=0.65 & sb1=0.3
     if (srat gt sb0) then  begin
       wxf=(sb0/srat)^(0.7)
       dpy=psize
       if withps eq 'y' then  dpx=psize*xyrat/srat
       if withps eq 'n' then  dpx=psize*xyrat/sb0*(sb0/srat)^(0.3)
     endif
     if (srat gt sb1) and (srat le sb0) then  begin
       wyf=(srat/sb0)^(0.7)
       dpx=psize*xyrat/sb0
       if withps eq 'y' then  dpy=psize/sb0*srat
       if withps eq 'n' then  dpy=psize*(srat/sb0)^(0.3)
     endif
     if (srat le sb1) then  begin
       dpx=psize*xyrat/sb0
       wyf=(sb1/sb0)^(0.7)
       if withps eq 'y' then  dpy=psize/sb0*sb1
       if withps eq 'n' then  dpy=psize*(sb1/sb0)^(0.3)
     endif
     if withps eq 'y' then begin
       dpx=psfact*dpx & dpy=psfact*dpy
     endif 
     xleft=0.08 & cbdist1=0.07 & cbthick=0.03*dpx  & yinter=0.05 
     if withps eq 'n' then begin
      yinter=yinter/wyf & cbthick=cbthick/wxf 
      cbdist1=cbdist1/wxf 
     endif
     ylo=0.5-0.5*yinter-dpy
     print, srat, dpx, dpy
     xa1=xleft & xe1=xleft+dpx  & xcb1=xe1+cbdist1
     ylo1=ylo & yup1=ylo+dpy & ylo2=yup1+yinter & yup2=ylo2+dpy 
     pos1=[xa1,ylo2,xe1,yup2]  & pos2=[xcb1,ylo2,xcb1+cbthick,yup2]
     pos3=[xa1,ylo1,xe1,yup1]  & pos4=[xcb1,ylo1,xcb1+cbthick,yup1]

     wsize=[wshort,wlong]  &  wsize=fix(wfact*wsize)
     wsize(0)=wxf*wsize(0) & wsize(1)=wyf*wsize(1)
     if (wsize(0) ne wsold(0)) or (wsize(1) ne wsold(1))  then $
       window,wino,xsize=wsize(0),ysize=wsize(1),title=run 
     wsold = wsize

     
     xpos=findgen(4)
     xpos(0)=xpmax+0.006*difx/dpx
     xpos(1)=xpmin-0.03*difx/dpx
     xpos(2)=xpmax-0.12*difx
     xpos(3)=xpmax-0.005*difx/dpx
     ypos=findgen(10)
     ypos(0)=ypmin+0.2*dify            ; location for 'time'
     ypos(1)=ypos(0)-0.025*dify/dpy   ; next line
     ypos(2)=ypos(0)+0.075*dify/dpy   ; location 'CASE'
     ypos(3)=ypmin+.85*dify             ; location 'Max='
     ypos(4)=ypos(3)-0.025*dify/dpy   ; next line
     ypos(5)=ypmin+.65*dify    ; location 'Min='
     ypos(6)=ypos(5)-0.025*dify/dpy   ; next line
     ypos(7)=ypmin+.86*dify
     ypos(8)=ypmax+.04*dify
     ypos(9)=ypmin-.05*dify

   endif
   
  grayplot=withps & if colps eq 'y' then grayplot='n'
       
       !P.REGION=[0.,0.,1.0,1.0]
       !P.MULTI=[0,6,0,0,0]
       !P.CHARSIZE=1.7
       !P.FONT=3
       !X.TICKS=4
       !Y.TICKS=4
       !X.THICK=2
       !Y.THICK=2
       !X.RANGE=[xpmin,xpmax]
       !Y.RANGE=[ypmin,ypmax]
    if newplot eq 'b' then goto, plotb


plota:  
;   PLOTA
    if coltab eq 'o' then loadct,file='/users/ao/idl_lib/colortab0',45
    if grayplot eq 'y' then loadct,file='/users/ao/idl_lib/colortab0',0
    
  if (fgroup eq '1') or (fgroup eq '6') or (fgroup eq '7') then begin 
    fp1=fa & fp2=fb 
  endif else begin
    print,'vor ploinfo', plane
    ploinfo, fa,fb,fc, fp1,fp2,plane,fgroup,head1,head2
    print,'in ploinfo', head1,head2
  endelse

  nl=9
  if contonly eq 'y' then begin
     cont1, pos1,xpos,ypos,nl1,nl2,names,head1,xtit0,ytit,plane
     cont2, pos3,xpos,ypos,nl1,nl2,names,head2,xtit,ytit1,plane
  end else begin
     sca1,pos1,pos2,xpos,ypos,nl1,nl2,names,head1,xtit0,ytit,plane
     sca2,pos3,pos4,xpos,ypos,nl1,nl2,names,head2,xtit,ytit1,plane
  endelse
  goto, menu


plotb:  
;   PLOTB
  if (fgroup eq '1') or (fgroup eq '6') or (fgroup eq '7') then begin
    print, 'NO VECTORPLOT'
    goto, menu
  endif
  
    if coltab eq 'o' then loadct,file='/users/ao/idl_lib/colortab0',45
    if grayplot eq 'y' then loadct,file='/users/ao/idl_lib/colortab0',0
    
    !P.REGION=[0.,0.,1.0,1.0]
    !P.CHARSIZE=2.0
    !P.MULTI=[0,6,0,0,0]
    
    nl=9 
    ploinfo1, fa,fb,fc,fc1,fc2,fc3, f0,fp2,far1,far2,$
              xar,yar,plane,fgroup,head4,head5
  if contonly eq 'y' then begin
     covec, pos1,xpos,ypos,nl1,nl2,names,head5,xtit0,ytit,plane
     cont2, pos3,xpos,ypos,nl1,nl2,names,head4,xtit,ytit1,plane
  end else begin
    vecp, pos1,pos2,xpos,ypos,nl1,nl2,names,head5,xtit0,ytit,plane
    sca2, pos3,pos4,xpos,ypos,nl1,nl2,names,head4,xtit,ytit1,plane
  endelse
  goto, menu



end


