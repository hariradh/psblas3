!!$ 
!!$              Parallel Sparse BLAS  version 2.2
!!$    (C) Copyright 2006/2007/2008
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
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
! File: psb_dgelp.f90
!
!
! Subroutine: psb_dgelp
!             Apply a left permutation to a dense matrix
!
! Arguments:
! trans    - character. 
! iperm    - integer.
! x        - real, dimension(:,:).
! info     - integer.                 Return code.
subroutine psb_dgelp(trans,iperm,x,info)
  use psb_serial_mod, psb_protect_name => psb_dgelp
  use psb_const_mod
  use psb_error_mod
  implicit none

  real(psb_dpk_), intent(inout)      ::  x(:,:)
  integer, intent(in)                  ::  iperm(:)
  integer, intent(out)                 ::  info
  character, intent(in)                :: trans

  ! local variables
  integer                  :: ictxt
  real(psb_dpk_),allocatable  :: dtemp(:)
  integer                  :: int_err(5), i1sz, i2sz, err_act,i,j
  integer, allocatable     :: itemp(:)
  real(psb_dpk_),parameter    :: one=1
  integer              :: debug_level, debug_unit

!!$  interface dgelp
!!$    subroutine dgelp(trans,m,n,p,b,ldb,work,lwork,ierror)
!!$      use psb_const_mod
!!$      integer, intent(in)  :: ldb, m, n, lwork
!!$      integer, intent(out) :: ierror
!!$      character, intent(in) :: trans
!!$      real(psb_dpk_), intent(inout) ::  b(ldb,*), work(*)
!!$      integer, intent(in)  :: p(*)
!!$    end subroutine dgelp
!!$  end interface

  character(len=20)   :: name, ch_err
  name = 'psb_dgelp'

  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  i1sz    = size(x,dim=1)
  i2sz    = size(x,dim=2)

  if (debug_level >= psb_debug_serial_)&
       & write(debug_unit,*)  trim(name),': size',i1sz,i2sz

  allocate(dtemp(i1sz),itemp(size(iperm)),stat=info)
  if (info /= psb_success_) then
    info=2040
    call psb_errpush(info,name)
    goto 9999
  end if
  itemp(:) = iperm(:) 

  if (.not.psb_isaperm(i1sz,itemp)) then
    info=psb_err_iarg_invalid_value_
    int_err(1) = 1      
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  endif
  select case( psb_toupper(trans))
  case('N') 
    do j=1,i2sz
      do i=1,i1sz
        dtemp(i) = x(itemp(i),j)
      end do
      do i=1,i1sz
        x(i,j) = dtemp(i) 
      end do
    end do
  case('T')
    do j=1,i2sz
      do i=1,i1sz
        dtemp(itemp(i)) = x(i,j)
      end do
      do i=1,i1sz
        x(i,j) = dtemp(i) 
      end do
    end do
  case default
    info=psb_err_from_subroutine_
    ch_err='dgelp'
    call psb_errpush(info,name,a_err=ch_err)
  end select

  deallocate(dtemp,itemp)

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_dgelp



!!$ 
!!$              Parallel Sparse BLAS  version 2.2
!!$    (C) Copyright 2006/2007/2008
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
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
!
!
! Subroutine: psb_dgelpv
!             Apply a left permutation to a dense matrix
!
! Arguments:
! trans    - character. 
! iperm    - integer.
! x        - real, dimension(:).
! info     - integer.                 Return code.
subroutine psb_dgelpv(trans,iperm,x,info)
  use psb_serial_mod, psb_protect_name => psb_dgelpv
  use psb_const_mod
  use psb_error_mod
  implicit none

  real(psb_dpk_), intent(inout)    ::  x(:)
  integer, intent(in)                  ::  iperm(:)
  integer, intent(out)                 ::  info
  character, intent(in)              ::  trans

  ! local variables
  integer :: ictxt
  integer :: int_err(5), i1sz, err_act, i
  real(psb_dpk_),allocatable  ::  dtemp(:)
  integer, allocatable     :: itemp(:)
  real(psb_dpk_),parameter    :: one=1
  integer              :: debug_level, debug_unit

!!$  interface dgelp
!!$    subroutine dgelp(trans,m,n,p,b,ldb,work,lwork,ierror)
!!$      use psb_const_mod
!!$      integer, intent(in)  :: ldb, m, n, lwork
!!$      integer, intent(out) :: ierror
!!$      character, intent(in) :: trans
!!$      real(psb_dpk_), intent(inout) ::  b(*), work(*)
!!$      integer, intent(in)  :: p(*)
!!$    end subroutine dgelp
!!$  end interface

  character(len=20)   :: name, ch_err
  name = 'psb_dgelpv'

  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  i1sz = min(size(x),size(iperm))

  if (debug_level >= psb_debug_serial_)&
       & write(debug_unit,*)  trim(name),': size',i1sz
  allocate(dtemp(i1sz),itemp(size(iperm)),stat=info)
  if (info /= psb_success_) then
    info=2040
    call psb_errpush(info,name)
    goto 9999
  end if
  itemp(:) = iperm(:) 
  
  if (.not.psb_isaperm(i1sz,itemp)) then
    info=psb_err_iarg_invalid_value_
    int_err(1) = 1      
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  endif

  select case( psb_toupper(trans))
  case('N') 
    do i=1,i1sz
      dtemp(i) = x(itemp(i))
    end do
    do i=1,i1sz
      x(i) = dtemp(i) 
    end do
  case('T')
    do i=1,i1sz
      dtemp(itemp(i)) = x(i)
    end do
    do i=1,i1sz
      x(i) = dtemp(i) 
    end do
  case default
    info=psb_err_from_subroutine_
    ch_err='dgelp'
    call psb_errpush(info,name,a_err=ch_err)
  end select

  deallocate(dtemp,itemp)

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return

end subroutine psb_dgelpv

