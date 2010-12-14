module psb_hash_map_mod
  use psb_const_mod
  use psb_desc_const_mod
  use psb_indx_map_mod
  use psb_hash_mod 

  type, extends(psb_indx_map) :: psb_hash_map

    integer              :: hashvsize, hashvmask
    integer, allocatable :: hashv(:), glb_lc(:,:), loc_to_glob(:)
    type(psb_hash_type), allocatable  :: hash

  contains

    procedure, pass(idxmap)  :: init_vl    => hash_init_vl
    procedure, pass(idxmap)  :: hash_map_init => hash_init_vg

    procedure, pass(idxmap)  :: sizeof    => hash_sizeof
    procedure, pass(idxmap)  :: asb       => hash_asb
    procedure, pass(idxmap)  :: free      => hash_free
    procedure, pass(idxmap)  :: get_fmt   => hash_get_fmt

    procedure, pass(idxmap)  :: row_extendable => hash_row_extendable

    procedure, pass(idxmap)  :: l2gs1     => hash_l2gs1
    procedure, pass(idxmap)  :: l2gs2     => hash_l2gs2
    procedure, pass(idxmap)  :: l2gv1     => hash_l2gv1
    procedure, pass(idxmap)  :: l2gv2     => hash_l2gv2

    procedure, pass(idxmap)  :: g2ls1     => hash_g2ls1
    procedure, pass(idxmap)  :: g2ls2     => hash_g2ls2
    procedure, pass(idxmap)  :: g2lv1     => hash_g2lv1
    procedure, pass(idxmap)  :: g2lv2     => hash_g2lv2

    procedure, pass(idxmap)  :: g2ls1_ins => hash_g2ls1_ins
    procedure, pass(idxmap)  :: g2ls2_ins => hash_g2ls2_ins
    procedure, pass(idxmap)  :: g2lv1_ins => hash_g2lv1_ins
    procedure, pass(idxmap)  :: g2lv2_ins => hash_g2lv2_ins

    procedure, pass(idxmap)  :: bld_g2l_map => hash_bld_g2l_map

  end type psb_hash_map

  private :: hash_initvl, hash_initvg, hash_sizeof, hash_asb, &
       & hash_free, hash_get_fmt, hash_l2gs1, hash_l2gs2, &
       & hash_l2gv1, hash_l2gv2, hash_g2ls1, hash_g2ls2, &
       & hash_g2lv1, hash_g2lv2, hash_g2ls1_ins, hash_g2ls2_ins, &
       & hash_g2lv1_ins, hash_g2lv2_ins, hash_init_vlu, &
       & hash_bld_g2l_map,  hash_inner_cnvs1, hash_inner_cnvs2,&
       & hash_inner_cnv1, hash_inner_cnv2, hash_row_extendable 


  interface hash_inner_cnv 
    module procedure  hash_inner_cnvs1, hash_inner_cnvs2,&
         & hash_inner_cnv1, hash_inner_cnv2 
  end interface hash_inner_cnv
  private :: hash_inner_cnv

