  time = fltarr(10001,8)
  bp = fltarr(10001,8) & vp=bp & jp=bp & resp=bp & er=bp
  xep=fltarr(10001,8) & yep=xep & zep=xep & xjp=xep & yjp=xep & zjp=xep
  itot = intarr(8)
  dumm = ''
  zeit=0.0
  r1=1.1 & r2=r1 & r3=r1 & r4=r1 & r5=r1 & r6=r1 & r7=r1 & r8=r1 
  contin='' & again='y' & withps='n' & fall = '' & change=''
  fnumber=1 & nop=1

  print, 'how many plots'
  read, nop
  
 for iop=0, nop-1  do  begin 
  print, 'what filenumber'
  read, fnumber
;  openr, 2, 'magdmax'
  openr, 2, 'magdmax'+string(fnumber,'(i1)')

  readf, 2, format='(a80)', dumm
  readf, 2, format='(a80)', dumm
  readf, 2, format='(a80)', dumm
  readf, 2, format='(a80)', dumm

  i=0
  while not eof(2) do begin
    readf, 2, zeit
    print, zeit
    time(i,iop)=zeit
    
;    readf, 2, format='(a80)', dumm
    print,dumm
    readf,2,r1,r2,r3,r4,r5,r6 ,r7,r8
    bp(i,iop)=r1-r5
    
    for k=0,2 do  readf, 2, format='(a80)', dumm
    print,dumm
    readf,2,r1,r2,r3,r4,r5,r6 ,r7,r8
    vp(i,iop)=r1-r5 
    
    for k=0,5 do  readf, 2, format='(a80)', dumm
    print,dumm
    readf,2,r1,r2,r3,r4
    jp(i,iop)=r1

    for k=0,8 do  readf, 2, format='(a80)', dumm
    print,dumm
    readf,2,r1,r2,r3,r4
    resp(i,iop)=r1

    itot(iop)=i
    if i lt 3999 then i=i+1 else stop, ' to many records '
  endwhile
  close, 2
 endfor

 er=jp*resp
  
   print, 'Which case?'
   read, fall

   while again eq 'y' do begin

    print, 'With postscript?'
    read, withps
     if withps eq 'y' then begin 
      set_plot,'ps'
      device,filename='maxvx.ps'
      device,/inches,xsize=8.,scale_factor=1.0,xoffset=0.5
      device,/inches,ysize=10.0,scale_factor=1.0,yoffset=0.5
      device,/times,/bold,font_index=3
     endif

    !P.REGION=[0.,0.,1.0,1.25]
    !P.MULTI=[0,0,4]

    print, 'plot page?'
    read, contin
    if (contin eq '' or contin eq 'y') then begin
     !P.CHARSIZE=2.0  
     
     !P.POSITION=[0.2,0.65,0.6,0.8]
     allmax = max(vp(1:10000,*),kax)
     print, kax, allmax
     trange = max(time(*,0:(nop-1)))
     plot, time(2:itot(0),0), vp(2:itot(0),0),$
        title='Vx (t)',$
        font=3, xrange=[0,trange], yrange=[0,2]
     for k=1,nop-1 do  oplot, time(1:itot(k),k), vp(1:itot(k),k), line=k

     !P.POSITION=[0.2,0.45,0.6,0.6]
     allmax = max(bp(1:10000,*),kax)
     print, kax, allmax
     trange = max(time(*,0:(nop-1)))
     plot, time(2:itot(0),0), bp(2:itot(0),0),$
        title='Bx (t)',$
        font=3, xrange=[0,trange], yrange=[0,2]
     for k=1,nop-1 do  oplot, time(1:itot(k),k), bp(1:itot(k),k), line=k

     !P.POSITION=[0.2,0.2,0.6,0.4]
     allmax = max(er(1:10000,*),kax)
     print, kax, allmax
     trange = max(time(*,0:(nop-1)))
     plot, time(2:itot(0),0), er(2:itot(0),0),$
        title='Reconnection Rate',$
        xtitle='t', font=3, xrange=[0,trange], yrange=[0,.2]
     for k=1,nop-1 do  oplot, time(1:itot(k),k), er(1:itot(k),k), line=k

     
    endif
    

    print, 'view results again or make ps file?'
    read, again
    if withps eq 'y' then device,/close
    set_plot,'x'
   endwhile

end  
  
