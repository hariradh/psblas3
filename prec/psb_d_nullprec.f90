module psb_d_nullprec

  use psb_d_base_prec_mod
  
  type, extends(psb_d_base_prec_type) :: psb_d_null_prec_type
  contains
    procedure, pass(prec) :: d_apply_v => psb_d_null_apply_vect
    procedure, pass(prec) :: d_apply   => psb_d_null_apply
    procedure, pass(prec) :: precbld   => psb_d_null_precbld
    procedure, pass(prec) :: precinit  => psb_d_null_precinit
    procedure, pass(prec) :: precseti  => psb_d_null_precseti
    procedure, pass(prec) :: precsetr  => psb_d_null_precsetr
    procedure, pass(prec) :: precsetc  => psb_d_null_precsetc
    procedure, pass(prec) :: precfree  => psb_d_null_precfree
    procedure, pass(prec) :: precdescr => psb_d_null_precdescr
    procedure, pass(prec) :: sizeof    => psb_d_null_sizeof
  end type psb_d_null_prec_type

  private :: psb_d_null_apply, psb_d_null_precbld, psb_d_null_precseti,&
       & psb_d_null_precsetr, psb_d_null_precsetc, psb_d_null_sizeof,&
       & psb_d_null_precinit, psb_d_null_precfree, psb_d_null_precdescr, &
       & psb_d_null_apply_vect
  
contains
  

  subroutine psb_d_null_apply_vect(alpha,prec,x,beta,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_d_null_prec_type), intent(in)  :: prec
    class(psb_d_vect),intent(inout)   :: x
    real(psb_dpk_),intent(in)         :: alpha, beta
    class(psb_d_vect),intent(inout)   :: y
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_prec_apply'

    call psb_erractionsave(err_act)

    !
    ! This is the base version and we should throw an error. 
    ! Or should it be the NULL preonditioner???
    !
    info = psb_success_
    
    nrow = psb_cd_get_local_rows(desc_data)
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

    call psb_geaxpby(alpha,x,beta,y,desc_data,info)
    if (info /= psb_success_ ) then 
      info = psb_err_from_subroutine_
      call psb_errpush(infoi,name,a_err="psb_geaxpby")
      goto 9999
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

  end subroutine psb_d_null_apply_vect

  subroutine psb_d_null_apply(alpha,prec,x,beta,y,desc_data,info,trans,work)
    use psb_base_mod
    type(psb_desc_type),intent(in)    :: desc_data
    class(psb_d_null_prec_type), intent(in)  :: prec
    real(psb_dpk_),intent(inout)      :: x(:)
    real(psb_dpk_),intent(in)         :: alpha, beta
    real(psb_dpk_),intent(inout)      :: y(:)
    integer, intent(out)              :: info
    character(len=1), optional        :: trans
    real(psb_dpk_),intent(inout), optional, target :: work(:)
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_prec_apply'

    call psb_erractionsave(err_act)

    !
    ! This is the base version and we should throw an error. 
    ! Or should it be the NULL preonditioner???
    !
    info = psb_success_
    
    nrow = psb_cd_get_local_rows(desc_data)
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

    call psb_geaxpby(alpha,x,beta,y,desc_data,info)
    if (info /= psb_success_ ) then 
      info = psb_err_from_subroutine_
      call psb_errpush(infoi,name,a_err="psb_geaxpby")
      goto 9999
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

  end subroutine psb_d_null_apply


  subroutine psb_d_null_precinit(prec,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precinit'

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
  end subroutine psb_d_null_precinit

  subroutine psb_d_null_precbld(a,desc_a,prec,info,upd,amold,afmt,vmold)
    
    use psb_base_mod
    Implicit None
    
    type(psb_dspmat_type), intent(in), target :: a
    type(psb_desc_type), intent(in), target   :: desc_a
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer, intent(out)                      :: info
    character, intent(in), optional           :: upd
    character(len=*), intent(in), optional    :: afmt
    class(psb_d_base_sparse_mat), intent(in), optional :: amold
    class(psb_d_vect), intent(in), optional   :: vmold
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precbld'

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
  end subroutine psb_d_null_precbld

  subroutine psb_d_null_precseti(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    integer, intent(in)                      :: val 
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precseti

  subroutine psb_d_null_precsetr(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    real(psb_dpk_), intent(in)               :: val 
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precsetr

  subroutine psb_d_null_precsetc(prec,what,val,info)
    
    use psb_base_mod
    Implicit None
    
    class(psb_d_null_prec_type),intent(inout) :: prec
    integer, intent(in)                      :: what 
    character(len=*), intent(in)             :: val
    integer, intent(out)                     :: info
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precset'

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
  end subroutine psb_d_null_precsetc

  subroutine psb_d_null_precfree(prec,info)
    
    use psb_base_mod
    Implicit None

    class(psb_d_null_prec_type), intent(inout) :: prec
    integer, intent(out)                :: info
    
    Integer :: err_act, nrow
    character(len=20)  :: name='d_null_precset'
    
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
    
  end subroutine psb_d_null_precfree
  

  subroutine psb_d_null_precdescr(prec,iout)
    
    use psb_base_mod
    Implicit None

    class(psb_d_null_prec_type), intent(in) :: prec
    integer, intent(in), optional    :: iout

    Integer :: err_act, nrow, info
    character(len=20)  :: name='d_null_precset'
    integer :: iout_

    call psb_erractionsave(err_act)

    info = psb_success_
   
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    write(iout_,*) 'No preconditioning'

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_d_null_precdescr

  function psb_d_null_sizeof(prec) result(val)
    use psb_base_mod
    class(psb_d_null_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0

    return
  end function psb_d_null_sizeof

end module psb_d_nullprec
