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

Module psb_c_tools_mod

  interface  psb_geall
    subroutine psb_calloc(x, desc_a, info, n, lb)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      implicit none
      complex(psb_spk_), allocatable, intent(out)    :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)            :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_calloc
    subroutine psb_callocv(x, desc_a,info,n)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      complex(psb_spk_), allocatable, intent(out)    :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)            :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_callocv
  end interface


  interface psb_geasb
    subroutine psb_casb(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_spk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_casb
    subroutine psb_casbv(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_spk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_casbv
  end interface

  interface psb_sphalo
    Subroutine psb_csphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      Type(psb_cspmat_type),Intent(in)    :: a
      Type(psb_cspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in)      :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_csphalo
  end interface

  interface psb_gefree
    subroutine psb_cfree(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      complex(psb_spk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)            :: info
    end subroutine psb_cfree
    subroutine psb_cfreev(x, desc_a, info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      complex(psb_spk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer, intent(out)            :: info
    end subroutine psb_cfreev
  end interface


  interface psb_geins
    subroutine psb_cinsi(m,irw,val, x, desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_spk_),intent(inout)      ::  x(:,:)
      integer, intent(in)              ::  irw(:)
      complex(psb_spk_), intent(in)  ::  val(:,:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_cinsi
    subroutine psb_cinsvi(m, irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_spk_),intent(inout)      ::  x(:)
      integer, intent(in)              ::  irw(:)
      complex(psb_spk_), intent(in)  ::  val(:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_cinsvi
  end interface


  interface psb_cdbldext
    Subroutine psb_ccdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      integer, intent(in)                     :: novr
      Type(psb_cspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_ccdbldext
  end interface

  interface psb_spall
    subroutine psb_cspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(out)               :: info
      integer, optional, intent(in)      :: nnz
    end subroutine psb_cspalloc
  end interface

  interface psb_spasb
    subroutine psb_cspasb(a,desc_a, info, afmt, upd, dupl,mold)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type, psb_c_base_sparse_mat
      type(psb_cspmat_type), intent (inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
      class(psb_c_base_sparse_mat), intent(in), optional :: mold
    end subroutine psb_cspasb
  end interface

  interface psb_spfree
    subroutine psb_cspfree(a, desc_a,info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_cspmat_type), intent(inout)      ::a
      integer, intent(out)        :: info
    end subroutine psb_cspfree
  end interface


  interface psb_spins
    subroutine psb_cspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_spk_), intent(in)      :: val(:)
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
    end subroutine psb_cspins
    subroutine psb_cspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_spk_), intent(in)        :: val(:)
      integer, intent(out)                 :: info
    end subroutine psb_cspins_2desc
  end interface


  interface psb_sprn
    subroutine psb_csprn(a, desc_a,info,clear)
      use psb_descriptor_type, only : psb_desc_type, psb_spk_
      use psb_mat_mod, only : psb_cspmat_type
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_csprn
  end interface

!!$
!!$  interface psb_linmap_init
!!$    module procedure psb_clinmap_init
!!$  end interface
!!$
!!$  interface psb_linmap_ins
!!$    module procedure psb_clinmap_ins
!!$  end interface
!!$
!!$  interface psb_linmap_asb
!!$    module procedure psb_clinmap_asb
!!$  end interface
!!$
!!$contains
!!$  subroutine psb_clinmap_init(a_map,cd_xt,descin,descout)
!!$    use psb_base_tools_mod
!!$    use psb_c_mat_mod
!!$    use psb_descriptor_type
!!$    use psb_serial_mod
!!$    use psb_penv_mod
!!$    use psb_error_mod
!!$    implicit none 
!!$    type(psb_cspmat_type), intent(out) :: a_map
!!$    type(psb_desc_type), intent(out)   :: cd_xt
!!$    type(psb_desc_type), intent(in)    :: descin, descout 
!!$
!!$    integer :: nrow_in, nrow_out, ncol_in, info, ictxt
!!$
!!$    ictxt = descin%get_context()
!!$
!!$    call psb_cdcpy(descin,cd_xt,info)
!!$    if (info == psb_success_) call psb_cd_reinit(cd_xt,info)
!!$    if (info /= psb_success_) then 
!!$      write(psb_err_unit,*) 'Error on reinitialising the extension map'
!!$      call psb_error(ictxt)
!!$      call psb_abort(ictxt)
!!$      stop
!!$    end if
!!$
!!$    nrow_in  = cd_xt%get_local_rows()
!!$    ncol_in  = cd_xt%get_local_cols()
!!$    nrow_out = descout%get_local_rows()
!!$
!!$    call a_map%csall(nrow_out,ncol_in,info)
!!$
!!$  end subroutine psb_clinmap_init
!!$
!!$  subroutine psb_clinmap_ins(nz,ir,ic,val,a_map,cd_xt,descin,descout)
!!$    use psb_base_tools_mod
!!$    use psb_c_mat_mod
!!$    use psb_descriptor_type
!!$    implicit none 
!!$    integer, intent(in)                  :: nz
!!$    integer, intent(in)                  :: ir(:),ic(:)
!!$    complex(psb_spk_), intent(in)      :: val(:)
!!$    type(psb_cspmat_type), intent(inout) :: a_map
!!$    type(psb_desc_type), intent(inout)   :: cd_xt
!!$    type(psb_desc_type), intent(in)      :: descin, descout 
!!$    integer :: info
!!$
!!$    call psb_spins(nz,ir,ic,val,a_map,descout,cd_xt,info)
!!$
!!$  end subroutine psb_clinmap_ins
!!$
!!$  subroutine psb_clinmap_asb(a_map,cd_xt,descin,descout,afmt)
!!$    use psb_base_tools_mod
!!$    use psb_c_mat_mod
!!$    use psb_descriptor_type
!!$    use psb_serial_mod
!!$    implicit none 
!!$    type(psb_cspmat_type), intent(inout)   :: a_map
!!$    type(psb_desc_type), intent(inout)     :: cd_xt
!!$    type(psb_desc_type), intent(in)        :: descin, descout 
!!$    character(len=*), optional, intent(in) :: afmt
!!$
!!$    integer :: nrow_in, nrow_out, ncol_in, info, ictxt
!!$
!!$    ictxt = descin%get_context()
!!$
!!$    call psb_cdasb(cd_xt,info)
!!$    call a_map%set_ncols(cd_xt%get_local_cols())
!!$    call a_map%cscnv(info,type=afmt)
!!$
!!$  end subroutine psb_clinmap_asb


end module psb_c_tools_mod
