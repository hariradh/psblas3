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
! File: psb_dasum.f90
!
! Function: psb_dasum 
!    Computes norm1 of X
!
!    norm1 := sum(sub( X )(i))
!
!    where sub( X ) denotes X(1:N,JX:).
!
! Arguments:
!    x(:,:) -  real                     The input vector.
!    desc_a -  type(psb_desc_type).     The communication descriptor.
!    info   -  integer.                 Return code
!    jx     -  integer(optional).       The column offset.
!
function psb_dasum (x,desc_a, info, jx)

  use psb_serial_mod
  use psb_descriptor_type
  use psb_check_mod
  use psb_error_mod
  use psb_penv_mod
  implicit none

  real(psb_dpk_), intent(in)      :: x(:,:)
  type(psb_desc_type), intent(in)   :: desc_a
  integer, intent(out)              :: info
  integer, optional, intent(in)     :: jx
  real(psb_dpk_)                  :: psb_dasum

  ! locals
  integer           :: ictxt, np, me, err_act, &
       &      iix, jjx, ix, ijx, m, i, idx, ndm
  real(psb_dpk_)  :: asum, dasum
  character(len=20) :: name, ch_err

  name='psb_dasum'
  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)

  asum=0.d0

  ictxt=psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  ix = 1
  if (present(jx)) then
    ijx = jx
  else
    ijx = 1
  endif

  m = psb_cd_get_global_rows(desc_a)

  ! check vector correctness
  call psb_chkvect(m,1,size(x,1),ix,ijx,desc_a,info,iix,jjx)
  if(info /= psb_success_) then
    info=psb_err_from_subroutine_
    ch_err='psb_chkvect'
    call psb_errpush(info,name,a_err=ch_err)
    goto 9999
  end if

  if (iix /= 1) then
    info=psb_err_ix_n1_iy_n1_unsupported_
    call psb_errpush(info,name)
    goto 9999
  end if

  ! compute local max
  if ((m /= 0)) then
    if(psb_cd_get_local_rows(desc_a) > 0) then
      asum=dasum(psb_cd_get_local_rows(desc_a)-iix+1,x(iix:,jjx),ione)

      ! adjust asum because overlapped elements are computed more than once
      do i=1,size(desc_a%ovrlap_elem,1)
        idx  = desc_a%ovrlap_elem(i,1)
        ndm  = desc_a%ovrlap_elem(i,2)
        asum = asum - (real(ndm-1)/real(ndm))*abs(x(idx,jjx))
      end do

      ! compute global sum
      call psb_sum(ictxt, asum)

    else
      asum=0.d0
      ! compute global sum
      call psb_sum(ictxt, asum)
    end if
  else
    asum=0.d0
  end if


  psb_dasum=asum

  call psb_erractionrestore(err_act)
  return  

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  return
end function psb_dasum


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
!
! Function: psb_dasumv 
!    Computes norm1 of X
!
!    norm1 := sum(X(i))
!
! Arguments:
!    x(:)   -  real                     The input vector.
!    desc_a -  type(psb_desc_type).     The communication descriptor.
!    info   -  integer.                   Return code
!
function psb_dasumv (x,desc_a, info)

  use psb_serial_mod
  use psb_descriptor_type
  use psb_check_mod
  use psb_error_mod
  use psb_penv_mod
  implicit none

  real(psb_dpk_), intent(in)      :: x(:)
  type(psb_desc_type), intent(in)   :: desc_a
  integer, intent(out)              :: info
  real(psb_dpk_)                  :: psb_dasumv

  ! locals
  integer            :: ictxt, np, me, err_act, iix, jjx, jx, ix, m, i, idx, ndm
  real(psb_dpk_)   :: asum, dasum
  character(len=20)  :: name, ch_err

  name='psb_dasumv'
  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)

  asum=0.d0

  ictxt=psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  ix = 1
  jx=1

  m = psb_cd_get_global_rows(desc_a)

  ! check vector correctness
  call psb_chkvect(m,1,size(x),ix,jx,desc_a,info,iix,jjx)
  if(info /= psb_success_) then
    info=psb_err_from_subroutine_
    ch_err='psb_chkvect'
    call psb_errpush(info,name,a_err=ch_err)
    goto 9999
  end if

  if (iix /= 1) then
    info=psb_err_ix_n1_iy_n1_unsupported_
    call psb_errpush(info,name)
    goto 9999
  end if

  ! compute local max
  if ((m /= 0)) then
    if(psb_cd_get_local_rows(desc_a) > 0) then
      asum=dasum(psb_cd_get_local_rows(desc_a),x,ione)
      ! adjust asum because overlapped elements are computed more than once
      do i=1,size(desc_a%ovrlap_elem,1)
        idx  = desc_a%ovrlap_elem(i,1)
        ndm  = desc_a%ovrlap_elem(i,2)
        asum = asum - (real(ndm-1)/real(ndm))*abs(x(idx))
      end do

      ! compute global sum
      call psb_sum(ictxt, asum)

    else
      asum=0.d0
      ! compute global sum
      call psb_sum(ictxt, asum)
    end if
  else
    asum=0.d0
  end if

  psb_dasumv=asum

  call psb_erractionrestore(err_act)
  return  

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  return
end function psb_dasumv



