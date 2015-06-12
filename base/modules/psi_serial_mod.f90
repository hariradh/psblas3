!!$ 
!!$              Parallel Sparse BLAS  version 3.4
!!$    (C) Copyright 2006, 2010, 2015
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
module psi_serial_mod
  use psb_const_mod, only : psb_ipk_, psb_spk_, psb_dpk_
  interface psb_gelp
    ! 2-D version
    module subroutine psb_sgelp(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      real(psb_spk_), intent(inout)      ::  x(:,:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)                :: trans
    end subroutine psb_sgelp
    ! 1-D version
    module subroutine psb_sgelpv(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      real(psb_spk_), intent(inout)    ::  x(:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)              :: trans
    end subroutine psb_sgelpv
    module subroutine psb_dgelp(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      real(psb_dpk_), intent(inout)      ::  x(:,:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)                :: trans
    end subroutine psb_dgelp
    ! 1-D version
    module subroutine psb_dgelpv(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      real(psb_dpk_), intent(inout)    ::  x(:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)              :: trans
    end subroutine psb_dgelpv
    ! 2-D version
    module subroutine psb_cgelp(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      complex(psb_spk_), intent(inout)      ::  x(:,:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)                :: trans
    end subroutine psb_cgelp
    ! 1-D version
    module subroutine psb_cgelpv(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      complex(psb_spk_), intent(inout)    ::  x(:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)              :: trans
    end subroutine psb_cgelpv
    ! 2-D version
    module subroutine psb_zgelp(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      complex(psb_dpk_), intent(inout)      ::  x(:,:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)                :: trans
    end subroutine psb_zgelp
    ! 1-D version
    module subroutine psb_zgelpv(trans,iperm,x,info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      complex(psb_dpk_), intent(inout)    ::  x(:)
      integer(psb_ipk_), intent(in)                  ::  iperm(:)
      integer(psb_ipk_), intent(out)                 ::  info
      character, intent(in)              :: trans
    end subroutine psb_zgelpv
  end interface



  interface psi_gth
    module subroutine psi_igthv(n,idx,alpha,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_ 
      integer(psb_ipk_) :: n, idx(:)
      integer(psb_ipk_) :: x(:), y(:), alpha, beta
    end subroutine psi_igthv
    module subroutine psi_sgthv(n,idx,alpha,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_spk_) :: x(:), y(:), alpha, beta
    end subroutine psi_sgthv
    module subroutine psi_dgthv(n,idx,alpha,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_dpk_) :: x(:), y(:), alpha, beta
    end subroutine psi_dgthv
    module subroutine psi_cgthv(n,idx,alpha,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_spk_) :: x(:), y(:),alpha,beta
    end subroutine psi_cgthv
    module subroutine psi_zgthv(n,idx,alpha,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_dpk_) :: x(:), y(:),alpha,beta
    end subroutine psi_zgthv
    module subroutine psi_sgthzmv(n,k,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      real(psb_spk_) :: x(:,:), y(:)
    end subroutine psi_sgthzmv
    module subroutine psi_dgthzmv(n,k,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      real(psb_dpk_) :: x(:,:), y(:)
    end subroutine psi_dgthzmv
    module subroutine psi_igthzmv(n,k,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      integer(psb_ipk_) :: x(:,:), y(:)
    end subroutine psi_igthzmv
    module subroutine psi_cgthzmv(n,k,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      complex(psb_spk_) :: x(:,:), y(:)
    end subroutine psi_cgthzmv
    module subroutine psi_zgthzmv(n,k,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      complex(psb_dpk_) :: x(:,:), y(:)
    end subroutine psi_zgthzmv
    module subroutine psi_sgthzv(n,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_spk_) :: x(:), y(:)
    end subroutine psi_sgthzv
    module subroutine psi_dgthzv(n,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_dpk_) :: x(:), y(:)
    end subroutine psi_dgthzv
    module subroutine psi_igthzv(n,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      integer(psb_ipk_) :: x(:), y(:)
    end subroutine psi_igthzv
    module subroutine psi_cgthzv(n,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_spk_) :: x(:), y(:)
    end subroutine psi_cgthzv
    module subroutine psi_zgthzv(n,idx,x,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_dpk_) :: x(:), y(:)
    end subroutine psi_zgthzv
  end interface


  interface psi_sct
    module subroutine psi_ssctmv(n,k,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      real(psb_spk_) :: beta, x(:), y(:,:)
    end subroutine psi_ssctmv
    module subroutine psi_ssctv(n,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_spk_) :: beta, x(:), y(:)
    end subroutine psi_ssctv
    module subroutine psi_dsctmv(n,k,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      real(psb_dpk_) :: beta, x(:), y(:,:)
    end subroutine psi_dsctmv
    module subroutine psi_dsctv(n,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      real(psb_dpk_) :: beta, x(:), y(:)
    end subroutine psi_dsctv
    module subroutine psi_isctmv(n,k,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      integer(psb_ipk_) :: beta, x(:), y(:,:)
    end subroutine psi_isctmv
    module subroutine psi_isctv(n,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      integer(psb_ipk_) :: beta, x(:), y(:)
    end subroutine psi_isctv
    module subroutine psi_csctmv(n,k,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      complex(psb_spk_) :: beta, x(:), y(:,:)
    end subroutine psi_csctmv
    module subroutine psi_csctv(n,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_spk_) :: beta, x(:), y(:)
    end subroutine psi_csctv
    module subroutine psi_zsctmv(n,k,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, k, idx(:)
      complex(psb_dpk_) :: beta, x(:), y(:,:)
    end subroutine psi_zsctmv
    module subroutine psi_zsctv(n,idx,x,beta,y)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_) :: n, idx(:)
      complex(psb_dpk_) :: beta, x(:), y(:)
    end subroutine psi_zsctv
  end interface


  interface psb_geaxpby
    module subroutine psi_iaxpbyv(m,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m
      integer(psb_ipk_), intent (in)       ::  x(:)
      integer(psb_ipk_), intent (inout)    ::  y(:)
      integer(psb_ipk_), intent (in)       :: alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_iaxpbyv
    module subroutine psi_iaxpby(m,n,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m, n
      integer(psb_ipk_), intent (in)       ::  x(:,:)
      integer(psb_ipk_), intent (inout)    ::  y(:,:)
      integer(psb_ipk_), intent (in)       ::  alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_iaxpby
    module subroutine psi_saxpbyv(m,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m
      real(psb_spk_), intent (in)       ::  x(:)
      real(psb_spk_), intent (inout)    ::  y(:)
      real(psb_spk_), intent (in)       :: alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_saxpbyv
    module subroutine psi_saxpby(m,n,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m, n
      real(psb_spk_), intent (in)       ::  x(:,:)
      real(psb_spk_), intent (inout)    ::  y(:,:)
      real(psb_spk_), intent (in)       ::  alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_saxpby
    module subroutine psi_daxpbyv(m,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m
      real(psb_dpk_), intent (in)       ::  x(:)
      real(psb_dpk_), intent (inout)    ::  y(:)
      real(psb_dpk_), intent (in)       :: alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_daxpbyv
    module subroutine psi_daxpby(m,n,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m, n
      real(psb_dpk_), intent (in)       ::  x(:,:)
      real(psb_dpk_), intent (inout)    ::  y(:,:)
      real(psb_dpk_), intent (in)       ::  alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_daxpby
    module subroutine psi_caxpbyv(m,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m
      complex(psb_spk_), intent (in)    ::  x(:)
      complex(psb_spk_), intent (inout) ::  y(:)
      complex(psb_spk_), intent (in)    :: alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_caxpbyv
    module subroutine psi_caxpby(m,n,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      implicit none 
      integer(psb_ipk_), intent(in)               :: m, n
      complex(psb_spk_), intent (in)    ::  x(:,:)
      complex(psb_spk_), intent (inout) ::  y(:,:)
      complex(psb_spk_), intent (in)    ::  alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_caxpby
    module subroutine psi_zaxpbyv(m,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_
      integer(psb_ipk_), intent(in)               :: m
      complex(psb_dpk_), intent (in)    ::  x(:)
      complex(psb_dpk_), intent (inout) ::  y(:)
      complex(psb_dpk_), intent (in)    :: alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_zaxpbyv
    module subroutine psi_zaxpby(m,n,alpha, x, beta, y, info)
      import :: psb_ipk_, psb_spk_, psb_dpk_ 
      integer(psb_ipk_), intent(in)               :: m, n
      complex(psb_dpk_), intent (in)    ::  x(:,:)
      complex(psb_dpk_), intent (inout) ::  y(:,:)
      complex(psb_dpk_), intent (in)    ::  alpha, beta
      integer(psb_ipk_), intent(out)              :: info
    end subroutine psi_zaxpby
  end interface

end module psi_serial_mod
