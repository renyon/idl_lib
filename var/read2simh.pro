PRO read2simh,tim,ress
COMMON procommon, nsat,startime,itot,pi,ntmax, $
                  rhobd,pbd,vxbd,vybd,vzbd,bxbd,bybd,bzbd, $
                  xsi,ysi,zsi,vxsi,vysi,vzsi, $
                  time,bxs,bys,bzs,vxs,vys,vzs,rhos,ps,bs,ptots, $
                  jxs,jys,jzs,xs,ys,zs,cutalong

; READ INPUT DATA FOR NSAT SATELLITES
;------------------------------------
  pbd = fltarr(2) & rhobd = pbd & vxbd = pbd & vybd = pbd & vzbd = pbd
  bxbd = pbd & bybd = pbd & bzbd = pbd
  zeit = 0.0 
  
   tim=0.0 & fnumber=1 & cutalong='x' & bdok='y'
   nx=long(503) & ny=long(503)
   nxf = 201   &   nyf = 201
;----PARAMETER-------
  xmin = -20. & ymin = -20.0
  xmax =  20. & ymax =  20.0

; READ INPUT DATA OF DIMENSION NX, NY
   print, 'Input filenumber'
   read, fnumber
   name='magtap'+string(fnumber,'(i2.2)')
   openr, 8, name,/F77_UNFORMATTED
   readu, 8,  nx,ny,tim
   print, 'dimension nx=',nx,'     ny=',ny

   x=fltarr(nx,/NOZERO) & y=fltarr(ny,/NOZERO)
   g1=fltarr(nx,/NOZERO) & g2=g1 & g3=g1 
   h1=fltarr(ny,/NOZERO) & h2=h1 & h3=h1 
   bx=fltarr(nx,ny,/NOZERO) & by=bx & bz=bx & vx=bx & vy=bx & vz=bx
   rho=bx & u=bx & res=bx & p=bx  & jx=bx & jy=bx & jz=bx
   
   readu, 8,  x,g1,g2,g3,g3,g3,g3, y,h1,h2,h3,h3,h3,h3
;  print, 'after read x'
   xmin=x(1) & xmax=x(nx-2) & ymin=y(1) & ymax=y(ny-2) 
;  print, y
   
    print, 'xmin=', xmin, '  xmax=', xmax
    print, 'ymin=', ymin, '  ymax=', ymax

   readu, 8,  bx,by,bz
    print, 'after read b'
   readu, 8,  vx,vy,vz
    print, 'after read v'
   readu, 8,  rho,u,res
    print, 'after read rho'
   close, 8
   vx=vx/rho &  vz=vz/rho & vy=vy/rho & p=2*u^(5.0/3.0)
print,'Res:',res(*,126)
   jandec, nx,ny,g1,h1,bx,by,bz,jx,jy,jz

   print, 'Cut along x or y:'
   read, cutalong & if cutalong ne 'y' then cutalong='x'
;   print,'cutalong=',cutalong
   
   if cutalong eq 'x' then begin
     print, 'boundaries along x ',xmin,'/ ',xmax,'ok? (enter,y, or n)'
     read, bdok
     if bdok eq 'n' then begin
       print,'Enter new xmin, xmax'
       read,xmin,xmax
     endif
     if (xmin lt x(1)) then begin
       print, 'warning! xmin:',xmin,' out of bounds:',x(1),' Reset!'
       xmin=x(1)
     endif  
     if (xmax gt x(nx-2)) then begin
       print, 'warning! xmax:',xmax,' out of bounds:',x(nx-2),' Reset!'
       xmax=x(nx-2)
     endif  
     rhobd(0)=total(rho(1,*))/ny & rhobd(1)=total(rho(nx-2,*))/ny
     pbd(0)=total(p(1,*))/ny     & pbd(1)=total(p(nx-2,*))/ny
     bxbd(0)=total(bx(1,*))/ny   & bxbd(1)=total(bx(nx-2,*))/ny
     bybd(0)=total(by(1,*))/ny   & bybd(1)=total(by(nx-2,*))/ny
     bzbd(0)=total(bz(1,*))/ny   & bzbd(1)=total(bz(nx-2,*))/ny
     vxbd(0)=total(vx(1,*))/ny   & vxbd(1)=total(vx(nx-2,*))/ny
     vybd(0)=total(vy(1,*))/ny   & vybd(1)=total(vy(nx-2,*))/ny
     vzbd(0)=total(vz(1,*))/ny   & vzbd(1)=total(vz(nx-2,*))/ny
