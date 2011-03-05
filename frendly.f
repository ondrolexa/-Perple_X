 
c Copyright (c) 1990 by James A. D. Connolly, Institute for Mineralogy and
c Petrography, Swiss Federal Insitute of Technology, CH-8092 Zurich,
c SWITZERLAND. All rights reserved.
 
c Please do not distribute this source.
 
c------------------------------------------------------------------------
 
c FRENDLY - a thermodynamic calculator for petrologic problems.
 
c------------------------------------------------------------------------
 
      program FRNDLY
 
      implicit none
 
      include 'perplex_parameters.h'
 
      character uname*8, y*1, rxny*1, opname*100

      integer i,j,k,idiag, ier, icopt
 
      double precision pp(2),tt(2),xx(2),gg(2),ee(2),ss(2),vv(2),ccp(2),
     *                 uu(2),aa(2),g,e,u,s,vol,cp

      double precision props,psys,psys1
      common/ cxt22 /props(i8,k5),psys(i8),psys1(i8)
 
      integer iff,idss,ifug,ifyn,isyn
      common/ cst10 /iff(2),idss(h5),ifug,ifyn,isyn

      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps

      integer ipot,jv,iv
      common/ cst24 /ipot,jv(l2),iv(l2)

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      integer inc,jpot
      common/ cst101 /inc(l2),jpot

      integer iam
      common/ cst4 /iam

      save idiag
c----------------------------------------------------------------------- 
c                                 iam is a flag indicating the Perple_X program
      iam = 5
c                                 version info
      call vrsion
c                                 assign data files
      call fopen2 (2,opname)
c                                 read options
      opname = 'perplex_option.dat'
      call redop1 (.false.,opname)
 
      idiag = 0
 
c      write (*,1040)
c      read (*,'(a)') uname
c      write (*,1050) uname
c      read (*,'(a)') y
c      if (y.ne.'y'.and.y.ne.'Y') then
c         write (*,1060) uname
c         stop
c      end if

 
      do 

         write (*,1030)
         read (*,*,iostat=ier) icopt

         if (ier.ne.0) then 
            call rerr
            cycle 
         else if (icopt.eq.5) then 
            exit 
         end if 
 
         call jnput2 (icopt,rxny,uname)
 
         if (icopt.eq.1) then
c                                 calculating equilibrium properties for a
c                                 reaction:
c                                 select variables and set up plot file:
            if (idiag.eq.0) call setplt (.false.)
 
            idiag = 1
 
            do 

               call eqrxn 
 
               write (*,1070)
               read (*,'(a)') rxny

               if (rxny.ne.'y'.and.rxny.ne.'Y') exit 
  
               call jnput2 (icopt,rxny,uname)
                
            end do
 
         else if (icopt.eq.2) then
c                                 calculating properties at arbitrary conditions:
            write (*,1180) 
            read (*,'(a)') y

            if (y.eq.'y'.or.y.eq.'Y') then
c                                 tabulated properties
               call setplt (.true.)

               do i = 1, inc(1)

                  v(iv(1)) = vmin(iv(1)) + dfloat(i-1)*dv(iv(1))

                  do j = 1, inc(2)

                     v(iv(2)) = vmin(iv(2)) + dfloat(j-1)*dv(iv(2))

                     do k = 1, inc(3)

                        v(iv(3)) = vmin(iv(3)) + dfloat(k-1)*dv(iv(3))

                        call prop (g,e,u,s,vol,cp)

                        write (n4,1000) v(1),v(2),v(3),g,e,s,vol,cp,
     *                                  -g/r/v(2)/2.302585093d0 
                     end do 
                  end do 
               end do 
    
               close (n4)

               cycle 

            else 

               write (*,1080) uname,uname,uname,uname

               do 
c                                 interactively entered conditions
                  write (*,1100)
                  read (*,*,iostat=ier) v(1),v(2)
                  if (ier.ne.0) then 
                     call rerr
                     cycle
                  end if 

                  if (v(1).eq.0d0) exit 

                  if (ifyn.eq.0) then

                     do 
                        write (*,1110)
                        read (*,*,iostat=ier) v(3)
                        if (ier.eq.0) exit
                        call rerr
                     end do 

                  end if
c
                  call prop (g,e,u,s,vol,cp)
c
                  write (*,1120) v(2),v(1),g/1d3,e/1d3,
     *                     (g-v(1)*vol)/1d3,u/1d3,s,vol,cp,
     *                     -g/r/v(2),-g/r/v(2)/2.302585093d0
c
                  call dphasf (g)

                  write (*,1120) v(2),v(1),g/1d3,props(2,1)/1d3,
     *                     (g-v(1)*props(1,1))/1d3,u/1d3,props(15,1),
     *                     props(1,1),props(12,1),
     *                     -g/r/v(2),-g/r/v(2)/2.302585093d0


                  write (*,1090)
                  read (*,'(a)') y

                  if (y.eq.'y'.or.y.eq.'Y') call change 
c
               end do 

            end if 

         else if (icopt.eq.3) then
c                                 calculate change in props from an arbitrary
c                                 condition
            write (*,1140)
c
            do 
               do i = 1, 2
                  do 
                     write (*,1150) i,i
                     read (*,*,iostat=ier) pp(i),tt(i)
                     if (ier.eq.0) exit 
                     call rerr
                  end do 

                  v(1) = pp(i)
                  v(2) = tt(i)

                  if (v(1).eq.0d0) exit 

                  if (ifyn.eq.0) then
53                   write (*,1160)
                     read (*,*,iostat=ier) xx(i)
                     call rerror (ier,*53)
                     v(3) = xx(i)
                  end if
c
                  call prop
     *              (gg(i),ee(i),uu(i),ss(i),vv(i),ccp(i))
 
                  aa(i) = gg(i)-pp(i)*vv(i)
 
               end do 
 
               if (v(1).eq.0d0) exit
 
               write (*,1170)  (gg(2)-gg(1))/1d3,(ee(2)-ee(1))/1d3,
     *                   (aa(2)-aa(1))/1d3,
     *                   (uu(2)-uu(1))/1d3,
     *                   ss(2)-ss(1),
     *                   vv(2)-vv(1),ccp(2)-ccp(1)
 
               write (*,1090)
               read (*,'(a)') y
               if (y.eq.'y'.or.y.eq.'Y') call change 

            end do 
 
         else if (icopt.eq.4) then
c                                 create a new data base entry
            call nentry
 
         end if
 
      end do 
 
      write (*,1130) uname
 
      if (idiag.eq.1) write (n4,1010) 1,1,1,1,1,0,0,0,0,1d0,0,0
 
      stop

1000  format (80(g14.7,1x))
1010  format (9(1x,i1),/,f3.1,/,2(1x,i1))
1030  format (/,'Choose from following options:',
     *  //,2x,'1 - calculate equilibrium coordinates for a reaction.',
     *   /,2x,'2 - calculate thermodynamic properties for a phase or',
     *          ' reaction relative to',/,6x,'the reference state.',
     *   /,2x,'3 - calculate change in thermodynamic properties ',
     *          ' from one p-t-x',/,6x,'condition to another.',
     *   /,2x,'4 - create new thermodynamic data file entries.',
     *   /,2x,'5 - quit.',
     *  //,'With options 1-3 you may also modify',
     *     ' thermodynamic data, the modified data',/,'can then',
     *     ' be stored as a new entry in the thermodynamic data',
     *     ' file.',/)
1040  format (/,'Hi! I am a user freindly program.',/,
     *          'What is your name? ')
1050  format (/,'Hi ',a,'!, I like you and I hope we have fun!',/,
     *          'Can you say "therm-o-dy-nam-ics" (y/n)?')
1060  format (/,'Weeell ', a,' why dont you go read Gibbs and try me',
     *          ' again later?')
