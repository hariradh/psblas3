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
!
! package: psb_linmap_mod
!    Defines facilities for mapping between vectors belonging
!    to different spaces.
!
module psb_d_linmap_mod

  use psb_const_mod
  use psb_linmap_type_mod


  interface psb_map_X2Y
    subroutine psb_d_map_X2Y(alpha,x,beta,y,map,info,work)
      use psb_linmap_type_mod
      implicit none 
      type(psb_dlinmap_type), intent(in) :: map
      real(psb_dpk_), intent(in)     :: alpha,beta
      real(psb_dpk_), intent(inout)  :: x(:)
      real(psb_dpk_), intent(out)    :: y(:)
      integer, intent(out)           :: info 
      real(psb_dpk_), optional       :: work(:)
    end subroutine psb_d_map_X2Y
  end interface

  interface psb_map_Y2X
    subroutine psb_d_map_Y2X(alpha,x,beta,y,map,info,work)
      use psb_linmap_type_mod
      implicit none 
      type(psb_dlinmap_type), intent(in) :: map
      real(psb_dpk_), intent(in)     :: alpha,beta
      real(psb_dpk_), intent(inout)  :: x(:)
      real(psb_dpk_), intent(out)    :: y(:)
      integer, intent(out)           :: info 
      real(psb_dpk_), optional       :: work(:)
    end subroutine psb_d_map_Y2X
  end interface


  interface psb_is_ok_map
    module procedure psb_is_ok_dlinmap
  end interface

  interface psb_get_map_kind
    module procedure psb_get_dmap_kind
  end interface

  interface psb_set_map_kind
    module procedure psb_set_dmap_kind
  end interface

  interface psb_map_cscnv
    module procedure psb_d_map_cscnv
  end interface

  interface psb_is_asb_map
    module procedure psb_is_asb_dlinmap
  end interface

  interface psb_linmap_sub
    module procedure psb_d_linmap_sub
  end interface

  interface psb_move_alloc
    module procedure  psb_dlinmap_transfer
  end interface

  interface psb_linmap
    function psb_d_linmap(map_kind,desc_X, desc_Y, map_X2Y, map_Y2X,iaggr,naggr)
      use psb_linmap_type_mod
      implicit none 
      type(psb_dlinmap_type)         :: psb_d_linmap    
      type(psb_desc_type), target       :: desc_X, desc_Y
      type(psb_dspmat_type), intent(in) :: map_X2Y, map_Y2X
      integer, intent(in)               :: map_kind
      integer, intent(in), optional     :: iaggr(:), naggr(:)
    end function psb_d_linmap
  end interface

  interface psb_sizeof
    module procedure psb_dlinmap_sizeof
  end interface

