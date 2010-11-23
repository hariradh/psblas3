module psb_gen_block_map_mod
  use psb_const_mod
  use psb_desc_const_mod
  use psb_indx_map_mod
  
  type, extends(psb_indx_map) :: psb_gen_block_map
    private 
    integer :: ictxt          = -1
    integer :: mpic           = -1
    integer :: state          = -1 
    integer :: global_rows    = -1
    integer :: global_cols    = -1
    integer :: local_rows     = -1
    integer :: local_cols     = -1
    integer :: min_glob_row   = -1
    integer :: max_glob_row   = -1
    integer, allocatable :: loc_to_glob(:), srt_l2g(:,:) 
  contains
    procedure, pass(idxmap)  :: init      => block_init

    procedure, pass(idxmap)  :: get_state => block_get_state
    procedure, pass(idxmap)  :: set_state => block_set_state
    procedure, pass(idxmap)  :: is_repl   => block_is_repl
    procedure, pass(idxmap)  :: is_bld    => block_is_bld
    procedure, pass(idxmap)  :: is_upd    => block_is_upd
    procedure, pass(idxmap)  :: is_asb    => block_is_asb
    procedure, pass(idxmap)  :: is_valid  => block_is_valid
    procedure, pass(idxmap)  :: sizeof    => block_sizeof
    procedure, pass(idxmap)  :: asb       => block_asb
    procedure, pass(idxmap)  :: free      => block_free

    procedure, pass(idxmap)  :: l2gs1 => block_l2gs1
    procedure, pass(idxmap)  :: l2gs2 => block_l2gs2
    procedure, pass(idxmap)  :: l2gv1 => block_l2gv1
    procedure, pass(idxmap)  :: l2gv2 => block_l2gv2

    procedure, pass(idxmap)  :: g2ls1 => block_g2ls1
    procedure, pass(idxmap)  :: g2ls2 => block_g2ls2
    procedure, pass(idxmap)  :: g2lv1 => block_g2lv1
    procedure, pass(idxmap)  :: g2lv2 => block_g2lv2

    procedure, pass(idxmap)  :: g2ls1_ins => block_g2ls1_ins
    procedure, pass(idxmap)  :: g2ls2_ins => block_g2ls2_ins
    procedure, pass(idxmap)  :: g2lv1_ins => block_g2lv1_ins
    procedure, pass(idxmap)  :: g2lv2_ins => block_g2lv2_ins

    procedure, pass(idxmap)  :: get_gr   => block_get_gr
    procedure, pass(idxmap)  :: get_gc   => block_get_gc
    procedure, pass(idxmap)  :: get_lr   => block_get_lr
    procedure, pass(idxmap)  :: get_lc   => block_get_lc
    procedure, pass(idxmap)  :: get_ctxt => block_get_ctxt
    procedure, pass(idxmap)  :: get_mpic => block_get_mpic

    procedure, pass(idxmap)  :: set_gr    => block_set_gr
    procedure, pass(idxmap)  :: set_gc    => block_set_gc
    procedure, pass(idxmap)  :: set_lr    => block_set_lr
    procedure, pass(idxmap)  :: set_lc    => block_set_lc
    procedure, pass(idxmap)  :: set_ctxt  => block_set_ctxt
    procedure, pass(idxmap)  :: set_mpic  => block_set_mpic

  end type psb_gen_block_map

