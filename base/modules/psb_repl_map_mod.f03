module psb_repl_map_mod
  use psb_const_mod
  use psb_desc_const_mod
  use psb_indx_map_mod
  
  type, extends(psb_indx_map) :: psb_repl_map

  contains

    procedure, pass(idxmap)  :: init      => repl_init

    procedure, pass(idxmap)  :: is_repl   => repl_is_repl
    procedure, pass(idxmap)  :: asb       => repl_asb
    procedure, pass(idxmap)  :: free      => repl_free
    procedure, pass(idxmap)  :: get_fmt   => repl_get_fmt

    procedure, pass(idxmap)  :: l2gs1 => repl_l2gs1
    procedure, pass(idxmap)  :: l2gs2 => repl_l2gs2
    procedure, pass(idxmap)  :: l2gv1 => repl_l2gv1
    procedure, pass(idxmap)  :: l2gv2 => repl_l2gv2

    procedure, pass(idxmap)  :: g2ls1 => repl_g2ls1
    procedure, pass(idxmap)  :: g2ls2 => repl_g2ls2
    procedure, pass(idxmap)  :: g2lv1 => repl_g2lv1
    procedure, pass(idxmap)  :: g2lv2 => repl_g2lv2

    procedure, pass(idxmap)  :: g2ls1_ins => repl_g2ls1_ins
    procedure, pass(idxmap)  :: g2ls2_ins => repl_g2ls2_ins
    procedure, pass(idxmap)  :: g2lv1_ins => repl_g2lv1_ins
    procedure, pass(idxmap)  :: g2lv2_ins => repl_g2lv2_ins

  end type psb_repl_map

  private :: repl_init, repl_is_repl, repl_asb, repl_free,&
       & repl_get_fmt, repl_l2gs1, repl_l2gs2, repl_l2gv1,&
       & repl_l2gv2, repl_g2ls1, repl_g2ls2, repl_g2lv1,&
       & repl_g2lv2, repl_g2ls1_ins, repl_g2ls2_ins,&
       & repl_g2lv1_ins, repl_g2lv2_ins


contains

  function repl_is_repl(idxmap) result(val)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    logical :: val
    val = .true.
  end function repl_is_repl
    
    
  function repl_sizeof(idxmap) result(val)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer(psb_long_int_k_) :: val
    
    val = idxmap%psb_indx_map%sizeof()

  end function repl_sizeof



  subroutine repl_l2gs1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer  :: idxv(1)
    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if

    idxv(1) = idx
    call idxmap%l2g(idxv,info,owned=owned)
    idx = idxv(1)

  end subroutine repl_l2gs1

  subroutine repl_l2gs2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%l2g(idxout,info,mask,owned)
    
  end subroutine repl_l2gs2


  subroutine repl_l2gv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i
    logical :: owned_
    info = 0

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    if (present(mask)) then 

      do i=1, size(idx)
        if (mask(i)) then 
          if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
            ! do nothing
          else 
            idx(i) = -1
            info = -1
          end if
        end if
      end do

    else  if (.not.present(mask)) then 

      do i=1, size(idx)
        if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
          ! do nothing
        else 
          idx(i) = -1
          info = -1
        end if
      end do

    end if

  end subroutine repl_l2gv1

  subroutine repl_l2gv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%l2g(idxout(1:im),info,mask,owned)
    if (is > im) info = -3 

  end subroutine repl_l2gv2


  subroutine repl_g2ls1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned
    integer :: idxv(1)
    info = 0

    if (present(mask)) then 
      if (.not.mask) return
    end if
    
    idxv(1) = idx 
    call idxmap%g2l(idxv,info,owned=owned)
    idx = idxv(1) 
      
  end subroutine repl_g2ls1

  subroutine repl_g2ls2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%g2l(idxout,info,mask,owned)
    
  end subroutine repl_g2ls2


  subroutine repl_g2lv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i, nv, is
    logical :: owned_

    info = 0

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if
    if (present(owned)) then 
      owned_ = owned
    else
      owned_ = .false.
    end if

    is = size(idx)

    if (present(mask)) then 

      if (idxmap%is_asb()) then 
        do i=1, is
          if (mask(i)) then 
            if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              ! do nothing
            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do
      else if (idxmap%is_valid()) then 
        do i=1,is
          if (mask(i)) then 
            if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              ! do nothing

            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do
      else 
        idx(1:is) = -1
        info = -1
      end if

    else  if (.not.present(mask)) then 

      if (idxmap%is_asb()) then 
        do i=1, is
          if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            ! do nothing
          else 
            idx(i) = -1
            info = -1
          end if
        end do
      else if (idxmap%is_valid()) then 
        do i=1,is
          if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            ! do nothing 
          else 
            idx(i) = -1
            info = -1
          end if
        end do
      else 
        idx(1:is) = -1
        info = -1
      end if

    end if

  end subroutine repl_g2lv1

  subroutine repl_g2lv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned

    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l(idxout(1:im),info,mask,owned)
    if (is > im) info = -3 

  end subroutine repl_g2lv2



  subroutine repl_g2ls1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    integer :: idxv(1)

    info = 0
    if (present(mask)) then 
      if (.not.mask) return
    end if
    idxv(1) = idx
    call idxmap%g2l_ins(idxv,info)
    idx = idxv(1) 

  end subroutine repl_g2ls1_ins

  subroutine repl_g2ls2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    idxout = idxin
    call idxmap%g2l_ins(idxout,info)
    
  end subroutine repl_g2ls2_ins


  subroutine repl_g2lv1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: i, nv, is, ix

    info = 0
    is = size(idx)

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if


    if (idxmap%is_asb()) then 
      ! State is wrong for this one ! 
      idx = -1
      info = -1

    else if (idxmap%is_valid()) then 

      if (present(mask)) then 
        do i=1, is
          if (mask(i)) then 
            if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              ! do nothing
            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do

      else if (.not.present(mask)) then 

        do i=1, is
          if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            ! do nothing
          else 
            idx(i) = -1
            info = -1
          end if
        end do
      end if

    else 
      idx = -1
      info = -1
    end if

  end subroutine repl_g2lv1_ins

  subroutine repl_g2lv2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: is, im
    
    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l_ins(idxout(1:im),info,mask)
    if (is > im) info = -3 

  end subroutine repl_g2lv2_ins




  subroutine repl_init(idxmap,ictxt,nl,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, nl
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, j, ntot
    integer, allocatable :: vnl(:)

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if
    
    
    idxmap%global_rows  = nl
    idxmap%global_cols  = nl
    idxmap%local_rows   = nl
    idxmap%local_cols   = nl
    idxmap%ictxt        = ictxt
    idxmap%state        = psb_desc_bld_
    call psb_get_mpicomm(ictxt,idxmap%mpic)

  end subroutine repl_init


  subroutine repl_asb(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    integer, intent(out) :: info
    
    integer :: ictxt, iam, np 
    
    info = 0 
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)

    idxmap%state = psb_desc_asb_
    
  end subroutine repl_asb

  subroutine repl_free(idxmap)
    implicit none 
    class(psb_repl_map), intent(inout) :: idxmap
    
    call idxmap%psb_indx_map%free()
    
  end subroutine repl_free


  function repl_get_fmt(idxmap) result(res)
    implicit none 
    class(psb_repl_map), intent(in) :: idxmap
    character(len=5) :: res
    res = 'REPL'
  end function repl_get_fmt

end module psb_repl_map_mod
