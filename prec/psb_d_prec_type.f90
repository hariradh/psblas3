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
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!	Module to   define PREC_DATA,           !!
!!      structure for preconditioning.          !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
module psb_d_prec_type

  ! Reduces size of .mod file.
  use psb_base_mod, only : psb_dpk_, psb_spk_, psb_long_int_k_,&
       & psb_desc_type, psb_sizeof, psb_free, psb_cdfree,&
       & psb_erractionsave, psb_erractionrestore, psb_error, psb_get_errstatus,&
       & psb_dspmat_type

  
  use psb_prec_const_mod
  use psb_d_base_prec_mod
  
  type psb_dprec_type
    class(psb_d_base_prec_type), allocatable :: prec
  contains
    procedure, pass(prec)               :: d_apply2_vect
    procedure, pass(prec)               :: d_apply2v
    procedure, pass(prec)               :: d_apply1v
    generic, public                     :: apply => d_apply2v, d_apply1v, d_apply2_vect
    procedure, pass(prec)               :: get_nzeros => psb_d_get_nzeros
  end type psb_dprec_type

  interface psb_precfree
    module procedure psb_d_precfree
  end interface

  interface psb_nullify_prec
    module procedure psb_nullify_dprec
  end interface


  interface psb_precdescr
    module procedure psb_file_prec_descr
  end interface

  interface psb_precdump
    module procedure psb_d_prec_dump
  end interface

  interface psb_sizeof
    module procedure psb_dprec_sizeof
  end interface