contains

  function psb_get_dmap_kind(map)    
    implicit none
    type(psb_dlinmap_type), intent(in) :: map
    Integer                      :: psb_get_dmap_kind
    if (allocated(map%itd_data)) then
      psb_get_dmap_kind = map%itd_data(psb_map_kind_) 
    else    
      psb_get_dmap_kind = -1
    end if
  end function psb_get_dmap_kind


  subroutine psb_set_dmap_kind(map_kind,map)    
    implicit none
    integer, intent(in)          :: map_kind
    type(psb_dlinmap_type), intent(inout) :: map

    map%itd_data(psb_map_kind_) = map_kind

  end subroutine psb_set_dmap_kind

  subroutine psb_d_map_cscnv(map,info,type,mold)    
    use psb_mat_mod
    implicit none
    type(psb_dlinmap_type), intent(inout)  :: map
    integer, intent(out)                   :: info
    character(len=*), intent(in), optional :: type
    class(psb_d_base_sparse_mat), intent(in), optional :: mold

    call map%map_X2Y%cscnv(info,type=type,mold=mold)
    if (info == psb_success_)&
         & call map%map_Y2X%cscnv(info,type=type,mold=mold)

  end subroutine psb_d_map_cscnv

  function psb_is_asb_dlinmap(map) result(this)
    use psb_descriptor_type
    implicit none 
    type(psb_dlinmap_type), intent(in) :: map
    logical :: this

    this = .false.
    if (.not.allocated(map%itd_data)) return
    select case(psb_get_map_kind(map))
    case (psb_map_aggr_)
      if (.not.associated(map%p_desc_X)) return
      if (.not.associated(map%p_desc_Y)) return
      this  = &
           & psb_is_asb_desc(map%p_desc_X).and.psb_is_asb_desc(map%p_desc_Y)    

    case(psb_map_gen_linear_)    

      this = &
           & psb_is_asb_desc(map%desc_X).and.psb_is_asb_desc(map%desc_Y)    

    end select

  end function psb_is_asb_dlinmap

  function psb_is_ok_dlinmap(map) result(this)
    use psb_descriptor_type
    implicit none 
    type(psb_dlinmap_type), intent(in) :: map
    logical  :: this
    this = .false.
    if (.not.allocated(map%itd_data)) return
    select case(psb_get_map_kind(map))
    case (psb_map_aggr_)
      if (.not.associated(map%p_desc_X)) return
      if (.not.associated(map%p_desc_Y)) return
      this = &
           & psb_is_ok_desc(map%p_desc_X).and.psb_is_ok_desc(map%p_desc_Y)    
    case(psb_map_gen_linear_)    
      this = &
           & psb_is_ok_desc(map%desc_X).and.psb_is_ok_desc(map%desc_Y)    
    end select

  end function psb_is_ok_dlinmap

  function psb_dlinmap_sizeof(map) result(val)
    use psb_descriptor_type
    use psb_mat_mod, only : psb_sizeof
    implicit none 
    type(psb_dlinmap_type), intent(in) :: map
    integer(psb_long_int_k_) :: val

    val = 0
    if (allocated(map%itd_data))   &
         & val = val + psb_sizeof_int*size(map%itd_data)
    if (allocated(map%iaggr))   &
         & val = val + psb_sizeof_int*size(map%iaggr)
    if (allocated(map%naggr))   &
         & val = val + psb_sizeof_int*size(map%naggr)
    val = val + psb_sizeof(map%desc_X)
    val = val + psb_sizeof(map%desc_Y)
    val = val + psb_sizeof(map%map_X2Y)
    val = val + psb_sizeof(map%map_Y2X)

  end function psb_dlinmap_sizeof

  subroutine psb_d_linmap_sub(out_map,map_kind,desc_X, desc_Y,&
       & map_X2Y, map_Y2X,iaggr,naggr)
    use psb_linmap_type_mod
    implicit none 
    type(psb_dlinmap_type), intent(out) :: out_map    
    type(psb_desc_type), target       :: desc_X, desc_Y
    type(psb_dspmat_type), intent(in) :: map_X2Y, map_Y2X
    integer, intent(in)               :: map_kind
    integer, intent(in), optional     :: iaggr(:), naggr(:)
    out_map = psb_linmap(map_kind,desc_X,desc_Y,map_X2Y,map_Y2X,iaggr,naggr)
  end subroutine psb_d_linmap_sub

  subroutine  psb_dlinmap_transfer(mapin,mapout,info)
    use psb_realloc_mod
    use psb_descriptor_type
    use psb_mat_mod, only : psb_move_alloc
    implicit none 
    type(psb_dlinmap_type) :: mapin,mapout
    integer, intent(out)      :: info 
    
    call psb_move_alloc(mapin%itd_data,mapout%itd_data,info)
    call psb_move_alloc(mapin%iaggr,mapout%iaggr,info)
    call psb_move_alloc(mapin%naggr,mapout%naggr,info)
    mapout%p_desc_X => mapin%p_desc_X 
    mapin%p_desc_X  => null()
    mapout%p_desc_Y => mapin%p_desc_Y
    mapin%p_desc_Y  => null()
    call psb_move_alloc(mapin%desc_X,mapout%desc_X,info)
    call psb_move_alloc(mapin%desc_Y,mapout%desc_Y,info)
    call psb_move_alloc(mapin%map_X2Y,mapout%map_X2Y,info)
    call psb_move_alloc(mapin%map_Y2X,mapout%map_Y2X,info)

  end subroutine psb_dlinmap_transfer
  
end module psb_d_linmap_mod
