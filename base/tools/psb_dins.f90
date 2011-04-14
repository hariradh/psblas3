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
! Subroutine: psb_dinsvi
!    Insert dense submatrix to dense matrix. Note: the row indices in IRW 
!    are assumed to be in global numbering and are converted on the fly. 
!    Row indices not belonging to the current process are silently discarded.
! 
! Arguments: 
!    m       - integer.        Number of rows of submatrix belonging to 
!                              val to be inserted.
!    irw(:)  - integer          Row indices of rows of val (global numbering)
!    val(:)  - real                  The source dense submatrix.  
!    x(:)    - real                  The destination dense matrix.  
!    desc_a  - type(psb_desc_type).         The communication descriptor.
!    info    - integer.                       return code
!    dupl    - integer               What to do with duplicates: 
!                                     psb_dupl_ovwrt_    overwrite
!                                     psb_dupl_add_      add         
subroutine psb_dinsvi(m, irw, val, x, desc_a, info, dupl)
  use psb_base_mod, psb_protect_name => psb_dinsvi
  use psi_mod
  implicit none

  ! m rows number of submatrix belonging to val to be inserted
  ! ix  x global-row corresponding to position at which val submatrix
  !     must be inserted

  !....parameters...
  integer, intent(in)                ::  m
  integer, intent(in)                ::  irw(:)
  real(psb_dpk_), intent(in)       ::  val(:)
  real(psb_dpk_), intent(inout)    ::  x(:)
  type(psb_desc_type), intent(in)    ::  desc_a
  integer, intent(out)               ::  info
  integer, optional, intent(in)      ::  dupl

  !locals.....
  integer                :: ictxt,i,&
       & loc_rows,loc_cols,mglob,err_act, int_err(5)
  integer                :: np, me, dupl_
  integer, allocatable   :: irl(:)
  character(len=20)      :: name

  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)
  name = 'psb_dinsvi'

  if (.not.psb_is_ok_desc(desc_a)) then
    int_err(1)=3110
    call psb_errpush(info,name)
    return
  end if

  ictxt = psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  !... check parameters....
  if (m < 0) then
    info = psb_err_iarg_neg_
    int_err(1) = 1
    int_err(2) = m
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (.not.psb_is_ok_desc(desc_a)) then
    info = psb_err_input_matrix_unassembled_
    int_err(1) = psb_cd_get_dectype(desc_a)
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (size(x, dim=1) < psb_cd_get_local_rows(desc_a)) then
    info = 310
    int_err(1) = 5
    int_err(2) = 4
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  if (m == 0) return  
  loc_rows = psb_cd_get_local_rows(desc_a)
  loc_cols = psb_cd_get_local_cols(desc_a)
  mglob    = psb_cd_get_global_rows(desc_a)


  allocate(irl(m),stat=info) 
  if (info /= psb_success_) then 
    info = psb_err_alloc_dealloc_
    call psb_errpush(info,name)
    goto 9999
  endif
    
  if (present(dupl)) then 
    dupl_ = dupl
  else
    dupl_ = psb_dupl_ovwrt_
  endif

  call psi_idx_cnv(m,irw,irl,desc_a,info,owned=.true.)

  select case(dupl_) 
  case(psb_dupl_ovwrt_) 
    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      if (irl(i) > 0) then
        ! this row belongs to me
        ! copy i-th row of block val in x
        x(irl(i)) = val(i)
      end if
    enddo

  case(psb_dupl_add_) 

    do i = 1, m
      !loop over all val's rows

      if (irl(i) > 0) then
          ! this row belongs to me
          ! copy i-th row of block val in x
        x(irl(i)) = x(irl(i)) +  val(i)
      end if
    enddo

  case default
    info = 321
    call psb_errpush(info,name)
    goto 9999
  end select
  deallocate(irl)

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

end subroutine psb_dinsvi

subroutine psb_dins_vect(m, irw, val, x, desc_a, info, dupl)
  use psb_base_mod, psb_protect_name => psb_dins_vect
  use psi_mod
  implicit none

  ! m rows number of submatrix belonging to val to be inserted
  ! ix  x global-row corresponding to position at which val submatrix
  !     must be inserted

  !....parameters...
  integer, intent(in)              :: m
  integer, intent(in)              :: irw(:)
  real(psb_dpk_), intent(in)       :: val(:)
  class(psb_d_vect), intent(inout) :: x
  type(psb_desc_type), intent(in)  :: desc_a
  integer, intent(out)             :: info
  integer, optional, intent(in)    :: dupl

  !locals.....
  integer                :: ictxt,i,&
       & loc_rows,loc_cols,mglob,err_act, int_err(5)
  integer                :: np, me, dupl_
  integer, allocatable   :: irl(:)
  character(len=20)      :: name

  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)
  name = 'psb_dinsvi'

  if (.not.psb_is_ok_desc(desc_a)) then
    int_err(1)=3110
    call psb_errpush(info,name)
    return
  end if

  ictxt = psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  !... check parameters....
  if (m < 0) then
    info = psb_err_iarg_neg_
    int_err(1) = 1
    int_err(2) = m
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (.not.psb_is_ok_desc(desc_a)) then
    info = psb_err_input_matrix_unassembled_
    int_err(1) = psb_cd_get_dectype(desc_a)
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (x%get_nrows() < psb_cd_get_local_rows(desc_a)) then
    info = 310
    int_err(1) = 5
    int_err(2) = 4
    call psb_errpush(info,name,int_err)
    goto 9999
  endif

  if (m == 0) return  
  loc_rows = psb_cd_get_local_rows(desc_a)
  loc_cols = psb_cd_get_local_cols(desc_a)
  mglob    = psb_cd_get_global_rows(desc_a)


  allocate(irl(m),stat=info) 
  if (info /= psb_success_) then 
    info = psb_err_alloc_dealloc_
    call psb_errpush(info,name)
    goto 9999
  endif
    
  if (present(dupl)) then 
    dupl_ = dupl
  else
    dupl_ = psb_dupl_ovwrt_
  endif

  call psi_idx_cnv(m,irw,irl,desc_a,info,owned=.true.)
  
  call x%ins(m,irl,val,dupl_,info) 
  if (info /= 0) then 
    call psb_errpush(info,name)
    goto 9999
  end if
  deallocate(irl)

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

