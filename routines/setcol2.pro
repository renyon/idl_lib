pro setcol2, withgrey

nmax=!D.TABLE_SIZE
print,!D.TABLE_SIZE

i1aa=nmax/32 & i1a=nmax/16 & i6a=13*nmax/16& i4a=9*nmax/16
i0=0 & i1=nmax/8 & i2=2*nmax/8 & i3=3*nmax/8  & i4=4*nmax/8  & i5=5*nmax/8 
i6=6*nmax/8 & i7=7*nmax/8 & i8=nmax-1

r = findgen(256) & r(*)=1. & g=r & b=r
gmax1=0.55 & bmax1=0.85 & bmax2=0.5 & rmax1=1.0 & vmax1=0.5 & vmax2=0.25

if withgrey eq 'y' then begin
  ;int1+2:
  for i=i0,i2 do r(i)=i*gmax1/float(i2) 
  ;int3-6:
  for i=i2,i6 do r(i)=(i-i2)*(bmax1-gmax1)/(float(i6)-float(i2))+gmax1
  ;int7+8:
  for i=i6,i8 do r(i)=(i-i6)*(rmax1-bmax1)/(float(i8)-float(i6))+bmax1

  r(i8)=1.
  r(0)=0.
  g = r   & b = r
endif
if withgrey ne 'y' then begin
  ;int1a:
   for i=i0,i1aa do r(i) = 1.8*i*(vmax1-vmax2)/float(i1aa) + vmax2
   for i=i0,i1aa do b(i) = 1.8*i*(vmax1-vmax2)/float(i1aa) + vmax2
  ;int1a:
   for i=i1aa,i1 do r(i) = 1.7*(i1-i)*vmax1/(float(i1)-float(i1aa) )
   for i=i1aa,i1 do b(i) = 1.7*(i1-i)*vmax1/(float(i1)-float(i1aa) )
  ;int1:
   r(i1:i3) = 0. &  for i=i0,i1 do g(i)=1.6*i*gmax1/float(i1) 
  ;int2:
   g(i1:i2) = 1.5*gmax1   
   for i=i1,i3 do b(i)=1.5*(i-i1)*bmax1/(float(i3)-float(i1))
  ;int3:
   for i=i2,i3 do g(i)=1.4*(i3-i)*gmax1/(float(i3)-float(i2))
  ;int4:
  g(i3:i6a)=0.
  ;b(i3:i4a)=bmax1 &  
  for i=i3,i4a do b(i)=1.3*(i-i3)*(rmax1-bmax1)/(float(i4a)-float(i3)) + bmax1
  for i=i3,i6a do r(i)=1.3*(i-i3)*rmax1/(float(i6a)-float(i3))
  ;int5:
  for i=i4a,i6 do b(i)=1.2*(i6-i)*rmax1/(float(i6)-float(i4a))
  ;int6:
  b(i6:i8)=0. 
  ;int7;int8:
  for i=i6a,i8 do g(i)=1.1*(i-i6a)*rmax1/(float(i8)-float(i6a))  
  ;for i=i7,i8 do b(i)=1.1*(i-i7)*bmax1/(float(i8)-float(i7))
  ;for i=i7,i8 do r(i)=1.1*(i8-i)*rmax1/(float(i8)-float(i7))
  r(i6a:i8)=rmax1
endif


r(i8)=1. & g(i8)=1. & b(i8)= 1.
 r(0)=0. & g(0)=0. & b(0)=0. 



r=bytscl(r)
b=bytscl(b)
g=bytscl(g)

TVLCT, R, G, B

return
end
