PRO vplot, far1,far2,xar,yar,length,pos,head,cutata,cutatb,time,run, $
    xpos,yposa,yposb,ypos1,ypos2,ypos3,ypos4

    fpmax=sqrt(max(far1^2+far2^2))
    !P.POSITION=pos
    vect, far1, far2, xar, yar, length=length,$
    title=head
    xyouts,xpos,yposa,cutata 
    xyouts,xpos,yposb,cutatb 
    xyouts,xpos,ypos1,'t='+string(time,'(i3)') 
    xyouts,xpos,ypos2,' '+run 
    xyouts,xpos,ypos3,'Max=' 
    xyouts,xpos,ypos4,'  '+string(fpmax,'(f7.3)') 

return
end