;     vy=vy-vybd(0) & vybd(0)=0.0 & vybd(1)=vybd(1)-vybd(0)
;     vz=vz-vzbd(0) & vzbd(0)=0.0 & vzbd(1)=vzbd(1)-vzbd(0)
   endif
   if cutalong eq 'y' then begin
     print, 'boundaries along y ',ymin,'/ ',ymax,'ok? (enter,y, or n)'
     read, bdok
     if bdok eq 'n' then begin
       print,'Enter new ymin, ymax'
       read,ymin,ymax
     endif
     if (ymin lt y(1)) then begin
       print, 'warning! ymin:',ymin,' out of bounds:',y(1),' Reset!'
       ymin=y(1)
     endif  
     if (ymax gt y(ny-2)) then begin
       print, 'warning! ymax:',ymax,' out of bounds:',y(ny-2),' Reset!'
       ymax=y(ny-2)
     endif  
     rhobd(0)=total(rho(*,1))/nx & rhobd(1)=total(rho(*,ny-2))/nx
     pbd(0)=total(p(*,1))/nx     & pbd(1)=total(p(*,ny-2))/nx
     bxbd(0)=total(bx(*,1))/nx   & bxbd(1)=total(bx(*,ny-2))/nx
     bybd(0)=total(by(*,1))/nx   & bybd(1)=total(by(*,ny-2))/nx
     bzbd(0)=total(bz(*,1))/nx   & bzbd(1)=total(bz(*,ny-2))/nx
     vxbd(0)=total(vx(*,1))/nx   & vxbd(1)=total(vx(*,ny-2))/nx
     vybd(0)=total(vy(*,1))/nx   & vybd(1)=total(vy(*,ny-2))/nx
     vzbd(0)=total(vz(*,1))/nx   & vzbd(1)=total(vz(*,ny-2))/nx
   endif
   
; GRID FOR INTERPOLATION
   ioxf=fltarr(nxf) & ioyf=fltarr(nyf)
   xf=findgen(nxf) & yf=findgen(nyf)
   dxf=(xmax-xmin)/float(nxf-1) & xf=xf*dxf+xmin
   dyf=(ymax-ymin)/float(nyf-1) & yf=yf*dyf+ymin
   in=-1 & k=0
   repeat begin
     in=in+1
     while xf(in) gt x(k+1) do k=k+1
     ioxf(in) = float(k) + (xf(in)-x(k))/(x(k+1)-x(k)) 
   endrep until in eq nxf-1
   in=-1 & k=0
   repeat begin
     in=in+1
     while yf(in) gt y(k+1) do k=k+1
     ioyf(in) = float(k) + (yf(in)-y(k))/(y(k+1)-y(k))        
   endrep until in eq nyf-1
        
   bxf=interpolate(bx,ioxf,ioyf,/grid)
   byf=interpolate(by,ioxf,ioyf,/grid)
   bzf=interpolate(bz,ioxf,ioyf,/grid)
   vxf=interpolate(vx,ioxf,ioyf,/grid)
   vyf=interpolate(vy,ioxf,ioyf,/grid)
   vzf=interpolate(vz,ioxf,ioyf,/grid)
   jxf=interpolate(jx,ioxf,ioyf,/grid)
   jyf=interpolate(jy,ioxf,ioyf,/grid)
   jzf=interpolate(jz,ioxf,ioyf,/grid)
   rhof=interpolate(rho,ioxf,ioyf,/grid)
   resf=interpolate(res,ioxf,ioyf,/grid)
   pf=interpolate(p,ioxf,ioyf,/grid)


  if cutalong eq 'x' then  begin 
    nsat=nyf & itot=nxf & startime=x(0)
  endif else begin
    nsat=nxf & itot=nyf & startime=y(0)
  endelse

  xsi=fltarr(nsat) & ysi=xsi & zsi=xsi 
  vxsi=xsi & vysi=xsi & vzsi=xsi
  xs=fltarr(nsat,itot) & ys=xs & zs=xs 
  bxs=xs & bys=xs & bzs=xs & vxs=xs & vys=xs & vzs=xs
  rhos=xs & ps=xs & bs=xs & ptots=xs & jxs=xs & jys=xs & jzs=xs
  ress=xs & time=fltarr(itot) 
  
  if cutalong eq 'x' then  begin 
    time=xf
    xsi[0:nsat-1]=xf(0) & ysi=yf & zsi[0:nsat-1]=0.0
    for i=0,nsat-1 do xs(i,*)=xf
    for i=0,itot-1 do ys(*,i)=yf
;  print,time
    bxs=rotate(bxf,4) & bys=rotate(byf,4) & bzs=rotate(bzf,4)
    vxs=rotate(vxf,4) & vys=rotate(vyf,4) & vzs=rotate(vzf,4)
    jxs=rotate(jxf,4) & jys=rotate(jyf,4) & jzs=rotate(jzf,4)
    rhos=rotate(rhof,4) & ress=rotate(resf,4) & ps=rotate(pf,4)
  endif else begin
    time=yf
    xsi=xf & ysi[0:nsat-1]=yf(0) & zsi[0:nsat-1]=0.0
    for i=0,itot-1 do xs(*,i)=xf
    for i=0,nsat-1 do ys(i,*)=yf
    bxs=bxf & bys=byf & bzs=bzf & vxs=vxf & vys=vyf & vzs=vzf
    rhos=rhof & ress=resf & ps=pf & jxs=jxf & jys=jyf & jzs=jzf
  endelse
  vxsi[0:nsat-1]=0.0 & vysi[0:nsat-1]=0.0 & vzsi[0:nsat-1]=0.0
  zs(0:nsat-1,0:itot-1)=0.

    bs=sqrt(bxs*bxs+bys*bys+bzs*bzs)
    ptots=ps+bs^2

return
end

  
