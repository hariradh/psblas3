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
Module psb_tools_mod
  use psb_const_mod
  use psb_spmat_type


  interface psb_cd_set_bld
    subroutine psb_cd_set_bld(desc,info)
      use psb_descriptor_type
      type(psb_desc_type), intent(inout) :: desc
      integer                            :: info
    end subroutine psb_cd_set_bld
  end interface

  interface psb_cd_set_ovl_bld
    subroutine psb_cd_set_ovl_bld(desc,info)
      use psb_descriptor_type
      type(psb_desc_type), intent(inout) :: desc
      integer                            :: info
    end subroutine psb_cd_set_ovl_bld
  end interface

  interface psb_cd_reinit
    Subroutine psb_cd_reinit(desc,info)
      use psb_descriptor_type
      Implicit None

      !     .. Array Arguments ..
      Type(psb_desc_type), Intent(inout) :: desc
      integer, intent(out)               :: info
    end Subroutine psb_cd_reinit
  end interface

  interface psb_cdcpy
    subroutine psb_cdcpy(desc_in, desc_out, info)
      use psb_descriptor_type

      implicit none
      !....parameters...

      type(psb_desc_type), intent(in)  :: desc_in
      type(psb_desc_type), intent(out) :: desc_out
      integer, intent(out)             :: info
    end subroutine psb_cdcpy
  end interface


  interface  psb_geall
    subroutine psb_salloc(x, desc_a, info, n, lb)
      use psb_descriptor_type
      implicit none
      real(psb_spk_), allocatable, intent(out) :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_salloc
    subroutine psb_sallocv(x, desc_a,info,n)
      use psb_descriptor_type
      real(psb_spk_), allocatable, intent(out)       :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_sallocv
    subroutine psb_dalloc(x, desc_a, info, n, lb)
      use psb_descriptor_type
      implicit none
      real(psb_dpk_), allocatable, intent(out) :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_dalloc
    subroutine psb_dallocv(x, desc_a,info,n)
      use psb_descriptor_type
      real(psb_dpk_), allocatable, intent(out)       :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer,intent(out)             :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_dallocv
    subroutine psb_ialloc(x, desc_a, info,n, lb)
      use psb_descriptor_type
      integer, allocatable, intent(out)                 :: x(:,:)
      type(psb_desc_type), intent(in)  :: desc_a
      integer, intent(out)             :: info
      integer, optional, intent(in)    :: n, lb
    end subroutine psb_ialloc
    subroutine psb_iallocv(x, desc_a,info,n)
      use psb_descriptor_type
      integer, allocatable, intent(out)                :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_iallocv
    subroutine psb_calloc(x, desc_a, info, n, lb)
      use psb_descriptor_type
      implicit none
      complex(psb_spk_), allocatable, intent(out)    :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_calloc
    subroutine psb_callocv(x, desc_a,info,n)
      use psb_descriptor_type
      complex(psb_spk_), allocatable, intent(out)    :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_callocv
    subroutine psb_zalloc(x, desc_a, info, n, lb)
      use psb_descriptor_type
      implicit none
      complex(psb_dpk_), allocatable, intent(out)    :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
      integer, optional, intent(in)   :: n, lb
    end subroutine psb_zalloc
    subroutine psb_zallocv(x, desc_a,info,n)
      use psb_descriptor_type
      complex(psb_dpk_), allocatable, intent(out)    :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
      integer, optional, intent(in)   :: n
    end subroutine psb_zallocv
  end interface


  interface psb_geasb
    subroutine psb_sasb(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_spk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_sasb
    subroutine psb_sasbv(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_spk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_sasbv
    subroutine psb_dasb(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_dpk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_dasb
    subroutine psb_dasbv(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      real(psb_dpk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_dasbv
    subroutine psb_iasb(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      integer, allocatable, intent(inout)                ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_iasb
    subroutine psb_iasbv(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      integer, allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_iasbv
    subroutine psb_casb(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_spk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_casb
    subroutine psb_casbv(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_spk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_casbv
    subroutine psb_zasb(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_dpk_), allocatable, intent(inout)       ::  x(:,:)
      integer, intent(out)            ::  info
    end subroutine psb_zasb
    subroutine psb_zasbv(x, desc_a, info)
      use psb_descriptor_type
      type(psb_desc_type), intent(in) ::  desc_a
      complex(psb_dpk_), allocatable, intent(inout)   ::  x(:)
      integer, intent(out)        ::  info
    end subroutine psb_zasbv
  end interface

  interface psb_sphalo
    Subroutine psb_ssphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type
      use psb_spmat_type
      Type(psb_sspmat_type),Intent(in)    :: a
      Type(psb_sspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in),target :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_ssphalo
    Subroutine psb_dsphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type
      use psb_spmat_type
      Type(psb_dspmat_type),Intent(in)    :: a
      Type(psb_dspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in),target :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_dsphalo
    Subroutine psb_csphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type
      use psb_spmat_type
      Type(psb_cspmat_type),Intent(in)    :: a
      Type(psb_cspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in)      :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_csphalo
    Subroutine psb_zsphalo(a,desc_a,blk,info,rowcnv,colcnv,&
         & rowscale,colscale,outfmt,data)
      use psb_descriptor_type
      use psb_spmat_type
      Type(psb_zspmat_type),Intent(in)    :: a
      Type(psb_zspmat_type),Intent(inout) :: blk
      Type(psb_desc_type),Intent(in)      :: desc_a
      integer, intent(out)                :: info
      logical, optional, intent(in)       :: rowcnv,colcnv,rowscale,colscale
      character(len=5), optional          :: outfmt 
      integer, intent(in), optional       :: data
    end Subroutine psb_zsphalo
  end interface


  interface psb_cdprt
    subroutine psb_cdprt(iout,desc_p,glob,short)
      use psb_const_mod
      use psb_descriptor_type
      implicit none 
      type(psb_desc_type), intent(in)    :: desc_p
      integer, intent(in)                :: iout
      logical, intent(in), optional      :: glob,short
    end subroutine psb_cdprt
  end interface


  interface psb_gefree
    subroutine psb_sfree(x, desc_a, info)
      use psb_descriptor_type
      real(psb_spk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_sfree
    subroutine psb_sfreev(x, desc_a, info)
      use psb_descriptor_type
      real(psb_spk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_sfreev
    subroutine psb_dfree(x, desc_a, info)
      use psb_descriptor_type
      real(psb_dpk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_dfree
    subroutine psb_dfreev(x, desc_a, info)
      use psb_descriptor_type
      real(psb_dpk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_dfreev
    subroutine psb_ifree(x, desc_a, info)
      use psb_descriptor_type
      integer,allocatable, intent(inout)                 :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_ifree
    subroutine psb_ifreev(x, desc_a, info)
      use psb_descriptor_type
      integer, allocatable, intent(inout)                :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_ifreev
    subroutine psb_cfree(x, desc_a, info)
      use psb_descriptor_type
      complex(psb_spk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_cfree
    subroutine psb_cfreev(x, desc_a, info)
      use psb_descriptor_type
      complex(psb_spk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_cfreev
    subroutine psb_zfree(x, desc_a, info)
      use psb_descriptor_type
      complex(psb_dpk_),allocatable, intent(inout)        :: x(:,:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_zfree
    subroutine psb_zfreev(x, desc_a, info)
      use psb_descriptor_type
      complex(psb_dpk_),allocatable, intent(inout)        :: x(:)
      type(psb_desc_type), intent(in) :: desc_a
      integer                         :: info
    end subroutine psb_zfreev
  end interface


  interface psb_geins
    subroutine psb_sinsi(m,irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_spk_),intent(inout)           ::  x(:,:)
      integer, intent(in)                ::  irw(:)
      real(psb_spk_), intent(in)       ::  val(:,:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_sinsi
    subroutine psb_sinsvi(m,irw,val,x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_spk_),intent(inout)     ::  x(:)
      integer, intent(in)                ::  irw(:)
      real(psb_spk_), intent(in)       ::  val(:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_sinsvi
    subroutine psb_dinsi(m,irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_dpk_),intent(inout)           ::  x(:,:)
      integer, intent(in)                ::  irw(:)
      real(psb_dpk_), intent(in)       ::  val(:,:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_dinsi
    subroutine psb_dinsvi(m,irw,val,x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)                ::  m
      type(psb_desc_type), intent(in)    ::  desc_a
      real(psb_dpk_),intent(inout)     ::  x(:)
      integer, intent(in)                ::  irw(:)
      real(psb_dpk_), intent(in)       ::  val(:)
      integer, intent(out)               ::  info
      integer, optional, intent(in)      ::  dupl
    end subroutine psb_dinsvi
    subroutine psb_iinsi(m,irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      integer,intent(inout)                  ::  x(:,:)
      integer, intent(in)              ::  irw(:)
      integer, intent(in)              ::  val(:,:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_iinsi
    subroutine psb_iinsvi(m, irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)             ::  m
      type(psb_desc_type), intent(in) ::  desc_a
      integer,intent(inout)                 ::  x(:)
      integer, intent(in)             ::  irw(:)
      integer, intent(in)             ::  val(:)
      integer, intent(out)            ::  info
      integer, optional, intent(in)   ::  dupl
    end subroutine psb_iinsvi
    subroutine psb_cinsi(m,irw,val, x, desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_spk_),intent(inout)      ::  x(:,:)
      integer, intent(in)              ::  irw(:)
      complex(psb_spk_), intent(in)  ::  val(:,:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_cinsi
    subroutine psb_cinsvi(m, irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_spk_),intent(inout)      ::  x(:)
      integer, intent(in)              ::  irw(:)
      complex(psb_spk_), intent(in)  ::  val(:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_cinsvi
    subroutine psb_zinsi(m,irw,val, x, desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_dpk_),intent(inout)      ::  x(:,:)
      integer, intent(in)              ::  irw(:)
      complex(psb_dpk_), intent(in)  ::  val(:,:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_zinsi
    subroutine psb_zinsvi(m, irw,val, x,desc_a,info,dupl)
      use psb_descriptor_type
      integer, intent(in)              ::  m
      type(psb_desc_type), intent(in)  ::  desc_a
      complex(psb_dpk_),intent(inout)      ::  x(:)
      integer, intent(in)              ::  irw(:)
      complex(psb_dpk_), intent(in)  ::  val(:)
      integer, intent(out)             ::  info
      integer, optional, intent(in)    ::  dupl
    end subroutine psb_zinsvi
  end interface


  interface psb_cdall
    module procedure psb_cdall
  end interface

  interface psb_cdasb
    module procedure psb_cdasb
  end interface

  interface psb_cdins
    subroutine psb_cdinsrc(nz,ia,ja,desc_a,info,ila,jla)
      use psb_descriptor_type
      type(psb_desc_type), intent(inout) :: desc_a
      integer, intent(in)                :: nz,ia(:),ja(:)
      integer, intent(out)               :: info
      integer, optional, intent(out)     :: ila(:), jla(:)
    end subroutine psb_cdinsrc
    subroutine psb_cdinsc(nz,ja,desc,info,jla,mask)
      use psb_descriptor_type
      type(psb_desc_type), intent(inout) :: desc
      integer, intent(in)                :: nz,ja(:)
      integer, intent(out)               :: info
      integer, optional, intent(out)     :: jla(:)
      logical, optional, target, intent(in) :: mask(:)
    end subroutine psb_cdinsc
  end interface


  interface psb_cdbldext
    Subroutine psb_scdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type
      Use psb_spmat_type
      integer, intent(in)                     :: novr
      Type(psb_sspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_scdbldext
    Subroutine psb_dcdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type
      Use psb_spmat_type
      integer, intent(in)                     :: novr
      Type(psb_dspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_dcdbldext
    Subroutine psb_ccdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type
      Use psb_spmat_type
      integer, intent(in)                     :: novr
      Type(psb_cspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_ccdbldext
    Subroutine psb_zcdbldext(a,desc_a,novr,desc_ov,info,extype)
      use psb_descriptor_type
      Use psb_spmat_type
      integer, intent(in)                     :: novr
      Type(psb_zspmat_type), Intent(in)       :: a
      Type(psb_desc_type), Intent(in), target :: desc_a
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      integer, intent(in),optional            :: extype
    end Subroutine psb_zcdbldext
    Subroutine psb_cd_lstext(desc_a,in_list,desc_ov,info, mask,extype)
      use psb_descriptor_type
      Implicit None
      Type(psb_desc_type), Intent(in), target :: desc_a
      integer, intent(in)                     :: in_list(:)
      Type(psb_desc_type), Intent(out)        :: desc_ov
      integer, intent(out)                    :: info
      logical, intent(in), optional, target   :: mask(:)
      integer, intent(in),optional            :: extype
    end Subroutine psb_cd_lstext
  end interface

  interface psb_cdren
    subroutine psb_cdren(trans,iperm,desc_a,info)
      use psb_descriptor_type
      type(psb_desc_type), intent(inout)    :: desc_a
      integer, intent(inout)                :: iperm(:)
      character, intent(in)                 :: trans
      integer, intent(out)                  :: info
    end subroutine psb_cdren
  end interface

  interface psb_spall
    subroutine psb_sspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout) :: desc_a
      type(psb_sspmat_type), intent(out) :: a
      integer, intent(out)               :: info
      integer, optional, intent(in)      :: nnz
    end subroutine psb_sspalloc
    subroutine psb_dspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type
      use psb_spmat_type
      use psb_d_mat_mod
      type(psb_desc_type), intent(inout) :: desc_a
      type(psb_d_sparse_mat), intent(out) :: a
      integer, intent(out)               :: info
      integer, optional, intent(in)      :: nnz
    end subroutine psb_dspalloc
    subroutine psb_cspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout) :: desc_a
      type(psb_cspmat_type), intent(out) :: a
      integer, intent(out)               :: info
      integer, optional, intent(in)      :: nnz
    end subroutine psb_cspalloc
    subroutine psb_zspalloc(a, desc_a, info, nnz)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout) :: desc_a
      type(psb_zspmat_type), intent(out) :: a
      integer, intent(out)               :: info
      integer, optional, intent(in)      :: nnz
    end subroutine psb_zspalloc
  end interface

  interface psb_spasb
    subroutine psb_sspasb(a,desc_a, info, afmt, upd, dupl)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_sspmat_type), intent (inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
    end subroutine psb_sspasb
    subroutine psb_dspasb(a,desc_a, info, afmt, upd, dupl,mold)
      use psb_descriptor_type
      use psb_spmat_type
      use psb_d_mat_mod
      type(psb_d_sparse_mat), intent (inout)  :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
      class(psb_d_base_sparse_mat), intent(in), optional :: mold
    end subroutine psb_dspasb
    subroutine psb_cspasb(a,desc_a, info, afmt, upd, dupl)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_cspmat_type), intent (inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
    end subroutine psb_cspasb
    subroutine psb_zspasb(a,desc_a, info, afmt, upd, dupl)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_zspmat_type), intent (inout)   :: a
      type(psb_desc_type), intent(in)         :: desc_a
      integer, intent(out)                    :: info
      integer,optional, intent(in)            :: dupl, upd
      character(len=*), optional, intent(in)  :: afmt
    end subroutine psb_zspasb
  end interface

!!$  interface psb_spfree
!!$    module procedure psb_ssp_free, psb_dsp_free, psb_zsp_free
!!$  end interface

  interface psb_spfree
    subroutine psb_sspfree(a, desc_a,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_sspmat_type), intent(inout)       ::a
      integer, intent(out)        :: info
    end subroutine psb_sspfree
    subroutine psb_dspfree(a, desc_a,info)
      use psb_descriptor_type
      use psb_spmat_type
      use psb_d_mat_mod
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_d_sparse_mat), intent(inout)       ::a
      integer, intent(out)        :: info
    end subroutine psb_dspfree
    subroutine psb_cspfree(a, desc_a,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_cspmat_type), intent(inout)      ::a
      integer, intent(out)        :: info
    end subroutine psb_cspfree
    subroutine psb_zspfree(a, desc_a,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in) :: desc_a
      type(psb_zspmat_type), intent(inout)       ::a
      integer, intent(out)        :: info
    end subroutine psb_zspfree
  end interface


  interface psb_spins
    subroutine psb_sspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      real(psb_spk_), intent(in)           :: val(:)
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
    end subroutine psb_sspins
    subroutine psb_sspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      real(psb_spk_), intent(in)           :: val(:)
      integer, intent(out)                 :: info
    end subroutine psb_sspins_2desc
    subroutine psb_dspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type
      use psb_spmat_type
      use psb_d_mat_mod
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_d_sparse_mat), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      real(psb_dpk_), intent(in)         :: val(:)
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
    end subroutine psb_dspins
    subroutine psb_dspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_dspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      real(psb_dpk_), intent(in)           :: val(:)
      integer, intent(out)                 :: info
    end subroutine psb_dspins_2desc
    subroutine psb_cspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_spk_), intent(in)      :: val(:)
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
    end subroutine psb_cspins
    subroutine psb_cspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_spk_), intent(in)        :: val(:)
      integer, intent(out)                 :: info
    end subroutine psb_cspins_2desc
    subroutine psb_zspins(nz,ia,ja,val,a,desc_a,info,rebuild)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(inout)   :: desc_a
      type(psb_zspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_dpk_), intent(in)      :: val(:)
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: rebuild
    end subroutine psb_zspins
    subroutine psb_zspins_2desc(nz,ia,ja,val,a,desc_ar,desc_ac,info)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_ar
      type(psb_desc_type), intent(inout)   :: desc_ac
      type(psb_zspmat_type), intent(inout) :: a
      integer, intent(in)                  :: nz,ia(:),ja(:)
      complex(psb_dpk_), intent(in)        :: val(:)
      integer, intent(out)                 :: info
    end subroutine psb_zspins_2desc
  end interface


  interface psb_sprn
    subroutine psb_ssprn(a, desc_a,info,clear)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_sspmat_type), intent(inout) :: a
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_ssprn
    subroutine psb_dsprn(a, desc_a,info,clear)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_dspmat_type), intent(inout) :: a
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_dsprn
    subroutine psb_csprn(a, desc_a,info,clear)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_cspmat_type), intent(inout) :: a
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_csprn
    subroutine psb_zsprn(a, desc_a,info,clear)
      use psb_descriptor_type
      use psb_spmat_type
      type(psb_desc_type), intent(in)      :: desc_a
      type(psb_zspmat_type), intent(inout) :: a
      integer, intent(out)                 :: info
      logical, intent(in), optional        :: clear
    end subroutine psb_zsprn
  end interface


  interface psb_glob_to_loc
    subroutine psb_glob_to_loc2(x,y,desc_a,info,iact,owned)
      use psb_descriptor_type
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(in)                 ::  x(:)  
      integer,intent(out)                ::  y(:)  
      integer, intent(out)               ::  info
      logical, intent(in),  optional     :: owned
      character, intent(in), optional    ::  iact
    end subroutine psb_glob_to_loc2
    subroutine psb_glob_to_loc(x,desc_a,info,iact,owned)
      use psb_descriptor_type
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(inout)              ::  x(:)  
      integer, intent(out)               ::  info
      logical, intent(in),  optional     :: owned
      character, intent(in), optional    ::  iact
    end subroutine psb_glob_to_loc
    subroutine psb_glob_to_loc2s(x,y,desc_a,info,iact,owned)
      use psb_descriptor_type
      implicit none 
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(in)                 ::  x
      integer,intent(out)                ::  y  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact
      logical, intent(in),  optional     :: owned

    end subroutine psb_glob_to_loc2s

    subroutine psb_glob_to_locs(x,desc_a,info,iact,owned)
      use psb_descriptor_type
      implicit none 
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(inout)              ::  x  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact
      logical, intent(in),  optional     :: owned
    end subroutine psb_glob_to_locs
  end interface

  interface psb_loc_to_glob
    subroutine psb_loc_to_glob2(x,y,desc_a,info,iact)
      use psb_descriptor_type
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(in)                 ::  x(:)  
      integer,intent(out)                ::  y(:)  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact
    end subroutine psb_loc_to_glob2
    subroutine psb_loc_to_glob(x,desc_a,info,iact)
      use psb_descriptor_type
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(inout)              ::  x(:)  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact
    end subroutine psb_loc_to_glob
    subroutine psb_loc_to_glob2s(x,y,desc_a,info,iact)
      use psb_descriptor_type
      implicit none 
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(in)                 ::  x
      integer,intent(out)                ::  y  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact

    end subroutine psb_loc_to_glob2s
    subroutine psb_loc_to_globs(x,desc_a,info,iact)
      use psb_descriptor_type
      type(psb_desc_type), intent(in)    ::  desc_a
      integer,intent(inout)              ::  x  
      integer, intent(out)               ::  info
      character, intent(in), optional    ::  iact
    end subroutine psb_loc_to_globs

  end interface

  interface psb_get_boundary
    module procedure psb_get_boundary
  end interface

  interface psb_get_overlap
    subroutine psb_get_ovrlap(ovrel,desc,info)
      use psb_descriptor_type
      implicit none 
      integer, allocatable, intent(out) :: ovrel(:)
      type(psb_desc_type), intent(in) :: desc
      integer, intent(out)            :: info
    end subroutine psb_get_ovrlap
  end interface

  interface psb_icdasb
    subroutine psb_icdasb(desc,info,ext_hv)
      use psb_descriptor_type
      Type(psb_desc_type), intent(inout) :: desc
      integer, intent(out)               :: info
      logical, intent(in),optional       :: ext_hv
    end subroutine psb_icdasb
  end interface


  interface psb_linmap_init
    module procedure psb_dlinmap_init, psb_zlinmap_init
  end interface

  interface psb_linmap_ins
    module procedure psb_dlinmap_ins, psb_zlinmap_ins
  end interface

  interface psb_linmap_asb
    module procedure psb_dlinmap_asb, psb_zlinmap_asb
  end interface

  interface psb_is_owned
    module procedure psb_is_owned
  end interface

  interface psb_is_local
    module procedure psb_is_local
  end interface

  interface psb_owned_index
    module procedure psb_owned_index, psb_owned_index_v
  end interface

  interface psb_local_index
    module procedure psb_local_index, psb_local_index_v
  end interface

contains

  function psb_is_owned(idx,desc)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx
    type(psb_desc_type), intent(in) :: desc
    logical :: psb_is_owned
    logical :: res
    integer :: info

    call psb_owned_index(res,idx,desc,info)
    if (info /= 0) res=.false.
    psb_is_owned = res
  end function psb_is_owned

  function psb_is_local(idx,desc)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx
    type(psb_desc_type), intent(in) :: desc
    logical :: psb_is_local
    logical :: res
    integer :: info

    call psb_local_index(res,idx,desc,info)
    if (info /= 0) res=.false.
    psb_is_local = res
  end function psb_is_local

  subroutine psb_owned_index(res,idx,desc,info)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx
    type(psb_desc_type), intent(in) :: desc
    logical, intent(out) :: res
    integer, intent(out) :: info

    integer :: lx

    call psb_glob_to_loc(idx,lx,desc,info,iact='I',owned=.true.)

    res = (lx>0)
  end subroutine psb_owned_index

  subroutine psb_owned_index_v(res,idx,desc,info)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx(:)
    type(psb_desc_type), intent(in) :: desc
    logical, intent(out) :: res(:)
    integer, intent(out) :: info
    integer, allocatable  :: lx(:)

    allocate(lx(size(idx)),stat=info)
    res=.false.
    if (info /= 0) return
    call psb_glob_to_loc(idx,lx,desc,info,iact='I',owned=.true.)

    res = (lx>0)
  end subroutine psb_owned_index_v

  subroutine psb_local_index(res,idx,desc,info)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx
    type(psb_desc_type), intent(in) :: desc
    logical, intent(out) :: res
    integer, intent(out) :: info

    integer :: lx

    call psb_glob_to_loc(idx,lx,desc,info,iact='I',owned=.false.)

    res = (lx>0)
  end subroutine psb_local_index

  subroutine psb_local_index_v(res,idx,desc,info)
    use psb_descriptor_type
    implicit none 
    integer, intent(in) :: idx(:)
    type(psb_desc_type), intent(in) :: desc
    logical, intent(out) :: res(:)
    integer, intent(out) :: info    
    integer, allocatable  :: lx(:)

    allocate(lx(size(idx)),stat=info)
    res=.false.
    if (info /= 0) return
    call psb_glob_to_loc(idx,lx,desc,info,iact='I',owned=.false.)

    res = (lx>0)
  end subroutine psb_local_index_v

  subroutine psb_get_boundary(bndel,desc,info)
    use psb_descriptor_type
    use psi_mod
    implicit none 
    integer, allocatable, intent(out) :: bndel(:)
    type(psb_desc_type), intent(in) :: desc
    integer, intent(out)            :: info

    call psi_crea_bnd_elem(bndel,desc,info)

  end subroutine psb_get_boundary

  subroutine psb_cdall(ictxt, desc, info,mg,ng,parts,vg,vl,flag,nl,repl, globalcheck)
    use psb_descriptor_type
    use psb_serial_mod
    use psb_const_mod
    use psb_error_mod
    use psb_penv_mod
    implicit None
    include 'parts.fh'
    Integer, intent(in)               :: mg,ng,ictxt, vg(:), vl(:),nl
    integer, intent(in)               :: flag
    logical, intent(in)               :: repl, globalcheck
    integer, intent(out)              :: info
    type(psb_desc_type), intent(out)  :: desc

    optional :: mg,ng,parts,vg,vl,flag,nl,repl, globalcheck

    interface 
      subroutine psb_cdals(m, n, parts, ictxt, desc, info)
        use psb_descriptor_type
        include 'parts.fh'
        Integer, intent(in)                 :: m,n,ictxt
        Type(psb_desc_type), intent(out)    :: desc
        integer, intent(out)                :: info
      end subroutine psb_cdals
      subroutine psb_cdalv(v, ictxt, desc, info, flag)
        use psb_descriptor_type
        Integer, intent(in)               :: ictxt, v(:)
        integer, intent(in), optional     :: flag
        integer, intent(out)              :: info
        Type(psb_desc_type), intent(out)  :: desc
      end subroutine psb_cdalv
      subroutine psb_cd_inloc(v, ictxt, desc, info, globalcheck)
        use psb_descriptor_type
        implicit None
        Integer, intent(in)               :: ictxt, v(:)
        integer, intent(out)              :: info
        type(psb_desc_type), intent(out)  :: desc
        logical, intent(in), optional     :: globalcheck
      end subroutine psb_cd_inloc
      subroutine psb_cdrep(m, ictxt, desc,info)
        use psb_descriptor_type
        Integer, intent(in)               :: m,ictxt
        Type(psb_desc_type), intent(out)  :: desc
        integer, intent(out)              :: info
      end subroutine psb_cdrep
    end interface
    character(len=20)   :: name
    integer :: err_act, n_, flag_, i, me, np, nlp
    integer, allocatable :: itmpsz(:) 



    if (psb_get_errstatus() /= 0) return 
    info=0
    name = 'psb_cdall'
    call psb_erractionsave(err_act)

    call psb_info(ictxt, me, np)

    if (count((/ present(vg),present(vl),&
         &  present(parts),present(nl), present(repl) /)) /= 1) then 
      info=581
      call psb_errpush(info,name,a_err=" vg, vl, parts, nl, repl")
      goto 999 
    endif

    desc%base_desc => null() 

    if (present(parts)) then 
      if (.not.present(mg)) then 
        info=581
        call psb_errpush(info,name)
        goto 999 
      end if
      if (present(ng)) then 
        n_ = ng
      else
        n_ = mg 
      endif
      call  psb_cdals(mg, n_, parts, ictxt, desc, info)

    else if (present(repl)) then 
      if (.not.present(mg)) then 
        info=581
        call psb_errpush(info,name)
        goto 999 
      end if
      if (.not.repl) then 
        info=581
        call psb_errpush(info,name)
        goto 999 
      end if
      call  psb_cdrep(mg, ictxt, desc, info)

    else if (present(vg)) then 
      if (present(flag)) then 
        flag_=flag
      else
        flag_=0
      endif
      call psb_cdalv(vg, ictxt, desc, info, flag=flag_)

    else if (present(vl)) then 
      call psb_cd_inloc(vl,ictxt,desc,info, globalcheck=globalcheck)

    else if (present(nl)) then 
      allocate(itmpsz(0:np-1),stat=info)
      if (info /= 0) then 
        info = 4000 
        call psb_errpush(info,name)
        goto 999
      endif

      itmpsz = 0
      itmpsz(me) = nl
      call psb_sum(ictxt,itmpsz)
      nlp=0 
      do i=0, me-1
        nlp = nlp + itmpsz(i)
      end do
      call psb_cd_inloc((/(i,i=nlp+1,nlp+nl)/),ictxt,desc,info,globalcheck=.false.)

    endif

    if (info /= 0) goto 999

    call psb_erractionrestore(err_act)
    return

999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error(ictxt)
      return
    end if
    return


  end subroutine psb_cdall

  subroutine psb_cdasb(desc,info)
    use psb_descriptor_type

    Type(psb_desc_type), intent(inout) :: desc
    integer, intent(out)               :: info

    call psb_icdasb(desc,info,ext_hv=.false.)
  end subroutine psb_cdasb


  subroutine psb_dlinmap_init(a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    type(psb_dspmat_type), intent(out) :: a_map
    type(psb_desc_type), intent(out)   :: cd_xt
    type(psb_desc_type), intent(in)    :: descin, descout 

    integer :: nrow_in, nrow_out, ncol_in, info, ictxt

    ictxt = psb_cd_get_context(descin)
    call psb_cdcpy(descin,cd_xt,info)
    if (info ==0) call psb_cd_reinit(cd_xt,info)
    if (info /= 0) then 
      write(0,*) 'Error on reinitialising the extension map'
      call psb_error(ictxt)
      call psb_abort(ictxt)
      stop
    end if

    nrow_in  = psb_cd_get_local_rows(cd_xt)
    ncol_in  = psb_cd_get_local_cols(cd_xt)
    nrow_out = psb_cd_get_local_rows(descout)

    call psb_sp_all(nrow_out,ncol_in,a_map,info)

  end subroutine psb_dlinmap_init

  subroutine psb_dlinmap_ins(nz,ir,ic,val,a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    implicit none 
    integer, intent(in)                  :: nz
    integer, intent(in)                  :: ir(:),ic(:)
    real(kind(1.d0)), intent(in)         :: val(:)
    type(psb_dspmat_type), intent(inout) :: a_map
    type(psb_desc_type), intent(inout)   :: cd_xt
    type(psb_desc_type), intent(in)      :: descin, descout 
    integer :: info
    call psb_spins(nz,ir,ic,val,a_map,descout,cd_xt,info)

  end subroutine psb_dlinmap_ins

  subroutine psb_dlinmap_asb(a_map,cd_xt,descin,descout,afmt)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    implicit none 
    type(psb_dspmat_type), intent(inout)   :: a_map
    type(psb_desc_type), intent(inout)     :: cd_xt
    type(psb_desc_type), intent(in)        :: descin, descout 
    character(len=*), optional, intent(in) :: afmt


    integer :: nrow_in, nrow_out, ncol_in, info, ictxt

    ictxt = psb_cd_get_context(descin)

    call psb_cdasb(cd_xt,info)
    a_map%k = psb_cd_get_local_cols(cd_xt)
    call psb_spcnv(a_map,info,afmt=afmt)

  end subroutine psb_dlinmap_asb

  subroutine psb_zlinmap_init(a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    type(psb_zspmat_type), intent(out) :: a_map
    type(psb_desc_type), intent(out)   :: cd_xt
    type(psb_desc_type), intent(in)    :: descin, descout 

    integer :: nrow_in, nrow_out, ncol_in, info, ictxt

    ictxt = psb_cd_get_context(descin)

    call psb_cdcpy(descin,cd_xt,info)
    if (info ==0) call psb_cd_reinit(cd_xt,info)
    if (info /= 0) then 
      write(0,*) 'Error on reinitialising the extension map'
      call psb_error(ictxt)
      call psb_abort(ictxt)
      stop
    end if

    nrow_in  = psb_cd_get_local_rows(cd_xt)
    ncol_in  = psb_cd_get_local_cols(cd_xt)
    nrow_out = psb_cd_get_local_rows(descout)

    call psb_sp_all(nrow_out,ncol_in,a_map,info)

  end subroutine psb_zlinmap_init

  subroutine psb_zlinmap_ins(nz,ir,ic,val,a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    implicit none 
    integer, intent(in)                  :: nz
    integer, intent(in)                  :: ir(:),ic(:)
    complex(kind(1.d0)), intent(in)      :: val(:)
    type(psb_zspmat_type), intent(inout) :: a_map
    type(psb_desc_type), intent(inout)   :: cd_xt
    type(psb_desc_type), intent(in)      :: descin, descout 
    integer :: info

    call psb_spins(nz,ir,ic,val,a_map,descout,cd_xt,info)

  end subroutine psb_zlinmap_ins

  subroutine psb_zlinmap_asb(a_map,cd_xt,descin,descout,afmt)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    implicit none 
    type(psb_zspmat_type), intent(inout)   :: a_map
    type(psb_desc_type), intent(inout)     :: cd_xt
    type(psb_desc_type), intent(in)        :: descin, descout 
    character(len=*), optional, intent(in) :: afmt

    integer :: nrow_in, nrow_out, ncol_in, info, ictxt

    ictxt = psb_cd_get_context(descin)

    call psb_cdasb(cd_xt,info)
    a_map%k = psb_cd_get_local_cols(cd_xt)
    call psb_spcnv(a_map,info,afmt=afmt)

  end subroutine psb_zlinmap_asb



end module psb_tools_mod
