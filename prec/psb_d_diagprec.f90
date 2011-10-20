module psb_d_diagprec
  use psb_d_base_prec_mod

  
  type, extends(psb_d_base_prec_type) :: psb_d_diag_prec_type
    real(psb_dpk_), allocatable :: d(:)
    class(psb_d_vect), allocatable :: dv
  contains
    procedure, pass(prec) :: d_apply_v => psb_d_diag_apply_vect
    procedure, pass(prec) :: d_apply   => psb_d_diag_apply
    procedure, pass(prec) :: precbld   => psb_d_diag_precbld
    procedure, pass(prec) :: precinit  => psb_d_diag_precinit  
    procedure, pass(prec) :: precseti  => psb_d_diag_precseti
    procedure, pass(prec) :: precsetr  => psb_d_diag_precsetr
    procedure, pass(prec) :: precsetc  => psb_d_diag_precsetc
    procedure, pass(prec) :: precfree  => psb_d_diag_precfree
    procedure, pass(prec) :: precdescr => psb_d_diag_precdescr
    procedure, pass(prec) :: sizeof    => psb_d_diag_sizeof
    procedure, pass(prec) :: get_nzeros => psb_d_diag_get_nzeros
  end type psb_d_diag_prec_type

  private :: psb_d_diag_apply, psb_d_diag_precbld, psb_d_diag_precseti,&
       & psb_d_diag_precsetr, psb_d_diag_precsetc, psb_d_diag_sizeof,&
       & psb_d_diag_precinit, psb_d_diag_precfree, psb_d_diag_precdescr,&
       & psb_d_diag_apply_vect, psb_d_diag_get_nzeros
  

contains
  

  subroutine psb_d_diag_apply_vect(alpha,prec,x,beta,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_d_diag_prec_type), intent(inout)  :: prec
    class(psb_d_vect),intent(inout)   :: x
    real(psb_dpk_),intent(in)         :: alpha, beta
    class(psb_d_vect),intent(inout)   :: y
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_prec_apply'
    real(psb_dpk_), pointer :: ww(:)
    class(psb_d_vect), allocatable :: dw

    call psb_erractionsave(err_act)

    !
    ! This is the base version and we should throw an error. 
    ! Or should it be the DIAG preonditioner???
    !
    info = psb_success_
    
    nrow = desc_data%get_local_rows()
    if (x%get_nrows() < nrow) then 
      info = 36
      call psb_errpush(info,name,i_err=(/2,nrow,0,0,0/))
      goto 9999
    end if
    if (y%get_nrows() < nrow) then 
      info = 36
      call psb_errpush(info,name,i_err=(/3,nrow,0,0,0/))
      goto 9999
    end if
    if (.not.allocated(prec%d)) then
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner: D")
      goto 9999
    end if
    if (size(prec%d) < nrow) then
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner: D")
      goto 9999
    end if
    
    if (size(work) >= x%get_nrows()) then 
      ww => work
    else
      allocate(ww(x%get_nrows()),stat=info)
      if (info /= psb_success_) then 
        call psb_errpush(psb_err_alloc_request_,name,&
             & i_err=(/x%get_nrows(),0,0,0,0/),a_err='real(psb_dpk_)')
        goto 9999      
      end if
    end if
    
!!$      allocate(dw, mold=x, stat=info) 
!!$      call dw%bld(x%get_nrows())
!!$      if (.true.) then 
!!$        if (info == 0) call dw%mlt(prec%dv,x,info)
!!$      else
!!$        if (info == 0) call dw%axpby(nrow,done,x,dzero,info) 
!!$        if (info == 0) call dw%mlt(prec%dv,info)
!!$      end if
!!$      if (info == 0) call y%axpby(nrow,alpha,dw,beta,info)

    call y%mlt(alpha,prec%dv,x,beta,info)

!!$      call x%mlt(ww,prec%d(1:nrow),info)
!!$    if (info == 0) call psb_geaxpby(alpha,ww,beta,y,desc_data,info)

