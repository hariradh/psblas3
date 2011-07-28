!!$ 
!!$              Parallel Sparse BLAS  version 3.0
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        CNRS-IRIT, Toulouse
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the PSBLAS group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$  
!!$ CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
!!$ C                                                                      C
!!$ C  References:                                                         C
!!$ C          [1] Duff, I., Marrone, M., Radicati, G., and Vittoli, C.    C
!!$ C              Level 3 basic linear algebra subprograms for sparse     C
!!$ C              matrices: a user level interface                        C
!!$ C              ACM Trans. Math. Softw., 23(3), 379-401, 1997.          C
!!$ C                                                                      C
!!$ C                                                                      C
!!$ C         [2]  S. Filippone, M. Colajanni                              C
!!$ C              PSBLAS: A library for parallel linear algebra           C
!!$ C              computation on sparse matrices                          C
!!$ C              ACM Trans. on Math. Softw., 26(4), 527-550, Dec. 2000.  C
!!$ C                                                                      C
!!$ C         [3] M. Arioli, I. Duff, M. Ruiz                              C
!!$ C             Stopping criteria for iterative solvers                  C
!!$ C             SIAM J. Matrix Anal. Appl., Vol. 13, pp. 138-144, 1992   C
!!$ C                                                                      C
!!$ C                                                                      C
!!$ C         [4] R. Barrett et al                                         C
!!$ C             Templates for the solution of linear systems             C
!!$ C             SIAM, 1993                                          
!!$ C                                                                      C
!!$ C                                                                      C
!!$ CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! File:  psb_dcgs.f90
!
! Subroutine: psb_dcgs
!    Implements the Conjugate Gradient Squared method.
!
!
! Arguments:
!
!    a      -  type(psb_dspmat_type)      Input: sparse matrix containing A.
!    prec   -  class(psb_dprec_type)       Input: preconditioner
!    b      -  real,dimension(:)          Input: vector containing the
!                                         right hand side B
!    x      -  real,dimension(:)          Input/Output: vector containing the
!                                         initial guess and final solution X.
!    eps    -  real                       Input: Stopping tolerance; the iteration is
!                                         stopped when the error estimate |err| <= eps
!    desc_a -  type(psb_desc_type).       Input: The communication descriptor.
!    info   -  integer.                   Output: Return code
!
!    itmax  -  integer(optional)          Input: maximum number of iterations to be
!                                         performed.
!    iter   -  integer(optional)          Output: how many iterations have been
!                                         performed.
!                                         performed.
!    err    -  real   (optional)          Output: error estimate on exit. If the
!                                         denominator of the estimate is exactly
!                                         0, it is changed into 1. 
!    itrace -  integer(optional)          Input: print an informational message
!                                         with the error estimate every itrace
!                                         iterations
!    istop  -  integer(optional)          Input: stopping criterion, or how
!                                         to estimate the error. 
!                                         1: err =  |r|/|b|; here the iteration is
!                                            stopped when  |r| <= eps * |b|
!                                         2: err =  |r|/(|a||x|+|b|);  here the iteration is
!                                            stopped when  |r| <= eps * (|a||x|+|b|)
!                                         where r is the (preconditioned, recursive
!                                         estimate of) residual. 
!
!
Subroutine psb_dcgs(a,prec,b,x,eps,desc_a,info,itmax,iter,err,itrace,istop)
  use psb_base_mod
  use psb_prec_mod
  use psb_inner_krylov_mod
  use psb_krylov_mod
  implicit none
  type(psb_dspmat_type), intent(in)  :: a
  

  Type(psb_desc_type), Intent(in)    :: desc_a 
  class(psb_dprec_type), Intent(in)   :: prec 
  Real(psb_dpk_), Intent(in)       :: b(:)
  Real(psb_dpk_), Intent(inout)    :: x(:)
  Real(psb_dpk_), Intent(in)       :: eps
  integer, intent(out)               :: info
  Integer, Optional, Intent(in)      :: itmax, itrace,istop
  Integer, Optional, Intent(out)     :: iter
  Real(psb_dpk_), Optional, Intent(out) :: err
!!$   local data
  Real(psb_dpk_), allocatable, target   :: aux(:),wwrk(:,:)
  Real(psb_dpk_), Pointer  :: ww(:), q(:),&
       & r(:), p(:), v(:), s(:), z(:), f(:), rt(:),qt(:),uv(:)
  Integer       :: itmax_, naux, mglob, it, itrace_,int_err(5),&
       & np,me, n_row, n_col,istop_, err_act
  Integer            :: itx, isvch, ictxt
  integer            :: debug_level, debug_unit
  Real(psb_dpk_)   :: alpha, beta, rho, rho_old, sigma 
  type(psb_itconv_type) :: stopdat
  character(len=20)           :: name
  character(len=*), parameter :: methdname='CGS'

  info = psb_success_
  name = 'psb_dcgs'
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  ictxt = desc_a%get_context()
  Call psb_info(ictxt, me, np)
  if (debug_level >= psb_debug_ext_)&
       & write(debug_unit,*) me,' ',trim(name),': from psb_info',np

  mglob = desc_a%get_global_rows()
  n_row = desc_a%get_local_rows()
  n_col = desc_a%get_local_cols()

  If (Present(istop)) Then 
    istop_ = istop 
  Else
    istop_ = 2
  Endif

  call psb_chkvect(mglob,1,size(x,1),1,1,desc_a,info)
  if (info == psb_success_) call psb_chkvect(mglob,1,size(b,1),1,1,desc_a,info)
  if(info /= psb_success_) then
    info=psb_err_from_subroutine_    
    call psb_errpush(info,name,a_err='psb_chkvect on X/B')
    goto 9999
  end if

  naux=4*n_col 
  Allocate(aux(naux),stat=info)
  if (info == psb_success_) Call psb_geall(wwrk,desc_a,info,n=11)
  if (info == psb_success_) Call psb_geasb(wwrk,desc_a,info)  
  if (info /= psb_success_) Then 
     info=psb_err_from_subroutine_non_ 
     call psb_errpush(info,name)
     goto 9999
  End If

  q  => wwrk(:,1)
  qt => wwrk(:,2)
  r  => wwrk(:,3)
  rt => wwrk(:,4)
  p  => wwrk(:,5)
  v  => wwrk(:,6)
  uv => wwrk(:,7)
  z  => wwrk(:,8)
  f  => wwrk(:,9)
  s  => wwrk(:,10)
  ww => wwrk(:,11)


  If (Present(itmax)) Then 
    itmax_ = itmax
  Else
    itmax_ = 1000
  Endif

  If (Present(itrace)) Then
    itrace_ = itrace
  Else
    itrace_ = 0
  End If

  ! Ensure global coherence for convergence checks.
  call psb_set_coher(ictxt,isvch)
  
  itx   = 0

  call psb_init_conv(methdname,istop_,itrace_,itmax_,a,b,eps,desc_a,stopdat,info)
  if (info /= psb_success_) Then 
     call psb_errpush(psb_err_from_subroutine_non_,name)
     goto 9999
  End If

  restart: Do 