contains

  function block_get_state(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%state

  end function block_get_state
  

  function block_get_gr(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%global_rows

  end function block_get_gr
  

  function block_get_gc(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%global_cols

  end function block_get_gc
  

  function block_get_lr(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%local_rows

  end function block_get_lr
  

  function block_get_lc(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%local_cols

  end function block_get_lc
  

  function block_get_ctxt(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%ictxt

  end function block_get_ctxt
  

  function block_get_mpic(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer :: val
    
    val = idxmap%mpic

  end function block_get_mpic
  

  subroutine block_set_state(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%state = val
  end subroutine block_set_state

  subroutine block_set_ctxt(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%ictxt = val
  end subroutine block_set_ctxt
  
  subroutine block_set_gr(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%global_rows = val
  end subroutine block_set_gr

  subroutine block_set_gc(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%global_cols = val
  end subroutine block_set_gc

  subroutine block_set_lr(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%local_rows = val
  end subroutine block_set_lr

  subroutine block_set_lc(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%local_rows = val
  end subroutine block_set_lc

  subroutine block_set_mpic(idxmap,val)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)  :: val
    
    idxmap%mpic = val
  end subroutine block_set_mpic

  
  function block_is_repl(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    logical :: val
    val = .false.
  end function block_is_repl
    
  
  function block_is_bld(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    logical :: val
    val = (idxmap%state == psb_desc_bld_)
  end function block_is_bld
    
  function block_is_upd(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    logical :: val
    val = (idxmap%state == psb_desc_upd_)
  end function block_is_upd
    
  function block_is_asb(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    logical :: val
    val = (idxmap%state == psb_desc_asb_)
  end function block_is_asb
    
  function block_is_valid(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    logical :: val
    val = idxmap%is_bld().or.idxmap%is_upd().or.idxmap%is_asb()
  end function block_is_valid
    
  function block_sizeof(idxmap) result(val)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer(psb_long_int_k_) :: val
    
    val = 8 * psb_sizeof_int
    if (allocated(idxmap%loc_to_glob)) &
         & val = val + size(idxmap%loc_to_glob)*psb_sizeof_int
    if (allocated(idxmap%srt_l2g)) &
         & val = val + size(idxmap%srt_l2g)*psb_sizeof_int

  end function block_sizeof


  subroutine block_free(idxmap)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    
    if (allocated(idxmap%loc_to_glob)) &
         & deallocate(idxmap%loc_to_glob)
    if (allocated(idxmap%srt_l2g)) &
         & deallocate(idxmap%srt_l2g)

  end subroutine block_free


  subroutine block_l2gs1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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

  end subroutine block_l2gs1

  subroutine block_l2gs2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%l2g(idxout,info,mask,owned)
    
  end subroutine block_l2gs2


  subroutine block_l2gv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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
            idx(i) = idxmap%min_glob_row + idx(i) - 1
          else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
               & .and.(.not.owned_)) then
            idx(i) = idxmap%loc_to_glob(idx(i)-idxmap%local_rows)
          else 
            idx(i) = -1
            info = -1
          end if
        end if
      end do

    else  if (.not.present(mask)) then 

      do i=1, size(idx)
        if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
          idx(i) = idxmap%min_glob_row + idx(i) - 1
        else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
             & .and.(.not.owned_)) then
          idx(i) = idxmap%loc_to_glob(idx(i)-idxmap%local_rows)
        else 
          idx(i) = -1
          info = -1
        end if
      end do

    end if

  end subroutine block_l2gv1

  subroutine block_l2gv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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

  end subroutine block_l2gv2


  subroutine block_g2ls1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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
      
  end subroutine block_g2ls1

  subroutine block_g2ls2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%g2l(idxout,info,mask,owned)
    
  end subroutine block_g2ls2


  subroutine block_g2lv1(idx,idxmap,info,mask,owned)
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
                 &.and.(.not.owned_)) then
              nv  = size(idxmap%srt_l2g,1)
              idx(i) = psb_ibsrch(idx(i),nv,idxmap%srt_l2g(:,1))
              if (idx(i) > 0) idx(i) = idxmap%srt_l2g(idx(i),2)+idxmap%local_rows
            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do
      else if (idxmap%is_valid()) then 
        do i=1,is
          if (mask(i)) then 
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
                 &.and.(.not.owned_)) then
              nv  = idxmap%local_cols-idxmap%local_rows+1
              idx(i) = psb_issrch(idx(i),nv,idxmap%loc_to_glob)
              if (idx(i) > 0) idx(i) = idx(i) + idxmap%local_rows
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
          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
               &.and.(.not.owned_)) then
            nv  = size(idxmap%srt_l2g,1)
            idx(i) = psb_ibsrch(idx(i),nv,idxmap%srt_l2g(:,1))
            if (idx(i) > 0) idx(i) = idxmap%srt_l2g(idx(i),2)+idxmap%local_rows
          else 
            idx(i) = -1
            info = -1
          end if
        end do
      else if (idxmap%is_valid()) then 
        do i=1,is
          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)&
               &.and.(.not.owned_)) then
            nv  = idxmap%local_cols-idxmap%local_rows+1
            idx(i) = psb_issrch(idx(i),nv,idxmap%loc_to_glob)
            if (idx(i) > 0) idx(i) = idx(i) + idxmap%local_rows
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

  end subroutine block_g2lv1

  subroutine block_g2lv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_gen_block_map), intent(in) :: idxmap
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

  end subroutine block_g2lv2



  subroutine block_g2ls1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
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

  end subroutine block_g2ls1_ins

  subroutine block_g2ls2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    
    idxout = idxin
    call idxmap%g2l_ins(idxout,info)
    
  end subroutine block_g2ls2_ins


  subroutine block_g2lv1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
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
            if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
              idx(i) = idx(i) - idxmap%min_glob_row + 1
            else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
              nv  = idxmap%local_cols-idxmap%local_rows+1
              ix  = psb_issrch(idx(i),nv,idxmap%loc_to_glob)
              if (ix < 0) then 
                ix = idxmap%local_cols + 1
                call psb_ensure_size(ix,idxmap%loc_to_glob,info,addsz=500)
                if (info /= 0) then 
                  info = -4
                  return
                end if
                idxmap%local_cols      = ix
                ix                     = ix - idxmap%local_rows
                idxmap%loc_to_glob(ix) = idx(i)
              end if
              idx(i)                   = ix
            else 
              idx(i) = -1
              info = -1
            end if
          end if
        end do

      else if (.not.present(mask)) then 

        do i=1, is
          if ((idxmap%min_glob_row <= idx(i)).and.(idx(i) <= idxmap%max_glob_row)) then
            idx(i) = idx(i) - idxmap%min_glob_row + 1
          else if ((1<= idx(i)).and.(idx(i) <= idxmap%global_rows)) then
            nv  = idxmap%local_cols-idxmap%local_rows+1
            ix  = psb_issrch(idx(i),nv,idxmap%loc_to_glob)
            if (ix < 0) then 
              ix = idxmap%local_cols + 1
              call psb_ensure_size(ix,idxmap%loc_to_glob,info,addsz=500)
              if (info /= 0) then 
                info = -4
                return
              end if
              idxmap%loc_to_glob(ix) = idx(i)
              idxmap%local_cols      = ix
            end if
            idx(i)                   = ix
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

  end subroutine block_g2lv1_ins

  subroutine block_g2lv2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
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

  end subroutine block_g2lv2_ins





  subroutine block_init(idxmap,ictxt,nl,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
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
    allocate(vnl(0:np),stat=info)
    if (info /= 0)  then
      info = -2
      return
    end if
    
    vnl(:)   = 0
    vnl(iam) = nl
    call psb_sum(ictxt,vnl)
    ntot = sum(vnl)
    vnl(1:np) = vnl(0:np-1)
    vnl(0) = 0
    do i=1,np
      vnl(i) = vnl(i) + vnl(i-1)
    end do
    if (ntot /= vnl(np)) then 
      write(0,*) ' Mismatch in block_init ',ntot,vnl(np)
    end if
    
    idxmap%global_rows  = ntot
    idxmap%global_cols  = ntot
    idxmap%local_rows   = nl
    idxmap%local_cols   = nl
    idxmap%ictxt        = ictxt
    idxmap%state        = psb_desc_bld_
    call psb_get_mpicomm(ictxt,idxmap%mpic)
    idxmap%min_glob_row = vnl(iam)+1
    idxmap%max_glob_row = vnl(iam+1) 
    allocate(idxmap%loc_to_glob(nl),stat=info) 
    if (info /= 0)  then
      info = -2
      return
    end if
    
    
  end subroutine block_init


  subroutine block_asb(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_gen_block_map), intent(inout) :: idxmap
    integer, intent(out) :: info
    
    integer :: nhal, ictxt, iam, np 
    
    info = 0 
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)

    nhal = idxmap%local_cols-idxmap%local_rows

    call psb_realloc(nhal,idxmap%loc_to_glob,info)
    call psb_realloc(nhal,2,idxmap%srt_l2g,info)
    idxmap%srt_l2g(1:nhal,1) = idxmap%loc_to_glob(1:nhal)
    call psb_qsort(idxmap%srt_l2g(:,1),&
         & ix=idxmap%srt_l2g(:,2),dir=psb_sort_up_)
    idxmap%state = psb_desc_asb_
    
  end subroutine block_asb

end module psb_gen_block_map_mod