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
Module psb_z_tools_mod
  use psb_descriptor_type, only : psb_desc_type, psb_dpk_, psb_ipk_
  use psb_z_vect_mod, only : psb_z_base_vect_type, psb_z_vect_type
  use psb_z_mat_mod, only : psb_zspmat_type, psb_z_base_sparse_mat

  interface  psb_geall
    subroutine psb_zalloc(x, desc_a, info, n, lb)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      implicit none
      complex(psb_dpk_), allocatable, intent(out)    :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_), intent(out)            :: info
      integer(psb_ipk_), optional, intent(in)   :: n, lb
    end subroutine psb_zalloc
    subroutine psb_zallocv(x, desc_a,info,n)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      complex(psb_dpk_), allocatable, intent(out)    :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_), intent(out)            :: info
      integer(psb_ipk_), optional, intent(in)   :: n
    end subroutine psb_zallocv
    subroutine psb_zalloc_vect(x, desc_a,info,n)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_z_vect_type), intent(out)  :: x
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_),intent(out)             :: info
      integer(psb_ipk_), optional, intent(in)   :: n
    end subroutine psb_zalloc_vect
    subroutine psb_zalloc_vect_r2(x, desc_a,info,n,lb)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_z_vect_type), allocatable, intent(out)  :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_),intent(out)             :: info
      integer(psb_ipk_), optional, intent(in)   :: n, lb
    end subroutine psb_zalloc_vect_r2
  end interface


  interface psb_geasb
    subroutine psb_zasb(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_dpk_), allocatable, intent(inout)       ::  x(:,:)
      integer(psb_ipk_), intent(out)            ::  info
    end subroutine psb_zasb
    subroutine psb_zasbv(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_dpk_), allocatable, intent(inout)   ::  x(:)
      integer(psb_ipk_), intent(out)        ::  info
    end subroutine psb_zasbv
    subroutine psb_zasb_vect(x, desc_a, info,mold, scratch)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)      ::  desc_a
      type(psb_z_vect_type), intent(inout) :: x
      integer(psb_ipk_), intent(out)                 ::  info
      class(psb_z_base_vect_type), intent(in), optional :: mold
      logical, intent(in), optional        :: scratch
    end subroutine psb_zasb_vect
    subroutine psb_zasb_vect_r2(x, desc_a, info,mold, scratch)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)      ::  desc_a
      type(psb_z_vect_type), intent(inout) :: x(:)
      integer(psb_ipk_), intent(out)                 ::  info
      class(psb_z_base_vect_type), intent(in), optional :: mold
      logical, intent(in), optional        :: scratch
    end subroutine psb_zasb_vect_r2
  end interface

  interface psb_sphalo
    Subroutine psb_zsphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      Type(psb_zspmat_type),Intent(in)       :: a
      Type(psb_zspmat_type),Intent(inout)    :: blk
      Type(psb_desc_type),Intent(in), target :: desc_a
      integer(psb_ipk_), intent(out)                   :: info
      logical, optional, intent(in)          :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional             :: outfmt 
      integer(psb_ipk_), intent(in), optional          :: data
    end Subroutine psb_zsphalo
  end interface

  interface psb_gefree
    subroutine psb_zfree(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      complex(psb_dpk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_zfree
    subroutine psb_zfreev(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      complex(psb_dpk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_zfreev
    subroutine psb_zfree_vect(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)  ::  desc_a
      type(psb_z_vect_type), intent(inout) :: x
      integer(psb_ipk_), intent(out)             ::  info
    end subroutine psb_zfree_vect
    subroutine psb_zfree_vect_r2(x, desc_a, info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)  ::  desc_a
      type(psb_z_vect_type), allocatable, intent(inout) :: x(:)
      integer(psb_ipk_), intent(out)             ::  info
    end subroutine psb_zfree_vect_r2
  end interface


  interface psb_geins
    subroutine psb_zinsi(m,irw,val, x, desc_a,info,dupl,local)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      integer(psb_ipk_), intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_dpk_),intent(inout)      ::  x(:,:)
      integer(psb_ipk_), intent(in)              ::  irw(:)
      complex(psb_dpk_), intent(in)  ::  val(:,:)
      integer(psb_ipk_), intent(out)             ::  info
      integer(psb_ipk_), optional, intent(in)    ::  dupl
      logical, intent(in), optional        :: local
    end subroutine psb_zinsi
    subroutine psb_zinsvi(m, irw,val, x,desc_a,info,dupl,local)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      integer(psb_ipk_), intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_dpk_),intent(inout)      ::  x(:)
      integer(psb_ipk_), intent(in)              ::  irw(:)
      complex(psb_dpk_), intent(in)  ::  val(:)
      integer(psb_ipk_), intent(out)             ::  info
      integer(psb_ipk_), optional, intent(in)    ::  dupl
      logical, intent(in), optional        :: local
    end subroutine psb_zinsvi
    subroutine psb_zins_vect(m,irw,val,x,desc_a,info,dupl,local)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      integer(psb_ipk_), intent(in)              :: m
      type(psb_desc_type), intent(in)  :: desc_a
      type(psb_z_vect_type), intent(inout) :: x
      integer(psb_ipk_), intent(in)              :: irw(:)
      complex(psb_dpk_), intent(in)    :: val(:)
      integer(psb_ipk_), intent(out)             :: info
      integer(psb_ipk_), optional, intent(in)    :: dupl
      logical, intent(in), optional        :: local
    end subroutine psb_zins_vect
    subroutine psb_zins_vect_r2(m,irw,val,x,desc_a,info,dupl,local)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      integer(psb_ipk_), intent(in)              :: m
      type(psb_desc_type), intent(in)  :: desc_a
      type(psb_z_vect_type), intent(inout) :: x(:)
      integer(psb_ipk_), intent(in)              :: irw(:)
      complex(psb_dpk_), intent(in)    :: val(:,:)
      integer(psb_ipk_), intent(out)             :: info
      integer(psb_ipk_), optional, intent(in)    :: dupl
      logical, intent(in), optional        :: local
    end subroutine psb_zins_vect_r2
  end interface

  interface psb_cdbldext
    Subroutine psb_zcdbldext(a,desc_a,novr,desc_ov,info,extype)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      integer(psb_ipk_), intent(in)                     :: novr
      Type(psb_zspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer(psb_ipk_), intent(out)                    :: info
      integer(psb_ipk_), intent(in),optional            :: extype
    end Subroutine psb_zcdbldext
  end interface

  interface psb_spall
    subroutine psb_zspalloc(a, desc_a, info, nnz)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_zspmat_type), intent(inout) :: a
      integer(psb_ipk_), intent(out)               :: info
      integer(psb_ipk_), optional, intent(in)      :: nnz
    end subroutine psb_zspalloc
  end interface

  interface psb_spasb
    subroutine psb_zspasb(a,desc_a, info, afmt, upd, dupl,mold)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_zspmat_type), intent (inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer(psb_ipk_), intent(out)                    :: info
      integer(psb_ipk_),optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
      class(psb_z_base_sparse_mat), intent(in), optional :: mold
    end subroutine psb_zspasb
  end interface

  interface psb_spfree
    subroutine psb_zspfree(a, desc_a,info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_zspmat_type), intent(inout)       ::a
      integer(psb_ipk_), intent(out)        :: info
    end subroutine psb_zspfree
  end interface


  interface psb_spins
    subroutine psb_zspins(nz,ia,ja,val,a,desc_a,info,rebuild,local)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_zspmat_type), intent(inout) :: a
      integer(psb_ipk_), intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_dpk_), intent(in)      :: val(:)
      integer(psb_ipk_), intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
      logical, intent(in), optional        :: local
    end subroutine psb_zspins
    subroutine psb_zspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_zspmat_type), intent(inout) :: a
      integer(psb_ipk_), intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_dpk_), intent(in)        :: val(:)
      integer(psb_ipk_), intent(out)                 :: info
    end subroutine psb_zspins_2desc
  end interface


  interface psb_sprn
    subroutine psb_zsprn(a, desc_a,info,clear)
      import :: psb_desc_type, psb_dpk_, psb_ipk_, &
           & psb_z_base_vect_type, psb_z_vect_type, &
           & psb_zspmat_type, psb_z_base_sparse_mat
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_zspmat_type), intent(inout) :: a
      integer(psb_ipk_), intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_zsprn
  end interface

end module psb_z_tools_mod
