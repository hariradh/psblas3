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
! File: psb_dsprn.f90
!
! Subroutine: psb_dsprn
!    Reinit sparse matrix structure for psblas routines: on output the matrix 
!    is in the update state.
! 
! Arguments: 
!    a        - type(psb_dspmat_type).        The sparse matrix to be reinitiated.      
!    desc_a   - type(psb_desc_type).          The communication descriptor.
!    info     - integer.                        Return code.
!    clear    - logical, optional               Whether the coefficients should be zeroed
!                                               default .true.          
Subroutine psb_dsprn(a, desc_a,info,clear)
  use psb_base_mod, psb_protect_name => psb_dsprn
  Implicit None

  !....Parameters...
  Type(psb_desc_type), intent(in)      :: desc_a
  Type(psb_dspmat_type), intent(inout) :: a
  integer, intent(out)                 :: info
  logical, intent(in), optional        :: clear

  !locals
  Integer             :: ictxt,np,me,err,err_act
  integer             :: debug_level, debug_unit
  integer             :: int_err(5)
  character(len=20)   :: name
  logical             :: clear_

  info = psb_success_
  err  = 0
  int_err(1)=0
  name = 'psb_dsprn'
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  ictxt = desc_a%get_context()
  call psb_info(ictxt, me, np)
  if (debug_level >= psb_debug_outer_) &
       & write(debug_unit,*) me,' ',trim(name),': start '

  if (psb_is_bld_desc(desc_a)) then
    ! Should do nothing, we are called redundantly
    return
  endif
  if (.not.psb_is_asb_desc(desc_a)) then
    info=590     
    call psb_errpush(info,name)
    goto 9999
  endif

  call a%reinit(clear=clear)

  if (info /= psb_success_) goto 9999
  if (debug_level >= psb_debug_outer_) &
       & write(debug_unit,*) me,' ',trim(name),': done'

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  return

end subroutine psb_dsprn