end subroutine psb_dins_vect


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
! Subroutine: psb_dinsi
!    Insert dense submatrix to dense matrix. Note: the row indices in IRW 
!    are assumed to be in global numbering and are converted on the fly. 
!    Row indices not belonging to the current process are silently discarded.
! 
! Arguments: 
!    m        - integer.        Number of rows of submatrix belonging to 
!                              val to be inserted.
!    irw(:)   - integer          Row indices of rows of val (global numbering)
!    val(:,:) - real                    The source dense submatrix.  
!    x(:,:)   - real                    The destination dense matrix.  
!    desc_a   - type(psb_desc_type).         The communication descriptor.
!    info     - integer.                       return code
!    dupl    - integer               What to do with duplicates: 
!                                     psb_dupl_ovwrt_    overwrite
!                                     psb_dupl_add_      add         
subroutine psb_dinsi(m, irw, val, x, desc_a, info, dupl)
  use psb_base_mod, psb_protect_name => psb_dinsi
  use psi_mod
  implicit none

  ! m rows number of submatrix belonging to val to be inserted

  ! ix  x global-row corresponding to position at which val submatrix
  !     must be inserted

  !....parameters...
  integer, intent(in)                ::  m
  integer, intent(in)                ::  irw(:)
  real(psb_dpk_), intent(in)       ::  val(:,:)
  real(psb_dpk_), intent(inout)    ::  x(:,:)
  type(psb_desc_type), intent(in)    ::  desc_a
  integer, intent(out)               ::  info
  integer, optional, intent(in)      ::  dupl

  !locals.....
  integer                :: ictxt,i,loc_row,j,n,&
       & loc_rows,loc_cols,mglob,err_act, int_err(5)
  integer                :: np,me,dupl_
  integer, allocatable   :: irl(:)
  character(len=20)   :: name

  if(psb_get_errstatus() /= 0) return 
  info=psb_success_
  call psb_erractionsave(err_act)
  name = 'psb_dinsi'

  if (.not.psb_is_ok_desc(desc_a)) then
    int_err(1)=3110
    call psb_errpush(info,name)
    return
  end if

  ictxt = psb_cd_get_context(desc_a)

  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif

  !... check parameters....
  if (m < 0) then
    info = psb_err_iarg_neg_
    int_err(1) = 1
    int_err(2) = m
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (.not.psb_is_ok_desc(desc_a)) then
    info = psb_err_input_matrix_unassembled_
    int_err(1) = psb_cd_get_dectype(desc_a)
    call psb_errpush(info,name,int_err)
    goto 9999
  else if (size(x, dim=1) < psb_cd_get_local_rows(desc_a)) then
    info = 310
    int_err(1) = 5
    int_err(2) = 4
    call psb_errpush(info,name,int_err)
    goto 9999
  endif
  if (m == 0) return 

  loc_rows = psb_cd_get_local_rows(desc_a)
  loc_cols = psb_cd_get_local_cols(desc_a)
  mglob    = psb_cd_get_global_rows(desc_a)

  n = min(size(val,2),size(x,2))

  if (present(dupl)) then 
    dupl_ = dupl
  else
    dupl_ = psb_dupl_ovwrt_
  endif

  allocate(irl(m),stat=info) 
  if (info /= psb_success_) then 
    info = psb_err_alloc_dealloc_
    call psb_errpush(info,name)
    goto 9999
  endif
  
  call psi_idx_cnv(m,irw,irl,desc_a,info,owned=.true.)

  select case(dupl_) 
  case(psb_dupl_ovwrt_) 
    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      loc_row = irl(i)
      if (loc_row > 0) then
        ! this row belongs to me
        ! copy i-th row of block val in x
        do j=1,n
          x(loc_row,j) = val(i,j)
        end do
      end if
    enddo

  case(psb_dupl_add_) 

    do i = 1, m
      !loop over all val's rows

      ! row actual block row 
      loc_row = irl(i)
      if (loc_row > 0) then
        ! this row belongs to me
        ! copy i-th row of block val in x
        do j=1,n
          x(loc_row,j) = x(loc_row,j) +  val(i,j)
        end do
      end if
    enddo

  case default
    info = 321
    call psb_errpush(info,name)
    goto 9999
  end select
  deallocate(irl)

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

end subroutine psb_dinsi