contains


  subroutine psb_file_prec_descr(p,iout)
    use psb_base_mod
    type(psb_dprec_type), intent(in) :: p
    integer, intent(in), optional    :: iout
    integer :: iout_, info
    character(len=20) :: name='prec_descr' 
    
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    if (.not.allocated(p%prec)) then 
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner")
    end if
    call p%prec%precdescr(iout)

  end subroutine psb_file_prec_descr


  subroutine psb_d_prec_dump(prec,info,prefix,head)
    use psb_base_mod
    implicit none 
    type(psb_dprec_type), intent(in) :: prec
    integer, intent(out)             :: info
    character(len=*), intent(in), optional :: prefix,head
    !  len of prefix_ 

    info = 0

    if (.not.allocated(prec%prec)) then 
      info = -1
      write(psb_err_unit,*) 'Trying to dump a non-built preconditioner'
      return
    end if
    
    call prec%prec%dump(info,prefix,head)
    
    
  end subroutine psb_d_prec_dump


  subroutine psb_d_precfree(p,info)
    use psb_base_mod
    type(psb_dprec_type), intent(inout) :: p
    integer, intent(out)                :: info
    integer             :: me, err_act,i
    character(len=20)   :: name
    if(psb_get_errstatus() /= 0) return 
    info=psb_success_
    name = 'psb_precfree'
    call psb_erractionsave(err_act)

    me=-1

    if (allocated(p%prec)) then 
      call p%prec%precfree(info)
      if (info /= psb_success_) goto 9999
      deallocate(p%prec,stat=info)
      if (info /= psb_success_) goto 9999
    end if
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return

  end subroutine psb_d_precfree

  subroutine psb_nullify_dprec(p)
    type(psb_dprec_type), intent(inout) :: p


  end subroutine psb_nullify_dprec


  function psb_dprec_sizeof(prec) result(val)
    use psb_base_mod
    type(psb_dprec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    integer :: i
    val = 0
    
    if (allocated(prec%prec)) then 
      val = val + prec%prec%sizeof()
    end if
  end function psb_dprec_sizeof


  subroutine d_apply2_vect(prec,x,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_dprec_type), intent(inout) :: prec
    class(psb_d_vect),intent(inout)   :: x
    class(psb_d_vect),intent(inout)   :: y
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    
    character     :: trans_ 
    real(psb_dpk_), pointer :: work_(:)
    integer :: ictxt,np,me,err_act
    character(len=20)   :: name
    
    name='d_apply2v'
    info = psb_success_
    call psb_erractionsave(err_act)
    
    ictxt = desc_data%get_context()
    call psb_info(ictxt, me, np)
    
    if (present(trans)) then 
      trans_=psb_toupper(trans)
    else
      trans_='N'
    end if
    
    if (present(work)) then 
      work_ => work
    else
      allocate(work_(4*desc_data%get_local_cols()),stat=info)
      if (info /= psb_success_) then 
        info = psb_err_from_subroutine_
        call psb_errpush(info,name,a_err='Allocate')
        goto 9999      
      end if
      
    end if
    
    if (.not.allocated(prec%prec)) then 
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner")
      goto 9999
    end if

    call prec%prec%apply(done,x,dzero,y,desc_data,info,trans=trans_,work=work_)

    if (present(work)) then 
    else
      deallocate(work_,stat=info)
      if (info /= psb_success_) then 
        info = psb_err_from_subroutine_
        call psb_errpush(info,name,a_err='DeAllocate')
        goto 9999      
      end if
    end if
    
    call psb_erractionrestore(err_act)
    return
    
9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return

  end subroutine d_apply2_vect

  subroutine d_apply2v(prec,x,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_dprec_type), intent(in) :: prec
    real(psb_dpk_),intent(inout)      :: x(:)
    real(psb_dpk_),intent(inout)      :: y(:)
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    
    character     :: trans_ 
    real(psb_dpk_), pointer :: work_(:)
    integer :: ictxt,np,me,err_act
    character(len=20)   :: name
    
    name='d_apply2v'
    info = psb_success_
    call psb_erractionsave(err_act)
    
    ictxt = desc_data%get_context()
    call psb_info(ictxt, me, np)
    
    if (present(trans)) then 
      trans_=psb_toupper(trans)
    else
      trans_='N'
    end if
    
    if (present(work)) then 
      work_ => work
    else
      allocate(work_(4*desc_data%get_local_cols()),stat=info)
      if (info /= psb_success_) then 
        info = psb_err_from_subroutine_
        call psb_errpush(info,name,a_err='Allocate')
        goto 9999      
      end if
      
    end if
    
    if (.not.allocated(prec%prec)) then 
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner")
      goto 9999
    end if
    call prec%prec%apply(done,x,dzero,y,desc_data,info,trans=trans_,work=work_)
    if (present(work)) then 
    else
      deallocate(work_,stat=info)
      if (info /= psb_success_) then 
        info = psb_err_from_subroutine_
        call psb_errpush(info,name,a_err='DeAllocate')
        goto 9999      
      end if
    end if
    
    call psb_erractionrestore(err_act)
    return
    
9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return

  end subroutine d_apply2v

  subroutine d_apply1v(prec,x,desc_data,info,trans)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_dprec_type), intent(in) :: prec
    real(psb_dpk_),intent(inout)      :: x(:)
    integer, intent(out)              :: info
    character(len=1), optional        :: trans

    character     :: trans_
    integer :: ictxt,np,me, err_act
    real(psb_dpk_), pointer :: WW(:), w1(:)
    character(len=20)   :: name
    name='d_apply1v'
    info = psb_success_
    call psb_erractionsave(err_act)
    
    
    ictxt=desc_data%get_context()
    call psb_info(ictxt, me, np)
    if (present(trans)) then 
      trans_=psb_toupper(trans)
    else
      trans_='N'
    end if
    
    if (.not.allocated(prec%prec)) then 
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner")
      goto 9999
    end if
    allocate(ww(size(x)),w1(size(x)),stat=info)
    if (info /= psb_success_) then 
      info = psb_err_from_subroutine_
      call psb_errpush(info,name,a_err='Allocate')
      goto 9999      
    end if
    call prec%prec%apply(done,x,dzero,ww,desc_data,info,trans=trans_,work=w1)
    if(info /= psb_success_) goto 9999
    x(:) = ww(:)
    deallocate(ww,W1,stat=info)
    if (info /= psb_success_) then 
      info = psb_err_from_subroutine_
      call psb_errpush(info,name,a_err='DeAllocate')
      goto 9999      
    end if

    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_errpush(info,name)
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine d_apply1v

  function psb_d_get_nzeros(prec) result(res)
    class(psb_dprec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: res
    
    res = 0
    if (allocated(prec%prec)) &
         & res = prec%prec%get_nzeros()
    
  end function psb_d_get_nzeros
  

end module psb_d_prec_type
