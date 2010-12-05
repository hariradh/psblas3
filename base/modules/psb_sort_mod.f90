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
!  The merge-sort and quicksort routines are implemented in the
!  serial/aux directory
!  References:
!  D. Knuth
!  The Art of Computer Programming, vol. 3
!  Addison-Wesley
!  
!  Aho, Hopcroft, Ullman
!  Data Structures and Algorithms
!  Addison-Wesley
!
module psb_sort_mod
  use psb_const_mod

  ! 
  !  The up/down constant are defined in pairs having 
  !  opposite values. We make use of this fact in the heapsort routine.
  !
  integer, parameter :: psb_sort_up_      = 1, psb_sort_down_     = -1
  integer, parameter :: psb_lsort_up_     = 2, psb_lsort_down_    = -2
  integer, parameter :: psb_asort_up_     = 3, psb_asort_down_    = -3
  integer, parameter :: psb_alsort_up_    = 4, psb_alsort_down_   = -4
  integer, parameter :: psb_sort_ovw_idx_ = 0, psb_sort_keep_idx_ =  1
  integer, parameter :: psb_heap_resize   = 200

  type psb_int_heap
    integer              :: last, dir
    integer, allocatable :: keys(:)
  end type psb_int_heap
  type psb_int_idx_heap
    integer              :: last, dir
    integer, allocatable :: keys(:)
    integer, allocatable :: idxs(:)
  end type psb_int_idx_heap
  type psb_real_idx_heap
    integer                     :: last, dir
    real(psb_spk_), allocatable :: keys(:)
    integer, allocatable        :: idxs(:)
  end type psb_real_idx_heap
  type psb_double_idx_heap
    integer                     :: last, dir
    real(psb_dpk_), allocatable :: keys(:)
    integer, allocatable        :: idxs(:)
  end type psb_double_idx_heap
  type psb_scomplex_idx_heap
    integer                        :: last, dir
    complex(psb_spk_), allocatable :: keys(:)
    integer, allocatable           :: idxs(:)
  end type psb_scomplex_idx_heap
  type psb_dcomplex_idx_heap
    integer                        :: last, dir
    complex(psb_dpk_), allocatable :: keys(:)
    integer, allocatable           :: idxs(:)
  end type psb_dcomplex_idx_heap


  interface psb_iblsrch
    function  psb_iblsrch(key,n,v) result(ipos)
      integer ipos, key, n
      integer v(n)
    end function psb_iblsrch
  end interface

  interface psb_ibsrch
    function  psb_ibsrch(key,n,v) result(ipos)
      integer ipos, key, n
      integer v(n)
    end function psb_ibsrch
  end interface

  interface psb_issrch
    function psb_issrch(key,n,v) result(ipos)
      implicit none
      integer ipos, key, n
      integer v(n)
    end function psb_issrch
  end interface

  interface psb_isaperm
    logical function psb_isaperm(n,eip)               
      integer, intent(in) :: n                                                      
      integer, intent(in) :: eip(n)
      integer, allocatable :: ip(:)
    end function psb_isaperm
  end interface


  interface psb_msort
    subroutine imsort(x,ix,dir,flag)
      integer, intent(inout)           :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine imsort
    subroutine smsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_spk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine smsort
    subroutine dmsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_dpk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine dmsort
    subroutine camsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_spk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine camsort
    subroutine zamsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_dpk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine zamsort
  end interface


  interface psb_msort_unique
    subroutine imsort_u(x,nout,dir)
      integer, intent(inout)           :: x(:) 
      integer, intent(out)             :: nout
      integer, optional, intent(in)    :: dir
    end subroutine imsort_u
  end interface

  interface psb_qsort
    subroutine iqsort(x,ix,dir,flag)
      integer, intent(inout)           :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine iqsort
    subroutine sqsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_spk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine sqsort
    subroutine dqsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_dpk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine dqsort
    subroutine cqsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_spk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine cqsort
    subroutine zqsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_dpk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine zqsort
  end interface
  

  interface psb_hsort