function psb_dasum_d_vect(x, desc_a, info) result(res)
  use psb_penv_mod
  use psb_serial_mod
  use psb_descriptor_type
  use psb_check_mod
  use psb_error_mod
  use psb_d_vect_mod
  implicit none

  real(psb_dpk_)                      :: res
  class(psb_d_vect), intent (in)      :: x
  type(psb_desc_type), intent (in)    :: desc_a
  integer, intent(out)                :: info

  ! locals
  integer                  :: ictxt, np, me,&
       & err_act, iix, jjx, jx, ix, m, imax, idamax
  real(psb_dpk_)         :: asum
  character(len=20)        :: name, ch_err

  name='psb_dasumv'
  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)

  asum=0.d0

  ictxt=psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  ix = 1
  jx = 1

  m = psb_cd_get_global_rows(desc_a)

  call psb_chkvect(m,1,x%get_nrows(),ix,jx,desc_a,info,iix,jjx)
  if(info /= psb_success_) then
    info=psb_err_from_subroutine_
    ch_err='psb_chkvect'
    call psb_errpush(info,name,a_err=ch_err)
    goto 9999
  end if

  if (iix /= 1) then
    info=psb_err_ix_n1_iy_n1_unsupported_
    call psb_errpush(info,name)
    goto 9999
  end if

  ! compute local max
  if ((psb_cd_get_local_rows(desc_a) > 0).and.(m /= 0)) then
    asum=x%asum(psb_cd_get_local_rows(desc_a))
  else 
    asum = dzero
  end if

  ! compute global sum
  call psb_sum(ictxt, asum)

  res=asum

  call psb_erractionrestore(err_act)
  return  

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  return

end function psb_dasum_d_vect



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
!
! Subroutine: psb_dasumvs
!    Computes norm1 of X
!
!    norm1 := sum(X(i))
!
! Arguments:
!    res    -  real                       The result.
!    x(:)   -  real                       The input vector.
!    desc_a -  type(psb_desc_type).     The communication descriptor.
!    info   -  integer.                   Return code
!    jx     -  integer(optional).         The column offset.
!
subroutine psb_dasumvs(res,x,desc_a, info)
  use psb_base_mod, psb_protect_name => psb_dasumvs
  implicit none

  real(psb_dpk_), intent(in)      :: x(:)
  real(psb_dpk_), intent(out)     :: res
  type(psb_desc_type), intent(in)   :: desc_a
  integer, intent(out)              :: info

  ! locals
  integer            :: ictxt, np, me, err_act, iix, jjx, ix, jx, m, i, idx, ndm
  real(psb_dpk_)   :: asum, dasum
  character(len=20)  :: name, ch_err

  name='psb_dasumvs'
  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)

  asum=0.d0

  ictxt=psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  ix = 1
  jx = 1

  m = psb_cd_get_global_rows(desc_a)

  ! check vector correctness
  call psb_chkvect(m,1,size(x),ix,jx,desc_a,info,iix,jjx)
  if(info /= psb_success_) then
    info=psb_err_from_subroutine_
    ch_err='psb_chkvect'
    call psb_errpush(info,name,a_err=ch_err)
    goto 9999
  end if

  if (iix /= 1) then
    info=psb_err_ix_n1_iy_n1_unsupported_
    call psb_errpush(info,name)
    goto 9999
  end if

  ! compute local max
  if ((m /= 0)) then
    if(psb_cd_get_local_rows(desc_a) > 0) then
      asum=dasum(psb_cd_get_local_rows(desc_a),x,ione)

      ! adjust asum because overlapped elements are computed more than once
      do i=1,size(desc_a%ovrlap_elem,1)
        idx  = desc_a%ovrlap_elem(i,1)
        ndm  = desc_a%ovrlap_elem(i,2)
        asum = asum - (real(ndm-1)/real(ndm))*abs(x(idx))
      end do

      ! compute global sum
      call psb_sum(ictxt,asum)

    else
      asum=0.d0
      ! compute global sum
      call psb_sum(ictxt, asum)
    end if
  else
    asum=0.d0
  end if


  res = asum

  call psb_erractionrestore(err_act)
  return  

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error(ictxt)
    return
  end if
  return
end subroutine psb_dasumvs