1070  format ('Calculate a different equilibrium (y/n)?')
1080  format (/,'now ',a,', there is one thing i want you to remember'
     *         ,' and that is that the',/,'values for G and H that i',
     *          ' calculate are "apparent" free energies and',
     *         /,'enthalpies. ',a,' if you dont know what that means'
     *         ,' read Helgeson et al. 1978.',//,a,
     *          ' now i am going to prompt you for conditions',
     *          ' at which i should',/,'calculate thermodynamic',
     *          ' properties, when you want to stop just enter',
     *          ' zeroes.',//,
     *          'ok, here we go, it is fun time ',a,'!',//)
1090  format ('Modify or output thermodynamic parameters (y/n)? ')
1100  format ('Enter P(bars) and T(K) (zeroes to quit): ')
1110  format ('Enter X(CO2/O) in fluid phase: ')
1120  format (/,'At ',g13.6,'K and ',g13.6,'bar:',//,
     *                 6x,'G(kj)   =',g15.8,/,6x,'H(kj)   =',g15.8,/,
     *                 6x,'A(kj)   =',g15.8,/,
     *                 6x,'U(kj)   =',g15.8,/,
     *                 6x,'S(j/k)  =',g13.6,/,6x,'V(j/bar)=',g13.6,/,
     *                 6x,'Cp(j/k) =',g13.6,/,
     *                 6x,'loge K  =',g13.6,/,
     *                 6x,'log10 K =',g13.6,/)
1130  format (/,'Have a nice day ',a,'!',/)
1140  format (/,'Option to calculate change in ',
     *        'thermodynamic properties from',/,
     *        'P(1)-T(1)-X(CO2/O)(1) to P(2)-T(2)-X(CO2/O)(2)',/,
     *        'enter zeros to quit.',//)
1150  format ('Enter P(',i1,') (bars) and T(',i1,') (K) (0 to quit):')
1160  format ('Enter X(CO2/O)(',i1,'): ')
1170  format (//,6x,'delta G(kj)   =',g15.8,/,
     *           6x,'delta H(kj)   =',g15.8,/,
     *           6x,'delta A(kj)   =',g15.8,/,
     *           6x,'delta U(kj)   =',g15.8,/,
     *           6x,'delta S(j/k)  =',g13.6,/,
     *           6x,'delta V(j/bar)=',g13.6,/,
     *           6x,'delta cp(j/k) =',g13.6,/,
     *           6x,'   loge K     =',g13.6,/,
     *           6x,'   log10 K    =',g13.6,/)
1180  format ('Write a properties table (Y/N)?')
 
      end

      subroutine chptx
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      integer ier, i, j

      character*8 vname,xname
      common/ csta2 /xname(k5),vname(l2)

      double precision delv
      common/ cst63 /delv(l2)

      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      integer ipot,jv,iv
      common/ cst24 /ipot,jv(l2),iv(l2)
 
      write (*,1020)

      do i = 1, ipot
         j = iv(i) 
20       write (*,1000) vname(j),vmin(j),vmax(j)
         read (*,*,iostat=ier) vmin(j),vmax(j)
         if (j.eq.3.and.vmin(j).lt.0d0.or.
     *       j.eq.3.and.vmax(j).gt.1d0.or.
     *       j.ne.3.and.vmin(j).ge.vmax(j).or.ier.ne.0) then
            write (*,1010) 
            goto 20
         end if
         v(j) = vmin(j)
         delv(j) = vmax(j) - vmin(j) 
         dv(j) = delv(j) / 4d1
      end do 
 
      call concrt

1000  format (/,'Enter new min/max values for ',a,' (',
     *           'old values were ',g12.5,',',g12.5,')',/)
1010  format (/,'Try again.',/)
1020  format (/,'This option does not change plot limits!'
     *         ,' To do this, modify default plot options',
     *        /,'while running PSVDRAW.',/)
      end 
 
      subroutine eqrxn 
c------------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer i
   
      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      integer ipot,jv,iv
      common/ cst24 /ipot,jv(l2),iv(l2)

      integer inc,jpot
      common/ cst101 /inc(l2),jpot
c------------------------------------------------------------------------
c                                search for an equilibrium point
c                                on the x-y coordinate frame.
      do i = 1, inc(iv(3))
         v(iv(3)) = vmin(iv(3)) + dfloat(i-1)*dv(iv(3))
         call newhld
      end do 
 
      end
 

      subroutine setplt (table)
c----------------------------------------------------------------------
c select variables for a plot or table
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      character y*1,n4name*100,title*100

      integer i,j,ier,ic,ix, nprops

      logical table

      character*14 pnames(9)

      integer inc,jpot
      common/ cst101 /inc(l2),jpot

      character*100 prject,tfname
      common/ cst228 /prject,tfname

      double precision delv
      common/ cst63 /delv(l2)

      character*8 vname,xname
      common/ csta2  /xname(k5),vname(l2)

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      integer iff,idss,ifug,ifyn,isyn
      common/ cst10 /iff(2),idss(h5),ifug,ifyn,isyn

      integer ipot,jv,iv
      common/ cst24 /ipot,jv(l2),iv(l2)

      integer io3,io4,io9
      common/ cst41 /io3,io4,io9

      save pnames 
      data pnames/'   P(bar)    ','    T(K)     ','  X(CO2/O)   ',
     *'  g(J/mol)   ','  h(J/mol)   ','  s(J/K/mol) ','v(J/bar/mol) ',
     *' cp(J/K/mol) ','  log10(K)   '/
c----------------------------------------------------------------------
      ipot = 2
      jpot = ipot
      nprops = 9 
 
      do i = 1, l2
         iv(i) = i
         vmin(i) = 0d0
         vmax(i) = vmin(i)
         dv(i) = 1d0
         inc(i) = 1
      end do 
c                                 saturated phase:
      if (ifyn.eq.0) ipot = ipot + 1
 
      do 
c                                 select the x variable (iv(1)):
         write (*,2130)
         write (*,2140) (j,vname(iv(j)), j = 1, ipot)
         write (*,*)
         read (*,*,iostat=ier) ic
         if (ier.eq.0) exit
         call rerr 

      end do 

      ix = iv(1)
      iv(1) = iv(ic)
      iv(ic) = ix
c                                 get x variable limits and increment
      do 

         if (table) then
            write (*,1000) vname(iv(1))
            read (*,*,iostat=ier) vmin(iv(1)),vmax(iv(1)),dv(iv(1)) 
         else 
            write (*,2150) vname(iv(1))
            read (*,*,iostat=ier) vmin(iv(1)),vmax(iv(1))
         end if 

         if (ier.eq.0) exit
         call rerr

      end do 
c                                 select the y variable (iv(2)):
      if (ipot.eq.3) then

         do 

             write (*,2110)
             write (*,2140) (j,vname(iv(j)), j = 2, ipot)
             write (*,*)
             read (*,*,iostat=ier) ic

             if (ier.eq.0) exit 
             call rerr

          end do 

      else

        ic = 2

      end if

      ix = iv(2)
      iv(2) = iv(ic)
      iv(ic) = ix
 
      do 

         if (table) then
            write (*,1000) vname(iv(2))
            read (*,*,iostat=ier) vmin(iv(2)),vmax(iv(2)),dv(iv(2)) 
         else 
            write (*,2150) vname(iv(2))
            read (*,*,iostat=ier) vmin(iv(2)),vmax(iv(2))
         end if 

         if (ier.eq.0) exit 
         call rerr

      end do 
c                                 third variable?
      if (ipot.eq.3) then 

         if (table) then 

            write (*,1010) vname(iv(3))
            read (*,'(a)') y
c
            if (y.eq.'y'.or.y.eq.'Y') then
               write (*,1000) vname(iv(3))
               read (*,*,iostat=ier) vmin(iv(3)),vmax(iv(3)),dv(iv(3)) 
            end if 

         else 

            write (*,2160) vname(iv(3))
            read (*,'(a)') y
c
            if (y.eq.'y'.or.y.eq.'Y') then

               jpot = 3

               do 
                  write (*,2150) vname(iv(3))
                  read (*,*,iostat=ier) vmin(iv(3)),vmax(iv(3))
                  if (ier.eq.0) exit               
                  call rerr
               end do

               do  
                  write (*,1060)
                  read (*,*,iostat=ier) inc(iv(3))
                  if (ier.eq.0) exit 
                  call rerr
               end do 

               if (inc(iv(3)).lt.1) inc(iv(3)) = 1

            end if 

         end if 
c                                 set third variable if unused:
         if (jpot.eq.2) then 

            do 

               write (*,2180) vname(iv(3))
               read (*,*,iostat=ier) vmin(iv(3))
               if (ier.eq.0) exit 
               call rerr

            end do 

            vmax(iv(3)) = vmin(iv(3))

         end if 

      end if 
c                                 increments or counters:
      if (table) then
 
         do i = 1, jpot
            inc(iv(i)) = dabs(vmax(iv(i))-vmin(iv(i)))/dv(iv(i)) + 1
         end do 

      else 

         do i = 1, jpot
            delv(i) = vmax(i)-vmin(i) 
            dv(i) = delv(i) / dfloat(inc(i))
            delv(i) = vmax(i)-vmin(i)
         end do 
c                                 set convergence criteria for univeq:
         call concrt
c                                 plot file output?
         write (*,1020) 
         read (*,'(a)') y

         if (y.eq.'y'.or.y.eq.'Y') then
            io4 = 0
         else 
            io4 = 1
         end if       

      end if 
c                                 setup output files:
   
      if (table.or.io4.eq.0) then
c                                 query output file name
         write (*,1080)
c                                 readrt loads the root into prject
         call readrt 

         if (table) then 
            call mertxt (n4name,prject,'.tab',0)
         else
            call mertxt (n4name,prject,'.plt',0)
         end if            

         open (n4,file=n4name)
c                                 query for title
         write (*,1070)
         read (*,'(a)') title
 
      end if
c                                 write file headers
      if (table) then 
c                                 terminal info on variables
         write (*,1090)
         write (*,1040) pnames

         write (n4,'(a)') title
         write (n4,*) jpot
         write (n4,*) nprops

         do i = 1, jpot
            write (n4,*) vname(iv(i))
            write (n4,*) vmin(iv(i))
            write (n4,*) dv(iv(i))
            write (n4,*) inc(iv(i))
         end do 

         write (n4,1040) pnames

      else if (io4.eq.0) then 

         write (n4,*) 1
         write (n4,*) 0, 0, 0
         write (n4,*) 0, 0, 0, 0, 0, 0
         write (n4,'(a)') title,' ',' ',' '
         write (n4,*) ipot,(iv(i),i=1,ipot),1,2
         write (n4,'(a)') '0 0 0 0. 0. 0. 0. 0.'
         write (n4,1030) (vmax(iv(i)),vmin(iv(i)),i=1,ipot)
         write (n4,'(a)') (vname(iv(i)),i=1,ipot)

      end if 

1000  format ('Enter minimum, maximum, and increment for 'a,':')
1010  format (/,'Make the table also a function of ',a,' (y/n)?')
1020  format (/,'Generate a plot file (y/n)?')
1030  format (6(g11.5,1x))
1040  format (80(a14,1x))
1060  format (/,'Enter number of sections:')
1070  format (/,'Enter calculation title:')
1080  format (/,'Enter a plot/table file name [without the ',
     *          '.plt/.tab suffix]:')
1090  format (/,'Table row entries will be:',/)
2130  format (/,'Select the first independent (x) variable:',/)
2140  format (10x,i1,' - ',a)
2150  format (/,'Enter minimum and maximum values for ',a,':')
2110  format (/,'Select the second independent (y) variable:',/)
2180  format (/,'Specify the value for: ',a)
2160  format (/,'Calculate sections as a function of ',a,' (y/n)?')
 
      end 

      subroutine newhld
c-----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      character y*1

      integer ivi,ivd,ier,igo

      double precision div

      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      character*8 vname,xname
      common/ csta2 /xname(k5),vname(l2)

      integer ipot,jv,iv1,iv2,iv3,iv4,iv5
      common/ cst24 /ipot,jv(l2),iv1,iv2,iv3,iv4,iv5
c-----------------------------------------------------------------------
c                                  initialization:
c       ifuk = 0
10     write (*,1160)
       write (*,1170) vname(iv1),vname(iv2)
c                                  write potential variable sectioning
c                                  constraints:
       if (ipot.gt.2) write (*,1180) vname(iv3), v(iv3)
c                                  set starting values for search
      v(iv1)=vmin(iv1)
      v(iv2)=vmin(iv2)
c                                  test stability along an edge of the
c                                  diagrams coordinate frame:
      call search (ivi,ivd,div,ier)
      if (ier.eq.1) then
         write (*,1010)
         goto 20
      end if
 
      call trace (ivd,ivi,div,igo)
c                                  this would permit continuation of the
c                                  search on failures from trace if iste
c                                  were not initialized in search (but here).      
c      if (igo.eq.1.and.ifuk.eq.0) then
c         ifuk = 1
c         goto 30
c      else if (igo.eq.1.and.ifuk.eq.1) then
c         write (*,1030)
c      end if         
 
20    write (*,1040)
      read (*,1000) y
      if (y.eq.'y'.or.y.eq.'Y') then
         call chptx
         goto 10
      end if 
      write (*,1020)
      read (*,1000) y
      if (y.ne.'y'.and.y.ne.'Y') goto 99
      call change 
      goto 10
 
1000  format (a)
1010  format (/,'Equilibrium is not in specified',
     *          ' coordinate frame.',/)
1020  format (/,'Modify data and',
     *        ' recalculate the equilibrium (y/n)? ')
1040  format (/,'Change PTX limits (y/n)?',/)
1160  format (/,'-------------------------------------------------'
     *          ,'---------------',/)
1170  format ('The ',a,'-',a,' loci of the univariant field'
     *        ,' follows:')
1180  format ('(subject to the constraint ',a,'=',g12.6,')',/)


99    end
 
      subroutine search (ivi,ivd,div,ier)
c-----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer ivi,ivd,ier,i
    
      double precision div,ddv,gval,gst
 
      double precision a,b
      integer ipvt,idv,iophi,idphi,iiphi,iflg1
      common/ cst23 /a(k8,k8),b(k8),ipvt(k8),idv(k8),
     *               iophi,idphi,iiphi,iflg1

      integer ipot,jv,iv1,iv2,iv3,iv4,iv5
      common/ cst24 /ipot,jv(l2),iv1,iv2,iv3,iv4,iv5

      double precision vmax,vmin,dv
      common/ cst9  /vmax(l2),vmin(l2),dv(l2)

      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps
c-----------------------------------------------------------------------
c                                 initialization
      ier=0
      v(iv1) = vmin(iv1)
      v(iv2) = vmin(iv2)
      call grxn (gst)
 
      do 60 i = 1, 4
c                                 set default dependent and independent
c                                 variables and increments for each edge
c                                 to be searched.
      goto (10,20,30,40),i
c                                 traverse 1.
10    ivi=iv2
      ivd=iv1
      ddv=dv(ivd)
      div=dv(ivi)
      v(ivi)=vmin(ivi)
      goto 80
c                                 traverse 2.
20    ivi=iv1
      ivd=iv2
      ddv=dv(ivd)
      div=-dv(ivi)
      v(ivi)=vmax(ivi)
      goto 80
c                                 traverse 3.
30    ivi=iv2
      ivd=iv1
      ddv=-dv(ivd)
      div=-dv(ivi)
      v(ivi)=vmax(ivi)
      goto 80
c                                 traverse 4.
40    ivi=iv1
      ivd=iv2
      ddv=-dv(ivd)
      div=dv(ivi)
      v(ivi)=vmin(ivi)
c                                 begin search:
80    v(ivd)=v(ivd)+ddv
c                                 out of range?:
      goto (110,110,120,120),i
110   if (v(ivd).gt.vmax(ivd)) then
        v(ivd)=vmax(ivd)
      else if (i.eq.1) then
        if (v(ivd).gt.vmin(ivd)) goto 130
        ddv=dabs(ddv)/2.d0
        v(ivd)=vmin(ivd)
        iflg1=0
        goto 80
      end if
      goto 130
c
120   if (v(ivd).lt.vmin(ivd)) then
        v(ivd)=vmin(ivd)
      else if (i.eq.1) then
        if (v(ivd).lt.vmin(ivd)) goto 130
        ddv=-dabs(ddv)/2.d0
        v(ivd)= vmin(ivd)
        iflg1=0
        goto 80
      end if
c                                 calculate phase energies:
130   call grxn (gval)
      if (gval*gst.lt.0d0) goto 99
c                                 check if search is in range:
      goto (140,140,150,150),i
140   if (v(ivd).ge.vmax(ivd)) goto 60
      goto 80
150   if (v(ivd).le.vmin(ivd)) goto 60
      goto 80
c                                 next traverse.
60    continue
c                                 set this ier flag to indicate
c                                 the reaction wasn't found
      ier=1
c                                 done:
99    end
 
      subroutine trace (iovd,iovi,odiv,igo)
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      integer iovd,iovi,ivd,igo,ier,jer,icter,ird,ivi

      double precision odiv,div

      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps
     
      integer ipt2
      double precision ptx
      common/ cst32 /ptx(l5),ipt2
c-----------------------------------------------------------------------
      ivi = iovi
      ivd = iovd
      igo = 0
50    call univeq (ivd,ier)
c                                 if univeq fails on a bounding edge
c                                 write error message and return:
      goto (9000,9000),ier
c                                 set the increment for the iv
      div=odiv
c                                 initialize counters
      ipt2=0
      icter=0
c                                 assign the 1st point
      call assptx
c                                 follow the equilibrium
60    call sfol1 (ivd,ivi,ier,div)
c                                 sfol1 returns ier=1
      goto (70,70),ier
      ivi=iovi
      ivd=iovd
      goto 9999
70    call switch (div,ivi,ivd,jer)
      goto (75),jer
      icter=icter+1
      if (icter.lt.4) goto 60
 
75    call warn (10, v(ivi), igo, 'TRACE')
 
      call outrxn
      ivi=iovi
      ivd=iovd
c                                 return on error
      goto 9999
c                                 error in univeq:
9000  call warn (79, v(ivi), ird, 'TRACE')
      write (*,*) ' failed at P=',v(1),' T=',v(2),' XCO2 =',v(3)
      goto (9999), igo
      ivi = iovd
      ivd = iovi
      igo = 1
      goto 50
 
9999  end
 
      subroutine sfol1 (ivd,ivi,ier,dv)
c-----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer ivi,ivd,ier

      double precision dv
 
      double precision v,tr,pr,r,ps
      common/ cst5  /v(l2),tr,pr,r,ps

      double precision vmax,vmin,odv
      common/ cst9  /vmax(l2),vmin(l2),odv(l2)

      integer ipt2
      double precision ptx
      common/ cst32 /ptx(l5),ipt2
c-----------------------------------------------------------------------
c                                 begin traverse:
10    v(ivi)=v(ivi)+dv
c                                 is search in range?
      if (v(ivi).gt.vmax(ivi)) then
        v(ivi)=vmax(ivi)
      else if (v(ivi).lt.vmin(ivi)) then
        v(ivi)=vmin(ivi)
      end if
c                                 solve for the equilibrium conditions:
      call univeq (ivd,ier)
c                                 on error return:
c                                 calling routine will switch variables.
      goto (9999,9999),ier
c                                 iflag=0:
      if (ipt2.gt.449) goto 9000
c                                 dependent v in range? if
c                                 greater than the maximum value for v
c                                 or less than the minimum value for v
c                                 reset conditions, and
c                                 switch independent/dependent variables
      if (v(ivd).gt.vmax(ivd)) then
          v(ivd)=vmax(ivd)
        else if (v(ivd).lt.vmin(ivd)) then
          v(ivd)=vmin(ivd)
        else
          call assptx
          if ((v(ivi).eq.vmax(ivi)).or.(v(ivi).eq.vmin(ivi)))
     *       goto 9000
          goto 10
      end if
c                                 solve for the equilibrium with
c                                 the switched variables:
      call univeq (ivi,ier)
      goto (9000,9000),ier
c                                 assign final value
      call assptx
c                                 output the traversed equilibrium:
9000  call outrxn
      ier=0
9999  end
 
      subroutine outrxn
c-----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer i,l
 
      integer idr,ivct
      double precision vnu
      common/ cst25 /vnu(k7),idr(k7),ivct

      character*8 names
      common/ cst8 /names(k1)

      integer icomp,istct,iphct,icp
      common/ cst6 /icomp,istct,iphct,icp

      integer ipt2
      double precision ptx
      common/ cst32 /ptx(l5),ipt2

      integer io3,io4,io9
      common/ cst41 /io3,io4,io9
c-----------------------------------------------------------------------
      if (iphct.gt.4) goto 20
      write (*,1050) (vnu(l),names(l),l=1,iphct)
      goto 30
20    write (*,1050) (vnu(l),names(l),l=1,4)
      write (*,1060) (vnu(l),names(l),l=5,iphct)
30    write (*,*)
      write (*,1000) (ptx(i),i=1,ipt2)
      write (*,*)
      goto 10
 
10    goto (99), io4
      if (ipt2.eq.0) goto 99
 
      write (n4,1010) ipt2,0,1,iphct,(i,i=1,iphct),0,0,0,0
      write (n4,1020) (vnu(l),l=1,iphct)
      write (n4,1000) (ptx(i),i=1,ipt2)
 
1000  format (3(1x,g10.4,1x,g10.4,3x))
1010  format (20(i5,1x))
1020  format (10(g9.3,1x))
1050  format (/,4(1x,g9.3,1x,a))
1060  format (6x,4(1x,g9.3,1x,a),/,6x,4(1x,g9.3,1x,a))
99    end
 
      subroutine grxn (gval)
c--------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer j

      double precision fo2,fs2,gph,gval
 
      integer io2
      common/ oxy /io2

      integer iffr,isr
      double precision vuf,vus
      common/ cst201 /vuf(2),vus(h5),iffr,isr

      integer idf
      double precision act
      common/ cst205 /act(k7),idf(2)

      integer iff,idss,ifug,ifyn,isyn
      common/ cst10 /iff(2),idss(h5),ifug,ifyn,isyn

      double precision fh2o,fco2
      common/ cst11 /fh2o,fco2

      integer icomp,istct,iphct,icp
      common/ cst6 /icomp,istct,iphct,icp

      integer idr,ivct
      double precision vnu
      common/ cst25 /vnu(k7),idr(k7),ivct

      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps
c---------------------------------------------------------------------
c                                 compute free energy change of the rxn
      gval = 0d0
      fh2o = 0d0
      fco2 = 0d0
 
      if (ifyn.eq.0) call cfluid (fo2,fs2)
 
      do j = 1,iphct
         call gphase (j,gph)
         gval = gval + vnu(j) * (gph + r * t * dlog(act(j)))
      end do 
 
      gval = gval + vuf(1) * fh2o*r*t + vuf(2)*fco2*r*t

      if (io2.ne.0.and.ifyn.eq.0) gval = gval + vnu(io2)*r*t*fo2
 
      end

      subroutine change 
c---------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer i,j,ier,id,lct,jdis,klam,imurg,kv,ichk,h,k,kd,jd

      double precision cmurg8,cmurg7,cmurg6
 
      character y*1

      double precision tm(m7,m6)
 
      double precision thermo,uf,us
      common/ cst1 /thermo(k4,k10),uf(2),us(h5)

      character*8 names
      common/ cst8 /names(k1)

      character*29 list
      common / cst206 /list(20)

      double precision therdi,therlm
      common/ cst203 /therdi(m8,m9),therlm(m7,m6,k9)

      integer idf
      double precision act
      common/ cst205 /act(k7),idf(2)

      integer iff,idss,ifug,ifyn,isyn
      common/ cst10 /iff(2),idss(h5),ifug,ifyn,isyn

      integer icomp,istct,iphct,icp
      common/ cst6 /icomp,istct,iphct,icp

      integer idr,ivct
      double precision vnu
      common/ cst25 /vnu(k7),idr(k7),ivct

      double precision cp
      common/ cst12 /cp(k5,k1)

      integer iffr,isr
      double precision vuf,vus
      common/ cst201 /vuf(2),vus(h5),iffr,isr

      integer ltyp,lmda,idis
      common/ cst204 /ltyp(k1),lmda(k1),idis(k1)

      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps
c-----------------------------------------------------------------------
      write (*,1110)
      read (*,1050) y
      ier = 0
 
      if (y.ne.'y'.and.y.ne.'Y') goto 20
         
      if (iphct.gt.1.or.vnu(1).ne.1d0) then
         write (*,1120)
         read (*,1050) y
      else 
         y = 'n'
      end if 
 
      if (y.ne.'y'.and.y.ne.'Y') then

         if (iphct.gt.1) then 
 
            do 
               write (*,1000) (i,names(i),i=1,iphct)
               read (*,*,iostat=ier) id
               if (ier.eq.0) exit 
               call rerr
            end do 

         else
            id = 1
         end if 

         write (*,1040) names(id)
         read (*,1050) names(id)

         call unlam (tm,id,lct)

         call unver
     *           (thermo(1,id),thermo(2,id),thermo(3,id),thermo(4,id),
     *            thermo(5,id),thermo(6,id),thermo(7,id),thermo(8,id),
     *            thermo(9,id),thermo(10,id),thermo(11,id),
     *            thermo(12,id),thermo(13,id),thermo(14,id),
     *            thermo(15,id),thermo(16,id),thermo(17,id),
     *            thermo(18,id),tr,pr)
c                                get lamda and dis codes
         if (ltyp(id).gt.7.and.ltyp(id).lt.10) goto 91
c                                 add in activity correction
         thermo(1,k10) = thermo(1,id)
         thermo(2,k10) = thermo(2,id)
         thermo(1,id) = thermo(1,id) + tr * r * dlog (act(id))
         thermo(2,id) = thermo(2,id) - r * dlog (act(id))
 
         call append (n2)
         call outdat (n2,id,1)
c                                 reset data
         thermo(1,id) = thermo(1,k10) 
         thermo(2,id) = thermo(2,k10) 


         goto 99

      else

         id = 20
         idis(id) = 0
         ltyp(id) = 0
         jdis = 0
         klam = 0

         write (*,1130)
         read (*,1050) names(id)
 
         do i = 1, k4
            thermo(i,id) = 0d0
         end do 

         do i = 1, icomp
            cp(i,id) = 0d0  
         end do 
 
         imurg = 0
         klam = 0 

         do j = 1, iphct

            cmurg8 = thermo(18,j)

            if (cmurg8.ne.0d0.and.iphct.gt.1) then
c                                    test for Gottschalk
               call warn (45,cmurg8,iphct,names(id)) 
               goto 99
            else if (cmurg8.ne.0d0) then
c                                    test for Murghnahan EoS
               imurg = 1
               cmurg6 = thermo(16,j)
               cmurg7 = thermo(17,j)

            end if             

            do i = 1, k4
               thermo(i,id) = thermo(i,id) + vnu(j) * thermo(i,j)
            end do 

            do i = 1, icomp
               cp(i,id) = cp(i,id) + vnu(j) * cp(i,j)
            end do 

            if (imurg.eq.1) then 
               thermo(16,id) = cmurg6
               thermo(17,id) = cmurg7
               thermo(18,id) = cmurg8
            end if 


            if (idis(j).ne.0) then

               idis(id) = m9
               jdis = jdis + 1
               jd = idis(j) 
               if (jdis.gt.1) goto 91
               do i = 1, 7      
                  therdi(i,m9) = vnu(j) * therdi(i,jd)
               end do 
               therdi(8,m9) = therdi(8,jd)
               therdi(9,m9) = therdi(9,jd)

            end if

            if (ltyp(j).ne.0) then

               ltyp(id) = ltyp(j)
               kd = iphct + 1
               lmda(id) = kd
               jd = lmda(j)
               klam = klam + 1

               if (ltyp(j).eq.10) then
                  if (klam.gt.3) goto 91
                  ltyp(id) = 9 + klam
                  therlm(1,klam,kd) = therlm(1,1,jd)
                  therlm(2,klam,kd) = vnu(j) * therlm(2,1,jd)
                  therlm(3,klam,kd) = vnu(j) * therlm(3,1,jd)
               else if (ltyp(j).lt.4) then
                  if (klam.gt.1) goto 91
                  do i = 1, ltyp(j)
                     therlm(1,i,kd) = vnu(j) * therlm(1,i,jd)
                     therlm(2,i,kd) = vnu(j) * therlm(2,i,jd)
                     therlm(5,i,kd) = vnu(j) * therlm(5,i,jd)
                     therlm(6,i,kd) = vnu(j) * therlm(6,i,jd)
                     therlm(3,i,kd) = therlm(3,i,jd)
                     therlm(4,i,kd) = therlm(4,i,jd)
                     therlm(7,i,kd) = therlm(7,i,jd)
                     therlm(8,i,kd) = therlm(8,i,jd)
                  end do
               else if (ltyp(j).lt.8) then

                  if (klam.gt.1) goto 91

                  do k = 1, ltyp(j) - 3

                     therlm(1,k,kd) = therlm(1,k,jd)
                     therlm(2,k,kd) = therlm(2,k,jd)

                     do h = 3, 12
                        therlm(h,k,kd) = therlm(h,k,jd)*vnu(j)
                     end do
                  end do 
               end if
            end if
         end do

         call unlam (tm,id,lct)

         call unver
     *           (thermo(1,id),thermo(2,id),thermo(3,id),thermo(4,id),
     *            thermo(5,id),thermo(6,id),thermo(7,id),thermo(8,id),
     *            thermo(9,id),thermo(10,id),thermo(11,id),
     *            thermo(12,id),thermo(13,id),thermo(14,id),
     *            thermo(15,id),thermo(16,id),thermo(17,id),
     *            thermo(18,id),tr,pr)
c                                 add in activity correction
         thermo(1,k10) = thermo(1,id)
         thermo(2,k10) = thermo(2,id)

         do i = 1, iphct
            thermo(1,id) = thermo(1,id) + vnu(i) * tr * r * dlog(act(i))
            thermo(2,id) = thermo(2,id) - vnu(i) * r * dlog(act(i))
         end do 
c                                 output the data 
         call append (n2)
         call outdat (n2,id,1)
c                                 reset data
         thermo(1,id) = thermo(1,k10) 
         thermo(2,id) = thermo(2,k10) 

         goto 99

      end if
 
20    if (iphct.gt.1) then
         write (*,1000) (i,names(i),i=1,iphct)
         read (*,*,iostat=ier) id
         call rerror (ier,*20)
      else
         id = 1
      end if 

      ichk = 0

      write (*,1010)

10    write (*,1020) (i,list(i),i=1,20)
      read (*,*,iostat=ier) kv
      call rerror (ier,*10)
      if (kv.eq.0) then
         if (ichk.eq.0) goto 30
c                                 write entry to permanant file:
         write (*,1070) names(id)
         read (*,1050) y
c
         if (y.eq.'y'.or.y.eq.'Y') then
c                                 add in activity correction
            thermo(1,k10) = thermo(1,id)
            thermo(2,k10) = thermo(2,id)
            thermo(1,id) = thermo(1,id) + tr * r * dlog (act(id))
            thermo(2,id) = thermo(2,id) - r * dlog (act(id))
 
            call append (n2)
            call outdat (n2,id,1)

            thermo(1,id) = thermo(1,k10) 
            thermo(2,id) = thermo(2,k10) 


         end if
c
         call conver
     *        (thermo(1,id), thermo(2,id), thermo(3,id),thermo(4,id),
     *         thermo(5,id), thermo(6,id), thermo(7,id),thermo(8,id),
     *         thermo(9,id), thermo(10,id),thermo(11,id),
     *         thermo(12,id),thermo(13,id),thermo(14,id),
     *         thermo(15,id),thermo(16,id),thermo(17,id),
     *         thermo(18,id),thermo(19,id),thermo(20,id),
     *         thermo(21,id),thermo(22,id),thermo(23,id),tr,pr,r,0)
         goto 30
      end if
c
         if (ichk.eq.0) then

            call unlam (tm,id,lct)

            call unver
     *           (thermo(1,id),thermo(2,id),thermo(3,id),thermo(4,id),
     *            thermo(5,id),thermo(6,id),thermo(7,id),thermo(8,id),
     *            thermo(9,id),thermo(10,id),thermo(11,id),
     *            thermo(12,id),thermo(13,id),thermo(14,id),
     *            thermo(15,id),thermo(16,id),thermo(17,id),
     *            thermo(18,id),tr,pr)

            write (*,1040) names(id)
            read (*,1050) names(id)
            ichk = 1
         end if
         if (kv.eq.19) goto 50
         if (kv.eq.20) goto 60
5014        write (*,1030) list(kv),names(id),thermo(kv,id)
            read (*,*,iostat=ier) thermo(kv,id)
            call rerror (ier,*5014)
            goto 10
50       write (*,1030) list(kv),names(id),act(id)
         read (*,*,iostat=ier) act(id)
         call rerror (ier,*50)
         goto 10
c
60       write (*,1030) list(kv),names(id),vnu(id)
         read (*,*,iostat=ier) vnu(id)
         call rerror (ier,*60)
 
         if (id.eq.idf(1)) then
            vuf(1) = vnu(id)
         else if (id.eq.idf(2)) then
            vuf(2) = vnu(id)
         end if
 
         goto 10
 
30    write (*,1150)
      read (*,1050) y
      if (y.eq.'y'.or.y.eq.'Y') goto 20
 
      goto (99),ifyn
      write (*,1160)
      read (*,1050) y
      if (y.ne.'y'.and.y.ne.'Y') goto 99

      call rfluid (1,ifug) 
      goto 99

91    call warn (9,t,ifyn,names(id))

1000  format (/,'Select phase to modify',
     *          ' or output:',9(/,6x,i2,') ',a))
1010  format ('Thermodynamic properties are calculated from the ',
     *        'reference state constants'/,'G, S, V, and an ',
     *        'activity coefficient together ',
     *        'with the isobaric heat',/,'capacity function:',//,6x,
     *        'cp(pr,t) = a + b*t + c/t^2 + d*t^2 + e/t^(1/2) + f/t ',
     *        '+ g/t^3',//,
     *        ' and the volumetric function:',//,
     *        ' if b8 = 0 (Eq 2.1):',/,6x,
     *        'v(p,t) = v(pr,tr) + b2(t-tr) + b4(p-pr)',
     *        ' + b6(p-pr)^2 + b7(t-tr)^2',/,
     *        ' if b8 < 0 (Eq 2.2):',/,6x, 
     *        'v(p,t) = v(pr,tr) exp [b3*(t-tr) + b8*(p-pr)]',/,
     *        ' if b8 > 0 (Eq 2.3):',/,6x, 
     *        'v(p,t) = v(pr,t)[1 + b8*p/(Kt + b8*p)]^(1/b8)',/,6x,
     *        'alpha = b1 + b2*t + b3/t + b4/t^2 + b5/t^(1/2)',/,6x,
     *        'Kt = b6 + b7*t')
1020  format (/,'Enter the number of the parameter to be modified:'
     *      ,//,10(1x,i2,') ',a28,3x,i2,') ',a,/),/,
     *         'Enter zero when you are finished: ')
1030  format (/,'Old value for ',a,' of ',a,' was ',g15.8,/,
     *          'Enter new value: ')
1040  format (/,'Enter a name (<9 characters left justified) to',
     *          ' distinguish the modified',/,'version of ',a,'.',
     *          ' WARNING: if you intend to store modified data',/,
     *          'in the data file this name must be unique.',/)
1050  format (a)
1070  format (/,'Store ',a,' as an entry',
     *          ' in the thermodynamic data file (y/n)?')
1110  format (/,'Do you only want to output data (y/n)? ')
1120  format (/,'Output reaction properties (y/n)? ')
1130  format (/,'Enter an 8 character name for the reaction: ')
1150  format (/,'Modify properties of another phase (y/n)? ')
1160  format (/,'Change fluid equation of state (y/n)? ')

99    end
 
      subroutine nentry
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'

      integer i,ier,isv

      double precision fac
 
      character y*1
 
      character*8 names
      common/ cst8 /names(k1)

      integer eos
      common/ cst303 /eos(k10)

      integer cl
      character cmpnt*5, dname*80
      common/ csta5 /cl(k0),cmpnt(k0),dname

      character*29 list
      common / cst206 /list(20)

      integer icomp,istct,iphct,icp
      common/ cst6 /icomp,istct,iphct,icp

      integer idh2o,idco2,ikind,icmpn,icout,ieos
      double precision comp,tot
      common/ cst43 /comp(k0),tot,icout(k0),idh2o,idco2,
     *               ikind,icmpn,ieos

      double precision thermo,uf,us
      common/ cst1 /thermo(k4,k10),uf(2),us(h5)    

      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps
c-----------------------------------------------------------------------
      ier = 0
      write (*,1000) dname,tr,pr
 
      write (*,1120)
      read (*,'(a)') y
 
      if (y.eq.'c') then
         fac = 4.184d0
      else
         fac = 1d0
      end if
 
      write (*,1130)
      read (*,'(a)') y
 
      isv = 0
      if (y.eq.'v') isv = 1
 
      do 
  
      write (*,1010)
      read (*,'(a)') names(k10)
 
      do i = 1, icomp
5016     write (*,1030) cmpnt(i),names(k10)
         read (*,*,iostat=ier) comp(i)
         call rerror (ier,*5016)
      end do 
 
      do i = 1, 2
5020     write (*,1040) list(i),names(k10)
         read (*,*,iostat=ier) thermo(i,k10)
         call rerror (ier,*5020)
         thermo(i,k10) = fac * thermo(i,k10)
      end do 
 
5017  write (*,1040) list(3),names(k10)
      read (*,*,iostat=ier) thermo(3,k10)
      call rerror (ier,*5017)
 
      write (*,1050)
      do i = 4, 10
5018     write (*,1040) list(i),names(k10)
         read (*,*,iostat=ier) thermo(i,k10)
         call rerror (ier,*5018)
         thermo(i,k10) = fac * thermo(i,k10)
      end do 
 
      write (*,1060)
      write (*,1070)

      do i = 11, 18
5019     write (*,1040) list(i),names(k10)
         read (*,*,iostat=ier) thermo(i,k10)
         call rerror (ier,*5019)
         if (isv.eq.1) thermo(i,k10) = thermo(3,k10) * thermo(i,k10)
      end do 
c                                 classify eos:
         if (thermo(3,k10).lt.0d0) then 
c                                 negative "volume" signals one of the 
c                                 stixrude EoS's, for these EoS's "s" is
c                                 +/-n - number of atoms pfu.
            if (thermo(2,k10).gt.0d0) then

               eos(k10) = 5
c                                 stixrude & bukowinski JGR '93
            else

              eos(k10) = 6
c                                 stixrude & lithgow-bertelloni GJI '05
            end if 

         else if (thermo(18,k10).eq.0d0) then

            eos(k10) = 1
c                                 normal polynomial vdp term:
         else

            if (thermo(16,k10).eq.0d0) then
               eos(k10) = 3
            else if (thermo(18,k10).ge.3d0) then
               eos(k10) = 2
            else if (thermo(18,k10).le.3d0) then
               eos(k10) = 4
            else 
               eos(k10) = 7
            end if

         end if 
 
         call append (n2)

         call outdat (n2,k10,0)
 
         write (*,1110)
         read (*,'(a)') y
         if (y.ne.'y'.and.y.ne.'Y') exit

      end do 
 
1000  format (/,'Your entry will be formatted for the ',a,/,
     *      'data base with a t=',g13.6,'(k) p=',g13.6,'(bar)',/,
     *      'reference state (all energy terms must be in joules).',/)
1010  format ('Enter name for your entry, <8 characters, left',
     *        ' justified.',/,'WARNING: this name must not duplicate',
     *        ' an entry already',/,'in the data file!')
1030  format ('Enter number of moles of ',a,' in ',a,': ')
1040  format ('Enter ',a,' for ',a,': ')
1050  format (/,'Thermodynamic properties usually calculated from',
     *         ' heat capacity function (J/K):',/,6x,
     *         'cp(pr,t) = c1 + c2*t + c3/t^2 + c4*t^2 + c5/t^(1/2) ',
     *         '+ c6/t + c7/t^3')
1060  format (/,'Thermodynamic properties usually calculated from the',
     *        ' volumetric functions (J/bar):',/,
     *        ' if b8 = 0 (Eq 2.1):',/,6x,
     *        'v(p,t) = v(pr,tr) + b2(t-tr) + b4(p-pr)',
     *        ' + b6(p-pr)^2 + b7(t-tr)^2',/,
     *        ' if b8 < 0 (Eq 2.2):',/,6x, 
     *        'v(p,t) = v(pr,tr) exp [b3*(t-tr) + b8*(p-pr)]',/,
     *        ' if b8 > 0 (Eq 2.3):',/,6x, 
     *        'v(p,t) = v(pr,t)[1 + b8*p/(Kt + b8*p)]^(1/b8)',/,6x,
     *        'alpha = b1 + b2*t + b3/t + b4/t^2 + b5/t^(1/2)',/,6x,
     *        'Kt = b6 + b7*t')
1070  format (/,'For a more exhaustive listing of Perple_X equations-',
     *          'of-state refer to:',/,
     *          'www.perplex.ethz.ch/perplex_thermodynamic_data_file',
     *          '.html',/)
1110  format (/,'Make another entry (y/n)? ')
1120  format (/,'Enter a "c" to enter G, S, V, and a-g in calories: ')
1130  format (/,'Enter a "v" to scale b2-b7 by'
     *         ,' standard state volume: ')
      end
  
      subroutine prop (g,e,u,s,v,cp)
c----------------------------------------------------------------------
c props calculates thermodynamic properties by finite difference
c approximations from the gibbs function.
c-----------------------------------------------------------------------
      implicit none

      double precision g,e,u,s,v,cp,dp,dt,p0,t0,e2,s2,gtt,gp,gt
 
      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps
c                                finite difference increments:
      dp = 1d-1
      dt = 1d-2
      p0 = p
      t0 = t
 
      call grxn (g)
 
      p = p0 + dp
      call grxn (gp)
 
      p = p0
      t = t0 + dt
      call grxn (gt)
c                            entropy, volume, enthalpy:
      s = -(gt - g)/dt
      v = (gp -g)/dp
      e = s * t0 + g
      u = e - p0 * v
c                            heat capacity, this should be centered
c                            on t0, but it isn't:
      p = p0
      t = t0 + 2d0*dt
      call grxn (gtt)
 
      s2 = -(gtt - gt) / dt
 
      e2 = s2 * (t0+dt) + gt
 
      cp = (e2 - e) / dt
 
      p = p0
      t = t0

      end 

      subroutine append (lun)
c---------------------------------------------------------
c routine to allow frendly to append data to the thermo
c data file, necessary for microsoft NT compiler.
c---------------------------------------------------------
      implicit none

      integer lun, ier

      character*1 record
c                          find end of file:
      do 
         read (lun,*,iostat=ier) record
         if (ier.ne.0) exit
      end do 

      backspace (lun)
c                          start new record:
      write (lun,*)
c                          reposition at new
c                          record:
      backspace (lun)
      end

      subroutine jnput2 (icopt,rxny,uname)
c----------------------------------------------------------------------
c jnput2 reads all data in the thermodynamic data file, makes a list of
c possible phases and, depending on icopt, allows users to select 
c specific phases.

c icopt = 1-4 frendly
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      character*1 uname*8, y, rxny,mnames(k16*k17)*8
 
      double precision vvv

      logical eof, first, match

      integer inames, jcmpn, i, j, k, l, icopt, jdis, jlam, ier,
     *        isct, jj, itic, jphct
 
      character*8 names
      common/ cst8 /names(k1)

      integer idf
      double precision act
      common/ cst205 /act(k7),idf(2)

      integer iffr,isr
      double precision vuf,vus
      common/ cst201 /vuf(2),vus(h5),iffr,isr

      integer io2
      common/ oxy /io2

      integer iff,idss,ifug,ifyn,isyn
      common/ cst10  /iff(2),idss(h5),ifug,ifyn,isyn

      integer icomp,istct,iphct,icp
      common/ cst6  /icomp,istct,iphct,icp  

      character*8 exname,afname
      common/ cst36 /exname(h8),afname(2)

      character*8 name
      common/ csta6 /name

      double precision cp
      common/ cst12 /cp(k5,k1)

      integer cl
      character cmpnt*5, dname*80
      common/ csta5 /cl(k0),cmpnt(k0),dname

      integer ic
      common/ cst42 /ic(k0)

      integer idh2o,idco2,ikind,icmpn,icout,ieos
      double precision comp,tot
      common/ cst43 /comp(k0),tot,icout(k0),idh2o,idco2,
     *               ikind,icmpn,ieos
      integer ilam,idiso,lamin,idsin
      double precision tm,td
      common/ cst202 /tm(m7,m6),td(m8),ilam,idiso,lamin,idsin

      integer ltyp,lmda,idis
      common/ cst204 /ltyp(k1),lmda(k1),idis(k1)

      integer idr,ivct
      double precision vnu
      common/ cst25 /vnu(k7),idr(k7),ivct

      double precision thermo,uf,us
      common/ cst1 /thermo(k4,k10),uf(2),us(h5)

      double precision mcomp
      character mknam*8
      integer nmak
      logical mksat
      common / cst333 /mcomp(k16,k0),nmak,mksat(k16),mknam(k16,k17)

      double precision mkcoef, mdqf
      integer mknum, mkind
      common / cst334 /mkcoef(k16,k17),mdqf(k16,k17),mkind(k16,k17),
     *                 mknum(k16)

      integer make, mkst, mkend
      common / cst335 /make(k10)

      integer jcv,jvct,jpv,jtv,jf
      common / mu2f1 /jcv(2),jvct,jpv,jtv,jf(2)

      character*8 vname,xname
      common/ csta2  /xname(k5),vname(l2)

      character tname
      common/ csta10 /tname(2)

      integer iopt
      logical lopt
      double precision nopt
      common/ opts /nopt(i10),iopt(i10),lopt(i10)

      save first, inames, mnames
      data first/.true./
c-----------------------------------------------------------------------

      call topn2 (1)

      if (first) then

         call eohead (n2)
         call smakcp (inames,mnames)
         first = .false.
         call eohead (n2)

      end if 

      isyn = 1
c                              this check is here to avoid
c                              redimensioning comps, but cause
c                              the maximum number of components
c                              counted by frendly to be k5, if you
c                              want as many components in frendly as
c                              in the data base you must set k0 = k5.
      jcmpn = icmpn
      icomp = icmpn
      if (icmpn.gt.k5) then
         icomp = k5
         jcmpn = k5
         write (*,3020) k5
      end if 
c                               list database phases:
      write (*,1030)
      read (*,'(a)') y

      if (y.eq.'y'.or.y.eq.'Y') then 

         write (*,3000) (cmpnt(i),i=1,jcmpn)

         do 

            call getphi (name,eof)

            if (eof) then
c                               write make list:
               do i = 1, nmak

                  write (*,3010) mknam(i,mknum(i)+1),
     *                           (mcomp(i,j),j=1,jcmpn)
               end do 

               exit 

            end if
c                               acceptable data, count the phase
            write (*,3010) name, (comp(i),i=1,jcmpn)
 
         end do

      end if 

      do i = 1, k5
         ic(i) = i
      end do

      if (icopt.eq.4) goto 99
c                               initialize: 
      do k = 1, k5
         cp(k,1) = 0d0
      end do  
c                               initialization for k10 endnmembers
      do i = 1, k10
         make(i) = 0 
      end do
 
      do k = 1, k5+1
         lmda(k) = 0
         idis(k) = 0
         vnu(k) = 0d0
         act(k) = 0d0
         ltyp(k) = 0
      end do
 
      do k = 1, m7
          do l = 1, m6
            tm(k,l) = 0d0
          end do 
      end do 
 
      iphct = 0
      jdis = 0 
      io2 = 0 
      ifyn = 1
      jlam = 1
      jdis = 1
      vuf(1) = 0d0
      vuf(2) = 0d0
      idf(1) = 0
      idf(2) = 0
 
      if (icopt.eq.1) then
 
         rxny='y'
5002     write (*,4010)
         read (*,*,iostat=ier) isct
         call rerror (ier,*5002)
 
      else if (icopt.lt.8) then
 
         write (*,4000)
         read (*,'(a)') rxny
 
         if (rxny.eq.'y'.or.rxny.eq.'y') then
5007        write (*,4010)
            read (*,*,iostat=ier) isct
            call rerror (ier,*5007)
         else
            isct = 1
         end if

      end if
c                               jj is the pointer to the reaction props
      jj = isct+1
c                               get composition vectors for entities
c                               defined by a make definition:
      do i = 1, isct

30       match = .false.

         if (rxny.ne.'y'.and.rxny.ne.'Y') then
            write (*,4020)
         else
            write (*,4030) i
         end if
 
         read (*,'(a)') exname(1)
c                               general input data for main program
         call eohead (n2)
c                               first look in the real data:
         do  

           call getphi (name,eof)
c                               looked at all real data
           if (eof) exit

           if (exname(1).eq.name) exit 

         end do 

         if (eof) then 

            ieos = 0

            match = .false.
c                                look in the make list
            do k = 1, nmak

               name = mknam(k,mknum(k)+1)

               if (mksat(k).or.exname(1).ne.name) cycle
c                                load make data 
               do j = 1, icmpn
                  comp(j) = mcomp(k,j)
               end do 

               match = .true.

               make(iphct+1) = k

               exit 

            end do 

            if (.not.match) then 
c                                 no match with named phase
               write (*,4050) uname
               goto 30

            end if 

         end if 
c                                 set special flag if O2
         iphct = iphct + 1

         if (exname(1).eq.'O2      ') io2 = iphct 

         if (rxny.eq.'Y'.or.rxny.eq.'y') then

            do 
               write (*,1040) exname(1)
               read (*,*,iostat=ier) vvv
               if (ier.eq.0) exit
               call rerr
            end do 

         else
            vvv = 1d0
         end if
 
         if (lopt(7)) then 
            if (exname(1).eq.cmpnt(idh2o)) then
               vuf(1)=vvv
               idf(1)=iphct
               ifyn=0
            else if (exname(1).eq.cmpnt(idco2)) then
               vuf(2)=vvv
               idf(2)=iphct
               ifyn=0
            end if
         end if 
c                               get activity coefficients:
         do 
            write (*,4070) exname(1)
            read (*,*,iostat=ier) act(iphct)
            if (ier.eq.0) exit 
            call rerr
         end do 
c                               reaction coefficient:
         vnu(iphct)= vvv
c                               store the data 
         call loadit (iphct,.false.)

      end do 
c                                load the make dependencies               
      jphct = 21
c                                read header
      call eohead (n2)

      do 

         call getphi (name,eof)

         if (eof) exit

         do i = 1, inames

            if (name.ne.mnames(i)) cycle
c                                matched a name
            jphct = jphct + 1
c                                store thermodynamic parameters:
            call loadit (jphct,.false.)

         end do 

      end do 
c                                set counters
      mkend = jphct
      mkst  = 21

      do i = 1, nmak
c                                remake pointer array for makes 
         do j = 1, mknum(i)
            do k = mkst, mkend
               if (names(k).ne.mknam(i,j)) cycle
               mkind(i,j) = k
            end do
         end do 
      end do  
c                                 select equation of state for the
c                                 saturated phase.
      if (ifyn.eq.0) call rfluid (1,ifug)

      if (rxny.eq.'y'.or.rxny.eq.'Y') then
c                                 check reaction stoichiometries
55       do k= 1, k5
            cp(k,jj)=0d0
         end do 

         do l=1,iphct
            do k= 1, k5
               cp(k,jj) = cp(k,jj) + vnu(l)*cp(k,l)
            end do 
         end do 

         itic=0
         do k = 1, k5
            if (cp(k,jj).eq.0d0) cycle
               itic=itic+1
         end do 

         if (itic.eq.0) goto 99
 
         do k= 1, k5
            if (cp(k,jj).eq.0d0) cycle
            write (*,2460) cp(k,jj),cmpnt(k)
         end do 
 
         write (*,1070)
         read (*,'(a)') y
         if (y.ne.'y'.and.y.ne.'Y') goto 99
         call stoich
         goto 55
 
      end if
c                               position pointer to last record of
c                               data file to allow writing:
99    do
         read (n2,'(a)',iostat=i) name
         if (i.ne.0) exit
      end do

1030  format (/,'List database phases (y/n)? ')
1040  format ('Enter reaction coefficient for: ',a,
     *        ' products (+), reactants (-): ')
1041  format (/,'Select a phase or species to be used to define ',
     *        a,'(default =',a,')')
1051  format (/,'The phase or reaction has a T-dependent disordering ',
     *          'function.',/)
1061  format (/,'The phase or reaction has a transition-dependent ',
     *          'function.',/)
1070  format (/,'Change reaction coefficients (y/n)? ')
2460  format ('Warning ** reaction does not balance by ',g13.6,
     *        ' moles of ',a5)
3000  format (t30,'composition',/,' phase',4x,12(a5,1x))
3010  format (1x,a8,1x,12(f5.2,1x))
3020  format (/,'too many components, only first ',i2,
     *          ' will be listed.',/)
4020  format ('Calculate thermodynamic properties for phase: ')
4030  format ('Enter phase or species number ',i2,
     *       ' in your reaction: ')
4050  format ('Sorry ',a,', that name is invalid, try again.',/)
4070  format ('Enter activity of: ',a,
     *           ' (enter 1.0 for H2O or CO2): ')
4000  format (/,'Calculate thermodynamic ',
     *        'properties for a reaction (y/n)? ')
4010  format (/,'How many phases or species in the reaction? ')

      end

      subroutine stoich
c----------------------------------------------------------------------
      implicit none
 
      include 'perplex_parameters.h'
 
      character y*1

      integer i,ier,id

      integer idf
      double precision act
      common/ cst205 /act(k7),idf(2)

      integer idr,ivct
      double precision vnu
      common/ cst25 /vnu(k7),idr(k7),ivct

      character*8 names
      common/ cst8 /names(k1)

      integer icomp,istct,iphct,icp
      common/ cst6 /icomp,istct,iphct,icp

      integer iffr,isr
      double precision vuf,vus
      common/ cst201 /vuf(2),vus(h5),iffr,isr
c-----------------------------------------------------------------------
      ier = 0
20    write (*,1000) (i,names(i),vnu(i),i=1,iphct)
      write (*,*)
      read (*,*,iostat=ier) id
      call rerror (ier,*20)
 
5019  write (*,1030) names(id),vnu(id)
      read (*,*,iostat=ier) vnu(id)
      call rerror (ier,*5019)
 
      if (id.eq.idf(1)) then
         vuf(1) = vnu(id)
      else if (id.eq.idf(2)) then
         vuf(2) = vnu(id)
      end if
 
      write (*,1020)
      read (*,1010) y
      if (y.ne.'Y'.and.y.ne.'y') goto 99
      goto 20
 
1000  format (/,'Enter number of phase to be modified:',
     *        9(/,6x,i2,') ',a,' reaction coeff.=',f8.4))
1010  format (a1)
1020  format (/,'Modify coefficient of another phase (y/n)? ')
1030  format (/,'Old coefficient for ',a,' was ',f8.4,
     *          ' enter new value: ')
99    end

      subroutine dphasf (g0)
c-----------------------------------------------------------------------
c dphasf sets the props of a phase or reaction 
c computed by centered finite differences from the Gibbs energy
c as stored in props(i8,1)

c the difference increments are

c dt0, dp0 for 1st order derivatives (entropy,volume and enthalpy)
c dt1, dp1 for 2nd order derivatives (heat capacity, expansivity*, 
c          compressibility*)
c dt2, dp2 for 3rd order derivatives (gptt, gppt, gppp, gttt)
c          used for the T derivative of the bulk modulus. 

c *expansivity (alpha) as returned here is 1/v*dv/dt
c *compressibility (beta) as returned here is -1/v*dv/dp

c corrected to check for negative pressure, in which case 
c forward differences are used. june 22, 2004, JADC.
c-----------------------------------------------------------------------
      implicit none

      include 'perplex_parameters.h'

      double precision dt0,dt1,dt2,g0,g1a, g2a, dg, ss,alpha1,alpha2,
     *                 dp0,dp1,dp2,e,alpha,v,gincf,beta,cp,s,gtt,
     *                 g1,g2,g3,g4,g5,g7,gppp,gppt,gptt,gttt

      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps

      double precision props,psys,psys1
      common/ cxt22 /props(i8,k5),psys(i8),psys1(i8)

      integer iopt
      logical lopt
      double precision nopt
      common/ opts /nopt(i10),iopt(i10),lopt(i10)

      save dt0,dt1,dt2
      data dt0,dt1,dt2/0.5d0,5d0,5d1/
c----------------------------------------------------------------------

      dp2 = 5d-2 * p
      dp1 = dp2/1d1
      dp0 = dp1/1d1
            
      g0 = gincf(0d0,0d0)
c                                 straight derivatives:
c                                 first order
      if (p-dp0.le.0d0) then 

         v = (gincf(0d0,dp0) - g0)/dp0
         if (v.lt.0d0.or.dabs(v).gt.1d9)  
c                                 expand increment if invalid v
     *   v = (gincf(0d0,dp1) - g0)/dp1
         if (v.lt.0d0.or.dabs(v).gt.1d9)  
c                                 expand increment more if invalid v
     *   v = (gincf(0d0,dp2) - g0)/dp2

      else 

         v = (gincf(0d0,dp0) - gincf(0d0,-dp0))/dp0/2d0
         if ((v.lt.0d0.or.dabs(v).gt.1d9).and.p-dp1.gt.0d0)  
c                                 expand increment if invalid v
     *   v = (gincf(0d0,dp1) - gincf(0d0,-dp1))/dp1/2d0
         if ((v.lt.0d0.or.dabs(v).gt.1d9).and.p-dp2.gt.0d0)  
c                                 expand increment more if invalid v
     *   v = (gincf(0d0,dp2) - gincf(0d0,-dp2))/dp2/2d0

      end if 
c                                 in case the evaluating routine fails
c                                 on both calls to gincf 
      if (v.eq.0d0) v = 1d0

      s = (gincf(-dt0,0d0) - gincf(dt0,0d0))/dt0/2d0
c                                 this crap is necessary because 
c                                 optimization or my bad programming
c                                 corrupts gincf with compaq visual fortran.
      g1a = gincf(-dt0,0d0)
      g2a =  gincf(dt0,0d0)
      dg = g1a-g2a
      ss = dg/dt0/2d0
      s = ss
c
c 
c     write (*,*) s, ss, dg, gincf(-dt0,0d0) - gincf(dt0,0d0), dt0

      e = g0 + t * s
c                                 second order
      gtt = (gincf(dt1,0d0) + gincf(-dt1,0d0) - 2d0*g0)/dt1/dt1
      cp = -t*gtt
      if (cp.lt.0d0.or.dabs(cp).gt.1d9)  
c                                 expand increment if invalid cp
     *   cp = -t*(gincf(dt2,0d0) + gincf(-dt2,0d0) - 2d0*g0)/dt2/dt2
      if (cp.lt.0d0.or.dabs(cp).gt.1d9)  
c                                 shrink increment if invalid cp
     *   cp = -t*(gincf(dt0,0d0) + gincf(-dt0,0d0) - 2d0*g0)/dt0/dt0
   
      if (p-dp1.le.0d0) then 
c                                 use forward difference at small p's
         beta = (gincf(0d0,2d0*dp1) + g0 - 2d0*gincf(0d0,dp1))
     *          /dp1/dp1
         if (dabs(beta).gt.v.or.beta.ge.0d0)
c                                 expand increment if invalid beta
     *   beta = (gincf(0d0,2d0*dp2) + g0 - 2d0*gincf(0d0,dp2))
     *          /dp2/dp2                                 
         if (dabs(beta).gt.v.or.beta.ge.0d0)
c                                 shrink increment if invalid beta
     *   beta = (gincf(0d0,2d0*dp0) + g0 - 2d0*gincf(0d0,dp0))
     *          /dp0/dp0   

         alpha = ( gincf( dt1,dp1) - gincf( dt1,0d0)
     *            -gincf(-dt1,dp1) + gincf(-dt1,0d0))/dp1/dt1/2d0
         if (dabs(alpha).gt.v.or.alpha.le.0d0)
c                                 expand increment if invalid alpha
     *   alpha = ( gincf( dt2,dp2) - gincf( dt2,0d0)
     *            -gincf(-dt2,dp2) + gincf(-dt2,0d0))/dp2/dt2/2d0
         if (dabs(alpha).gt.v.or.alpha.le.0d0)
c                                 shrink increment if invalid alpha
     *   alpha = ( gincf( dt0,dp0) - gincf( dt0,0d0)
     *            -gincf(-dt0,dp0) + gincf(-dt0,0d0))/dp0/dt0/2d0

      else 

         beta = (gincf(0d0,dp1) + gincf(0d0,-dp1) - 2d0*g0)/dp1/dp1
         if (dabs(beta).gt.v.and.p-dp2.ge.0d0.or.beta.ge.0d0)
c                                 expand increment if invalid beta
     *   beta = (gincf(0d0,dp2) + gincf(0d0,-dp2) - 2d0*g0)/dp2/dp2
     
     
         if (dabs(beta).gt.v.or.beta.ge.0d0)
c                                 shrink increment if invalid beta
     *   beta = (gincf(0d0,dp0) + gincf(0d0,-dp0) - 2d0*g0)/dp0/dp0

         alpha = ( gincf( dt1,dp1) - gincf( dt1,-dp1)
     *            -gincf(-dt1,dp1) + gincf(-dt1,-dp1))/dp1/dt1/4d0
         if (dabs(alpha).gt.v.or.alpha.le.0d0) then 
c                                 expand increment if invalid alpha
            alpha1 = ( gincf( dt2,dp2) - gincf( dt2,-dp2)
     *            -gincf(-dt2,dp2) + gincf(-dt2,-dp2))/dp2/dt2/4d0
            if (dabs(alpha1).gt.v.or.alpha1.le.0d0) then
c                                 shrink increment if invalid alpha
               alpha2 = ( gincf( dt0,dp0) - gincf( dt0,-dp0)
     *            -gincf(-dt0,dp0) + gincf(-dt0,-dp0))/dp0/dt2/4d0
               if (dabs(alpha2).lt.v.and.alpha2.ge.0d0) then 
                  alpha = alpha2
               end if 
            else 
               alpha = alpha1
            end if 
         end if      
     
      end if  
c                                 third order derivatives, only need for
c                                 derivatives of seismic props.
      if (p-2d0*dp2.le.0d0) then 

         g1 = gincf(-dt2,0d0)
         g2 = gincf( dt2,2d0*dp2)
         g3 = gincf( dt2,0d0)
         g4 = gincf(-dt2,2d0*dp2)
         g5 = gincf(0d0,dp2)
         g7 = g3 - g1

         gppp = ((gincf(0d0,4d0*dp2) - g0)/2d0
     *           - gincf(0d0,3d0*dp2) + g5)/dp2**3
         gppt = (g2 + g3 + 2d0*(gincf(-dt2, dp2)-gincf(dt2,dp2))
     *           -g4 - g1)/dp2/dp2/dt2/2d0
         gptt = (g2 + g4  + 2d0*(g0 - gincf(0d0,2d0*dp2))
     *           -g3 - g1)/2d0/dp2/dt2/dt2

      else 

         g1 = gincf(-dt2,-dp2) - gincf( dt2,dp2)
         g3 = gincf( dt2,-dp2)
         g4 = gincf(-dt2,dp2)
         g5 = gincf(0d0,dp2) - gincf(0d0,-dp2)
         g7 = gincf(-dt2,0d0) - gincf(dt2, 0d0)

         gppp = ((gincf(0d0,2d0*dp2) - gincf(0d0,-2d0*dp2))/2d0 
     *        - g5)/dp2**3
         gppt = (g3 - g4 + 2d0*g7 - g1)/dp2/dp2/dt2/2d0
         gptt = (g4 - g3 - 2d0*g5 - g1)/2d0/dp2/dt2/dt2
 
      end if 

      gttt = ((gincf(dt2*2d0,0d0) - gincf(-dt2*2d0,0d0))/2d0 
     *        + g7)/dt2**3

      g7 = (gtt*beta-alpha**2)**2

      if (g7.ne.0d0) then 
c                                 temperature derivative of the adiabatic bulk modulus:
         props(18,1) = (((v*gppt-alpha*beta)*gtt
     *                   -(2d0*v*gptt-alpha**2)*alpha)*gtt
     *                   +v*gttt*alpha**2)/g7
c                                 pressure derivative of the adiabatic bulk modulus:
         props(20,1) = (((v*gppp-beta**2)*gtt
     *                   +(alpha*beta-2d0*v*gppt)*alpha)*gtt
     *                   +v*gptt*alpha**2)/g7
      else 

         props(18,1) = nopt(7)
         props(20,1) = nopt(7)

      end if 
c                                 -------------------------------------
c                                 up to this point beta = d2g/dp2
c                                 and alpha = d2g/dp2 now convert 
c                                 to their normal forms:
      beta = -beta/v
      alpha = alpha/v
c                                 
      if (beta.gt.v.or.beta.lt.0d0) beta = nopt(7)
c                                 aug 28, 2007, removed check on alpha to 
c                                 accomodate -alpha's generated by landau 
c                                 transition models. 
      if (cp.gt.1d9.or.cp.lt.0d0) cp = nopt(7)

      props(1,1) = v 
      props(2,1) = e
      props(12,1) = cp
      props(13,1) = alpha
      props(14,1) = beta
      props(15,1) = s

      end 

      double precision function gincf (dt,dp)
c-----------------------------------------------------------------------
      implicit none

      double precision dt,dp,gee

      double precision p,t,xco2,u1,u2,tr,pr,r,ps
      common/ cst5 /p,t,xco2,u1,u2,tr,pr,r,ps

      p = p + dp 
      t = t + dt 

      call grxn (gee)

      p = p - dp 
      t = t - dt

      gincf = gee 

      end 