!!$    module procedure ihsort, shsort, chsort, dhsort, zhsort
    subroutine ihsort(x,ix,dir,flag)
      use psb_const_mod
      integer, intent(inout)           :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine ihsort
    subroutine shsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_spk_), intent(inout)    :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine shsort
    subroutine dhsort(x,ix,dir,flag)
      use psb_const_mod
      real(psb_dpk_), intent(inout)  :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine dhsort
    subroutine chsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_spk_), intent(inout) :: x(:) 
      integer, optional, intent(in)    :: dir, flag
      integer, optional, intent(inout) :: ix(:)
    end subroutine chsort
    subroutine zhsort(x,ix,dir,flag)
      use psb_const_mod
      complex(psb_dpk_), intent(inout) :: x(:) 
      integer, optional, intent(in)      :: dir, flag
      integer, optional, intent(inout)   :: ix(:)
    end subroutine zhsort
  end interface


  interface psb_howmany_heap
    function  psb_howmany_int_heap(heap)
      import :: psb_int_heap
      type(psb_int_heap), intent(in) :: heap
      integer :: psb_howmany_int_heap
    end function psb_howmany_int_heap
    function  psb_howmany_real_idx_heap(heap)
      import :: psb_real_idx_heap
      type(psb_real_idx_heap), intent(in) :: heap
      integer :: psb_howmany_real_idx_heap
    end function psb_howmany_real_idx_heap
    function  psb_howmany_double_idx_heap(heap)
      import :: psb_double_idx_heap
      type(psb_double_idx_heap), intent(in) :: heap
      integer :: psb_howmany_double_idx_heap
    end function psb_howmany_double_idx_heap
    function  psb_howmany_int_idx_heap(heap)
      import :: psb_int_idx_heap
      type(psb_int_idx_heap), intent(in) :: heap
      integer :: psb_howmany_int_idx_heap
    end function psb_howmany_int_idx_heap
    function  psb_howmany_scomplex_idx_heap(heap)
      import :: psb_scomplex_idx_heap
      type(psb_scomplex_idx_heap), intent(in) :: heap
      integer :: psb_howmany_scomplex_idx_heap
    end function psb_howmany_scomplex_idx_heap
    function  psb_howmany_dcomplex_idx_heap(heap)
      import :: psb_dcomplex_idx_heap
      type(psb_dcomplex_idx_heap), intent(in) :: heap
      integer :: psb_howmany_dcomplex_idx_heap
    end function psb_howmany_dcomplex_idx_heap
  end interface
 

  interface psb_init_heap
    subroutine psb_init_int_heap(heap,info,dir)
      import :: psb_int_heap
      type(psb_int_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_int_heap
    subroutine psb_init_real_idx_heap(heap,info,dir)
      import :: psb_real_idx_heap
      type(psb_real_idx_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_real_idx_heap
    subroutine psb_init_int_idx_heap(heap,info,dir)
      import :: psb_int_idx_heap
      type(psb_int_idx_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_int_idx_heap
    subroutine psb_init_scomplex_idx_heap(heap,info,dir)
      import :: psb_scomplex_idx_heap
      type(psb_scomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_scomplex_idx_heap
    subroutine psb_init_dcomplex_idx_heap(heap,info,dir)
      import :: psb_dcomplex_idx_heap
      type(psb_dcomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_dcomplex_idx_heap
    subroutine psb_init_double_idx_heap(heap,info,dir)
      import :: psb_double_idx_heap
      type(psb_double_idx_heap), intent(inout) :: heap
      integer, intent(out)            :: info
      integer, intent(in), optional   :: dir
    end subroutine psb_init_double_idx_heap
  end interface


  interface psb_dump_heap
    subroutine psb_dump_int_heap(iout,heap,info)
      import :: psb_int_heap
      type(psb_int_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_int_heap
    subroutine psb_dump_real_idx_heap(iout,heap,info)
      import :: psb_real_idx_heap
      type(psb_real_idx_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_real_idx_heap
    subroutine psb_dump_double_idx_heap(iout,heap,info)
      import :: psb_double_idx_heap
      type(psb_double_idx_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_double_idx_heap
    subroutine psb_dump_int_idx_heap(iout,heap,info)
      import :: psb_int_idx_heap
      type(psb_int_idx_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_int_idx_heap
    subroutine psb_dump_scomplex_idx_heap(iout,heap,info)
      import :: psb_scomplex_idx_heap
      type(psb_scomplex_idx_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_scomplex_idx_heap
    subroutine psb_dump_dcomplex_idx_heap(iout,heap,info)
      import :: psb_dcomplex_idx_heap
      type(psb_dcomplex_idx_heap), intent(in) :: heap
      integer, intent(out)           :: info
      integer, intent(in)            :: iout
    end subroutine psb_dump_dcomplex_idx_heap
  end interface


  interface psb_insert_heap
    subroutine psb_insert_int_heap(key,heap,info)
      import :: psb_int_heap
      integer, intent(in)               :: key
      type(psb_int_heap), intent(inout) :: heap
      integer, intent(out)              :: info
    end subroutine psb_insert_int_heap
    subroutine psb_insert_int_idx_heap(key,index,heap,info)
      import :: psb_dpk_, psb_int_idx_heap
      integer, intent(in)                   :: key
      integer, intent(in)                   :: index
      type(psb_int_idx_heap), intent(inout) :: heap
      integer, intent(out)                  :: info
    end subroutine psb_insert_int_idx_heap
    subroutine psb_insert_real_idx_heap(key,index,heap,info)
      import :: psb_spk_, psb_real_idx_heap
      real(psb_spk_), intent(in)      :: key
      integer, intent(in)               :: index
      type(psb_real_idx_heap), intent(inout) :: heap
      integer, intent(out)              :: info
    end subroutine psb_insert_real_idx_heap
    subroutine psb_insert_double_idx_heap(key,index,heap,info)
      import :: psb_dpk_, psb_double_idx_heap
      real(psb_dpk_), intent(in)      :: key
      integer, intent(in)               :: index
      type(psb_double_idx_heap), intent(inout) :: heap
      integer, intent(out)              :: info
    end subroutine psb_insert_double_idx_heap
    subroutine psb_insert_scomplex_idx_heap(key,index,heap,info)
      import :: psb_spk_, psb_scomplex_idx_heap
      complex(psb_spk_), intent(in)              :: key
      integer, intent(in)                        :: index
      type(psb_scomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)                       :: info
    end subroutine psb_insert_scomplex_idx_heap
    subroutine psb_insert_dcomplex_idx_heap(key,index,heap,info)
      import :: psb_dpk_, psb_dcomplex_idx_heap
      complex(psb_dpk_), intent(in)            :: key
      integer, intent(in)                        :: index
      type(psb_dcomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)                       :: info
    end subroutine psb_insert_dcomplex_idx_heap
  end interface

  interface psb_heap_get_first
    subroutine psb_int_heap_get_first(key,heap,info)
      import :: psb_int_heap
      type(psb_int_heap), intent(inout) :: heap
      integer, intent(out)              :: key,info
    end subroutine psb_int_heap_get_first
    subroutine psb_int_idx_heap_get_first(key,index,heap,info)
      import :: psb_int_idx_heap
      type(psb_int_idx_heap), intent(inout) :: heap
      integer, intent(out)                  :: index,info
      integer, intent(out)                  :: key
    end subroutine psb_int_idx_heap_get_first
    subroutine psb_real_idx_heap_get_first(key,index,heap,info)
      import :: psb_spk_, psb_real_idx_heap
      type(psb_real_idx_heap), intent(inout) :: heap
      integer, intent(out)              :: index,info
      real(psb_spk_), intent(out)     :: key
    end subroutine psb_real_idx_heap_get_first
    subroutine psb_double_idx_heap_get_first(key,index,heap,info)
      import :: psb_dpk_, psb_double_idx_heap
      type(psb_double_idx_heap), intent(inout) :: heap
      integer, intent(out)              :: index,info
      real(psb_dpk_), intent(out)     :: key
    end subroutine psb_double_idx_heap_get_first
    subroutine psb_scomplex_idx_heap_get_first(key,index,heap,info)
      import :: psb_spk_, psb_scomplex_idx_heap
      type(psb_scomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)                       :: index,info
      complex(psb_spk_), intent(out)           :: key
    end subroutine psb_scomplex_idx_heap_get_first
    
    subroutine psb_dcomplex_idx_heap_get_first(key,index,heap,info)
      import :: psb_dpk_, psb_dcomplex_idx_heap
      type(psb_dcomplex_idx_heap), intent(inout) :: heap
      integer, intent(out)                       :: index,info
      complex(psb_dpk_), intent(out)           :: key
    end subroutine psb_dcomplex_idx_heap_get_first
  end interface

  interface 
    subroutine psi_insert_int_heap(key,last,heap,dir,info)
      implicit none 
      
      !  
      ! Input: 
      !   key:  the new value
      !   last: pointer to the last occupied element in heap
      !   heap: the heap
      !   dir:  sorting direction
      
      integer, intent(in)     :: key,dir
      integer, intent(inout)  :: heap(:),last
      integer, intent(out)    :: info
    end subroutine psi_insert_int_heap
  end interface
  
  interface 
    subroutine psi_int_heap_get_first(key,last,heap,dir,info)
      implicit none 
      
      integer, intent(inout)  :: key,last
      integer, intent(in)     :: dir
      integer, intent(inout)  :: heap(:)
      integer, intent(out)    :: info
    end subroutine psi_int_heap_get_first
  end interface
  
  interface 
    subroutine psi_insert_real_heap(key,last,heap,dir,info)
      import :: psb_spk_
      real(psb_spk_), intent(in)    :: key
      integer, intent(in)           :: dir
      real(psb_spk_), intent(inout) :: heap(:)
      integer, intent(inout)        :: last
      integer, intent(out)          :: info
      integer                       :: i, i2
      real(psb_spk_)                :: temp
    end subroutine psi_insert_real_heap
  end interface
  
  interface 
    subroutine psi_real_heap_get_first(key,last,heap,dir,info)
      import :: psb_spk_
      real(psb_spk_), intent(inout) :: key
      integer, intent(inout)        :: last
      integer, intent(in)           :: dir
      real(psb_spk_), intent(inout) :: heap(:)
      integer, intent(out)          :: info
    end subroutine psi_real_heap_get_first
  end interface
  
  interface 
    subroutine psi_insert_double_heap(key,last,heap,dir,info)
      import :: psb_dpk_
      real(psb_dpk_), intent(in)    :: key
      integer, intent(in)             :: dir
      real(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(inout)          :: last
      integer, intent(out)            :: info
      integer                         :: i, i2
      real(psb_dpk_)                :: temp
    end subroutine psi_insert_double_heap
  end interface
  
  interface 
    subroutine psi_double_heap_get_first(key,last,heap,dir,info)
      import :: psb_dpk_
      real(psb_dpk_), intent(inout) :: key
      integer, intent(inout)          :: last
      integer, intent(in)             :: dir
      real(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(out)            :: info
    end subroutine psi_double_heap_get_first
  end interface
  
  interface 
    subroutine psi_insert_scomplex_heap(key,last,heap,dir,info)
      import :: psb_spk_
      complex(psb_spk_), intent(in)    :: key
      integer, intent(in)              :: dir
      complex(psb_spk_), intent(inout) :: heap(:)
      integer, intent(inout)           :: last
      integer, intent(out)             :: info
    end subroutine psi_insert_scomplex_heap
  end interface
  
  interface 
    subroutine psi_scomplex_heap_get_first(key,last,heap,dir,info)
      import :: psb_spk_
      complex(psb_spk_), intent(inout) :: key
      integer, intent(inout)           :: last
      integer, intent(in)              :: dir
      complex(psb_spk_), intent(inout) :: heap(:)
      integer, intent(out)             :: info
    end subroutine psi_scomplex_heap_get_first
  end interface
  
  interface 
    subroutine psi_insert_dcomplex_heap(key,last,heap,dir,info)
      import :: psb_dpk_
      complex(psb_dpk_), intent(in)    :: key
      integer, intent(in)                :: dir
      complex(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(inout)             :: last
      integer, intent(out)               :: info
    end subroutine psi_insert_dcomplex_heap
  end interface
  
  interface 
    subroutine psi_dcomplex_heap_get_first(key,last,heap,dir,info)
      import :: psb_dpk_
      complex(psb_dpk_), intent(inout) :: key
      integer, intent(inout)             :: last
      integer, intent(in)                :: dir
      complex(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(out)               :: info
    end subroutine psi_dcomplex_heap_get_first
  end interface

  interface 
    subroutine psi_insert_int_idx_heap(key,index,last,heap,idxs,dir,info)
      integer, intent(in)     :: key
      integer, intent(in)     :: index,dir
      integer, intent(inout)  :: heap(:),last
      integer, intent(inout)  :: idxs(:)
      integer, intent(out)    :: info
    end subroutine psi_insert_int_idx_heap
  end interface
  
  interface 
    subroutine psi_int_idx_heap_get_first(key,index,last,heap,idxs,dir,info)
      integer, intent(inout) :: heap(:)
      integer, intent(out)   :: index,info
      integer, intent(inout) :: last,idxs(:)
      integer, intent(in)    :: dir
      integer, intent(out)   :: key
    end subroutine psi_int_idx_heap_get_first
  end interface
  
  interface 
    subroutine psi_insert_real_idx_heap(key,index,last,heap,idxs,dir,info)
      import :: psb_spk_
      real(psb_spk_), intent(in)     :: key
      integer, intent(in)            :: index,dir
      real(psb_spk_), intent(inout)  :: heap(:)
      integer, intent(inout)         :: idxs(:),last
      integer, intent(out)           :: info
    end subroutine psi_insert_real_idx_heap
  end interface
  
  interface 
    subroutine psi_real_idx_heap_get_first(key,index,last,heap,idxs,dir,info)
      import :: psb_spk_
      real(psb_spk_), intent(inout) :: heap(:)
      integer, intent(out)          :: index,info
      integer, intent(inout)        :: last,idxs(:)
      integer, intent(in)           :: dir
      real(psb_spk_), intent(out)   :: key
    end subroutine psi_real_idx_heap_get_first
  end interface

  interface 
    subroutine psi_insert_double_idx_heap(key,index,last,heap,idxs,dir,info)
      import :: psb_dpk_
      real(psb_dpk_), intent(in)     :: key
      integer, intent(in)              :: index,dir
      real(psb_dpk_), intent(inout)  :: heap(:)
      integer, intent(inout)           :: idxs(:),last
      integer, intent(out)             :: info
    end subroutine psi_insert_double_idx_heap
  end interface
  
  interface 
    subroutine psi_double_idx_heap_get_first(key,index,last,heap,idxs,dir,info)
      import :: psb_dpk_
      real(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(out)            :: index,info
      integer, intent(inout)          :: last,idxs(:)
      integer, intent(in)             :: dir
      real(psb_dpk_), intent(out)   :: key
    end subroutine psi_double_idx_heap_get_first
  end interface

  interface 
    subroutine psi_insert_scomplex_idx_heap(key,index,last,heap,idxs,dir,info)
      import :: psb_spk_
      complex(psb_spk_), intent(in)    :: key
      integer, intent(in)              :: index,dir
      complex(psb_spk_), intent(inout) :: heap(:)
      integer, intent(inout)           :: idxs(:),last
      integer, intent(out)             :: info
    end subroutine psi_insert_scomplex_idx_heap
  end interface

  interface 
    subroutine psi_scomplex_idx_heap_get_first(key,index,last,heap,idxs,dir,info)
      import :: psb_spk_
      complex(psb_spk_), intent(inout) :: heap(:)
      integer, intent(out)             :: index,info
      integer, intent(inout)           :: last,idxs(:)
      integer, intent(in)              :: dir
      complex(psb_spk_), intent(out)   :: key
    end subroutine psi_scomplex_idx_heap_get_first
  end interface

  interface 
    subroutine psi_insert_dcomplex_idx_heap(key,index,last,heap,idxs,dir,info)
      import :: psb_dpk_
      complex(psb_dpk_), intent(in)    :: key
      integer, intent(in)                :: index,dir
      complex(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(inout)             :: idxs(:),last
      integer, intent(out)               :: info
    end subroutine psi_insert_dcomplex_idx_heap
  end interface

  interface 
    subroutine psi_dcomplex_idx_heap_get_first(key,index,last,heap,idxs,dir,info)
      import :: psb_dpk_
      complex(psb_dpk_), intent(inout) :: heap(:)
      integer, intent(out)               :: index,info
      integer, intent(inout)             :: last,idxs(:)
      integer, intent(in)                :: dir
      complex(psb_dpk_), intent(out)   :: key
    end subroutine psi_dcomplex_idx_heap_get_first
  end interface
  

end module psb_sort_mod
