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
!!$
!
!
subroutine psb_s_map_X2Y(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_s_map_X2Y
  implicit none 
  type(psb_slinmap_type), intent(in) :: map
  real(psb_spk_), intent(in)     :: alpha,beta
  real(psb_spk_), intent(inout)  :: x(:)
  real(psb_spk_), intent(out)    :: y(:)
  integer, intent(out)           :: info 
  real(psb_spk_), optional       :: work(:)

  !
  real(psb_spk_), allocatable   :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       &  map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_X2Y'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_Y%get_context()
    nr2   = map%p_desc_Y%get_global_rows()
    nc2   = map%p_desc_Y%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(sone,map%map_X2Y,x,szero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_Y%get_context()
    nr1   = map%desc_X%get_local_rows() 
    nc1   = map%desc_X%get_local_cols() 
    nr2   = map%desc_Y%get_global_rows()
    nc2   = map%desc_Y%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(sone,map%map_X2Y,xt,szero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_s_map_X2Y


!
! Takes a vector x from space map%p_desc_Y and maps it onto
! map%p_desc_X under map%map_Y2X possibly with communication
! due to exch_bk_idx
!
subroutine psb_s_map_Y2X(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_s_map_Y2X

  implicit none 
  type(psb_slinmap_type), intent(in) :: map
  real(psb_spk_), intent(in)     :: alpha,beta
  real(psb_spk_), intent(inout)  :: x(:)
  real(psb_spk_), intent(out)    :: y(:)
  integer, intent(out)             :: info 
  real(psb_spk_), optional       :: work(:)

  !
  real(psb_spk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_Y2X'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_X%get_context()
    nr2   = map%p_desc_X%get_global_rows()
    nc2   = map%p_desc_X%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(sone,map%map_Y2X,x,szero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_X%get_context()
    nr1   = map%desc_Y%get_local_rows() 
    nc1   = map%desc_Y%get_local_cols() 
    nr2   = map%desc_X%get_global_rows()
    nc2   = map%desc_X%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(sone,map%map_Y2X,xt,szero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_s_map_Y2X


!
! Takes a vector x from space map%p_desc_X and maps it onto
! map%p_desc_Y under map%map_X2Y possibly with communication
! due to exch_fw_idx
!
subroutine psb_d_map_X2Y(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_d_map_X2Y
  implicit none 
  type(psb_dlinmap_type), intent(in) :: map
  real(psb_dpk_), intent(in)     :: alpha,beta
  real(psb_dpk_), intent(inout)  :: x(:)
  real(psb_dpk_), intent(out)    :: y(:)
  integer, intent(out)             :: info 
  real(psb_dpk_), optional       :: work(:)

  !
  real(psb_dpk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2 ,&
       &  map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_X2Y'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input: unassembled'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_Y%get_context()
    nr2   = map%p_desc_Y%get_global_rows()
    nc2   = map%p_desc_Y%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(done,map%map_X2Y,x,dzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_Y%get_context()
    nr1   = map%desc_X%get_local_rows() 
    nc1   = map%desc_X%get_local_cols() 
    nr2   = map%desc_Y%get_global_rows()
    nc2   = map%desc_Y%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(done,map%map_X2Y,xt,dzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input', &
         & map_kind, psb_map_aggr_, psb_map_gen_linear_
    info = 1
    return 
  end select

end subroutine psb_d_map_X2Y


subroutine psb_d_map_X2Y_vect(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_d_map_X2Y_vect
  implicit none 
  type(psb_dlinmap_type), intent(in) :: map
  real(psb_dpk_), intent(in)     :: alpha,beta
  class(psb_d_vect), intent(inout)  :: x,y
  integer, intent(out)           :: info 
  real(psb_dpk_), optional       :: work(:)
  
  info = 700 

  return
end subroutine psb_d_map_X2Y_vect


!
! Takes a vector x from space map%p_desc_Y and maps it onto
! map%p_desc_X under map%map_Y2X possibly with communication
! due to exch_bk_idx
!
subroutine psb_d_map_Y2X(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_d_map_Y2X

  implicit none 
  type(psb_dlinmap_type), intent(in) :: map
  real(psb_dpk_), intent(in)     :: alpha,beta
  real(psb_dpk_), intent(inout)  :: x(:)
  real(psb_dpk_), intent(out)    :: y(:)
  integer, intent(out)             :: info 
  real(psb_dpk_), optional       :: work(:)

  !
  real(psb_dpk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_Y2X'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_X%get_context()
    nr2   = map%p_desc_X%get_global_rows()
    nc2   = map%p_desc_X%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(done,map%map_Y2X,x,dzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_X%get_context()
    nr1   = map%desc_Y%get_local_rows() 
    nc1   = map%desc_Y%get_local_cols() 
    nr2   = map%desc_X%get_global_rows()
    nc2   = map%desc_X%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(done,map%map_Y2X,xt,dzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_d_map_Y2X

subroutine psb_d_map_Y2X_vect(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_d_map_Y2X_vect
  implicit none 
  type(psb_dlinmap_type), intent(in) :: map
  real(psb_dpk_), intent(in)     :: alpha,beta
  class(psb_d_vect), intent(inout)  :: x,y
  integer, intent(out)           :: info 
  real(psb_dpk_), optional       :: work(:)

  info = 700 
  return
end subroutine psb_d_map_Y2X_vect


!
! Takes a vector x from space map%p_desc_X and maps it onto
! map%p_desc_Y under map%map_X2Y possibly with communication
! due to exch_fw_idx
!
subroutine psb_c_map_X2Y(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_c_map_X2Y

  implicit none 
  type(psb_clinmap_type), intent(in) :: map
  complex(psb_spk_), intent(in)         :: alpha,beta
  complex(psb_spk_), intent(inout)      :: x(:)
  complex(psb_spk_), intent(out)        :: y(:)
  integer, intent(out)                  :: info 
  complex(psb_spk_), optional           :: work(:)

  !
  complex(psb_spk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_X2Y'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_Y%get_context()
    nr2   = map%p_desc_Y%get_global_rows()
    nc2   = map%p_desc_Y%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(cone,map%map_X2Y,x,czero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_Y%get_context()
    nr1   = map%desc_X%get_local_rows() 
    nc1   = map%desc_X%get_local_cols() 
    nr2   = map%desc_Y%get_global_rows()
    nc2   = map%desc_Y%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(cone,map%map_X2Y,xt,czero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_c_map_X2Y


!
! Takes a vector x from space map%p_desc_Y and maps it onto
! map%p_desc_X under map%map_Y2X possibly with communication
! due to exch_bk_idx
!
subroutine psb_c_map_Y2X(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_c_map_Y2X

  implicit none 
  type(psb_clinmap_type), intent(in) :: map
  complex(psb_spk_), intent(in)       :: alpha,beta
  complex(psb_spk_), intent(inout)    :: x(:)
  complex(psb_spk_), intent(out)      :: y(:)
  integer, intent(out)                  :: info 
  complex(psb_spk_), optional         :: work(:)

  !
  complex(psb_spk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_Y2X'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_X%get_context()
    nr2   = map%p_desc_X%get_global_rows()
    nc2   = map%p_desc_X%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(cone,map%map_Y2X,x,czero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_X%get_context()
    nr1   = map%desc_Y%get_local_rows() 
    nc1   = map%desc_Y%get_local_cols() 
    nr2   = map%desc_X%get_global_rows()
    nc2   = map%desc_X%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(cone,map%map_Y2X,xt,czero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_c_map_Y2X


!
! Takes a vector x from space map%p_desc_X and maps it onto
! map%p_desc_Y under map%map_X2Y possibly with communication
! due to exch_fw_idx
!
subroutine psb_z_map_X2Y(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_z_map_X2Y

  implicit none 
  type(psb_zlinmap_type), intent(in) :: map
  complex(psb_dpk_), intent(in)       :: alpha,beta
  complex(psb_dpk_), intent(inout)    :: x(:)
  complex(psb_dpk_), intent(out)      :: y(:)
  integer, intent(out)                  :: info 
  complex(psb_dpk_), optional         :: work(:)

  !
  complex(psb_dpk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_X2Y'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_Y%get_context()
    nr2   = map%p_desc_Y%get_global_rows()
    nc2   = map%p_desc_Y%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(zone,map%map_X2Y,x,zzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_Y%get_context()
    nr1   = map%desc_X%get_local_rows() 
    nc1   = map%desc_X%get_local_cols() 
    nr2   = map%desc_Y%get_global_rows()
    nc2   = map%desc_Y%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_X,info,work=work)
    if (info == psb_success_) call psb_csmm(zone,map%map_X2Y,xt,zzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_Y)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_Y,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_z_map_X2Y


!
! Takes a vector x from space map%p_desc_Y and maps it onto
! map%p_desc_X under map%map_Y2X possibly with communication
! due to exch_bk_idx
!
subroutine psb_z_map_Y2X(alpha,x,beta,y,map,info,work)
  use psb_base_mod, psb_protect_name => psb_z_map_Y2X

  implicit none 
  type(psb_zlinmap_type), intent(in) :: map
  complex(psb_dpk_), intent(in)       :: alpha,beta
  complex(psb_dpk_), intent(inout)    :: x(:)
  complex(psb_dpk_), intent(out)      :: y(:)
  integer, intent(out)                :: info 
  complex(psb_dpk_), optional         :: work(:)

  !
  complex(psb_dpk_), allocatable :: xt(:), yt(:)
  integer                       :: i, j, nr1, nc1,nr2, nc2,&
       & map_kind, map_data, nr, ictxt
  character(len=20), parameter  :: name='psb_map_Y2X'

  info = psb_success_
  if (.not.psb_is_asb_map(map)) then 
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end if

  map_kind = psb_get_map_kind(map)

  select case(map_kind)
  case(psb_map_aggr_)

    ictxt = map%p_desc_X%get_context()
    nr2   = map%p_desc_X%get_global_rows()
    nc2   = map%p_desc_X%get_local_cols() 
    allocate(yt(nc2),stat=info) 
    if (info == psb_success_) call psb_halo(x,map%p_desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(zone,map%map_Y2X,x,zzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%p_desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%p_desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if

  case(psb_map_gen_linear_)

    ictxt = map%desc_X%get_context()
    nr1   = map%desc_Y%get_local_rows() 
    nc1   = map%desc_Y%get_local_cols() 
    nr2   = map%desc_X%get_global_rows()
    nc2   = map%desc_X%get_local_cols() 
    allocate(xt(nc1),yt(nc2),stat=info) 
    xt(1:nr1) = x(1:nr1) 
    if (info == psb_success_) call psb_halo(xt,map%desc_Y,info,work=work)
    if (info == psb_success_) call psb_csmm(zone,map%map_Y2X,xt,zzero,yt,info)
    if ((info == psb_success_) .and. psb_is_repl_desc(map%desc_X)) then
      call psb_sum(ictxt,yt(1:nr2))
    end if
    if (info == psb_success_) call psb_geaxpby(alpha,yt,beta,y,map%desc_X,info)
    if (info /= psb_success_) then 
      write(psb_err_unit,*) trim(name),' Error from inner routines',info
      info = -1
    end if
   

  case default
    write(psb_err_unit,*) trim(name),' Invalid descriptor input'
    info = 1
    return 
  end select

end subroutine psb_z_map_Y2X