!!$    call dw%free(info) 
!!$    if (info /= psb_success_) then 
!!$      call psb_errpush(psb_err_from_subroutine_,name,a_err='Deallocate')
!!$      goto 9999      
!!$    end if

    if (size(work) < x%get_nrows()) then 
      deallocate(ww,stat=info)
      if (info /= psb_success_) then 
        call psb_errpush(psb_err_from_subroutine_,name,a_err='Deallocate')
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

  end subroutine psb_d_diag_apply_vect


  subroutine psb_d_diag_apply(alpha,prec,x,beta,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_d_diag_prec_type), intent(in)  :: prec
    real(psb_dpk_),intent(inout)      :: x(:)
    real(psb_dpk_),intent(in)         :: alpha, beta
    real(psb_dpk_),intent(inout)      :: y(:)
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_prec_apply'
    real(psb_dpk_), pointer :: ww(:)

    call psb_erractionsave(err_act)

    !
    ! This is the base version and we should throw an error. 
    ! Or should it be the DIAG preonditioner???
    !
    info = psb_success_
    
    nrow = desc_data%get_local_rows()
    if (size(x) < nrow) then 
      info = 36
      call psb_errpush(info,name,i_err=(/2,nrow,0,0,0/))
      goto 9999
    end if
    if (size(y) < nrow) then 
      info = 36
      call psb_errpush(info,name,i_err=(/3,nrow,0,0,0/))
      goto 9999
    end if
    if (.not.allocated(prec%d)) then
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner: D")
      goto 9999
    end if
    if (size(prec%d) < nrow) then
      info = 1124
      call psb_errpush(info,name,a_err="preconditioner: D")
      goto 9999
    end if
    
    if (size(work) >= size(x)) then 
      ww => work
    else
      allocate(ww(size(x)),stat=info)
      if (info /= psb_success_) then 
        call psb_errpush(psb_err_alloc_request_,name,i_err=(/size(x),0,0,0,0/),a_err='real(psb_dpk_)')
        goto 9999      
      end if
    end if

    ww(1:nrow) = x(1:nrow)*prec%d(1:nrow)
    call psb_geaxpby(alpha,ww,beta,y,desc_data,info)

    if (size(work) < size(x)) then 
      deallocate(ww,stat=info)
      if (info /= psb_success_) then 
        call psb_errpush(psb_err_from_subroutine_,name,a_err='Deallocate')
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

  end subroutine psb_d_diag_apply

  subroutine psb_d_diag_precinit(prec,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_diag_prec_type),intent(inout) :: prec
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_precinit'

    call psb_erractionsave(err_act)

    info = psb_success_

    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_d_diag_precinit


  subroutine psb_d_diag_precbld(a,desc_a,prec,info,upd,amold,afmt,vmold)
    
    use psb_base_mod
    Implicit None
    
    type(psb_dspmat_type), intent(in), target :: a
    type(psb_desc_type), intent(in), target   :: desc_a
    class(psb_d_diag_prec_type),intent(inout) :: prec
    integer, intent(out)                      :: info
    character, intent(in), optional           :: upd
    character(len=*), intent(in), optional    :: afmt
    class(psb_d_base_sparse_mat), intent(in), optional :: amold
    class(psb_d_vect), intent(in), optional   :: vmold
    Integer :: err_act, nrow,i
    character(len=20)  :: name='d_diag_precbld'

    call psb_erractionsave(err_act)

    info = psb_success_
    nrow = desc_a%get_local_cols()
    if (allocated(prec%d)) then 
      if (size(prec%d) < nrow) then 
        deallocate(prec%d,stat=info)
      end if
    end if
    if ((info == psb_success_).and.(.not.allocated(prec%d))) then 
      allocate(prec%d(nrow), stat=info)
    end if
    if (info /= psb_success_) then 
      info = psb_err_alloc_dealloc_
      call psb_errpush(info,name)
      goto 9999
    end if

    call a%get_diag(prec%d,info) 
    if (info /= psb_success_) then 
      info = psb_err_from_subroutine_
      call psb_errpush(info,name, a_err='get_diag')
      goto 9999
    end if
    
    do i=1,nrow
      if (prec%d(i) == dzero) then
        prec%d(i) = done
      else
        prec%d(i) = done/prec%d(i)
      endif
    end do
    if (present(vmold)) then 
      allocate(prec%dv,mold=vmold,stat=info) 
    else
      allocate(psb_d_vect :: prec%dv,stat=info) 
    end if
    if (info == 0) then 
      call prec%dv%bld(prec%d)
    else 
      write(0,*) 'Error on precbld ',info
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
  end subroutine psb_d_diag_precbld

  subroutine psb_d_diag_precseti(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_diag_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    integer, intent(in)                      :: val 
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_d_diag_precseti

  subroutine psb_d_diag_precsetr(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_diag_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    real(psb_dpk_), intent(in)               :: val 
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_d_diag_precsetr

  subroutine psb_d_diag_precsetc(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_diag_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    character(len=*), intent(in)             :: val
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_d_diag_precsetc

  subroutine psb_d_diag_precfree(prec,info)
    
    use psb_base_mod
    Implicit None

    class(psb_d_diag_prec_type), intent(inout) :: prec
    integer, intent(out)                :: info
    
    Integer :: err_act, nrow
    character(len=20)  :: name='d_diag_precset'
    
    call psb_erractionsave(err_act)
    
    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_d_diag_precfree
  

  subroutine psb_d_diag_precdescr(prec,iout)
    
    use psb_base_mod
    Implicit None

    class(psb_d_diag_prec_type), intent(in) :: prec
    integer, intent(in), optional    :: iout

    Integer :: err_act, nrow, info
    character(len=20)  :: name='d_diag_precdescr'

    integer :: iout_

    call psb_erractionsave(err_act)

    info = psb_success_
   
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    write(iout_,*) 'Diagonal scaling'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_d_diag_precdescr

  function psb_d_diag_sizeof(prec) result(val)
    use psb_base_mod, only: psb_long_int_k_
    class(psb_d_diag_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0
    val = val + psb_sizeof_dp * size(prec%d)
    return
  end function psb_d_diag_sizeof


  function psb_d_diag_get_nzeros(prec) result(val)
    use psb_base_mod, only: psb_long_int_k_
    class(psb_d_diag_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0
    val = val + size(prec%d)
    return
  end function psb_d_diag_get_nzeros


end module psb_d_diagprec