contains
  
  function hash_row_extendable(idxmap) result(val)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    logical :: val
    val = .true.
  end function hash_row_extendable
  
  function hash_sizeof(idxmap) result(val)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    integer(psb_long_int_k_) :: val

    val = idxmap%psb_indx_map%sizeof() 
    val = val + 2 * psb_sizeof_int
    if (allocated(idxmap%hashv)) &
         & val = val + size(idxmap%hashv)*psb_sizeof_int
    if (allocated(idxmap%glb_lc)) &
         & val = val + size(idxmap%glb_lc)*psb_sizeof_int
    if (allocated(idxmap%hash)) &
         & val = val + psb_sizeof(idxmap%hash)

  end function hash_sizeof


  subroutine hash_free(idxmap)
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer :: info

    if (allocated(idxmap%hashv)) &
         & deallocate(idxmap%hashv)
    if (allocated(idxmap%glb_lc)) &
         & deallocate(idxmap%glb_lc)

    if (allocated(idxmap%hash)) then 
      call psb_free(idxmap%hash,info) 
      deallocate(idxmap%hash)
    end if

    call idxmap%psb_indx_map%free()

  end subroutine hash_free


  subroutine hash_l2gs1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
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

  end subroutine hash_l2gs1

  subroutine hash_l2gs2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%l2g(idxout,info,mask,owned)

  end subroutine hash_l2gs2


  subroutine hash_l2gv1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
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
            idx(i) = idxmap%loc_to_glob(idx(i))
          else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
               & .and.(.not.owned_)) then
            idx(i) = idxmap%loc_to_glob(idx(i))
          else 
            idx(i) = -1
          end if
        end if
      end do

    else  if (.not.present(mask)) then 

      do i=1, size(idx)
        if ((1<=idx(i)).and.(idx(i) <= idxmap%local_rows)) then
          idx(i) = idxmap%loc_to_glob(idx(i))
        else if ((idxmap%local_rows < idx(i)).and.(idx(i) <= idxmap%local_cols)&
             & .and.(.not.owned_)) then
          idx(i) = idxmap%loc_to_glob(idx(i))
        else 
          idx(i) = -1
        end if
      end do

    end if

  end subroutine hash_l2gv1

  subroutine hash_l2gv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
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
    if (is > im) then 
      write(0,*) 'l2gv2 err -3'
      info = -3 
    end if

  end subroutine hash_l2gv2


  subroutine hash_g2ls1(idx,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
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

  end subroutine hash_g2ls1

  subroutine hash_g2ls2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask
    logical, intent(in), optional :: owned

    idxout = idxin
    call idxmap%g2l(idxout,info,mask,owned)

  end subroutine hash_g2ls2


  subroutine hash_g2lv1(idx,idxmap,info,mask,owned)
    use psb_penv_mod
    use psb_sort_mod
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    logical, intent(in), optional :: owned
    integer :: i, nv, is, mglob, ip, lip, nrow, ncol, nrm 
    integer :: ictxt, iam, np
    logical :: owned_

    info = 0
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np) 
    
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

    mglob = idxmap%get_gr()
    nrow  = idxmap%get_lr()
    ncol  = idxmap%get_lc()
    if (owned_) then 
      nrm = nrow
    else
      nrm = ncol
    end if
    if (present(mask)) then 

      if (idxmap%is_asb()) then 

        call hash_inner_cnv(is,idx,idxmap%hashvmask,&
             & idxmap%hashv,idxmap%glb_lc,mask=mask, nrm=nrm)

      else if (idxmap%is_valid()) then 

        do i = 1, is
          if (mask(i)) then 
            ip = idx(i) 
            if ((ip < 1 ).or.(ip>mglob)) then 
              idx(i) = -1
              cycle
            endif
            call hash_inner_cnv(ip,lip,idxmap%hashvmask,idxmap%hashv,idxmap%glb_lc,nrm)
            if (lip < 0) &
                 &  call psb_hash_searchkey(ip,lip,idxmap%hash,info)
            if (owned_) then 
              if (lip<=nrow) then 
                idx(i) = lip
              else 
                idx(i) = -1
              endif
            else
              idx(i) = lip
            endif
          end if
        enddo

      else 
        write(0,*) 'Hash status: invalid ',idxmap%get_state()
        idx(1:is) = -1
        info = -1
      end if

    else  if (.not.present(mask)) then 

      if (idxmap%is_asb()) then 

        call hash_inner_cnv(is,idx,idxmap%hashvmask,&
             & idxmap%hashv,idxmap%glb_lc,nrm=nrm)

      else if (idxmap%is_valid()) then 
        
        do i = 1, is
          ip = idx(i) 
          if ((ip < 1 ).or.(ip>mglob)) then 
            idx(i) = -1
            cycle
          endif
          call hash_inner_cnv(ip,lip,idxmap%hashvmask,idxmap%hashv,idxmap%glb_lc,nrm)
          if (lip < 0) &
               &  call psb_hash_searchkey(ip,lip,idxmap%hash,info)
          if (owned_) then 
            if (lip<=nrow) then 
              idx(i) = lip
            else 
              idx(i) = -1
            endif
          else
            idx(i) = lip
          endif
        enddo

      else 
        write(0,*) 'Hash status: invalid ',idxmap%get_state()
        idx(1:is) = -1
        info = -1

      end if

    end if

  end subroutine hash_g2lv1

  subroutine hash_g2lv2(idxin,idxout,idxmap,info,mask,owned)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
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
    if (is > im) then 
      write(0,*) 'g2lv2 err -3'
      info = -3 
    end if

  end subroutine hash_g2lv2



  subroutine hash_g2ls1_ins(idx,idxmap,info,mask)
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
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

  end subroutine hash_g2ls1_ins

  subroutine hash_g2ls2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin
    integer, intent(out)   :: idxout
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask

    idxout = idxin
    call idxmap%g2l_ins(idxout,info)

  end subroutine hash_g2ls2_ins


  subroutine hash_g2lv1_ins(idx,idxmap,info,mask)
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    use psb_penv_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(inout) :: idx(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: i, nv, is, ix, mglob, ip, lip, nrow, ncol, &
         & nrm, nxt, err_act, ictxt, me, np
    character(len=20)      :: name,ch_err

    info = psb_success_
    name = 'hash_g2l_ins'
    call psb_erractionsave(err_act)

    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt, me, np)

    is = size(idx)

    if (present(mask)) then 
      if (size(mask) < size(idx)) then 
        info = -1
        return
      end if
    end if


    mglob = idxmap%get_gr()
    nrow  = idxmap%get_lr()
    if (idxmap%is_bld()) then 

      if (present(mask)) then 
        do i = 1, is
          ncol  = idxmap%get_lc()
          if (mask(i)) then 
            ip = idx(i) 
            if ((ip < 1 ).or.(ip>mglob)) then 
              idx(i) = -1
              cycle
            endif
            nxt = ncol + 1 
            call hash_inner_cnv(ip,lip,idxmap%hashvmask,idxmap%hashv,idxmap%glb_lc,ncol)
            if (lip < 0) &
                 &  call psb_hash_searchinskey(ip,lip,nxt,idxmap%hash,info)

            if (info >=0) then 
              if (nxt == lip) then 
                ncol = nxt
                call psb_ensure_size(ncol,idxmap%loc_to_glob,info,pad=-1,addsz=200)
                if (info /= psb_success_) then
                  info=1
                  ch_err='psb_ensure_size'
                  call psb_errpush(psb_err_from_subroutine_ai_,name,&
                       &a_err=ch_err,i_err=(/info,0,0,0,0/))
                  goto 9999
                end if
                idxmap%loc_to_glob(nxt)  = ip
                call idxmap%set_lc(ncol)
              endif
              info = psb_success_
            else
              ch_err='SearchInsKeyVal'
              call psb_errpush(psb_err_from_subroutine_ai_,name,&
                   & a_err=ch_err,i_err=(/info,0,0,0,0/))
              goto 9999
            end if
            idx(i) = lip
            info = psb_success_
          else
            idx(i) = -1
          end if
        enddo

      else
        do i = 1, is
          ncol  = idxmap%get_lc()
          ip = idx(i) 
          if ((ip < 1 ).or.(ip>mglob)) then 
            idx(i) = -1
            cycle
          endif
          nxt = ncol + 1 
          call hash_inner_cnv(ip,lip,idxmap%hashvmask,idxmap%hashv,idxmap%glb_lc,ncol)
          if (lip < 0) &
               &  call psb_hash_searchinskey(ip,lip,nxt,idxmap%hash,info)

          if (info >=0) then 
            if (nxt == lip) then 
              ncol = nxt
              call psb_ensure_size(ncol,idxmap%loc_to_glob,info,pad=-1,addsz=200)
              if (info /= psb_success_) then
                info=1
                ch_err='psb_ensure_size'
                call psb_errpush(psb_err_from_subroutine_ai_,name,&
                     &a_err=ch_err,i_err=(/info,0,0,0,0/))
                goto 9999
              end if
              idxmap%loc_to_glob(nxt)  = ip
              call idxmap%set_lc(ncol)
            endif
            info = psb_success_
          else
            ch_err='SearchInsKeyVal'
            call psb_errpush(psb_err_from_subroutine_ai_,name,&
                 & a_err=ch_err,i_err=(/info,0,0,0,0/))
            goto 9999
          end if
          idx(i) = lip
          info = psb_success_
        enddo


      end if

    else 
      ! Wrong state
      idx = -1
      info = -1
    end if
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)

    if (err_act == psb_act_ret_) then
      return
    else
      call psb_error(ictxt)
    end if
    return

  end subroutine hash_g2lv1_ins

  subroutine hash_g2lv2_ins(idxin,idxout,idxmap,info,mask)
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(in)    :: idxin(:)
    integer, intent(out)   :: idxout(:)
    integer, intent(out)   :: info 
    logical, intent(in), optional :: mask(:)
    integer :: is, im

    is = size(idxin)
    im = min(is,size(idxout))
    idxout(1:im) = idxin(1:im)
    call idxmap%g2l_ins(idxout(1:im),info,mask)
    if (is > im) then 
      write(0,*) 'g2lv2_ins err -3'
      info = -3 
    end if

  end subroutine hash_g2lv2_ins

  subroutine hash_init_vl(idxmap,ictxt,vl,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_sort_mod
    use psb_realloc_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, vl(:)
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, j, ntot, nlu, nl, m, nrt,int_err(5)
    integer, allocatable :: vlu(:)
    character(len=20), parameter :: name='hash_map_init_vl'

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if

    nl = size(vl) 

    m   = maxval(vl(1:nl))
    nrt = nl
    call psb_sum(ictxt,nrt)
    call psb_max(ictxt,m)

    allocate(vlu(nl), stat=info) 
    if (info /= 0) then 
      info = -1
      return
    end if

    do i=1,nl
      if ((vl(i)<1).or.(vl(i)>m)) then 
        info = psb_err_entry_out_of_bounds_
        int_err(1) = i
        int_err(2) = vl(i)
        int_err(3) = nl
        int_err(4) = m
        exit
      endif
      vlu(i) = vl(i) 
    end do

    if ((m /= nrt).and.(iam == psb_root_))  then 
      write(psb_err_unit,*) trim(name),&
           & ' Warning: globalcheck=.false., but there is a mismatch'
      write(psb_err_unit,*) trim(name),&
           & '        : in the global sizes!',m,nrt
    end if
    !
    ! Now sort the input items, and check for  duplicates
    ! (unlikely, but possible)
    !
    call psb_msort_unique(vlu,nlu)
    if (nlu /= nl) then 
      write(0,*) 'Warning: duplicates in input'
    end if

    call hash_init_vlu(idxmap,ictxt,ntot,nlu,vlu,info)    

  end subroutine hash_init_vl

  subroutine hash_init_vg(idxmap,ictxt,vg,info)
    use psb_penv_mod
    use psb_error_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, vg(:)
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, j, ntot, lc2, nl, nlu, n, nrt,int_err(5)
    integer :: key, ih, ik, nh, idx, nbits, hsize, hmask
    integer, allocatable :: vlu(:)

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if

    n    = size(vg)
    ntot = n
    nl   = 0
    do i=1, n
      if ((vg(i)<0).or.(vg(i)>=np)) then 
        info = psb_err_partfunc_wrong_pid_
        int_err(1) = 3
        int_err(2) = vg(i)
        int_err(3) = i
        exit
      endif
      if (vg(i) == iam) nl = nl + 1 
    end do

    allocate(vlu(nl), stat=info) 
    if (info /= 0) then 
      info = -1
      return
    end if

    j = 0
    do i=1, n
      if (vg(i) == iam) then 
        j      = j + 1 
        vlu(j) = i
      end if
    end do


    call hash_init_vlu(idxmap,ictxt,ntot,nl,vlu,info)    


  end subroutine hash_init_vg


  subroutine hash_init_vlu(idxmap,ictxt,ntot,nl,vlu,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_sort_mod
    use psb_realloc_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(in)  :: ictxt, vlu(:), nl, ntot
    integer, intent(out) :: info
    !  To be implemented
    integer :: iam, np, i, j, lc2, nlu, m, nrt,int_err(5)
    integer :: key, ih, ik, nh, idx, nbits, hsize, hmask
    character(len=20), parameter :: name='hash_map_init_vlu'

    info = 0
    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if

    idxmap%global_rows  = ntot
    idxmap%global_cols  = ntot
    idxmap%local_rows   = nl
    idxmap%local_cols   = nl
    idxmap%ictxt        = ictxt
    idxmap%state        = psb_desc_bld_
    call psb_get_mpicomm(ictxt,idxmap%mpic)

    lc2 = int(1.5*nl) 
    allocate(idxmap%hash,idxmap%loc_to_glob(lc2),stat=info) 
    if (info /= 0)  then
      info = -2
      return
    end if

    call psb_hash_init(nl,idxmap%hash,info)
    if (info /= 0) then 
      write(0,*) 'from Hash_Init inside init_vlu',info
      info = -3
      return 
    endif

    do i=1, nl
      idxmap%loc_to_glob(i) = vlu(i) 
    end do

    call hash_bld_g2l_map(idxmap,info)
    call idxmap%set_state(psb_desc_bld_)

  end subroutine hash_init_vlu



  subroutine hash_bld_g2l_map(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_sort_mod
    use psb_realloc_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(out) :: info
    !  To be implemented
    integer :: ictxt, iam, np, i, j, lc2, nlu, m, nrt,int_err(5), nl
    integer :: key, ih, ik, nh, idx, nbits, hsize, hmask
    character(len=20), parameter :: name='hash_map_init_vlu'

    info = 0
    ictxt = idxmap%get_ctxt()

    call psb_info(ictxt,iam,np) 
    if (np < 0) then 
      write(psb_err_unit,*) 'Invalid ictxt:',ictxt
      info = -1
      return
    end if

    nl = idxmap%get_lc()

    call psb_realloc(nl,2,idxmap%glb_lc,info) 

    nbits = psb_hash_bits
    hsize = 2**nbits
    do 
      if (hsize < 0) then 
        ! This should never happen for sane values
        ! of psb_max_hash_bits.
        write(psb_err_unit,*) &
             & 'Error: hash size overflow ',hsize,nbits
        info = -2 
        return
      end if
      if (hsize > nl) exit
      if (nbits >= psb_max_hash_bits) exit
      nbits = nbits + 1
      hsize = hsize * 2 
    end do

    hmask = hsize - 1 
    idxmap%hashvsize = hsize
    idxmap%hashvmask = hmask

    if (info == psb_success_) &
         & call psb_realloc(hsize+1,idxmap%hashv,info,lb=0)
    if (info /= psb_success_) then 
      ! !$      ch_err='psb_realloc'
      ! !$      call psb_errpush(info,name,a_err=ch_err)
      ! !$      goto 9999
      info = -4 
      return
    end if

    idxmap%hashv(:) = 0

    do i=1, nl
      key = idxmap%loc_to_glob(i) 
      ih  = iand(key,hmask) 
      idxmap%hashv(ih) = idxmap%hashv(ih) + 1
    end do

    nh = idxmap%hashv(0) 
    idx = 1

    do i=1, hsize
      idxmap%hashv(i-1) = idx
      idx = idx + nh
      nh = idxmap%hashv(i)
    end do

    do i=1, nl
      key                  = idxmap%loc_to_glob(i)
      ih                   = iand(key,hmask)
      idx                  = idxmap%hashv(ih) 
      idxmap%glb_lc(idx,1) = key
      idxmap%glb_lc(idx,2) = i
      idxmap%hashv(ih)     = idxmap%hashv(ih) + 1
    end do

    do i = hsize, 1, -1 
      idxmap%hashv(i) = idxmap%hashv(i-1)
    end do

    idxmap%hashv(0) = 1
    do i=0, hsize-1 
      idx = idxmap%hashv(i)
      nh  = idxmap%hashv(i+1) - idxmap%hashv(i) 
      if (nh > 1) then 
        call psb_msort(idxmap%glb_lc(idx:idx+nh-1,1),&
             & ix=idxmap%glb_lc(idx:idx+nh-1,2),&
             & flag=psb_sort_keep_idx_)
      end if
    end do

  end subroutine hash_bld_g2l_map


  subroutine hash_asb(idxmap,info)
    use psb_penv_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none 
    class(psb_hash_map), intent(inout) :: idxmap
    integer, intent(out) :: info

    integer :: nhal, ictxt, iam, np 

    info = 0 
    ictxt = idxmap%get_ctxt()
    call psb_info(ictxt,iam,np)

    nhal = max(0,idxmap%local_cols-idxmap%local_rows)

    call hash_bld_g2l_map(idxmap,info)
    if (info /= 0) then 
      write(0,*) 'Error from bld_g2l_map'
      return
    end if

    call psb_free(idxmap%hash,info)
    if (info == 0) deallocate(idxmap%hash,stat=info)
    if (info /= 0) then
      write(0,*) 'Error from hash free'
      return
    end if
      
    call idxmap%set_state(psb_desc_asb_)

  end subroutine hash_asb

  function hash_get_fmt(idxmap) result(res)
    implicit none 
    class(psb_hash_map), intent(in) :: idxmap
    character(len=5) :: res
    res = 'HASH'
  end function hash_get_fmt


  subroutine hash_inner_cnvs1(x,hashmask,hashv,glb_lc,nrm)

    integer, intent(in)    :: hashmask,hashv(0:),glb_lc(:,:)
    integer, intent(inout) :: x
    integer, intent(in)    :: nrm
    integer :: i, ih, key, idx,nh,tmp,lb,ub,lm
    !
    ! When a large descriptor is assembled the indices 
    ! are kept in a (hashed) list of ordered lists. 
    ! Thus we first hash the index, then we do a binary search on the 
    ! ordered sublist. The hashing is based on the low-order bits 
    ! for a width of psb_hash_bits 
    !

    key = x
    ih  = iand(key,hashmask)
    idx = hashv(ih)
    nh  = hashv(ih+1) - hashv(ih) 
    if (nh > 0) then 
      tmp = -1 
      lb = idx
      ub = idx+nh-1
      do 
        if (lb>ub) exit
        lm = (lb+ub)/2
        if (key == glb_lc(lm,1)) then 
          tmp = lm
          exit
        else if (key<glb_lc(lm,1)) then 
          ub = lm - 1
        else
          lb = lm + 1
        end if
      end do
    else 
      tmp = -1
    end if
    if (tmp > 0) then 
      x = glb_lc(tmp,2)
      if (x > nrm) then 
        x = -1 
      end if
    else         
      x = tmp 
    end if
  end subroutine hash_inner_cnvs1

  subroutine hash_inner_cnvs2(x,y,hashmask,hashv,glb_lc,nrm)
    integer, intent(in)  :: hashmask,hashv(0:),glb_lc(:,:)
    integer, intent(in)  :: x
    integer, intent(out) :: y
    integer, intent(in)  :: nrm
    integer :: i, ih, key, idx,nh,tmp,lb,ub,lm
    !
    ! When a large descriptor is assembled the indices 
    ! are kept in a (hashed) list of ordered lists. 
    ! Thus we first hash the index, then we do a binary search on the 
    ! ordered sublist. The hashing is based on the low-order bits 
    ! for a width of psb_hash_bits 
    !

    key = x
    ih  = iand(key,hashmask)
    idx = hashv(ih)
    nh  = hashv(ih+1) - hashv(ih) 
    if (nh > 0) then 
      tmp = -1 
      lb = idx
      ub = idx+nh-1
      do 
        if (lb>ub) exit
        lm = (lb+ub)/2
        if (key == glb_lc(lm,1)) then 
          tmp = lm
          exit
        else if (key<glb_lc(lm,1)) then 
          ub = lm - 1
        else
          lb = lm + 1
        end if
      end do
    else 
      tmp = -1
    end if
    if (tmp > 0) then 
      y = glb_lc(tmp,2)
      if (y > nrm) then 
        y = -1 
      end if
    else         
      y = tmp 
    end if
  end subroutine hash_inner_cnvs2


  subroutine hash_inner_cnv1(n,x,hashmask,hashv,glb_lc,mask,nrm)
    integer, intent(in)    :: n,hashmask,hashv(0:),glb_lc(:,:)
    logical, intent(in), optional  :: mask(:)
    integer, intent(in), optional  :: nrm
    integer, intent(inout) :: x(:)

    integer :: i, ih, key, idx,nh,tmp,lb,ub,lm
    !
    ! When a large descriptor is assembled the indices 
    ! are kept in a (hashed) list of ordered lists. 
    ! Thus we first hash the index, then we do a binary search on the 
    ! ordered sublist. The hashing is based on the low-order bits 
    ! for a width of psb_hash_bits 
    !
    if (present(mask)) then 
      do i=1, n
        if (mask(i)) then 
          key = x(i) 
          ih  = iand(key,hashmask)
          idx = hashv(ih)
          nh  = hashv(ih+1) - hashv(ih) 
          if (nh > 0) then 
            tmp = -1 
            lb = idx
            ub = idx+nh-1
            do 
              if (lb>ub) exit
              lm = (lb+ub)/2
              if (key == glb_lc(lm,1)) then 
                tmp = lm
                exit
              else if (key<glb_lc(lm,1)) then 
                ub = lm - 1
              else
                lb = lm + 1
              end if
            end do
          else 
            tmp = -1
          end if
          if (tmp > 0) then 
            x(i) = glb_lc(tmp,2)
            if (present(nrm)) then 
              if (x(i) > nrm) then 
                x(i) = -1 
              end if
            end if
          else         
            x(i) = tmp 
          end if
        end if
      end do
    else
      do i=1, n
        key = x(i) 
        ih  = iand(key,hashmask)
        idx = hashv(ih)
        nh  = hashv(ih+1) - hashv(ih) 
        if (nh > 0) then 
          tmp = -1 
          lb = idx
          ub = idx+nh-1
          do 
            if (lb>ub) exit
            lm = (lb+ub)/2
            if (key == glb_lc(lm,1)) then 
              tmp = lm
              exit
            else if (key<glb_lc(lm,1)) then 
              ub = lm - 1
            else
              lb = lm + 1
            end if
          end do
        else 
          tmp = -1
        end if
        if (tmp > 0) then 
          x(i) = glb_lc(tmp,2)
          if (present(nrm)) then 
            if (x(i) > nrm) then 
              x(i) = -1 
            end if
          end if
        else         
          x(i) = tmp 
        end if
      end do
    end if
  end subroutine hash_inner_cnv1

  subroutine hash_inner_cnv2(n,x,y,hashmask,hashv,glb_lc,mask,nrm)
    integer, intent(in)  :: n, hashmask,hashv(0:),glb_lc(:,:)
    logical, intent(in), optional :: mask(:)
    integer, intent(in), optional :: nrm
    integer, intent(in)  :: x(:)
    integer, intent(out) :: y(:)

    integer :: i, ih, key, idx,nh,tmp,lb,ub,lm
    !
    ! When a large descriptor is assembled the indices 
    ! are kept in a (hashed) list of ordered lists. 
    ! Thus we first hash the index, then we do a binary search on the 
    ! ordered sublist. The hashing is based on the low-order bits 
    ! for a width of psb_hash_bits 
    !
    if (present(mask)) then 
      do i=1, n
        if (mask(i)) then 
          key = x(i) 
          ih  = iand(key,hashmask)
          if (ih > ubound(hashv,1) ) then 
            write(psb_err_unit,*) ' In inner cnv: ',ih,ubound(hashv)
          end if
          idx = hashv(ih)
          nh  = hashv(ih+1) - hashv(ih) 
          if (nh > 0) then 
            tmp = -1 
            lb = idx
            ub = idx+nh-1
            do 
              if (lb>ub) exit
              lm = (lb+ub)/2
              if (key == glb_lc(lm,1)) then 
                tmp = lm
                exit
              else if (key<glb_lc(lm,1)) then 
                ub = lm - 1
              else
                lb = lm + 1
              end if
            end do
          else 
            tmp = -1
          end if
          if (tmp > 0) then 
            y(i) = glb_lc(tmp,2)
            if (present(nrm)) then 
              if (y(i) > nrm) then 
                y(i) = -1 
              end if
            end if
          else         
            y(i) = tmp 
          end if
        end if
      end do

    else

      do i=1, n
        key = x(i) 
        ih  = iand(key,hashmask)
        if (ih > ubound(hashv,1) ) then 
          write(psb_err_unit,*) ' In inner cnv: ',ih,ubound(hashv)
        end if
        idx = hashv(ih)
        nh  = hashv(ih+1) - hashv(ih) 
        if (nh > 0) then 
          tmp = -1 
          lb = idx
          ub = idx+nh-1
          do 
            if (lb>ub) exit
            lm = (lb+ub)/2
            if (key == glb_lc(lm,1)) then 
              tmp = lm
              exit
            else if (key<glb_lc(lm,1)) then 
              ub = lm - 1
            else
              lb = lm + 1
            end if
          end do
        else 
          tmp = -1
        end if
        if (tmp > 0) then 
          y(i) = glb_lc(tmp,2)
          if (present(nrm)) then 
            if (y(i) > nrm) then 
              y(i) = -1 
            end if
          end if
        else         
          y(i) = tmp 
        end if
      end do
    end if
  end subroutine hash_inner_cnv2


end module psb_hash_map_mod