!!$
!!$   r0 = b-ax0
!!$ 
    if (itx >= itmax_) exit restart  
    it = 0      
    call psb_geaxpby(done,b,dzero,r,desc_a,info)
    if (info == psb_success_) call psb_spmm(-done,a,x,done,r,desc_a,info,work=aux)
    if (info == psb_success_) call psb_geaxpby(done,r,dzero,rt,desc_a,info)
    if (info /= psb_success_) then
       info=psb_err_from_subroutine_non_
       call psb_errpush(info,name)
       goto 9999
    end if
    

    ! Perhaps we already satisfy the convergence criterion...
    if (psb_check_conv(methdname,itx,x,r,desc_a,stopdat,info)) exit restart
    if (info /= psb_success_) Then 
      call psb_errpush(psb_err_from_subroutine_non_,name)
      goto 9999
    End If

    rho = dzero

    iteration:  do 
      it   = it + 1
      itx = itx + 1
      if (debug_level >= psb_debug_ext_) &
           & write(debug_unit,*) me,' ',trim(name),'iteration: ',itx

      rho_old = rho    
      rho = psb_gedot(rt,r,desc_a,info)

      if (rho == dzero) then
         if (debug_level >= psb_debug_ext_) &
              & write(debug_unit,*) me,' ',trim(name),&
              & ' iteration breakdown r',rho
        exit iteration
      endif

      if (it == 1) then
        call psb_geaxpby(done,r,dzero,uv,desc_a,info)
        if (info == psb_success_) call psb_geaxpby(done,r,dzero,p,desc_a,info)
      else
        beta = (rho/rho_old)
        call psb_geaxpby(done,r,dzero,uv,desc_a,info)
        if (info == psb_success_) call psb_geaxpby(beta,q,done,uv,desc_a,info)
        if (info == psb_success_) call psb_geaxpby(done,q,beta,p,desc_a,info)
        if (info == psb_success_) call psb_geaxpby(done,uv,beta,p,desc_a,info)
      end if

      if (info == psb_success_) call prec%apply(p,f,desc_a,info,work=aux)

      if (info == psb_success_) call psb_spmm(done,a,f,dzero,v,desc_a,info,&
           & work=aux)
      
      if (info /= psb_success_) then
         call psb_errpush(psb_err_from_subroutine_,name,a_err='First loop part ')
         goto 9999
      end if
      
      sigma = psb_gedot(rt,v,desc_a,info)
      if (sigma == dzero) then
         if (debug_level >= psb_debug_ext_) &
              & write(debug_unit,*) me,' ',trim(name),&
              & ' iteration breakdown s1', sigma
         exit iteration
      endif
      
      alpha = rho/sigma

      if (info == psb_success_) call psb_geaxpby(done,uv,dzero,q,desc_a,info)
      if (info == psb_success_) call psb_geaxpby(-alpha,v,done,q,desc_a,info)
      if (info == psb_success_) call psb_geaxpby(done,uv,dzero,s,desc_a,info)
      if (info == psb_success_) call psb_geaxpby(done,q,done,s,desc_a,info)
      
      if (info == psb_success_) call prec%apply(s,z,desc_a,info,work=aux)

      if (info == psb_success_) call psb_geaxpby(alpha,z,done,x,desc_a,info)

      if (info == psb_success_) call psb_spmm(done,a,z,dzero,qt,desc_a,info,&
           & work=aux)
      
      if (info == psb_success_) call psb_geaxpby(-alpha,qt,done,r,desc_a,info)
      
      if (info /= psb_success_) then
         call psb_errpush(psb_err_from_subroutine_,name,a_err='X update ')
         goto 9999
      end if

      if (psb_check_conv(methdname,itx,x,r,desc_a,stopdat,info)) exit restart
      if (info /= psb_success_) Then 
        call psb_errpush(psb_err_from_subroutine_non_,name)
        goto 9999
      End If

    end do iteration
  end do restart

  call psb_end_conv(methdname,itx,desc_a,stopdat,info,err,iter)

  deallocate(aux,stat=info)
  if (info == psb_success_) call psb_gefree(wwrk,desc_a,info)
  if (info /= psb_success_) then
    call psb_errpush(info,name)
    goto 9999
  end if

  ! restore external global coherence behaviour
  call psb_restore_coher(ictxt,isvch)
  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

End Subroutine psb_dcgs
